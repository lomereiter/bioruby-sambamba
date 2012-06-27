Before do
  # this file is known to contain some invalid records
  @tagsbam = Bio::Bam::File.new './test/data/tags.bam'
end

Given /^I have an alignment from a BAM file$/ do
  @alignment = @tagsbam.alignments.to_a[32]
end

When /^I call 'valid\?' method$/ do
  pending
#  @is_valid = @alignment.valid?
end

Then /^it should return whether it is valid or not$/ do
  @is_valid.should be_true
end

Given /^I have a BAM file$/ do
end

When /^I want to iterate over its records$/ do
  @records = @tagsbam.alignments
end

Then /^I should have an option to skip invalid ones$/ do
  @records.should respond_to(:each_valid).with(0).arguments
end

Then /^all the reads in this case should be valid$/ do
  count = 0
  @records.each_valid {|read| count += 1 }
  count.should == 411
end
