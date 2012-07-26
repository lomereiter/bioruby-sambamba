Given /^the associated BAI file$/ do
    @bam.has_index?.should be_true
end

When /^I say "(.*?)"$/ do |expr|
    bam = @bam
    @alignments = eval(expr)
end

Then /^I should get an enumerator for alignments$/ do
    @alignments.first.should be_instance_of Bio::Bam::Alignment
end

Then /^each of them should have reference sequence "(.*?)"$/ do |sequence|
    @alignments.each do |read|
        read.reference.should == sequence
    end
end

Then /^each of them should overlap region \[(\d+), (\d+)\] \(1-based\)$/ do |begpos, endpos|
    @alignments.each do |read|
        read.position.should <= endpos.to_i
        (read.position + read.bases_covered).should >= begpos.to_i
    end
end
