require 'fileutils'
require 'commitphotos/version'
require 'mini_magick'
require 'streamio-ffmpeg'
require 'rest-client'

include FileUtils

class Commitphotos
  DIR = File.expand_path(File.dirname(__FILE__))

  # For the install command
  def self.hook(global, video)
    if global
      destination = File.expand_path(`git config --get init.templatedir`.chomp)
      if destination.empty?
        destination = '~/.gittemplates'
        mkdir_p(destination) unless File.exist?(destination)
        `git config --global init.templatedir #{destination}`
      end
    else
      destination = File.expand_path(File.join(Dir.pwd, '.git/hooks'))
      abort 'Error: not a git repository.' unless File.exist? destination
    end
    
    type = video ? 'video' : 'image'
    
    local_post_commit = "#{DIR}/commitphotos/hooks/post-commit-#{type}"
    
    copy(local_post_commit, File.join(destination, 'post-commit'))
  end
  
  # Setup photo or video capture
  def self.take(type)
    
    
    begin
      case type
      when :video
        filename = "/tmp/#{Time.now.to_i}.mov"
        video(filename)
      when :image 
        filename = "/tmp/#{Time.now.to_i}.jpg"
        image(filename)
      end
    rescue => error
      abort "there was an error: #{error.message}"
    ensure
      remove filename
    end
  end

  # Take an image
  def self.image(file)
    `#{DIR}/imagesnap -q #{file}`
    
    image = MiniMagick::Image.open file
    image.resize '800x800>'
    image.write file
   
    post(File.open file)
  end
  
  # Take a video
  def self.video(file)
    `#{DIR}/videosnap -t 2 --no-audio #{file}`
    
    begin
      video = FFMPEG::Movie.new(file)
      gif = file.gsub('.mov', '.gif')
      video.transcode(gif, '-pix_fmt rgb24 -r 10')
      post(File.open gif)
    rescue => e
      abort "Unable to transcode file: #{e.message}"
    end
  end
  
  # Upload the photo or video
  def self.post(file)
    RestClient.post('http://commitphotos.herokuapp.com/photos/new', {
      "email" => `git config --get user.email`.chomp,
      "user_name" => `git config --get user.name`.chomp,
      "message" => `git log -1 HEAD --pretty=format:%s`,
      "photo" => file
    })
  end
end
