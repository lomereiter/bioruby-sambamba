Feature: syntax sugar

    In order to enjoy writing my scripts,
    As a Rubyista,
    I want some syntax sugar.

    Scenario: human-readable requests
        Given I have a BAM file
          And the associated BAI file
         When I say "bam.alignments.referencing('chr1').overlapping(1.Kbp .. 2.Kbp)"
         Then I should get an enumerator for alignments
          And each of them should have reference sequence "chr1"
          And each of them should overlap region [1000, 2000] (1-based)

    Scenario: shortcuts for programmers who are too lazy to type that much
        Given I have a BAM file
          And the associated BAI file
         When I say "bam['chr1'][500.bp .. 1.Kbp]"
         Then I should get an enumerator for alignments
          And each of them should have reference sequence "chr1"
          And each of them should overlap region [500, 1000] (1-based)

    Scenario: shortcut for filtering
        Given I have a BAM file
          And an alignment iterator
         When I use 'select' method of this iterator with a block
         Then it should be the same as calling Bio::Bam::filter with this block
          And passing it as an argument to the 'with_filter' method
