load File.dirname(__FILE__) + '/../test_helper.rb'

require 'net/http'
require 'net/https'

describe "Data Fetching" do
  include TestHelper


  it "JSON over HTTP" do
    require 'json'
    require 'httpclient'
    uri = "http://localhost:3618/projects/2/status"
    http = HTTPClient.new
    resp = http.get(uri)

    json_str = resp.content
    # debug json_str

    json_obj = JSON.parse(json_str)
    debug json_obj["count"]
    debug json_obj["build"][1].inspect
  end


end
