Given /^the fixture file "(.*?)"$/ do |filename|
  @input = fixture_file(filename)
end

Given /^I put them through the kernel$/ do
  input        = File.read(@input)
  @output, *_  = kernel.run(input)
end

Then /^the output should match the fixture "(.*?)"$/ do |filename|
  fixture_output = File.read(fixture_file(filename)).strip

  @output.should eql(fixture_output)
end

def fixture_file(filename)
  File.expand_path("../../../features/fixtures/#{filename}", __FILE__)
end

def tmp_file(filename)
  File.expand_path("../../../tmp/#{filename}", __FILE__)
end
