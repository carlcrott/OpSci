#!/usr/bin/env ruby
require 'rubygems'
require 'mechanize'

agent = Mechanize.new
page = agent.get('http://www.reddit.com/login')
form = page.form_with(:action => %r{post/login})

# Set the username and password
form.user = 'fake_user'
form.passwd = 'fake_password'

# The "remember me" checkbox is called "rem"
p form.class

p form.checkbox_with('rem').class

form.checkbox_with('rem').check
puts %Q{"remember me" is #{form.checkbox_with('rem').checked ? "" : "un"}checked}




















