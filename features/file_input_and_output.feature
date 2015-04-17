Feature: Using files as input and output
  In order to extract opinions
  Using a file as an input
  Using a file as an output

  Scenario Outline: Extract opinions from KAF
    Given the fixture file "<input_file>"
    And I put them through the kernel
    Then the output should match the fixture "<output_file>"
  Examples:
    | language | input_file            | output_file            |
    | English  | input.en.kaf          | output.en.kaf          |
    | English  | input_with_mods.en.kaf | output_with_mods.en.kaf |
    | English  | input_with_mods2.en.kaf | output_with_mods2.en.kaf |
    | Dutch    | input.nl.kaf          | output.nl.kaf          |
    | German   | input.de.kaf          | output.de.kaf          |
    | French   | input.fr.kaf          | output.fr.kaf          |
    | Italian  | input.it.kaf          | output.it.kaf          |
    | Spanish  | input.es.kaf          | output.es.kaf          |


