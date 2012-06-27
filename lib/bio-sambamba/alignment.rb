module Bio
  module Bam

    # Class representing an alignment record
    class Alignment
      
      # Creates a new object from JSON output of sambamba tool
      def initialize(json)
        @json = json
      end

      # Access a record tag
      def [](tag)
        raise 'tag length must be two' unless tag.length == 2
        @json['tags'][tag]
      end

      # Hash of record tags
      attr_reader :tags if false

      # Name of reference sequence
      attr_reader :reference if false

      # Query template name
      attr_reader :read_name if false

      # 1-based leftmost mapping position
      attr_reader :position if false

      # Mapping quality
      attr_reader :mapping_quality if false

      # CIGAR string
      attr_reader :cigar_string if false

      # Observed template length
      attr_reader :template_length if false

      # Bitwise flag
      attr_reader :flag if false

      # Phred-scaled base quality, an integer array
      # of the same length as the sequence
      attr_reader :quality if false

      # Segment sequence
      attr_reader :sequence if false

      # Reference sequence name of the mate/next segment
      attr_reader :mate_reference if false

      # 1-based leftmost position of the mate/next segment
      attr_reader :mate_position if false

      {'tags' => 'tags',
       'reference' => 'rname',
       'read_name' => 'qname',
       'position' => 'pos',
       'mapping_quality' => 'mapq',
       'cigar_string' => 'cigar',
       'template_length' => 'tlen',
       'flag' => 'flag',
       'quality' => 'qual',
       'sequence' => 'seq',
       'mate_reference' => 'rnext',
       'mate_position' => 'pnext'}.each do |k, v|
        eval <<-DEFINE_READER
          def #{k}
            @json['#{v}']
          end
        DEFINE_READER
      end

      # Template having multiple segments in sequencing
      def is_paired                
        (flag & 0x1) != 0
      end

      # Each segment properly aligned according to the aligner
      def proper_pair              
        (flag & 0x2) != 0
      end

      # Segment unmapped
      def is_unmapped              
        (flag & 0x4) != 0
      end

      # Next segment in the template unmapped
      def mate_is_unmapped         
        (flag & 0x8) != 0
      end

      # Sequence being reverse complemented
      def is_reverse_strand        
        (flag & 0x10) != 0
      end

      # Sequence of the next segment in the template being reversed
      def mate_is_reverse_strand   
        (flag & 0x20) != 0
      end

      # The first segment in the template
      def is_first_of_pair         
        (flag & 0x40) != 0
      end

      # The last segment in the template
      def is_second_of_pair        
        (flag & 0x80) != 0
      end

      # Secondary alignment
      def is_secondary_alignment   
        (flag & 0x100) != 0
      end

      # Not passing quality controls
      def failed_quality_control   
        (flag & 0x200) != 0
      end

      # PCR or optical duplicate
      def is_duplicate             
        (flag & 0x400) != 0
      end
    end

  end
end