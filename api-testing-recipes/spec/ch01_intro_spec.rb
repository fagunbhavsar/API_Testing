load File.dirname(__FILE__) + '/../test_helper.rb'

describe "Intro" do
  include TestHelper

  before(:all) do    
  end

  after(:all) do
  end

  it "Functional UI Test" do
    driver = Selenium::WebDriver.for(:chrome)
    driver.navigate.to("https://agileway.net")
    driver.find_element(:link_text, "CREATE ACCOUNT").click
    driver.find_element(:name, "email").send_keys("testwisely01@gmail.com")    
    driver.find_element(:name, "username").send_keys("testwisely01")    
    driver.find_element(:name, "password").send_keys("secret")
    driver.find_element(:name, "passwordConfirm").send_keys("secret")
    driver.find_element(:xpath, "//input[@id='terms']/../i").click
    driver.find_element(:id, "sign_up_btn").click  
  end

end
