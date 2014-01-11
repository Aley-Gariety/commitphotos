class Video < CommitPhoto
  def initialize
    path = "/tmp/#{Time.now.to_i.to_s}.mov"

    `#{dir}/videosnap -t 2 --no-audio #{path}`

    begin
      post(File.open path)
    rescue => e
      abort "Unable to capture video: #{e.message}"
    ensure
      FileUtils.rm(path)
    end
  end
end
