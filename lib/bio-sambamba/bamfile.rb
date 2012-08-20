require 'fileutils'

module Bio

  private
  RubyFile = File

  public
  # Module for reading BAM files
  module Bam

    public

    # Class providing access to BAM files
    class File
    
      include FileExistenceChecker

      # Creates an object for access to BAM file
      def initialize(filename)
        @filename = filename
        check_file_existence filename
      end
     
      # SAM header
      def header
        @header ||= Bio::Bam::SamHeader.new(@filename)
      end

      # Returns an AlignmentIterator object for iterating over all alignments in the file
      def alignments
        cmdline = ['sambamba', 'view', '--format', 'msgpack', @filename]
        Bio::Bam::AlignmentIterator.new(cmdline, reference_sequence_names)
      end

      # True if index file was found 
      def has_index?
        fn1 = @filename + '.bai'
        fn2 = @filename.chomp(RubyFile.extname(@filename)) + '.bai'
        RubyFile.exists?(fn1) || RubyFile.exists?(fn2)
      end

      # Fetches alignments overlapping a region. 
      # Returns an AlignmentIterator object.
      #
      # ---
      # *Arguments*:
      # * _chr_: reference sequence
      # * _region_: a Range representing an interval. Coordinates are 1-based.
      def fetch(chr, region)
        cmdline = ['sambamba', 'view', '--format=msgpack', @filename]
        iter = Bio::Bam::AlignmentIterator.new(cmdline, reference_sequence_names)
        iter.chromosome = chr
        iter.region = region
        iter
      end

      def reference_sequences
        @reference_sequences ||= JSON.parse(Bio::Command.query_command ['sambamba', 'view', '-I', @filename])
      end

      def [](chr)
        fetch(chr, nil)
      end

      private
      def reference_sequence_names
        @reference_sequence_names ||= reference_sequences.map {|ref| ref['name']}
      end
    end # class File
    
  end # module Bam
end # module Bio
