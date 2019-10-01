load File.dirname(__FILE__) + '/../test_helper.rb'

require 'net/http'
require 'net/https'

describe "Data Fetching" do
  include TestHelper

  it "Parse XML with REXML" do
    require "rexml/document"
    
    xml_string = <<EOF
  <Products>
    <Product>TestWise</Product>
    <Product>BuildWise</Product>
  </Products>
EOF
    doc = REXML::Document.new(xml_string)
    file = File.new(File.join(File.dirname(__FILE__), "../testdata", "books.xml"))
    doc = REXML::Document.new(file)
    
    # Accessing elements
    expect(doc.root.name).to eq("books")
    # expect(doc.root.elements["category"].size).to eq(2)
    
    # Creating an array of matching elements
    all_book_elems = doc.elements.to_a("//books/category/book/title" )
    all_book_titles = all_book_elems.collect{|x| x.text}
    expect(all_book_titles).to eq(["Practical Web Test Automation", "Selenium WebDriver Recipes in Ruby", "Learn Ruby Programming by Examples", "Learn Swift Programming by Examples"])

    # specific elmenent, 1-based
    second_book = doc.elements["//book[2]/title"].text
    debug "2nd => " + second_book
    
    # match first occurence
    first_programming_book = doc.elements["books/category[@name='Programming']/book/title"].text
    expect(first_programming_book).to eq("Learn Ruby Programming by Examples")
      
    # Gets an array of all of the "book" elements in the document.
    book_elems_array = REXML::XPath.match( doc, "//book" ) 
    expect(book_elems_array.size).to eq(4)    

    REXML::XPath.each(doc, "//category[@name='Test Automation']/book") { |book_elem|
      debug book_elem.elements["title"].text  # element text
      debug book_elem.attributes["isbn"]      # attribute value
    }
  end
  
  it "Parse XML with Nokogiri" do
    require 'nokogiri'
    file = File.new(File.join(File.dirname(__FILE__), "../testdata", "books.xml"))
    doc = Nokogiri::XML(File.open(file))
    
    expect( doc.xpath("//book").count ).to eq(4)
    expect( doc.xpath("//book/title")[0].text).to eq("Practical Web Test Automation")        
  end
  
  it "Strip out namespaces with Nokogiri" do
    require 'nokogiri'
    doc = Nokogiri::XML("<a xmlns:x='foo' xmlns:y='bar'><x:b id='1'/><y:b id='2'/></a>")
    doc.remove_namespaces!
    debug doc
  end
  
  # Slop mode, without Xpath    
  it "Parse XML with Nokogiri in sloppy mode" do
    require 'nokogiri'
    file = File.new(File.join(File.dirname(__FILE__), "../testdata", "books.xml"))
    doc = Nokogiri::Slop(File.read(file))
    
    expect(doc.books.category[1].book[0].title.content).to eq("Learn Ruby Programming by Examples")
    expect(doc.books.category[0]["name"]).to eq("Test Automation")
    
    # use some xpath
    expect(doc.books.category("[@name='Test Automation']").book[1].title.content).to eq("Selenium WebDriver Recipes in Ruby")
    
  end
  

  it "JSON over HTTP" do
    require 'json'
    require 'httpclient'
    uri = "http://finance.yahoo.com/webservice/v1/symbols/YHOO,AAPL/quote?format=json&view=detail"
    http = HTTPClient.new
    resp = http.get(uri)

    json_str = resp.content
    debug json_str

    json_obj = JSON.parse(json_str)
    #debug json_obj.inspect
    expect(json_obj["list"]["meta"]["count"]).to eq(2)
    yahoo_share_day_low = json_obj["list"]["resources"][0]["resource"]["fields"]["day_low"].to_f
    apple_share_day_high = json_obj["list"]["resources"][1]["resource"]["fields"]["day_high"].to_f
    debug yahoo_share_day_low
    debug apple_share_day_high
    raise "I wish I bought Apple Share exception" if apple_share_day_high > 150
  end
  
  it "Pretty print JSON" do
    require 'json'    
    json_obj = JSON.parse('{"staff":[ {"firstName":"John", "lastName":"Daw"}, {"firstName":"Tom", "lastName":"Jones"}]}')
    formatted_json = JSON.pretty_generate(json_obj) # => string  
    debug formatted_json
    File.open("tmp.json", "w").write(formatted_json)
  end
  
  # RSS feed is XML
  it "RSS Feed" do
    require 'open-uri'
    uri = "http://rss.cnn.com/rss/edition.rss"
    rss_xml = open(uri).read

    require 'nokogiri'
    xml_doc = Nokogiri.parse(rss_xml)
    xml_doc.remove_namespaces!
    puts xml_doc
    top_story_headlines = xml_doc.xpath("//item/title").collect{|x| x.text}
    debug top_story_headlines.count
    debug top_story_headlines.first
  end


  it "CSV over HTTP" do
    yahoo_exchange_rate_live_url = "http://download.finance.yahoo.com/d/quotes.csv?s=AUDJPY=X&f=sl1d1t1ba&e=.csv"
    csv_data = Net::HTTP.get(URI.parse(yahoo_exchange_rate_live_url))

    debug csv_data
    require 'csv'
    csv = CSV.parse(csv_data) # CSV
    csv_first_row =  csv.shift
    exchange_rate = csv_first_row[1].to_f
    debug exchange_rate
  end


  it "Parse String with Regular Expression" do
    coupon_text = "<response>Your coupon code: V7H67U used by 2016-08-18</response>"
    if coupon_text =~ /coupon code:\s+(\w+) used by\s([\d|-]+)/
      coupon_code = $1   # first captures group (\w+)
      expiry_date = $2
      debug "Coupon Code: #{coupon_code}"
      debug "Expire Date: #{expiry_date}"
    else
      raise "Error: no valid coupon returned"
    end
  end
  
end
