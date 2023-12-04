<#
The engineer finds the missing part and installs it in the engine! As the engine
springs to life, you jump in the closest gondola, finally ready to ascend to the
water source.

You don't seem to be going very fast, though. Maybe something is still wrong?
Fortunately, the gondola has a phone labeled "help", so you pick it up and the
engineer answers.

Before you can explain the situation, she suggests that you look out the window.
There stands the engineer, holding a phone in one hand and waving with the
other. You're going so slowly that you haven't even left the station. You exit
the gondola.

The missing part wasn't the only issue - one of the gears in the engine is
wrong. A gear is any * symbol that is adjacent to exactly two part numbers. Its
gear ratio is the result of multiplying those two numbers together.

This time, you need to find the gear ratio of every gear and add them all up so
that the engineer can figure out which gear needs to be replaced.

Consider the same engine schematic again:

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

In this schematic, there are two gears. The first is in the top left; it has
part numbers 467 and 35, so its gear ratio is 16345. The second gear is in the
lower right; its gear ratio is 451490. (The * adjacent to 617 is not a gear
because it is only adjacent to one part number.) Adding up all of the gear
ratios produces 467835.

What is the sum of all of the gear ratios in your engine schematic?
#>

# Get the input data
$InputData = Get-Content "$PSScriptRoot\Inputs.txt"

# Regex patterns
$OneOrMoreDigits = '[\d]+'
$StarChar = '\*'

# Build a list of all of the numbers, their line, index, and length
$Numbers = $InputData | Select-String $OneOrMoreDigits -AllMatches | 
    ForEach-Object {
        foreach($Match in $_.Matches) {
            [PSCustomObject]@{
                Number = $Match.Value -as [int64]
                Line = $_.LineNumber - 1
                Column = $Match.Index
                Length = $Match.Length
            }
        }
    }

# Build a list of all of the star locations
$Stars = $InputData | Select-String $StarChar -AllMatches | 
    ForEach-Object {
        foreach($Match in $_.Matches) {
            [PSCustomObject]@{
                Line = $_.LineNumber - 1
                Column = $Match.Index
            }
        }
    }

function HasNumber {
    # Function to check if a number exists at a given point with built in
    # bounds checking
    param (
        [Parameter(Mandatory)]
        [string[]]
        $Data,
        [Parameter(Mandatory)]
        [int]
        $Row,
        [Parameter(Mandatory)]
        [int]
        $Column
    )
    if ($Row -lt 0 -or $Row -ge $Data.Count) {
        return $false
    }
    if ($Column -lt 0 -or $Column -ge $Data[$Row].Length) {
        return $false
    }
    return $Data[$Row][$Column] -match '[\d]+'
}

function GetMatchAtPoint {
    # Function to get the match that contains the given point
    param (
        [Parameter(Mandatory)]
        [pscustomobject[]]
        $NumberMatches,
        [Parameter(Mandatory)]
        [int]
        $Row,
        [Parameter(Mandatory)]
        [int]
        $Column
    )
    foreach($Match in $NumberMatches) {
        if ($Match.Line -eq $Row -and $Column -ge $Match.Column -and $Column -lt ($Match.Column + $Match.Length)) {
            return $Match
        }
    }
    return $null
}

# Start out with a sum of zero
$GearRatioSum = 0

# Loop through each star. Check the 8 neighbors for numbers. If there are 
# exactly 2 numbers, multiply them together and add them to the sum
foreach ($Star in $Stars) {
    # Build a list of the 8 neighbor points
    $Neighbors = @(
        [pscustomobject]@{Row = $Star.Line - 1; Column = $Star.Column - 1},
        [pscustomobject]@{Row = $Star.Line - 1; Column = $Star.Column},
        [pscustomobject]@{Row = $Star.Line - 1; Column = $Star.Column + 1},
        [pscustomobject]@{Row = $Star.Line; Column = $Star.Column - 1},
        [pscustomobject]@{Row = $Star.Line; Column = $Star.Column + 1},
        [pscustomobject]@{Row = $Star.Line + 1; Column = $Star.Column - 1},
        [pscustomobject]@{Row = $Star.Line + 1; Column = $Star.Column},
        [pscustomobject]@{Row = $Star.Line + 1; Column = $Star.Column + 1}
    )
    # For each point, check if it contains a number, get the match at that point
    # and then select only the unique matches. (as there may be duplicates as 2
    # neighbors may be part of the same number)
    $NeighborNumbers = $Neighbors | ForEach-Object {
        if (HasNumber -Data $InputData -Row $_.Row -Column $_.Column) {
            GetMatchAtPoint -NumberMatches $Numbers -Row $_.Row -Column $_.Column
        }
    } | Select-Object -Unique Number, Line, Column, Length

    # If there are exactly 2 numbers, multiply them together and add them to the
    # GearRationSum
    if ($NeighborNumbers.Count -eq 2) {
        $GearRatioSum += ($NeighborNumbers[0].Number * $NeighborNumbers[1].Number)
    }
}

# Output the sum
$GearRatioSum