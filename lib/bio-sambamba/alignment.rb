module Bio
  module Bam

    # Class representing an alignment record
    class Alignment
      
      # Creates a new object from MessagePack record
      def initialize(obj, reference_sequence_names)
        @obj = obj
        @reference = reference_sequence_names[ref_id]
        @mate_reference = reference_sequence_names[mate_ref_id]
      end

      # Access a record tag
      def [](tag)
        raise 'tag length must be two' unless tag.length == 2
        tags[tag]
      end

      def ==(read)
        read.obj == obj
      end

      # Hash of record tags
      def tags
        obj[12]
      end

      # ID of reference sequence
      def ref_id
        obj[2]
      end

      # Query template name
      def read_name
        obj[0]
      end

      # 1-based leftmost mapping position
      def position
        obj[3]
      end

      # Mapping quality
      def mapping_quality
        obj[4]
      end

      # CIGAR: pairs of operations and lengths, 
      # or nil if information is not available
      def cigar_operations
        return nil if obj[5].nil?
        obj[6].chars.zip obj[5]
      end

      # CIGAR string
      def cigar
        return '*' if cigar_operations.nil?
        cigar_operations.reduce(''){|s, op_len| s + op_len[0] + op_len[1].to_s}
      end

      # Observed template length
      def template_length
        obj[9]
      end

      # Bitwise flag
      def flag
        obj[1]
      end

      # Phred-scaled base quality, an integer array
      # of the same length as the sequence
      def quality
        obj[11].bytes.to_a
      end

      # Segment sequence
      def sequence
        obj[10]
      end

      # Reference sequence name of the mate/next segment
      def mate_ref_id
        obj[7]
      end

      # 1-based leftmost position of the mate/next segment
      def mate_position
        obj[8]
      end

      # The number of reference bases covered
      def bases_covered
        return 0 if cigar_operations.nil?
        cigar_operations.reduce(0) {|res, op| 
          res += op[1] unless ('M=XDN'.index op[0]).nil?
          res
        }
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

      # Reference sequence name
      attr_reader :reference

      # Mate reference sequence name
      attr_reader :mate_reference

      private
      attr_accessor :obj

    end

  end
end
