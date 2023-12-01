<#
Your calculation isn't quite right. It looks like some of the digits are
actually spelled out with letters: one, two, three, four, five, six, seven,
eight, and nine also count as valid "digits".

Equipped with this new information, you now need to find the real first and last
digit on each line. For example:

two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen

In this example, the calibration values are 29, 83, 13, 24, 42, 14, and 76. 
Adding these together produces 281.

What is the sum of all of the calibration values?
#>

# Get the input data
$InputData = Get-Content "$PSScriptRoot\Input.txt"

# Map from number-strings to numbers
$NumberMap = @{
    'one'   = 1
    'two'   = 2
    'three' = 3
    'four'  = 4
    'five'  = 5
    'six'   = 6
    'seven' = 7
    'eight' = 8
    'nine'  = 9
}

# In a pipeline, calculate the required sum
$InputData | ForEach-Object {
    
    # Capture the current line so we can modify it, consequence-free
    $Text = $_

    # We cannot do something like the below, because number-strings can share
    # letters. Consider 'zoneight234' and 'xtwone3four'. Depending on the order
    # in which we did any naive string replacement, we'd get different answers.

    ############################################################################
    # foreach ($Number in $NumberMap.Keys) {
    #     $Text = $Text -replace $Number, $NumberMap[$Number]
    # }
    ############################################################################

    # Instead, look through the string and build a list of all matches and where
    # they occur.
    $Matched = @()
    foreach ($Number in $NumberMap.Keys) {
        # Find all the matches, not just the first, like 'IndexOf()' would
        $MatchedStrings = Select-String $Text -Pattern $Number -AllMatches

        # For each match, record the index and the number it matched
        foreach ($Match in $MatchedStrings.Matches) {
            $Matched += [PSCustomObject]@{
                Index = $Match.Index
                Number  = $NumberMap[$Number]
            }
        }
    }

    # Loop backwards through the matches and insert the matched digit at that 
    # index. So 'xtwone3four' would become 'x2tw1one34four'. Then when we later 
    # replace all non-digit characters, we'll get '2134' and can then take the 
    # first and last to get the correct value of 24.
    $Matched | Sort-Object -Property Index -Descending | ForEach-Object {
        $Text = $Text.Insert($_.Index, $_.Number)
    }

    # Remove all the remaining non-digit characters
    $Digits = $Text -replace '[^0-9]'

    # Take the first and last digit, combine them, convert to an integer and
    # Pass this down the pipeline.
    "$($Digits[0])$($Digits[-1])" -as [int64]

} | Measure-Object -Sum | Select-Object -ExpandProperty Sum