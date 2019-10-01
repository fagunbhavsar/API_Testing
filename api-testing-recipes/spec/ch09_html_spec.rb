load File.dirname(__FILE__) + '/../test_helper.rb'

describe "HTML" do
  include TestHelper

  before(:all) do

  end

  after(:all) do
  end




  it "Parse HTML with Nokogiri" do
    require 'nokogiri'
    
    html_str = <<EOF
<html><head><title>Hello World</title></head>
  <body>
        <h1>This is an awesome document</h1><input type="hidden" name="locale" value="en-AU">
    <p>
      This is a <b>bold</b> paragraph. <br>
        <a id="a-link" href="http://google.ca">I am a link</a>
    </p>
  </body></html>
EOF

    doc = Nokogiri::HTML(html_str)   
    debug doc.to_xhtml
    expect(doc.css("#a-link").text).to eq("I am a link")
    expect(doc.css("b").text).to eq("bold")
    expect(doc.css("input[name='locale']")[0]["value"]).to eq("en-AU")
    
    require 'open-uri'
    page = Nokogiri::HTML(open("http://travel.agileway.net"))   
    links = page.css("a")
    expect(links.size)
    expect(links[1].text).to eq("Login")
  end


  it "Headless web browsing with Mechanize and parse HTML" do
    require 'mechanize'  # gem install mechanize
    agent = Mechanize.new
    home_page  = agent.get 'http://travel.agileway.net'

    flight_page = home_page.form_with(:action => '/sessions') do |f|
      f.username = "agileway"  # set form name
      f.password = "testwise"
    end.submit

    passenger_page = flight_page.form_with(:action => "/flights/select_date") do |f|
      f.fromPort = "Sydney"  # dropdown
      f.toPort = "New York"
    end.submit

    payment_page = passenger_page.form_with(:action => "/flights/passenger") do |f|
      f.passengerFirstName = "Bob"
      f.passengerLastName  = "Tester"
    end.submit

    expect(payment_page.form_with(:action => "/payment/confirm").holder_name).to eq("Bob Tester")
  end

  it "Advanced HTML with cookie" do
    http = Net::HTTP.new('testwisely.com', 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE # Igore SSL error
    buy_buildwise_agent_path = "/carts/add_product?code=BWAS20"
    buy_testwise_path = "/carts/add_product?code=TWNA01"
    cart_path = "/shopping/cart"

    # make a request to get the server's cookies
    response = http.get(buy_buildwise_agent_path)
    if response.code == "301" || response.code == "302" # redirect
      all_cookies = response.get_fields('set-cookie')
      # debug all_cookies
      cookies_array = Array.new   # compose a cookie object
      all_cookies.each { | cookie |
        cookies_array.push(cookie.split('; ')[0])
      }
      cookies = cookies_array.join('; ')

      # following redirect
      response = http.get(response.header['location'], { 'Cookie' => cookies })
      expect(response.body).to include("<span id='cart_item_count'>1</span>") # one item in cart
    end

    response = http.get(buy_testwise_path, { 'Cookie' => cookies })

    response = http.get(cart_path, { 'Cookie' => cookies })
    expect(response.body).to include("<span id='cart_item_count'>2</span>") # now 2
    File.open("c:/temp/cart.html", "w").write(response.body)
  end

end
