require 'fileutils'

module Commitphotos
  def hook(global)
    if global
      destination = `git config --get init.templatedir`.chomp
      if destination.empty? or !File.exist?(destination)
        destination = '~/.gittemplates'
        FileUtils.mkdir_p(File.expand_path(destination))
        `git config --global init.templatedir #{destination}`
      end
    else
      destination = File.join(Dir.pwd, '.git/hooks')
      abort 'Error: not a git repository.' unless File.exist? destination
    end
    
    FileUtils.cp(File.join(File.dirname(__FILE__), '../hooks/post-commit'), File.expand_path(File.join(destination, 'post-commit')))
  end
end