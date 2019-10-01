load File.dirname(__FILE__) + '/../test_helper.rb'
gem "json"
require 'json'
require 'active_support/all'


class Book
  attr_accessor :title
  attr_accessor :isbn
  attr_accessor :isbn_13
  attr_accessor :authors

  def initialize
    @authors = []
  end

  def to_json(opts = {})
    hash = {
      "title" => @title,
      "isbn" =>  @isbn,
      "authors" => @authors.as_json()
    }
    return hash.to_json
  end

end

class Author
  attr_accessor :first_name
  attr_accessor :last_name
  attr_accessor :gender

  def as_json(opts = {})
    hash = {
      "first_name" =>  @first_name,
      "last_name" =>  @last_name
    }
    return hash
  end

end


class Invoice
  attr_accessor :reference_number, :invoice_date, :client, :total_price, :comments
end

describe "Generate" do
  include TestHelper

  before(:all) do

  end

  after(:all) do
  end

  it "Generate XML" do
    gem "builder"     # gem install builder
    require 'builder'
    builder = Builder::XmlMarkup.new
    xml = builder.person { |b|
      b.name("James Bond", :age => 40)
      b.phone("789-1234")
    }
    debug xml
  end

  it "Modify existing XML" do
    require 'nokogiri'      
    xml_string = <<EOF
  <Products>
    <Product version="1.5.5">BuildWise</Product>
    <Product version="4">TestWise</Product>
  </Products>
EOF
    doc = Nokogiri::XML(xml_string)
    elem = doc.xpath("//Product[text()='TestWise']")[0]
    elem.content = "TestWise IDE"
    elem["version"] = "1.6"
    debug doc.to_xml
    expect(doc.to_xml).to include('<Product version="1.6">TestWise IDE</Product>')
    
    # Add a new element and remove existing element
    buildwise_elem = doc.xpath("//Product[text()='BuildWise']")
    buildwise_elem.remove
    debug doc.to_s
    expect(doc.to_xml).not_to include('<Product>BuildWise</Product>')
    
    products_node =  doc.xpath("//Products")[0]    
    new_note = Nokogiri::XML::Node.new "Product", products_node
    new_note.content = "ClinicWise"  
    products_node.children.last.add_next_sibling(new_note)
    debug doc.to_s
    expect(doc.to_xml).to include('<Product>ClinicWise</Product>')
  end
  
  it "Generate JSON " do
    # primititve type
    results = {}
    results["count"] = 2 
    months = { "English" => ["January", "February"], "Chinese" => ["1yue", "2yue"] }    
    results["locale"] = months    
    debug results.to_json  
    expect(results.to_json).to include('{"count":2,"locale":{"English":["January",')
  end

  
  it "Modify existing JSON" do
    require 'json'
    json_obj = JSON.parse('{"staff":[ {"firstName":"John", "lastName":"Daw"}, {"firstName":"Tom", "lastName":"Jones"}]}')
    json_obj["staff"][0]["lastName"] = "Foo"
    json_obj["staff"].delete_at(1) # remove the second one
    expect(json_obj.to_json).not_to include('Jones')    

    json_obj["staff"] << {"firstName" => "New", "lastName" => "One"}
    debug json_obj.to_json
    expect(json_obj.to_json).to include('{"firstName":"New","lastName":"One"}')
  end
  
 it "Generate JSON from template" do
    require 'rest-client'
    require 'json' # gem install json

    # using the Get request to get sample JSON
    # ws_url = "http://jsonplaceholder.typicode.com/posts/1"
    # response = RestClient.get(ws_url)

    ws_url = "http://jsonplaceholder.typicode.com/posts"
    json_erb = ERB.new(File.read(File.join(File.dirname(__FILE__), "..", "testdata", "sample_json.erb")))
    
    (101..103).each do |id|
      @id = id
      @title = "Foo#{id}"
      @body = "Bar#{id}"
      json_request = json_erb.result(binding)
      # debug json_request
      response = RestClient.post(ws_url, json_request)          
      debug "=>|#{response.body}|" 
      expect(response.body).to include("#{@id}")
    end      
  end
  
  
  it "Generate JSON with model" do    
    a_book = Book.new
    a_book.title = "Practical Web Test Automation"
    a_book.isbn = "1505882893"

    author = Author.new
    author.first_name = "Zhimin"
    author.last_name = "Zhan"    
    a_book.authors << author

    another_author = Author.new
    another_author.first_name = "Steve"
    another_author.last_name = "Apple"
    a_book.authors << another_author

    debug a_book.to_json
  end
  
  
  it "Generate Zip file" do      
    require 'archive/zip' # gem install archive-zip
    # Add a_directory and its contents to example1.zip.
    data_dir = File.join(File.dirname(__FILE__), "../testdata")
    ouptut_zip_file = File.join(File.dirname(__FILE__), "../tmp", "testdata.zip")
    Archive::Zip.archive(ouptut_zip_file, data_dir)
    expect(File.exists?(ouptut_zip_file)).to be_truthy
  end

  it "Generate CSV file" do
    require "CSV"
    tmp_dir = File.join(File.dirname(__FILE__), "tmp")
    FileUtils.mkdir(tmp_dir) unless File.exists?(tmp_dir)
    CSV.open(File.join(tmp_dir, "clinicwise_pricing.csv"), "wb") do |csv|
      csv << ["Plan", "Practitioner Count", "Price per month"]
      csv << ["Solo", "1", "$35.00"]
      csv << ["Team", "5", "$65.00"]
    end
    
  end


  it "Create spreadsheet" do
    require 'spreadsheet'  # gem install spreadsheet
    book = Spreadsheet::Workbook.new
    sheet_1 = book.create_worksheet(:name => "ClinicWise")
    sheet_1.row(0).push "Practitioner Count", "Monthly Price"
    sheet_1.row(1).push 1, 35
    sheet_1.row(2).push 5, 65
    sheet_2 = book.create_worksheet(:name => "SiteWise CMS")
    sheet_2.row(0).push "Service", "Price"
    sheet_2.row(1).push "Set up", 499
    sheet_2.row(2).push "Monthly on-going", 35
    tmp_dir = File.join(File.dirname(__FILE__), "tmp")
    FileUtils.mkdir(tmp_dir) unless File.exists?(tmp_dir)
    book.write File.join(tmp_dir, "products.xls")
  end

  it "Generate Open XML Spreadsheet with templates " do
    require 'erb'
    require 'active_support/all'
    require 'faker'
    
    template = File.join(File.dirname(__FILE__), "../testdata", "template.xlsx.erb")
    erb = ERB.new(File.read(template))
    
    @starts_at = 7.days.ago(Date.today).beginning_of_week
    @ends_at =  @starts_at.end_of_week
    @invoices = []

    @total_invoice_amount = 0
    10.times do |id|
      an_invoice = Invoice.new
      an_invoice.reference_number = (1000 + id).to_s.rjust(4, "0")
      an_invoice.client = Faker::Name.name 
      an_invoice.invoice_date = rand(7).to_i.days.since(@starts_at)
      an_invoice.total_price = rand(3000)  + 10
      @total_invoice_amount +=  an_invoice.total_price 
      an_invoice.comments = ""
      @invoices << an_invoice
    end
    
    dest_file = File.join(File.dirname(__FILE__), "../tmp", "invoices.xls")
    the_output = erb.result(binding)
    debug "=> " + the_output
    File.open(dest_file, "w").write(the_output)
  end
end
