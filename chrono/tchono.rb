# require 'safariwatir'dd
require 'watir'
require 'watir-webdriver'
require 'debugger'

browser = Watir::Browser.new
user = 'alan.moran'
password = 'hjSDAi198s'
browser.goto 'http://txchrono.altoros.com:8182/'
browser.text_field(:id, 'Login1_UserName').set user
browser.text_field(:id, 'Login1_Password').set password
browser.button(:name, 'Login1$Login').click
browser.elements(:class, 'toggle_expand').each{ |e| e.click }
pr = browser.element('parentid', '392')
debugger
pr.elements(:type, 'text')
sleep 3

puts 'Bye'
