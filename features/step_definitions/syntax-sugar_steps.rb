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

Given /^an alignment iterator$/ do
    @alignments = @bam.alignments
end

When /^I use 'select' method of this iterator with a block$/ do
    @selected_reads = @alignments.select { read_name =~ /^EAS2/ }
end

Then /^it should be the same as calling Bio::Bam::filter with this block$/ do
    @filter = Bio::Bam::filter { read_name =~ /^EAS2/ } 
end

Then /^passing it as an argument to the 'with_filter' method$/ do
    # TODO: make comparison function for alignments
    @selected_reads.to_a.length.should == @alignments.with_filter(@filter).to_a.length
end
