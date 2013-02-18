# enable clicking on arbitrary elements (from http://collectiveidea.com/blog/archives/2010/08/03/clicking-any-element-with-cucumber-and-capybara/)

def click_elt(locator)
  msg = "No element found with the content of '#{locator}'"
  page.find_by_id(locator).click
end

Given /^I pause$/ do
  debugger
  puts "Pausing..."
end

When /^I wait briefly$/ do
  sleep 1
end

When /^I wait (\d+) seconds?/ do |num|
  sleep num.to_i
end

Given /^I allow user input?/ do
  puts "Allowing use of the browser..."
  page.find_by_id('debug').set('stop')
  while my_browser && page.find_by_id('debug')[:value] == 'stop' && opponent_browser && page.find_by_id('debug')[:value] == 'stop'
    sleep 1 
  end
end

