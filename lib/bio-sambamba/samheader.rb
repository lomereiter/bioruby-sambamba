module Bio
  module Bam

    # Represents SAM header
    class SamHeader
      include SambambaStderrParser
     
      # Creates a new SamHeader object for a specified file,
      # specifying additional options to pass to sambamba tool
      def initialize(filename, opts=[])
        @filename = filename
        @opts = opts
      end

      # Raw text of SAM header
      def raw_contents
        if @raw_contents.nil? then
          cmd = ['sambamba', 'view', '-H', @filename] + @opts
          Bio::Command.call_command_open3(cmd) do |pin, pout, perr|
            @raw_contents = pout.read
            raise_exception_if_stderr_is_not_empty(perr)
          end
        end
        @raw_contents
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

      # @return [PGLine] array of @PG lines
      def pg_lines
        @json ||= get_json
        @sq_lines ||= @json['pg_lines'].map{|json| PGLine.new(json)}
      end

      private
      # Calls sambamba to get underlying JSON object
      def get_json
        cmd = ['sambamba', 'view', '-H', '--format=json', @filename] + @opts
        line = ''
        Bio::Command.call_command_open3(cmd) do |pin, pout, perr|
          line = pout.read
          raise_exception_if_stderr_is_not_empty(perr)
        end
        @json = Oj.load(line)
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

  end
end
