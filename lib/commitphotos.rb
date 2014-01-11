require 'fileutils'
require 'commitphotos/version'
require 'mini_magick'
require 'streamio-ffmpeg'
require 'rest-client'
require 'tempfile'

require 'commitphotos/video'
require 'commitphotos/image'

class CommitPhoto
  # This will setup Commitphotos for the user.
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

  def self.image
    Image.new
  end

  def self.video
    Video.new
  end

  private

  def dir
    File.expand_path(File.dirname(__FILE__))
  end

  # Take the photo or video and upload it to commitphotos.com.
  def post(file)
    RestClient.post('http://commitphotos.herokuapp.com/photos/new',
      email:     `git config --get user.email`.chomp,
      user_name: `git config --get user.name`.chomp,
      message:   `git log -1 HEAD --pretty=format:%s`,
      photo:     file
    )
  end
end
