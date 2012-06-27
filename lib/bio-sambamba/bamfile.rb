module Bio

  # Module for reading BAM files
  module Bam

    # Class providing access to BAM files
    class File
     
      # Creates an object for access to BAM file
      def initialize(filename)
        @filename = filename
      end
     
      # SAM header
      def header
        @header ||= Bio::Bam::SamHeader.new(@filename)
      end

      # Returns an AlignmentIterator object for iterating over all alignments in the file
      def alignments
        Bio::Bam::AlignmentIterator.new ['sambamba', '--format=json', @filename]
      end

      # True if index file was found 
      def has_index?
        File::File.exists?(@filename + '.bai') || 
        File::File.exists?(@filename[0...-1] + 'i')
      end

      # Fetches alignments overlapping a region. 
      # Returns an AlignmentIterator object.
      #
      # ---
      # *Arguments*:
      # * _chr_: reference sequence
      # * _region_: a Range representing an interval. Coordinates are 1-based.
      def fetch(chr, region)
        Bio::Bam::AlignmentIterator.new ['sambamba', '--format=json', 
                                         @filename,
                                          "#{chr}:#{region.min}-#{region.max}"]
      end
    end
    
  end
end
