require 'minitest/autorun'

describe "SoapTest" do

   before do 
     # run before each test case
   end
   
   it "SOAP with dynamic request data" do
     template_str = File.read(File.expand_path("../../testdata/c_to_f.xml.erb", __FILE__))
     @degree = 30
     require 'net/http'
     require 'erb'
     request_xml = ERB.new(template_str).result(binding)
     http = Net::HTTP.new('www.w3schools.com', 80)
     resp, data = http.post("/xml/tempconvert.asmx", request_xml,
       {
         "SOAPAction" => "http://www.w3schools.com/xml/CelsiusToFahrenheit", 
         "Content-Type" => "text/xml"
       }
     )
     resp.code.must_equal("200")
     resp.body.must_include("<CelsiusToFahrenheitResult>86</CelsiusToFahrenheitResult>")
   end   
   
end
