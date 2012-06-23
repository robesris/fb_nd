Given /^I pause$/ do
  puts "Pausing..."
  debugger
  puts "Resuming."
end

When /^I wait briefly$/ do
  sleep 1
end

When /^I wait (\d+) seconds?/ do |num|
  sleep num.to_i
end


