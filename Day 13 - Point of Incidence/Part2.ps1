<#
You resume walking through the valley of mirrors and - SMACK! - run directly 
into one. Hopefully nobody was watching, because that must have been pretty 
embarrassing.

Upon closer inspection, you discover that every mirror has exactly one smudge: 
exactly one . or # should be the opposite type.

In each pattern, you'll need to locate and fix the smudge that causes a
different reflection line to be valid. (The old reflection line won't
necessarily continue being valid after the smudge is fixed.)

Here's the above example again:

#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#

The first pattern's smudge is in the top-left corner. If the top-left # were 
instead ., it would have a different, horizontal line of reflection:

1 ..##..##. 1
2 ..#.##.#. 2
3v##......#v3
4^##......#^4
5 ..#.##.#. 5
6 ..##..##. 6
7 #.#.##.#. 7

With the smudge in the top-left corner repaired, a new horizontal line of
reflection between rows 3 and 4 now exists. Row 7 has no corresponding reflected
row and can be ignored, but every other row matches exactly: row 1 matches row
6, row 2 matches row 5, and row 3 matches row 4.

In the second pattern, the smudge can be fixed by changing the fifth symbol on
row 2 from . to #:

1v#...##..#v1
2^#...##..#^2
3 ..##..### 3
4 #####.##. 4
5 #####.##. 5
6 ..##..### 6
7 #....#..# 7

Now, the pattern has a different horizontal line of reflection between rows 1
and 2.

Summarize your notes as before, but instead use the new different reflection
lines. In this example, the first pattern's new horizontal line has 3 rows above
it and the second pattern's new horizontal line has 1 row above it, summarizing
to the value 400.

In each pattern, fix the smudge and find the different line of reflection. What
number do you get after summarizing the new reflection line in each pattern in
your notes?
#>

# Get the input data
$InputData = Get-Content "$PSScriptRoot\InputData.txt"

# Create a list of grids/patterns
$Grids = @()

# Keep track of the last blank line we saw
$LastBlankLine = 0

$Index = 0
# Loop over all the lines of the input data.
for ($i = 0; $i -lt $InputData.Count; $i++) {
    $Line = $InputData[$i]
    $IsLastLine = $i -eq $InputData.Count - 1

    # When we are on a blank line, or the last line, we create a new grid
    # based on the lines we have seen since the last blank line.
    if ([string]::IsNullOrWhiteSpace($Line) -or $IsLastLine){
        $EndOn = if ($IsLastLine) { $i } else { $i - 1 }
        $Grids += [PSCustomObject]@{
            Id = $Index++
            Pattern = $InputData[$LastBlankLine..$EndOn]
            Symmetry = 'Unknown'
            MirrorNum = -1
            NumbersBefore = -1
        }
        $LastBlankLine = $i + 1
    }
}

function Find-LineOfReflection ([Object[]] $Pattern) {
    # The mirror location will be represented by a number.
    # The number will be an integer, but as it's representing a location
    # that is between two array indicies (also integers) it will represent the
    # mirror being to the right of that index. So if the mirror location was 1,
    # that represents the mirror being between indices 1 and 2.

    # As we want to check for mirror symmetry within the bounds of the grid,
    # we always need something to the left and right of the mirror.

    # So in the below example where there are 5 columns, indices 0-4.
    # The possible mirror locations are the number of columns minus 1.
    #   0   1   2   3     <- possible mirror locations
    # 0   1   2   3   4   <- indices
    # ------------------
    # X   X   X   X   X   <- columns
    # .   #   #   .   .  #  #  .

    $LoR = @()

    # Check for vertical symmetry (left/right)
    $NumCols = $Pattern[0].Length
    $MirrorPositions = $NumCols - 1
    :MirrorPosLoop for ($MirrorPos = 0; $MirrorPos -lt $MirrorPositions; $MirrorPos++) {
        # How many numbers are to the left and right of the mirror?
        $NumbersToLeft = $MirrorPos + 1
        $NumbersToRight = $NumCols - $NumbersToLeft

        # Take the lesser of the 2 numbers
        $NumbersToCheck = [Math]::Min($NumbersToLeft, $NumbersToRight)

        :PatternLines foreach ($Line in $Pattern) {
            # How many characters do we need to compare either side of the mirror?
            for ($i = 0; $i -lt $NumbersToCheck; $i++) {
                $LeftNum = $Line[$MirrorPos - $i]
                $RightNum = $Line[$MirrorPos + $i + 1]
                if ($LeftNum -ne $RightNum) {
                    # The numbers don't match, so this mirror position is not
                    # valid. Move onto the next mirror position.
                    continue MirrorPosLoop
                }
            }
        }

        # If we get here, then the mirror position is valid for all the lines
        $LoR += [PSCustomObject]@{
            id = "Vertical$MirrorPos"
            MirrorNum = $MirrorPos
            NumbersBefore = $MirrorPos + 1
            Symmetry = 'Vertical'
        }
    }

    # Check for horizontal symmetry (top/bottom)
    $NumRows = $Pattern.Count
    $MirrorPositions = $NumRows - 1
    :MirrorPosLoop for ($MirrorPos = 0; $MirrorPos -lt $MirrorPositions; $MirrorPos++) {
        # How many numbers are to the left and right of the mirror?
        $NumbersToLeft = $MirrorPos + 1
        $NumbersToRight = $NumRows - $NumbersToLeft

        # Take the lesser of the 2 numbers
        $NumbersToCheck = [Math]::Min($NumbersToLeft, $NumbersToRight)

        for ($i = 0; $i -lt $NumbersToCheck; $i++) {
            $LineBefore = $Pattern[$MirrorPos - $i]
            $LineAfter = $Pattern[$MirrorPos + $i + 1]
            if ($LineBefore -ne $LineAfter) {
                # The numbers don't match, so this mirror position is not
                # valid. Move onto the next mirror position.
                continue MirrorPosLoop
            }
        }

        # If we get here, then the mirror position is valid for all the lines
        $LoR += [PSCustomObject]@{
            id = "Horizontal$MirrorPos"
            MirrorNum = $MirrorPos
            NumbersBefore = $MirrorPos + 1
            Symmetry = 'Horizontal'
        }
    }
    return $LoR
}

# Check over all the grids
$Mirrors = @()
:GridLoop foreach ($Grid in $Grids) {
    $SmudgedMirrorId = Find-LineOfReflection -Pattern $Grid.Pattern | 
        Select-Object -First 1 -ExpandProperty id
    # Loop through every character of the Grid's pattern and change it to the opposite
    # of whatever it is currently. Then find the line of reflection for that grid, add it
    # to the mirrors array and change the character back to what it was.
    for ($Line = 0; $Line -lt $Grid.Pattern.Count; $Line++) {
        $Chars = $Grid.Pattern[$Line].ToCharArray()
        foreach ($i in 0..($Chars.Length - 1)) {
            if ($Chars[$i] -eq '.') {
                $Chars[$i] = '#'
            } elseif ($Chars[$i] -eq '#') {
                $Chars[$i] = '.'
            }
            $Grid.Pattern[$Line] = -join $Chars
            $Mirror = Find-LineOfReflection $Grid.Pattern
            if ($Chars[$i] -eq '.') {
                $Chars[$i] = '#'
            } elseif ($Chars[$i] -eq '#') {
                $Chars[$i] = '.'
            }
            $Grid.Pattern[$Line] = -join $Chars
            foreach ($m in $Mirror) {
                if ($m.id -ne $SmudgedMirrorId) {
                    Write-Host "Found alt mirror $($m.id) for grid $($Grid.id)"
                    $Mirrors += $m
                    continue GridLoop
                }
            }
        }
    }
}

$Total = 0
foreach ($Mirror in $Mirrors) {
    if ($Mirror.Symmetry -eq 'Vertical') {
        $Total += $Mirror.NumbersBefore
    } elseif ($Mirror.Symmetry -eq 'Horizontal') {
        $Total += 100 * $Mirror.NumbersBefore
    }
}
$Total