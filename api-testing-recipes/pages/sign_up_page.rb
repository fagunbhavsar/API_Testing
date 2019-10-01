require File.join(File.dirname(__FILE__), "abstract_page.rb")

class SignUpPage < AbstractPage

  def initialize(driver)
    super(driver, "") # <= TEXT UNIQUE TO THIS PAGE
  end

  def enter_username(user_username)
    driver.find_element(:name, "username").clear
    driver.find_element(:name, "username").send_keys(user_username)
  end

  def enter_email(user_email)
    driver.find_element(:name, "email").clear
    driver.find_element(:name, "email").send_keys(user_email)
  end

  def enter_password(user_password)
    driver.find_element(:name, "password").clear
    driver.find_element(:name, "password").send_keys(user_password)
  end

  def enter_password_confirmation(user_password_confirmation)
    driver.find_element(:name, "passwordConfirm").clear
    driver.find_element(:name, "passwordConfirm").send_keys(user_password_confirmation)
  end

  def check_accept_terms
    # find_element(:xpath, "//input[@type='checkbox']").click
    # find_element(:id, "terms").click
     driver.execute_script("$('#terms').prop('checked', true);")
     sleep 0.5
  end

  def click_register
    driver.find_element(:id, "sign_up_btn").click
    sleep 1.5
  end

  def click_accept_terms
    driver.find_element(:link_text, "Terms and Conditions").click
    sleep 0.5
    driver.find_element(:id, "i-agree").click
    sleep 1
  end

  def click_show_more_info
    driver.find_element(:id, "show_more_info_link").click
    sleep 0.3
  end

end
