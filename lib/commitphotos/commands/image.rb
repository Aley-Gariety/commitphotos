require 'rest-client'

module Commitphotos
  def image
    filename = "/tmp/#{Time.now.to_i}.jpg"
    message = `git log -1 HEAD --pretty=format:%s`
     
    begin
      `imagesnap -q -w 3 #{filename}`
      `convert #{filename} -resize '800x800>' #{filename}`
     
      RestClient.post('http://commitphotos.herokuapp.com/photos/new', {
        "email" => `git config --get user.email`.chomp,
        "user_name" => `git config --get user.name`.chomp,
        "photo" => File.open(filename)
        }
      )
     
      FileUtils.rm(filename)
      exit 0
    rescue => e
      puts "there was an error: #{e.message}"
      FileUtils.rm(filename)
      exit 1
    end
  end
end