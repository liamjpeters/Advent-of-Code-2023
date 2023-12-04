<#
You and the Elf eventually reach a gondola lift station; he says the gondola
lift will take you up to the water source, but this is as far as he can bring
you. You go inside.

It doesn't take long to find the gondolas, but there seems to be a problem:
they're not moving.

"Aaah!"

You turn around to see a slightly-greasy Elf with a wrench and a look of
surprise. "Sorry, I wasn't expecting anyone! The gondola lift isn't working
right now; it'll still be a while before I can fix it." You offer to help.

The engineer explains that an engine part seems to be missing from the engine,
but nobody can figure out which one. If you can add up all the part numbers in
the engine schematic, it should be easy to work out which part is missing.

The engine schematic (your puzzle input) consists of a visual representation of
the engine. There are lots of numbers and symbols you don't really understand,
but apparently any number adjacent to a symbol, even diagonally, is a "part
number" and should be included in your sum. (Periods (.) do not count as a
symbol.)

Here is an example engine schematic:

467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598..

In this schematic, two numbers are not part numbers because they are not
adjacent to a symbol: 114 (top right) and 58 (middle right). Every other number
is adjacent to a symbol and so is a part number; their sum is 4361.

Of course, the actual engine schematic is much larger. What is the sum of all of
the part numbers in the engine schematic?
#>

# Get the input data
$InputData = Get-Content "$PSScriptRoot\Inputs.txt"

# How many lines are there?
$NumRows = $InputData.Count

# How many characters are there per line?
$NumCols = $InputData[0].Length

# Regex patterns
$OneOrMoreDigits = '[\d]+'
$NotANumberOrPeriod = '[^\d.]'

# Start out with a sum of zero
$Sum = 0

# For each line, find all the numbers and their bounds (start and end)
# for each match, check if there is a symbol adjacent to it. If there is
# add it to the sum.
for ($i = 0; $i -lt $NumRows; $i++) {

    # Find all the numbers and their bounds
    $Matched = Select-String -InputObject $InputData[$i] -Pattern $OneOrMoreDigits -AllMatches |
        Select-Object -Expand Matches | 
        Select-Object Value, Index, Length

    # If there were no matches on this line, skip to the next one
    if ($Matched.Count -eq 0) {
        continue
    }

    # For each match on this line, check if there is a symbol adjacent to it.
    # If there is, add it to the sum.
    foreach($Match in $Matched) {

        # Build a string that is all the characters that surround the match
        $BoundsString = [System.Text.StringBuilder]::new()

        # If the match isn't the very start of the line, there's a character to
        # the left - Add that to our string.
        if ($Match.Index -gt 0) {
            $BoundsString.Append($InputData[$i][$Match.Index - 1]) | Out-Null
        }

        # If the match doesn't stop at the end of the line, there's a character
        # to the right - Add that to our string.
        if ($Match.Index + $Match.Length -lt $NumCols) {
            $BoundsString.Append($InputData[$i][$Match.Index + $Match.Length]) | Out-Null
        }

        # If we're not on the first line, there's a line above us. Add all the
        # characters from the top-left to the top-right. Being sure to not go
        # negative as this will wrap and cause undesired behaviour.
        if ($i -gt 0) {
            $BoundsString.Append($InputData[$i - 1][(
                [Math]::Max($Match.Index - 1, 0)
            )..(
                [Math]::Min($Match.Index + $Match.Length, $NumCols - 1)
            )] -join '') | Out-Null
        }

        # If we're not on the last line, there's a line below us. Add all the
        # characters from the bottom-left to the bottom-right. Being sure to not
        # go negative as this will wrap and cause undesired behaviour.
        if ($i -lt ($NumRows - 1)) {
            $BoundsString.Append($InputData[$i + 1][(
                [Math]::Max($Match.Index - 1, 0)
            )..(
                [Math]::Min($Match.Index + $Match.Length, $NumCols - 1)
            )] -join '') | Out-Null
        }

        # Check our built string for any characters that aren't numbers or
        # periods. If they match, add the number to the sum.
        if ($BoundsString.ToString() -match $NotANumberOrPeriod) {
            $Sum += $Match.Value -as [int64]
        }
    }
}

# Output the sum
$Sum