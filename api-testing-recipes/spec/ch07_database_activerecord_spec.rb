load File.dirname(__FILE__) + '/../test_helper.rb'

require 'active_record' # gem install activerecord

class Project < ActiveRecord::Base
end

class Build < ActiveRecord::Base
  belongs_to :project
end

describe "Database with ActiveRecord" do
  include TestHelper

  before(:all) do
    require 'mysql2'        # gem install mysql2

    # the database used in sample is BuildWise
    # recommend set BuildWise first (refer to BuildWise screencasts)
    ActiveRecord::Base.establish_connection(
      :adapter  => 'mysql2', # or 'postgresql' or 'sqlite3'
      :database => 'buildwise_production',
      :username => 'root',
      :password => ENV["MYSQL_PASSWORD"] || "",
      :host =>   'localhost'
    )
  end

  after(:all) do
    ActiveRecord::Base.connection.close
  end
 
  it "ActiveRecord to check database" do
    # debug ENV["MYSQL_PASSWORD"]
    puts Build.count
    longest_build = Build.order("duration desc").first
    debug longest_build.inspect # find out data
    debug longest_build.duration
  end

  it "ActiveRecord Association" do
    longest_build = Build.order("duration desc").first
    expect(longest_build.project.name).to eq("ClinicWise Full Build")
  end
  
end
