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

        Bio::Command.call_command(@command) do |io|
          io.each do |line|
            raise line unless line[0] == '{'
            yield Bio::Bam::Alignment.new(Oj.load(line))
          end
        end
      end
    end

  end
end
