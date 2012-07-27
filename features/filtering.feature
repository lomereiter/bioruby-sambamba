Feature: custom filters for BAM data

    In order to filter alignment records faster,
    As a user who deals with a lot of data,
    I want to be able to create custom filters and have them executed
    not in Ruby but in sambamba view tool.

    Background: 
        Given I have a BAM file
          And I have an iterator for alignment records in this file

    Scenario: setting filter for alignments
         When I create a filter with Bio::Bam::filter function
         Then I should be able to pass this filter to the 'with_filter' method of the iterator
          And it should give me a enumerator for those alignments which pass the filter

    Scenario Outline: setting conditions for flags
        When I create a filter with Bio::Bam::filter { flag.<name>.<is_set_or_unset> }
        Then I should get all alignments where flag called <name> <is_set_or_unset> correspondingly.

        Examples:
            |       name       |    is_set_or_unset  |
            |   proper_pair    |      is_set         |
            | mate_is_unmapped |     is_unset        |

    Scenario Outline: setting conditions for integer and string fields
        When I create a filter with Bio::Bam::filter { <field> <comparison_operator> <value> }
        Then I should get all alignments where <comparison_operator> for <field> and <value> is true

        Examples:
            |     field       | comparison_operator |   value   |
            |  mate_position  |        <            |   1.Kbp   |
            | mapping_quality |        >=           |    39     |
            |   read_name     |        >            | 'EAS114_' |

    Scenario Outline: setting conditions for tags
        When I create a filter with Bio::Bam::filter { tag(:<tagname>) <comparison_operator> <value> }
        Then I should get all alignments where tag with name <tagname> exists
        And <comparison_operator> for tag with name <tagname> and <value> is true

        Examples:
            | tagname | comparison_operator | value |
            |   Aq    |         ==          |   72  |
            |   UQ    |         !=          |   0   | 
            |   NM    |         >=          |   3   |

    Scenario Outline: regex matching for tags and string fields
        When I create a filter with Bio::Bam::filter { <field_or_tag> =~ <regex> }
        Then I should get all alignments where <field_or_tag> matches given <regex>

        Examples:
            | field_or_tag |       regex         |
            |  read_name   | /^B7_(?:\d+):+\d+$/ |
            |    cigar     | /[^M\d]/            |

    Scenario Outline: logical operations on filters
        Given I have several <conditions>
         When I enclose them by a <n-ary operation> block
         Then I should get a condition representing <n-ary operation> of those

        Examples:
            |            conditions                                |  n-ary operation   |
            | ["position >= 100.bp", "mate_position <= 200.bp"]    |      union         |
            | ["tag(:NM) == 3", "tag(:UQ) == 42"]                  |    intersection    |         

    Scenario Outline: negation of filter
        Given I have a condition <condition>
         When I enclose it in 'negate' block
         Then I should have a condition representing the same alignments as <'not' equivalent>

         Examples:
            |            condition          |      'not' equivalent          |
            |       flag.paired.is_set      |     flag.paired.is_unset       | 
            |     mapping_quality >= 50     |     mapping_quality < 50       |
