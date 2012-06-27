module Bio
  # Module for reading SAM files
  module Sam

    # Class providing access to SAM files
    class File

      # Creates an object for access to SAM file
      def initialize(filename)
        @filename = filename
      end

      # SAM header
      def header
        @header ||= Bio::Bam::SamHeader.new(@filename, ['-S'])
      end

      # Returns an AlignmentIterator object for iterating over all alignments in the file
      def alignments
        Bio::Bam::AlignmentIterator.new ['sambamba', '--format=json', '-S', @filename]
      end
    end

  end
end