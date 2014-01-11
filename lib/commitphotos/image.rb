class Image < CommitPhoto
  def initialize
    tempfile = Tempfile.new(Time.now.to_i.to_s)
    file = tempfile.path

    `#{dir}/imagesnap -q #{file}`

    begin
      image = MiniMagick::Image.open file
      image.resize '800x800>'
      image.write file
      post(File.open file)
    rescue => e
      abort "Unable to capture photo: #{e.message}"
    ensure
      tempfile.unlink
    end
  end
end
