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
        obj[0]
      end

      # Sorting order
      def sorting_order
        obj[1]
      end

      # An array of SQLine objects
      def sq_lines
        @sq_lines ||= obj[2].map{|rec| SQLine.new(rec)}
      end

      # An array of RGLine objects
      def rg_lines
        @rg_lines ||= obj[3].map{|rec| RGLine.new(rec)}
      end

      # An array of PGLine objects
      def pg_lines
        @pg_lines ||= obj[4].map{|rec| PGLine.new(rec)}
      end

      private
      def obj
        return @obj unless @obj.nil?
        cmd = ['sambamba', 'view', '-H', '--format', 'msgpack', @filename] + @opts
        line = ''
        Bio::Command.call_command_open3(cmd) do |pin, pout, perr|
          @obj = MessagePack.unpack(pout.read)
          raise_exception_if_stderr_is_not_empty(perr)
        end
        @obj
      end
    end

    # Represents a @SQ line from SAM header
    class SQLine

      # Wrap MessagePack record from sambamba output
      def initialize(obj)
        @obj = obj
      end

      # Reference sequence name
      def sequence_name
        @obj['SN']
      end

      # Reference sequence length
      def sequence_length
        @obj['LN']
      end

      # Genome assembly identifier
      def assembly
        @obj['AS']
      end

      # MD5 checksum of the sequence in uppercase, with gaps and spaces removed
      def md5
        @obj['M5']
      end

      # Species
      def species
        @obj['SP']
      end

      # URI of the sequence
      def uri
        @obj['UR']
      end

    end

    # Represents @RG line from SAM header, i.e. a read group
    class RGLine

      # Wrap MessagePack record from sambamba output
      def initialize(obj)
        @obj = obj
      end

      # Unique read group identifier
      def identifier
        @obj['ID']
      end

      # Name of sequencing center
      def sequencing_center
        @obj['CN']
      end

      # Description
      def description
        @obj['DS']
      end

      # Date the run was produced (ISO8601 date or date/time)
      def date
        @obj['DT']
      end

      # Flow order. The array of nucleotide bases that correspond to the 
      # nucleotides used for each flow of each read. Multi-base flows are 
      # encoded in IUPAC format, and non-nucleotide flows by various other
      # characters.
      def flow_order
        @obj['FO']
      end

      # The array of nucleotide bases that correspond to the key sequence of each read
      def key_sequence
        @obj['KS']
      end

      # Library
      def library
        @obj['LB']
      end

      # Programs used for processing the read group
      def programs
        @obj['PG']
      end

      # Predicted median insert size
      def predicted_insert_size
        @obj['PI']
      end

      # Platform/technology used to produce the reads
      def platform
        @obj['PL']
      end

      # Platform unit (e.g. flowcell-barcode lane for Illumina or slide for SOLiD). Unique identifier.
      def platform_unit
        @obj['PU']
      end

      # Sample
      def sample
        @obj['SM']
      end
    end

    # Represents @PG line from SAM header (program record)
    class PGLine

      # Wrap MessagePack record from sambamba output
      def initialize(obj)
        @obj = obj
      end

      # Unique program record identifier
      def identifier
        @obj['ID']
      end

      # Program name
      def program_name
        @obj['PN']
      end

      # Command line
      def command_line
        @obj['CL']
      end

      # Identifier of previous program in chain
      def previous_program
        @obj['PP']
      end

      # Program version
      def program_version
        @obj['VN']
      end
    end

  end
end
