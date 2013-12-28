require 'fileutils'
require 'commitphotos/version'
require 'mini_magick'
require 'rvideo'
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
    filename = "/tmp/#{Time.now.to_i}.jpg"
    
    begin
      case type
      when :video then video(filename)
      when :image then image(filename)
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
    `#{__FILE__}/../../videosnap -t 2 --no-audio #{file}`
    
    transcoder = RVideo::Transcoder.new
    
    begin
      transcoder.execute("ffmpeg -i $input_file$", {
        :input_file => file,
        :output_file => file
      })
      
      post(File.open file)
    rescue TranscoderError => e
      abort "Unable to transcode file: #{e.class} - #{e.message}"
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
