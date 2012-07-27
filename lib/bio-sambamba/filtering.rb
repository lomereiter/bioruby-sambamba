module Bio
  module Bam

    def self.filter &block
      AlignmentFilter.new &block
    end

    class AlignmentFilter
      def to_s
        @expression
      end

      def initialize &block
        qb = QueryBuilder.new
        qb.instance_eval &block
        @expression = qb.expression
      end
    end

    private
    BINARY_OPS = [:>, :<, :>=, :<=, :==, :!=] 

    module ComparisonQueries
      BINARY_OPS.each do |operator|
        self.send :define_method, operator do |other|
          if other.kind_of? String then
            other = '\'' + other.gsub('\'', '\\\\\'') + '\''
          end
          @querybuilder.subexpressions << "#{@name} #{operator} #{other}"
        end
      end
    end

    # see comment above for NumberQueries
    module StringQueries
      include ComparisonQueries
      def =~ regex
        raise 'operand must be Regexp' unless regex.kind_of? Regexp
        @querybuilder.subexpressions << "#{@name} =~ #{regex.inspect}"
      end
    end

    module FlagQueries
      def is_set
        @querybuilder.subexpressions << "#{@name}"
      end

      def is_unset
        @querybuilder.subexpressions << "not #{@name}"
      end
    end

    class QueryBuilder
      attr_accessor :subexpressions

      def initialize
        @subexpressions = []
        class << @subexpressions
          def pjoin str
            self.map{|expr| '(' + expr + ')'}.join str
          end
        end
      end

      def flag
        FlagQueryBuilder.new(self)
      end

      def tag tagname
        TagQueryBuilder.new(self, tagname)
      end

      @@default_value = { :ref_id          =>  -1,
                          :mate_ref_id     =>  -1,
                          :position        =>   0,
                          :mate_position   =>   0,
                          :template_length =>   0,
                          :mapping_quality => 255
                        }

      [:ref_id, :mate_ref_id,
       :position, :mate_position,
       :mapping_quality,
       :sequence_length,
       :template_length].each do |integer_field|

        self.send :define_method, integer_field do
          nb = NumberQueryBuilder.new(self, integer_field)

          if not @@default_value[integer_field].nil?
            class << nb
              def is_unknown
                expr = "#{@name} == #{@@default_value[@name]}"
                @querybuilder.subexpressions << expr
              end
            end
          end

          nb
        end

      end

      [:read_name, :sequence, :cigar].each do |string_field|
        self.send :define_method, string_field do
          StringQueryBuilder.new(self, string_field)
        end
      end

      def union &block
        qb = QueryBuilder.new
        qb.instance_eval &block
        @subexpressions << (qb.subexpressions.pjoin ' or ')
        nil
      end

      def intersection &block
        qb = QueryBuilder.new
        qb.instance_eval &block
        @subexpressions << (qb.subexpressions.pjoin ' and ')
      end

      def expression
        subexpressions.pjoin ' and '
      end
    end

    class FlagQueryBuilder
      include FlagQueries

      def initialize(querybuilder)
        @querybuilder = querybuilder
      end

      [:unmapped, :mate_is_unmapped, :paired, :proper_pair,
       :first_of_pair, :second_of_pair, :reverse_strand,
       :mate_is_reverse_strand, :secondary_alignment,
       :failed_quality_control, :duplicate].each do |flagname|
        self.send :define_method, flagname do
          @name = flagname
          self
        end
      end
    end

    class TagQueryBuilder
      include ComparisonQueries
      include StringQueries
      def initialize(querybuilder, tagname)
        @querybuilder = querybuilder
        @name = '[' + tagname.to_s + ']'
      end
    end

    class NumberQueryBuilder
      include ComparisonQueries
      BINARY_OPS.each do |op|
        self.send :define_method, op do |rhs|
          if not rhs.kind_of? Integer then
            raise "right-hand side must be an integer, not #{rhs.inspect}"
          end
          # 1-based -> 0-based
          if @name == :position || @name == :mate_position then
            rhs -= 1
          end
          super(rhs)
        end
      end

      def initialize(querybuilder, symbol)
        @querybuilder = querybuilder
        @name = symbol
      end
    end

    class StringQueryBuilder
      include StringQueries

      BINARY_OPS.each do |op|
        self.send :define_method, op do |rhs|
          if not rhs.kind_of? String then
            raise "right-hand side must be a string, not #{rhs.inspect}"
          end
          super(rhs)
        end
      end

      def initialize(querybuilder, symbol)
        @querybuilder = querybuilder
        @name = symbol
      end
    end

  end
end
