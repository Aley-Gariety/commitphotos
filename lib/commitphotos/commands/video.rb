require "mini_magick"
require "rest_client"

module Commitphotos
  def video
    filename = "/tmp/#{Time.now}.mov"
    `#{__FILE__}/../../videosnap -t 2 --no-audio #{filename}`
    
    video = MiniMagick::Image.open filename
    vide.convert :gif
    
    
    RestClient.new()
  end
end