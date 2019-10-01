load File.dirname(__FILE__) + '/../test_helper.rb'

describe "Database" do
  include TestHelper

  it "Sqlite 3 - Retrieve data records from database" do
    require 'sqlite3'
    db = SQLite3::Database.new File.join(File.dirname(__FILE__), "..", "testdata", "sample.db")

    # Users table: with login, name, age
    oldest_user_login = nil
    db.execute( "select * from users order by age desc" ) do |row|
      oldest_user_login = row[0]
      break
    end

    expect(oldest_user_login).to eq("mark")
  end

  it "MySQL " do
    # gem install mysql2 first
    require 'mysql2'
    client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => ENV["MYSQL_PASSWORD"] || "", :database => "buildwise_production")
    # client = Mysql2::Client.new(:host => "10.0.0.1", :username => "tester", :password => "wise", :database => "buildwise_production")
    results = client.query("SELECT duration FROM builds WHERE project_id=3 ORDER BY duration DESC")
    headers = results.fields # <= that's an array of field names, in order
    debug headers # ["duration"]
    longest_build_time = nil
    results.each do |row|
      # :duration only works if :symbolize_keys => true is in query parameter
      longest_build_time = row["duration"]
      break
    end
    debug longest_build_time

  end

  it "SQLServer" do
    gem "tiny_tds"
    debug ENV["SQLSERVER_DB_PASS"]
    require 'tiny_tds'
    client = TinyTds::Client.new(:username => 'sa',
      :password => ENV["SQLSERVER_DB_PASS"], # need to set it in environment variables, also need to set in build agents
      :host => 'db01.nonprod.com',
      :database => "clinicwise_integration")

    result = client.execute("SELECT * FROM USERS where CLINIC_ID = 9")
    result.each do |row|
      debug row.inspect # e.g {"Id" => 1, "Name" => "James"}
      # By default each row is a hash.
      # The keys are the fields, as you'd expect.
      # The values are pre-built Ruby primitives mapped from their corresponding types.
      break
    end

    client.close
  end

  it "Postgres" do
    gem "pg"  # https://bitbucket.org/ged/ruby-pg/wiki/Home
    require 'pg'

    conn = PG.connect( :host => "127.0.0.1",
    :port     => 5432,
    :user     => "postgres",
    :password => "test",
    :dbname => 'buildwise_production' )
    # localhost, postgres:test    
    
  end
  
end
