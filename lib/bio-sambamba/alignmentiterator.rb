module Bio
  module Bam

    # Class for iterating through alignments
    class AlignmentIterator
      include Enumerable

      # Creates a new AlignmentIterator object which will
      # parse JSON outputted by a specified command.
      def initialize(command)
        @command = command
      end

      # Iterate only through valid alignments
      def each_valid

        return enum_for(:each_valid) if not block_given?

        command = @command
        if command.index('--valid').nil?
          command.push '--valid'
        end

        AlignmentIterator.new(command).each do |read|
          yield read
        end
      end

      # Iterate through all alignments skipping
      # validation checks
      def each

        return enum_for(:each) if not block_given?

        command = @command

        if not chromosome.nil? then
          if not region.nil? then
            command.push "#{chromosome}:#{region.min}-#{region.max}"       
          else
            command.push "#{chromosome}"
          end
        elsif not region.nil? then
          raise 'must specify a reference when doing a region query'
        end

        Bio::Command.call_command(command) do |io|
          io.each do |line|
            raise line unless line[0] == '{'
            yield Bio::Bam::Alignment.new(Oj.load(line))
          end
        end
      end

      # Set filter for alignments
      def with_filter(filter)
        command = @command
        command.push('-F')
        command.push(filter.to_s)
        AlignmentIterator.new command
      end

      def select(&block)
        puts 'call select'
        with_filter (Bio::Bam::filter &block)
      end

      def referencing(chr)
        iter = self.clone
        iter.chromosome = chr
        iter
      end

      def overlapping(reg)
        iter = self.clone
        iter.region = reg
        iter
      end

      def [](reg)
        overlapping(reg)
      end

      def clone
        iter = AlignmentIterator.new @command
        iter.chromosome = chromosome
        iter.region = region
        iter
      end

      attr_accessor :chromosome
      attr_accessor :region
    end

  end
end
