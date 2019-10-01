load File.dirname(__FILE__) + '/../test_helper.rb'

require 'httpclient'

describe "Verify downloaded binary file" do
  include TestHelper
  
  # Download a binary file from a URL
  def download_file(url, dest_file_name)
    start_time = Time.now
    
    client = HTTPClient.new
    saved_file_path = File.join(File.dirname(__FILE__), "..", "tmp", dest_file_name)
    save_file = File.new(saved_file_path, "wb")    
    start_time = Time.now
    save_file.write(client.get_content(url))
    save_file.flush
    save_file.close
    
    time_to_download = Time.now - start_time
    debug("Time to download => #{time_to_download}")
    
    return saved_file_path
  end
  

    
  it "Verify file downloaded OK" do
    require 'open-uri'
    local_saved_file = File.join(File.dirname(__FILE__), "..", "tmp", "pwta-sample.pdf")
    if File.exists?(local_saved_file)
      require 'fileutils'
      FileUtils.rm(local_saved_file)
    end
    
    File.open(local_saved_file, "wb") do |saved_file|
      # the following "open" is provided by open-uri
      open("http://samples.leanpub.com/practical-web-test-automation-sample.pdf", "rb") do |read_file|
      saved_file.write(read_file.read)
      end
    end      
    expect(File.exists?(local_saved_file)).to eq(true)    
    debug File.size(local_saved_file)
    expect(File.size(local_saved_file)).to be > 1400000
  end
  
  it "Download file dynamic URL" do
    local_saved_file = File.join(File.dirname(__FILE__), "..", "tmp", "t_c.pdf")
    File.open(local_saved_file, "wb") do |saved_file|
      open("http://travel.agileway.net/terms_and_conditions", "rb") do |read_file|
       saved_file.write(read_file.read)
      end
    end
  end
  
  it "Download Zip file" do    
    gem 'rubyzip'
    require 'zip'
    
    zip_file_url = "https://testwisely.com/sites/testwisely/books/selenium_recipes/selenium-recipes-sample-source.zip"
    saved_file_path = download_file(zip_file_url, "selenium-recipes-sample-source.zip")
    zip_file_io = Zip::File.open(saved_file_path)
    all_file_list = []
    zip_file_io.each do |entry|
      all_file_list << entry.name
    end
    expect(all_file_list).to include("selenium-recipes-sample-source/ch01_open_chrome.rb")

    begin
      bad_zip_path = File.join(File.dirname(__FILE__), "../testdata/bad.zip")
      Zip::File.open(bad_zip_path)  
    rescue => e
      puts e.message 
      expect(e.message).to include("can't dup NilClass")
    end
    
  end

  it "Download Excel " do
    require 'spreadsheet'
    # more info, https://github.com/zdavatz/spreadsheet/blob/master/GUIDE.md
    
    pdf_path = File.join(File.dirname(__FILE__), "../testdata/users.xls")
    book = Spreadsheet.open(pdf_path)
    expect(book.worksheets.size).to eq(1)
    expect(book.worksheets.first.name).to eq("users")
    
    puts book.worksheets[0].rows.count  # => 5
    expect(book.worksheets[0].rows[1][2]).to eq("testwise")
    
    # load a corrupted excel file 
    begin
      bad_xls_path = File.join(File.dirname(__FILE__), "../testdata/bad.xls")
      book = Spreadsheet.open(bad_xls_path)    
    rescue => e
      puts e.message 
      # depends on data, the erorr might be different
      expect(e.message).to include("broken allocationtable chain") 
    end
    
  end

  #  "pdf-reader" gem needs to be installed
  it "Download PDF" do
    pdf_url = "http://samples.leanpub.com/practical-web-test-automation-sample.pdf"
    saved_file_path = download_file(pdf_url, "pwta.pdf")
    
    require 'pdf-reader'  # gem install pdf-reader
    fio = File.open(saved_file_path, "rb")
    reader = PDF::Reader.new(fio)
    pdf_metadata = reader.info
    puts pdf_metadata 
    expect(pdf_metadata[:Author]).to eq("Zhimin Zhan")
    expect(pdf_metadata[:Title]).to eq("Practical Web Test Automation")
    
    # load a corrupted png image    
    begin
      bad_pdf_path = File.join(File.dirname(__FILE__), "../testdata/bad.pdf")
      reader = PDF::Reader.new(File.open(bad_pdf_path, "rb"))
    rescue => e
      puts e.message 
      # depends on data, the erorr might be different
      expect(e.message).to include("xref table not found") 
    end
  end

  it "Download an image (PNG)" do
    require 'chunky_png' # gem install chunky_png
    png_image_url = "https://s3.amazonaws.com/titlepages.leanpub.com/selenium-recipes-in-ruby/hero?1427192483"
    saved_file_path = download_file(png_image_url, "selenium_recipes.png")

    image = ChunkyPNG::Image.from_file(saved_file_path)
    # PNG can set metadata on creation, maybe used for assertion    
    debug image.metadata.inspect
    puts image.metadata["date:create"] # eg. 2015-07-05T10:40:28+00:00
    
    # load a corrupted png image    
    begin
      bad_png_path = File.join(File.dirname(__FILE__), "../testdata/bad.png")
      image = ChunkyPNG::Image.from_file(bad_png_path)
    rescue => e
      puts e.message
      expect(e.message).to include("Chuck CRC mismatch!")
    end
  end
  
  it "Verify file by MD5 or SHA256 Hash" do
    require 'digest'
    file_path =  File.join(File.dirname(__FILE__), "../testdata/sample_invoice.pdf")
    md5_hash = Digest::MD5.file(file_path).hexdigest
    expect('7eb8022ea779f3288e7cdc0e8aae0745', md5_hash)
    sha256_hash = Digest::SHA256.file(file_path).hexdigest
    expect("eb90578bfb87698c95165b267f52aaf7ead469e69aa6f23fd92a48fbfe964cbf", sha256_hash)
  end
  
  
  it "Download file in Chrome" do
    # Change default download directory. On Mac, default to /Users/YOU/Downloads folder
    download_path = RUBY_PLATFORM =~ /mingw/ ? "C:\\TEMP": "/Users/zhimin/tmp"
    prefs = {
      :download => {
        :prompt_for_download => false,
        :default_directory => download_path
      }
    }
    driver = Selenium::WebDriver.for :chrome, :prefs => prefs
    driver.navigate.to "http://zhimin.com/books/pwta"
    driver.find_element(:link_text, "Download").click
    sleep 10 # wait download to complete
    expect(File.exists?("#{download_path}/practical-web-test-automation-sample.pdf")).to be_truthy
    driver.quit
  end
    
end
