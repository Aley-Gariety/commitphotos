require 'fileutils'

include FileUtils

module Commitphotos
  def hook(global, video)
    if global
      destination = `git config --get init.templatedir`.chomp
      if destination.empty?
        destination = '~/.gittemplates'
        mkdir_p(File.expand_path(destination)) unless File.exist?(destination)
        `git config --global init.templatedir #{destination}`
      end
    else
      destination = File.join(Dir.pwd, '.git/hooks')
      abort 'Error: not a git repository.' unless File.exist? destination
    end
    
    copy(File.join(File.dirname(__FILE__), "../hooks/post-commit-#{video ? 'video' : 'image'}"), File.expand_path(File.join(destination, 'post-commit')))
  end
end