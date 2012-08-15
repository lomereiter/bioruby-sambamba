module Bio
  module Bam

    # Class for iterating through alignments
    class AlignmentIterator
      include Enumerable
      include SambambaStderrParser

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

      private

      def get_command
        command = @command

        if not @chromosome.nil? then
          if not @region.nil? then
            command.push "#{@chromosome}:#{@region.min}-#{@region.max}"       
          else
            command.push "#{@chromosome}"
          end
        elsif not @region.nil? then
          raise 'must specify a reference when doing a region query'
        end

        command
      end

      public

      # Iterate through all alignments skipping
      # validation checks
      def each
        return enum_for(:each) if not block_given?

        command = get_command

        Bio::Command.call_command_open3(command) do |pin, pout, perr|
          pout.each do |line|
            json = Oj.load(line)
            yield Bio::Bam::Alignment.new(json)
          end
          raise_exception_if_stderr_is_not_empty(perr)
        end
      end

      # Set filter for alignments
      def with_filter(filter)
        iter = self.clone
        iter.command.push('-F')
        iter.command.push(filter.to_s)
        iter
      end

      def select(&block)
        with_filter (Bio::Bam::filter &block)
      end

      def count
        command = get_command
        command.push('-c')
        Bio::Command.call_command_open3(command) do |pin, pout, perr|
          raise_exception_if_stderr_is_not_empty(perr)
          pout.readline.to_i
        end
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
      attr_accessor :command
    end

  end
end
