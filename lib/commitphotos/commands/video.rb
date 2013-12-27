require "mini_magick"
require "rest-client"
require 'fileutils'

include FileUtils

module Commitphotos
  def video
    file = "/tmp/#{Time.now}.mov"
    message = `git log -1 HEAD --pretty=format:%s`
    
    begin
      `#{__FILE__}/../../videosnap -t 2 --no-audio #{filename}`
      
      video = MiniMagick::Image.open file
      video.convert :gif
      
      RestClient.post('http://commitphotos.herokuapp.com/photos/new', {
        "email" => `git config --get user.email`.chomp,
        "user_name" => `git config --get user.name`.chomp,
        "photo" => video
        }
      )
      
      remove file
    rescue => e
      puts "Error: #{e.message}"
      remove file
      exit 1
    end
  end
end