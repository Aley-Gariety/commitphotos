require 'fileutils'
require 'commitphotos/version'
require 'mini_magick'
require 'rest-client'
require 'tempfile'
require 'ostruct'
require 'erb'

require 'commitphotos/video'
require 'commitphotos/image'

class CommitPhoto

  def self.image
    puts "Say cheese! Taking a photo."
    Image.new
  end

  def self.video
    puts "Say cheese! Taking a video."
    Video.new
  end

  # This will setup Commitphotos for the user.
  def setup_hook(global, video)

    if global
      destination = File.expand_path(`git config --get init.templatedir`.chomp)
      create_global_hook_dir if destination.empty?
    else
      # We shouldn't require the user to be in a git repo if they're installing globally.
      abort 'Error: not a git repository.' unless File.exist? File.join(Dir.pwd, '.git')
      destination = File.expand_path(File.join(Dir.pwd, '.git/hooks'))
    end

    type = video ? :video : :image

    local_post_commit = "#{File.expand_path(File.dirname(__FILE__))}/commitphotos/hooks/post-commit-#{type}"

    FileUtils.mkdir_p(destination)
    content = hook_content(type)
    File.open(File.join(destination, 'post-commit'), 'w') { |file| file.write(content) }
    puts "You're good to go!"
  end

  private

  def create_global_hook_dir
    destination = '~/.gittemplates'
    FileUtils.mkdir_p(destination) unless File.exist?(destination)
    `git config --global init.templatedir #{destination}`
  end

  def hook_content(type)
    os = OpenStruct.new
    os.type = type

    template = "#{File.expand_path(File.dirname(__FILE__))}/commitphotos/templates/post-commit.erb"
    ERB.new(File.read(template)).result(os.instance_eval { binding })
  end

  def dir
    File.expand_path(File.dirname(__FILE__))
  end

  # Take the photo or video and upload it to commitphotos.com.
  def post(file)
    puts "Publishing to commitphotos.com..."
    RestClient.post('http://commitphotos.com/',
      user_name: `git config --get user.name`.chomp,
      message:   `git log -1 HEAD --pretty=format:%s`,
      photo:     File.new(file, 'rb')
    )

    exit
  end
end
