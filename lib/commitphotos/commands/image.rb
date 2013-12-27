require "mini_magick"
require 'rest-client'
require 'fileutils'

include FileUtils

module Commitphotos
  def image
    file = "/tmp/#{Time.now.to_i}.jpg"
    message = `git log -1 HEAD --pretty=format:%s`
     
    begin
      `imagesnap -q #{filename}`
     
      image = MiniMagick::Image.open file
      image.resize '800x800>'
     
      RestClient.post('http://commitphotos.herokuapp.com/photos/new', {
        "email" => `git config --get user.email`.chomp,
        "user_name" => `git config --get user.name`.chomp,
        "photo" => image
      })
     
      remove file
      exit 0
    rescue => error
      puts "there was an error: #{error.message}"
      remove file
      exit 1
    end
  end
end