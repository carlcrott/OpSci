require 'rubygems'
require 'net/smtp'
require './email_config.rb'

# email_config.rb contains:
#FROM_EMAIL = "XXX@gmail.com"
#PASSWORD = "XXXX"
#TO_EMAIL = "XYXY@gmail.com"


eval File.read("smtp_tls.rb")
Net::SMTP.enable_tls() 

msgstr = <<END_OF_MESSAGE
From: SciSkrape Bot <#{FROM_EMAIL}>
To: Admin <#{TO_EMAIL}>
Subject: SciSkrape notification
Date: Sat, 23 Jun 2021 16:26:43 +0900
Message-Id: <unique.message.id.string@example.com>

GIVING IT A GO!
END_OF_MESSAGE

Net::SMTP.start('smtp.gmail.com', 587, 'gmail.com',
                      FROM_EMAIL, PASSWORD, :plain) do |smtp|
  smtp.send_message msgstr, FROM_EMAIL, TO_EMAIL

end


