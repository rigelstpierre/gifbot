require 'bundler/setup'
require 'json'
require 'net/http'
require 'sinatra'

class GifBot < Sinatra::Base
  SLACK_TOKEN= ENV['SLACK_TOKEN']
  GIPHY_KEY="dc6zaTOxFJmzC" # This is Giphy's public API ket
  TRIGGER_WORD="#"
  IMAGE_STYLE="fixed_height" # or "fixed_width" or "original"

  post "/gif" do

    return 401 unless request["token"] == SLACK_TOKEN
    q = request["text"]
    return 200 unless q.start_with? TRIGGER_WORD
    q = URI::encode q[TRIGGER_WORD.size..-1]
    url = "http://api.giphy.com/v1/gifs/search?q=#{q}&api_key=#{GIPHY_KEY}&limit=50"
    resp = Net::HTTP.get_response(URI.parse(url))
    buffer = resp.body
    result = JSON.parse(buffer)
    images = result["data"].map {|item| item["images"]}
    images.select! {|image| image["original"]["size"].to_i < 1<<21}
    if images.empty?
      text = ":cry:"
    else
      selected = images[rand images.size]
      text = "<" + selected[IMAGE_STYLE]["url"] + ">"
    end
    reply = {username: "giphy", icon_emoji: ":monkey_face:", text: text}
    return JSON.generate(reply)
  end
end
