load File.dirname(__FILE__) + '/../test_helper.rb'

describe "Email" do
  include TestHelper

  before(:all) do    
  end

  after(:all) do
  end

  it "SMTP Send Email" do
    # identify SMTP host and port, default 25  
    require 'net/smtp'
raw_message  = <<END_OF_MESSAGE
From: AgileWay <mailer@agileway.com.au>
To:  <john@wiseclinic.com>
Subject: Welcome to ClinicWise
Date: Sat, 25 Jul 2015 13:16:42 +1000
Message-Id: <unique.message.id.string@example.com>

Welcome the best online clinic management system.
END_OF_MESSAGE

    Net::SMTP.start('10.246.177.41', 25) do |smtp|
      smtp.send_message raw_message,
      "mailer@agileway.com.au",
      "john@wiseclinic.com"
    end
    
  end


  it "SMTP: Send HTML Email to multiple recipents" do
    # identify SMTP host and port, default 25
    require 'net/smtp'
    
html_message = <<MESSAGE_END
From: Private Person <me@fromdomain.com>
To: A Test User <test@todomain.com>
MIME-Version: 1.0
Content-type: text/html
Subject: SMTP HTML e-mail test

<h1>This is headline.</h1>
<p>This is <b>HTML</b> message.</p>
MESSAGE_END

    Net::SMTP.start('127.0.0.1', 1025) do |smtp|
      smtp.send_message html_message,
      "mailer@agileway.com.au",
      [ "john@wiseclinic.com", "cc@wiseclinic.com", "bcc@example.org"]
    end
    
  end
  
  it "SMTP Email with passord using Gmail" do
    require 'net/smtp'

  # Net::SMTP.smtp.start('my.smtp.host', 25, 'mail.from.domain', username, password, :plain) do |smtp|                                                                       
  #   smtp.send_message data, fromAddress, toAddress
  # end

message_body = <<END_OF_EMAIL
From: Your Name <agileway@gmail.com>
To: Other Email <other.email@somewhere.com>
Subject: text message

This is a test message.
END_OF_EMAIL

    server = 'smtp.gmail.com'
    mail_from_domain = 'gmail.com'
    port = 587      # or 25 - double check with your provider
    username = 'agileway@gmail.com'
    password = # ENV["YOUR_GMAIL_PASSWORD"] 

    smtp = Net::SMTP.new(server, port)
    smtp.enable_starttls_auto
    smtp.start(server, username, password, :plain)
    smtp.send_message(message_body, 'agileway@gmail.com', 'courtneyzhan@gmail.com')    
  end
  
  it "Send email with Mail Gem" do
    require 'mail'

    Mail.defaults do
      delivery_method :smtp, :address => "127.0.0.1", :port => 1025
    end
    
    mail = Mail.new do
      from    'agileway@gmail.com'
      to      'john@wiseclinic.com'
      subject 'Welcome to ClinicWise'
      body    "Wise Choice, ..." 
    end

    mail.deliver    
    
    # attachment    
    mail = Mail.new do
      to      'natalie@wiseclinic.com'
      from    'AgileWay Support <agileway@gmail.com>'
      subject 'First multipart email sent with Mail'

      text_part do
        body 'This is plain text'
      end

      html_part do
        content_type 'text/html; charset=UTF-8'
        body '<h1>This is HTML</h1>'
      end
      
    end
    
    mail.add_file( File.join(File.dirname(__FILE__), "..", "testdata", "clinicwise_logo.png")  )
    mail.add_file( File.join(File.dirname(__FILE__), "..", "testdata", "sample_invoice.pdf")  )    
    mail.deliver    
  end
  

  it "POP3 Check Email" do
    require 'mail'
    Mail.defaults do
      retriever_method :pop3, 
                       :address    => "pop.gmail.com",
                       :port       => 995,
                       :user_name  => 'testwisely01@gmail.com',
                       :password   => ENV["YOUR_GMAIL_PASSWORD"],
                       :enable_ssl => true
    end
    
    Mail.first # first unread email
    # NOTE: next time you run, it changes as POP3 downloaded will mark as read
    debug Mail.first.subject
    Mail.last  # last unread email        
  end
  
  
  it "Read an email" do
    require 'mail'  # gem install mail
    mail = Mail.read(File.join(File.dirname(__FILE__), "..", "testdata", "message.eml"))

    puts mail.from 
    puts mail.envelope_from   #=> 'mikel@test.lindsaar.net'
    puts mail.to              #=> 'john@wiseclinic.com'
    puts mail.cc              #=>
    puts mail.subject         #=> "Welcome to ClinicWise"
    puts mail.date.to_s       #=> '2015-08-07T14:16:42+10:00'
    puts mail.message_id      #=> '<4D6AA7EB.6490534@xxx.xxx>'
    puts mail.body.decoded    #=> 'Wise Choice, ...
        
  end

  it "Read a Multipart email with attachments" do
    require 'mail'  # gem install mail
    mail = Mail.read(File.join(File.dirname(__FILE__), "..", "testdata", "multipart.eml"))
    
    expect(mail.parts.count).to eq(4)
    expect(mail.parts[0].body.decoded).to eq("This is plain text")
    expect(mail.parts[1].body.decoded).to eq("<h1>This is HTML</h1>")        
    expect(mail.parts[2].filename).to eq("clinicwise_logo.png")
    expect(mail.parts.last.filename).to eq("sample_invoice.pdf")
  end

end
