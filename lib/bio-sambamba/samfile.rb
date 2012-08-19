module Bio
  # Module for reading SAM files
  module Sam

    # Class providing access to SAM files
    class File
      
      include FileExistenceChecker

      # Creates an object for access to SAM file
      def initialize(filename)
        @filename = filename
        check_file_existence filename
      end

      # SAM header
      def header
        @header ||= Bio::Bam::SamHeader.new(@filename, ['-S'])
      end

      # Returns an AlignmentIterator object for iterating over all alignments in the file
      def alignments
        cmdline = ['sambamba', 'view', '--format', 'msgpack', '-S', @filename],
        Bio::Bam::AlignmentIterator.new(cmdline, reference_sequences)
      end

      def reference_sequences
        @reference_sequences ||= Oj.load(Bio::Command.query_command ['sambamba', 'view', '-I', '-S', @filename])
      end

      private
      def reference_sequence_names
        @reference_sequence_names ||= reference_sequences.map {|ref| ref['name']}
      end
    end

  end
end
