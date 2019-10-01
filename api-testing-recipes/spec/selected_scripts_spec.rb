# Special file for running selected test scripts against current browser: Don't edit
load File.dirname(__FILE__) + '/../test_helper.rb'
require File.dirname(__FILE__) + "/../mail_catcher_helper.rb"
describe "User can Sign up demo.sitewisecms.com" do
  include TestHelper
  include MailCatcherHelper

  it "Selected" do
    use_current_browser 
    driver.switch_to.frame(0)
    sleep 1
    activate_token = ""
    begin
    activate_token =  driver.find_element(:id, "activate_link")["data-path"]
    ensure
    driver.switch_to.default_content
    end
    debug activate_token
  end 
end