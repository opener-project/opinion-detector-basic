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
    | English  | input.1.kaf           | input.1.out.kaf        |
    | Dutch    | input.1.nl.kaf        | input.1.nl.out.kaf     |
    | English  | input.2.kaf           | input.2.out.kaf        |

