require 'bio/command'
require 'oj'

module Bio

  module Bam

    class File
      
      def initialize(filename)
        @filename = filename
      end
      
      def header
        @header ||= SamHeader.new(@filename)
      end

      def alignments
        AlignmentIterator.new ['sambamba', '--format=json', @filename]
      end

      def has_index?
        File::File.exists?(@filename + '.bai') || 
        File::File.exists?(@filename[0...-1] + 'i')
      end

      # region must be a range, and coordinates must be 0-based
      def fetch(chr, region)
        AlignmentIterator.new ['sambamba', '--format=json', 
                               @filename,
                               "#{chr}:#{region.min+1}-#{region.max+1}"]
      end
    end

    class SamHeader
      
      def initialize(filename)
        @filename = filename
      end

      def raw_contents
        @raw_contents ||= Bio::Command.query_command(['sambamba', '-H', @filename])
      end

      def version
        @json ||= get_json
        @json['format_version']
      end

      def sorting_order
        @json ||= get_json
        @json['sorting_order']
      end

      def sq_lines
        @json ||= get_json
        @sq_lines ||= @json['sq_lines'].map{|json| SQLine.new(json)}
      end

      def rg_lines
        @json ||= get_json
        @sq_lines ||= @json['rg_lines'].map{|json| RGLine.new(json)}
      end

      def pg_lines
        @json ||= get_json
        @sq_lines ||= @json['pg_lines'].map{|json| PGLine.new(json)}
      end

      private
      def get_json
        @json = Oj.load(Bio::Command.query_command(['sambamba', '-H', '--format=json', @filename]))
      end
    end

    class SQLine
      def initialize(json)
        @json = json
      end

      ['sequence_name', 'sequence_length', 
       'assembly', 'md5', 'species', 'uri'].each do |sq_line_field|
        eval <<-DEFINE_ACCESSOR
          def #{sq_line_field}
            @json['#{sq_line_field}']
          end
        DEFINE_ACCESSOR
      end
    end

    class RGLine
      def initialize(json)
        @json = json
      end

      ['identifier', 'sequencing_center', 'description', 'date',
       'flow_order', 'key_sequence', 'library', 'programs',
       'predicted_insert_size', 'platform', 
       'platform_unit', 'sample'].each do |rg_line_field|
        eval <<-DEFINE_ACCESSOR
          def #{rg_line_field}
            @json['#{rg_line_field}']
          end
        DEFINE_ACCESSOR
      end
    end

    class PGLine
      def initialize(json)
        @json = json
      end

      ['identifier', 'program_name', 'command_line',
       'previous_program', 'program_version'].each do |rg_line_field|
        eval <<-DEFINE_ACCESSOR
          def #{rg_line_field}
            @json['#{rg_line_field}']
          end
        DEFINE_ACCESSOR
      end
    end

    class Alignment
      def initialize(json)
        @json = json
      end

      def [](tag)
        raise 'tag length must be two' unless tag.length == 2
        @json['tags'][tag]
      end

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
        eval <<-DEFINE_ACCESSOR
          def #{k}
            @json['#{v}']
          end
        DEFINE_ACCESSOR
      end

      ### Template having multiple segments in sequencing
      def is_paired                
        (flag & 0x1) != 0
      end

      ### Each segment properly aligned according to the aligner
      def proper_pair              
        (flag & 0x2) != 0
      end

      ### Segment unmapped
      def is_unmapped              
        (flag & 0x4) != 0
      end

      ### Next segment in the template unmapped
      def mate_is_unmapped         
        (flag & 0x8) != 0
      end

      ### Sequence being reverse complemented
      def is_reverse_strand        
        (flag & 0x10) != 0
      end

      ### Sequence of the next segment in the template being reversed
      def mate_is_reverse_strand   
        (flag & 0x20) != 0
      end

      ### The first segment in the template
      def is_first_of_pair         
        (flag & 0x40) != 0
      end

      ### The last segment in the template
      def is_second_of_pair        
        (flag & 0x80) != 0
      end

      ### Secondary alignment
      def is_secondary_alignment   
        (flag & 0x100) != 0
      end

      ### Not passing quality controls
      def failed_quality_control   
        (flag & 0x200) != 0
      end

      ### PCR or optical duplicate
      def is_duplicate             
        (flag & 0x400) != 0
      end
    end

    class AlignmentIterator
      include Enumerable

      def initialize(command)
        @command = command
      end

      def each
        Bio::Command.call_command(@command) do |io|
          io.each do |line|
            yield Alignment.new(Oj.load(line))
          end
        end
      end
    end

  end
end
