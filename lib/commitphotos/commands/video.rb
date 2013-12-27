require "mini_magick"
require "rest-client"
require 'fileutils'

include FileUtils

module Commitphotos
  def video
    file = "/tmp/#{Time.now.to_i}.mov"
    message = `git log -1 HEAD --pretty=format:%s`
    
    begin
      `#{__FILE__}/../../videosnap -t 2 --no-audio #{filename}`
      
      video = MiniMagick::Image.open file
      video.convert :gif
      
      RestClient.post('http://commitphotos.herokuapp.com/photos/new', {
        "email" => `git config --get user.email`.chomp,
        "user_name" => `git config --get user.name`.chomp,
        "photo" => video
      })
      
      remove file
      exit 0
    rescue => error
      puts "Error: #{error.message}"
      remove file
      exit 1
    end
  end
end