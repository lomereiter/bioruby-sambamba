require 'bio/command'
require 'oj'

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
        @header ||= SamHeader.new(@filename, ['-S'])
      end

      # Returns an AlignmentIterator object for iterating over all alignments in the file
      def alignments
        AlignmentIterator.new ['sambamba', '--format=json', '-S', @filename]
      end
    end
  end

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
        @header ||= SamHeader.new(@filename)
      end

      # Returns an AlignmentIterator object for iterating over all alignments in the file
      def alignments
        AlignmentIterator.new ['sambamba', '--format=json', @filename]
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
        AlignmentIterator.new ['sambamba', '--format=json', 
                               @filename,
                               "#{chr}:#{region.min}-#{region.max}"]
      end
    end

    # Represents SAM header
    class SamHeader
     
      # Creates a new SamHeader object for a specified file,
      # specifying additional options to pass to sambamba tool
      def initialize(filename, opts=[])
        @filename = filename
        @opts = opts
      end

      # Raw text of SAM header
      def raw_contents
        @raw_contents ||= Bio::Command.query_command(['sambamba', '-H', @filename] + @opts)
      end

      # Format version
      def version
        @json ||= get_json
        @json['format_version']
      end

      # Sorting order
      def sorting_order
        @json ||= get_json
        @json['sorting_order']
      end

      # An array of SQLine objects
      def sq_lines
        @json ||= get_json
        @sq_lines ||= @json['sq_lines'].map{|json| SQLine.new(json)}
      end

      # An array of RGLine objects
      def rg_lines
        @json ||= get_json
        @sq_lines ||= @json['rg_lines'].map{|json| RGLine.new(json)}
      end

      # An array of PGLine objects
      def pg_lines
        @json ||= get_json
        @sq_lines ||= @json['pg_lines'].map{|json| PGLine.new(json)}
      end

      private
      # Calls sambamba to get underlying JSON object
      def get_json
        command = ['sambamba', '-H', '--format=json', @filename] + @opts
        @json = Oj.load(Bio::Command.query_command(command))
      end
    end

    # Represents a @SQ line from SAM header
    class SQLine

      # Wrap JSON object from sambamba output
      def initialize(json)
        @json = json
      end

      # Reference sequence name
      attr_reader :sequence_name if false

      # Reference sequence length
      attr_reader :sequence_length if false

      # Genome assembly identifier
      attr_reader :assembly if false

      # MD5 checksum of the sequence in uppercase, with gaps and spaces removed
      attr_reader :md5 if false

      # Species
      attr_reader :species if false

      # URI of the sequence
      attr_reader :uri if false

      ['sequence_name', 'sequence_length', 
       'assembly', 'md5', 'species', 'uri'].each do |sq_line_field|
        eval <<-DEFINE_READER
          def #{sq_line_field}
            @json['#{sq_line_field}']
          end
        DEFINE_READER
      end
    end

    # Represents @RG line from SAM header, i.e. a read group
    class RGLine

      # Wrap JSON object from sambamba output
      def initialize(json)
        @json = json
      end

      # Unique read group identifier
      attr_reader :identifier if false

      # Name of sequencing center
      attr_reader :sequencing_center if false

      # Description
      attr_reader :description if false

      # Date the run was produced (ISO8601 date or date/time)
      attr_reader :date if false

      # Flow order. The array of nucleotide bases that correspond to the 
      # nucleotides used for each flow of each read. Multi-base flows are 
      # encoded in IUPAC format, and non-nucleotide flows by various other
      # characters.
      attr_reader :flow_order if false

      # The array of nucleotide bases that correspond to the key sequence of each read
      attr_reader :key_sequence if false

      # Library
      attr_reader :library if false

      # Programs used for processing the read group
      attr_reader :programs if false

      # Predicted median insert size
      attr_reader :predicted_insert_size if false

      # Platform/technology used to produce the reads
      attr_reader :platform if false

      # Platform unit (e.g. flowcell-barcode.lane for Illumina or slide for SOLiD). Unique identifier.
      attr_reader :platform_unit if false

      # Sample
      attr_reader :sample if false

      ['identifier', 'sequencing_center', 'description', 'date',
       'flow_order', 'key_sequence', 'library', 'programs',
       'predicted_insert_size', 'platform', 
       'platform_unit', 'sample'].each do |rg_line_field|
        eval <<-DEFINE_READER
          def #{rg_line_field}
            @json['#{rg_line_field}']
          end
        DEFINE_READER
      end
    end

    # Represents @PG line from SAM header (program record)
    class PGLine

      # Wrap JSON object from sambamba output
      def initialize(json)
        @json = json
      end

      # Unique program record identifier
      attr_reader :identifier if false

      # Program name
      attr_reader :program_name if false

      # Command line
      attr_reader :command_line if false

      # Identifier of previous program in chain
      attr_reader :previous_program if false

      # Program version
      attr_reader :program_version if false

      ['identifier', 'program_name', 'command_line',
       'previous_program', 'program_version'].each do |rg_line_field|
        eval <<-DEFINE_READER
          def #{rg_line_field}
            @json['#{rg_line_field}']
          end
        DEFINE_READER
      end
    end

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

    # Class for iteration over alignments
    class AlignmentIterator
      include Enumerable

      # Creates a new AlignmentIterator object which will
      # parse JSON outputted by a specified command.
      def initialize(command)
        @command = command
      end

      # Iterate only through valid alignments
      def each_valid

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
        Bio::Command.call_command(@command) do |io|
          io.each do |line|
            yield Alignment.new(Oj.load(line))
          end
        end
      end
    end

  end
end
