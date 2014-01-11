require 'fileutils'
require 'rest-client'

include FileUtils

# some variables
local_post_commit_image_path = File.expand_path('lib/commitphotos/hooks/post-commit-image')
local_post_commit_video_path = File.expand_path('lib/commitphotos/hooks/post-commit-video')
local_post_commit_path = File.expand_path('.git/hooks/post-commit')
global_post_commit_path = File.expand_path(File.join(`git config --get init.templatedir`.chomp, 'post-commit'))

describe 'commitphotos' do
  before(:all) do
    `gem build commitphotos.gemspec`
    `gem install commitphotos-0.0.1.gem`
    `rm commitphotos-0.0.1.gem`
  end
  
  describe 'hook' do
    describe 'install' do
      before(:all) do
        `commitphotos install rspec_tmp`
      end
      
      it 'should move the image hook into the .git/hooks directory' do
        compare_file(local_post_commit_image_path, local_post_commit_path)
      end
    end
    
    describe 'install --global' do
      before(:all) do
        `commitphotos install rspec_tmp --global`
      end
      
      it 'should move the image hook into gits init.templatedir directory' do
        compare_file(local_post_commit_image_path, global_post_commit_path)
      end
    end
    
    describe 'install --video' do
      before(:all) do
        `commitphotos install rspec_tmp --video`
      end
      
      it 'should move the image hook into the .git/hooks directory' do
        compare_file(local_post_commit_video_path, local_post_commit_path)
      end
    end
    
    describe 'install --global --video' do
      before(:all) do
        `commitphotos install rspec_tmp --global --video`
      end
      
      it 'should move the image hook into the .git/hooks directory' do
        compare_file(local_post_commit_video_path, global_post_commit_path)
      end
    end
    
    after(:all) do
      remove(local_post_commit_path)
    end
  end
  
  describe 'image' do
    before do
      `ruby lib/commitphotos/hooks/post-commit-image`
    end
    
    it 'should upload a file to commitphotos.com' do
      # `ruby`
    end
  end
end