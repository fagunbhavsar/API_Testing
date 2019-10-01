load File.dirname(__FILE__) + '/../test_helper.rb'

describe "Combination - Data Driven" do
  include TestHelper

  before(:all) do
    @driver = $browser =  Selenium::WebDriver.for(browser_type)
  end

  before(:each) do
    #  driver.navigate.to(site_url.gsub("index.html", "assert.html"))
  end

  after(:all) do
    driver.close unless debugging?
  end

  it "Data Driven tests with Excel spreadsheet" do
    # Note, this library is not included in TestWise Community Edition,
    # Try in Pro edition or run from command line
    require 'spreadsheet'
    excel_file = File.join(File.dirname(__FILE__), "..", "testdata", "users.xls")
    excel_book = Spreadsheet.open excel_file
    sheet1 = excel_book.worksheet(0)
    sheet1.each_with_index do |row, idx|
      next if idx == 0 # ignore first row
      description,  login, password, expected_text = row[0], row[1], row[2], row[3]
      driver.navigate.to("http://travel.agileway.net")
      driver.find_element(:name, "username").send_keys(login)
      driver.find_element(:name, "password").send_keys(password)
      driver.find_element(:name, "username").submit
      expect(driver.find_element(:tag_name => "body").text).to include(expected_text)
      # if logged in OK, try log out, so next one can continue
      fail_safe{ driver.find_element(:link_text, "Sign off").click }
    end
  end

  it "Data driven test: CSV" do
    # Iterate each row in the CSV file, use data for test scripts
    csv_file = File.join(File.dirname(__FILE__), "..", "testdata", "users.csv")
    require 'csv'

    if RUBY_VERSION =~ /^1.8/
      require 'fastercsv' # old Ruby version, use 'fastcsv'
      CSV = FasterCSV
    end

    CSV.foreach(csv_file) do |row|
      # get user login details row by row
      login, password, expected_text = row[1], row[2], row[3]
      next if login == "LOGIN" # ignore first row
      driver.navigate.to("http://travel.agileway.net")
      driver.find_element(:name, "username").send_keys(login)
      driver.find_element(:name, "password").send_keys(password)
      driver.find_element(:name, "username").submit
      # debug expected_text
      expect(driver.find_element(:tag_name => "body").text).to include(expected_text)
      # if logged in OK, try log out, so next one can continue
      fail_safe{ driver.find_element(:link_text, "Sign off").click }
    end

  end


end
