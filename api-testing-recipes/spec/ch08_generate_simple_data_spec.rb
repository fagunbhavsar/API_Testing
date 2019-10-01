load File.dirname(__FILE__) + '/../test_helper.rb'

describe "Generate Simple Data" do
  include TestHelper

  before(:all) do

  end

  after(:all) do
  end

  it "Generate dynamic Date" do
    require 'date' # only need to require once

    # assume today is 2016-05-25
    Date.today.strftime("%m/%d/%Y") # => 05/25/2016    
    (Time.now + 1 * 24 * 3600).strftime("%Y-%m-%d %H:%M") # => 2016-05-25 19:57
  end

  it "Generate dynamic date using ActiveSupport" do
    require 'active_support/all'
    debug Date.today
    debug Date.today.next_week()
    debug Date.today.next_month()
    debug Date.today.tomorrow()
    debug Date.today.end_of_week
    debug 2.days.ago(Date.today)
    debug 3.days.since(Date.today)
  end
  
  it "Random boolean value" do
    debug rand(2) == 1  # true or false  
    random_gender = (rand(2) == 1 ? "male" : "female")    
    debug random_gender
  end
  
  
  it "Random numbers" do
    debug rand() # a real time between 0 and 1, eg 0.05619897760265391
    debug (rand(90) + 10) # a number between 10 and 99
  end

  it "Random strings" do
    # 10 alpha characters in lower case
    10.times.inject([]) { |result, el| result << random_number(97, 122).chr }.join

    require 'securerandom'
    # random 32 chars of a..f, 0..9, eg. 00eaa55ea2b83d41492c6c0e69483f91
    debug SecureRandom.hex


    # debug [*('A'..'Z')].sample(8).join
    # debug rand(36**6).to_s(36)
  end

  it "Personal details" do
    require 'faker'
    debug Faker::Name.name # => "Jeromy Erdman"
    debug Faker::Name.first_name # => "Maverick"
    debug Faker::Internet.email # => "jamarcus@kertzmann.com"
    debug Faker::Address.street_address # => "290 Nienow Flats"
    debug Faker::PhoneNumber.phone_number # => "621 Wuckert Plaza"
    
    new_name = Faker::Name.name 
    debug new_name                # Vernie Dare
    debug new_name.downcase[0..9] # vernie dar    
  end

  it "Generate Uniq ID" do
    require 'faker'
    # a very uniq ID
    debug Faker::Bitcoin.address # => 1MoE1F5X5aP4yxWYnYJZfw2JXHruuSUTSh
    debug Faker::Bitcoin.address # => 13NRmmntobsrKhzXrC5YEJauoYyvwefNp8

    # UUID (Universally Unique IDentifier)
    require 'securerandom'
    debug SecureRandom.uuid #=> a77e84e6-f9b3-42cb-bf17-4369c872986b
    debug SecureRandom.uuid #=> f45fc2a8-e272-4bb4-b36e-39d4fe410e3a
  end


  it "Test File at specific size" do
    require 'fileutils'
    tmp_dir = File.join(File.dirname(__FILE__), "tmp")
    FileUtils.mkdir(tmp_dir) unless File.exists?(tmp_dir)
    File.open(File.join(tmp_dir, "2MB.txt"), "w") {|f|
      f.write( '0' * 1024 * 1024 * 2 )
    }
  end

end
