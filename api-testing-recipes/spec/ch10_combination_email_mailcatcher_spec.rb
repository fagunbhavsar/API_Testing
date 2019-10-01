load File.dirname(__FILE__) + '/../test_helper.rb'
load File.dirname(__FILE__) + "/../mail_catcher_helper.rb"
require 'faker'

describe "User can Sign up demo.sitewisecms.com" do
  include TestHelper
  include MailCatcherHelper

  before(:all) do
    @driver = $browser = Selenium::WebDriver.for(browser_type)
    driver.manage().window().resize_to(default_browser_size[0], default_browser_size[1])
  end

  after(:all) do
    driver.quit unless debugging?
  end

  it "Sign up the verify the email" do
    driver.get("http://107.170.251.122:1080")
    sleep 1
    mailcatcher_clear

    driver.get("http://demo.sitewisecms.com/register")
    sign_up_page = SignUpPage.new(driver)
    email = Faker::Internet.email
    sign_up_page.enter_email(email)
    sign_up_page.enter_password("test")
    sign_up_page.enter_password_confirmation("test")
    driver.find_element(:id, "authcode").send_keys("WISE")
    sign_up_page.check_accept_terms
    sign_up_page.click_register

    driver.get("http://107.170.251.122:1080")
    mailcatcher_search("Welcome to SiteWise CMS")
    mailcatcher_open_message_from_top
    # the_email_text = mailcatcher_message_text

    driver.switch_to.frame(0)
    sleep 1  # wait 1 second for email, MailCatcher is fast
    activate_token = ""
    begin
      activate_token =  driver.find_element(:id, "activate_link")["data-path"]
    ensure
      driver.switch_to.default_content
    end
    debug activate_token

    driver.get("http://demo.sitewisecms.com" + activate_token)
    expect(page_text).to include("The account is activated successfully")

    driver.get("http://demo.sitewisecms.com/login")
    customer_login_page = CustomerLoginPage.new(driver)
    driver.find_element(:name, "email").send_keys(email)
    driver.find_element(:name, "password").send_keys("test")
    driver.find_element(:id, "sign_in_btn").click

    driver.find_element(:id, "logout_link").click  # verify it is in
    debug email
  end


end
