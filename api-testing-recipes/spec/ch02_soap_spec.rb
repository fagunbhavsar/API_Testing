load File.dirname(__FILE__) + '/../test_helper.rb'

require 'net/http'
require 'net/https'
require 'erb'
    
describe "SOAP Testing" do
  include TestHelper

  before(:all) do    
  end

  after(:all) do
  end

  # A list of free web services,  http://www.service-repository.com/  
  it "SOAP with sample XML" do
    
    # http://www.w3schools.com/xml/tempconvert.asmx?WSDL

    #POST http://www.w3schools.com/xml/tempconvert.asmx HTTP/1.1
    #Accept-Encoding: gzip,deflate
    #Content-Type: text/xml;charset=UTF-8
    #SOAPAction: "http://www.w3schools.com/webservices/CelsiusToFahrenheit"
    #Content-Length: 342
    #Host: www.w3schools.com
    #Connection: Keep-Alive
    #User-Agent: Apache-HttpClient/4.1.1 (java 1.5)

    request_xml = <<END_OF_MESSAGE
<?xml version="1.0" encoding="utf-8"?>
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" 
                  xmlns:x="http://www.w3schools.com/xml/">
   <soapenv:Header/>
   <soapenv:Body>
      <x:CelsiusToFahrenheit>
         <x:Celsius>10</x:Celsius>
      </x:CelsiusToFahrenheit>
   </soapenv:Body>
</soapenv:Envelope>
END_OF_MESSAGE

    http = Net::HTTP.new('www.w3schools.com', 80)
    resp, data = http.post("/xml/tempconvert.asmx", request_xml,
        {
          "SOAPAction" => "http://www.w3schools.com/xml/CelsiusToFahrenheit", 
          "Content-Type" => "text/xml",
          "Host" => "www.w3schools.com",
        }
      )
    expect(resp.code).to eq("200") # OK
    # debug resp.body
    # resp.each { |key, val| debug(key + ' = ' + val) }    
    expect(resp.body).to include("<CelsiusToFahrenheitResult>50</CelsiusToFahrenheitResult>")
  end
 
 
  it "SOAP with dynamic request data" do
    template_erb_file = File.expand_path("../../testdata/c_to_f.xml.erb", __FILE__)
    template_erb_str = File.read(template_erb_file)
    @degree = 30 # changeable in your test script
    request_xml = ERB.new(template_erb_str).result(binding)
    
    http = Net::HTTP.new('www.w3schools.com', 80)
    resp, data = http.post("/xml/tempconvert.asmx", request_xml,
      {
        "SOAPAction" => "http://www.w3schools.com/xml/CelsiusToFahrenheit", 
        "Content-Type" => "text/xml",
        "Host" => "www.w3schools.com",
      }
    )
    expect(resp.code).to eq("200") # OK
    debug resp.body
    expect(resp.body).to include("<CelsiusToFahrenheitResult>86</CelsiusToFahrenheitResult>")
  end

  it "Parse XML after stripping namespace" do
    xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><CelsiusToFahrenheitResponse xmlns="http://www.w3schools.com/webservices/"><CelsiusToFahrenheitResult>86</CelsiusToFahrenheitResult></CelsiusToFahrenheitResponse></soap:Body></soap:Envelope>'
    require 'nokogiri'
    xml_doc = Nokogiri.parse(xml )
    xml_doc.remove_namespaces!
    
    # debug xml_doc.to_s # 
    node = "//CelsiusToFahrenheitResponse/CelsiusToFahrenheitResult"
    expect(xml_doc.xpath(node).text).to eq("86")
  end
  
  
  it "Using Soap client - Savon" do
    # http://savonrb.com/version2/client.html
    gem 'savon', '~> 2.0'
    require 'savon'
    client = Savon.client do
      wsdl "http://www.w3schools.com/xml/tempconvert.asmx?WSDL"
      convert_request_keys_to :camelcase   # change :foo_bar => FooBar
      open_timeout 20  # fail early when the service not available
      log false         # show in STDOUT if set true
    end
    debug client.operations # => [:fahrenheit_to_celsius, :celsius_to_fahrenheit]
    response = client.call(:celsius_to_fahrenheit) do 
      message :celsius => "40"
    end
    debug response.to_s # get xml response string
    debug response.body.inspect
    fahrenheit = response.body[:celsius_to_fahrenheit_response][:celsius_to_fahrenheit_result]
    expect(fahrenheit).to eq("104")
  end
  
  
  it "SAXON" do
    gem 'savon', '~> 2.0'
    require 'savon'
    client = Savon.client do
      # The WSDL document provided by the service.
      wsdl "http://www.ratp.fr/wsiv/services/Wsiv?wsdl"

      # Lower timeouts so these specs don't take forever when the service is not available.
      open_timeout 10
      read_timeout 10

      log false
    end

    # XXX: the service seems to rely on the order of arguments.
    #      try to fix this with the new wsdl parser.
    response = client.call(:get_stations) do
      message(:limit => 5)
    end
    
    debug response.to_s
    station_count = response.body[:get_stations_response][:return][:stations].size
    expect(station_count).to eq(5)
    station_name = response.body[:get_stations_response][:return][:stations][0][:name]
    expect(station_name).to eq("Pereire") # the value might change
  end
end
