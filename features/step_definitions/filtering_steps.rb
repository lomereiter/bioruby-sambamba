Given /^I have an iterator for alignment records in this file$/ do
    @iter = @bam.alignments
end

When /^I create a filter with Bio::Bam::filter function$/ do
    @filter = Bio::Bam::filter { mapping_quality > 50 }
end

Then /^I should be able to pass this filter to the 'with_filter' method of the iterator$/ do
    @iter.should respond_to(:with_filter).with(1).argument
    @alignments = @iter.with_filter @filter
end

Then /^it should give me a enumerator for those alignments which pass the filter$/ do
    @alignments.each do |read|
      read.mapping_quality.should > 50
    end
end

When /^I create a filter with (.*?{[^}]*?})\s*$/ do |query|
    @filter = eval(query)
end

Then /^I should get all alignments where (.*?) for (\w+?) and (.*?) is true$/ do |op, field, val|
    @bam.alignments.with_filter(@filter).take(100).each do |read|
      eval("read.#{field} #{op} #{val}").should be true
    end
end

Then /^I should get all alignments where tag with name (\w{2}) exists$/ do |tagname|
    @bam.alignments.with_filter(@filter).take(100).each do |read|
      read.tags[tagname].should_not be nil
    end
end

Then /^(.*?) for tag with name (\w{2}) and (.*?) is true$/ do |op, tagname, val|
    @bam.alignments.with_filter(@filter).take(100).each do |read|
      eval("read.tags['#{tagname}'] #{op} #{val}").should be true
    end
end

Then /^I should get all alignments where (\w+) matches given (.*?)$/ do |field, regex|
    @bam.alignments.with_filter(@filter).take(100).each do |read|
      eval("read.#{field}.should =~ #{regex}")
    end
end

Then /^I should get all alignments where flag called (\w+) (\w+) correspondingly.$/ do |flagname, op|
    @bam.alignments.with_filter(@filter).take(100).each do |read|
      read.send(flagname.to_sym).should == (op == 'is_set') 
    end
end

Given /^I have several (.*?)$/ do |conditions|
    @conditions = eval(conditions)
    @filters = @conditions.map {|condition| Bio::Bam::filter { eval(condition) }} 
end

When /^I enclose them by a (\w+) block$/ do |op|
    all = @conditions.join "\n"
    @all_filter = Bio::Bam::filter { eval("#{op} { #{all} }") }
end

Then /^I should get a condition representing (\w+) of those$/ do |op|
    pending
    read_names_c = @filters.map {|f| @bam.alignments.with_filter(f).map(&:read_name).to_a}
    puts read_names_c.map(&:length)
    read_names_f = @bam.alignments.with_filter(@all_filter).map(&:read_name).to_a
    if op == 'union' then
        read_names_c.reduce(&:|).sort.should == read_names_f.uniq.sort
    elsif op == 'intersection'
        read_names_c.reduce(&:&).sort.should == read_names_f.uniq.sort
    else 
        raise 'unknown op: ' + op
    end
end

Given /^I have a flag\.paired\.is_set$/ do
    pending # express the regexp above with the code you wish you had
end

When /^I apply 'not' operator to it$/ do
    pending # express the regexp above with the code you wish you had
end

Then /^I should have a condition representing the same alignments as flag\.paired\.is_unset$/ do
    pending # express the regexp above with the code you wish you had
end

Given /^I have a mapping_quality >= (\d+)$/ do |arg1|
    pending # express the regexp above with the code you wish you had
end

Then /^I should have a condition representing the same alignments as mapping_quality < (\d+)$/ do |arg1|
    pending # express the regexp above with the code you wish you had
end
