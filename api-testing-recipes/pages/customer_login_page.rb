require File.join(File.dirname(__FILE__), "abstract_page.rb")

class CustomerLoginPage < AbstractPage

  def initialize(driver)
    super(driver, "") # <= TEXT UNIQUE TO THIS PAGE
  end

end
