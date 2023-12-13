<#
With your help, the hot springs team locates an appropriate spring which
launches you neatly and precisely up to the edge of Lava Island.

There's just one problem: you don't see any lava.

You do see a lot of ash and igneous rock; there are even what look like gray
mountains scattered around. After a while, you make your way to a nearby cluster
of mountains only to discover that the valley between them is completely full of
large mirrors. Most of the mirrors seem to be aligned in a consistent way;
perhaps you should head in that direction?

As you move through the valley of mirrors, you find that several of them have
fallen from the large metal frames keeping them in place. The mirrors are
extremely flat and shiny, and many of the fallen mirrors have lodged into the
ash at strange angles. Because the terrain is all one color, it's hard to tell
where it's safe to walk or where you're about to run into a mirror.

You note down the patterns of ash (.) and rocks (#) that you see as you walk
(your puzzle input); perhaps by carefully analyzing these patterns, you can
figure out where the mirrors are!

For example:

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

To find the reflection in each pattern, you need to find a perfect reflection
across either a horizontal line between two rows or across a vertical line
between two columns.

In the first pattern, the reflection is across a vertical line between two
columns; arrows on each of the two columns point at the line between the
columns:

123456789
    ><   
#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.
    ><   
123456789

In this pattern, the line of reflection is the vertical line between columns 5
and 6. Because the vertical line is not perfectly in the middle of the pattern,
part of the pattern (column 1) has nowhere to reflect onto and can be ignored;
every other column has a reflected column within the pattern and must match
exactly: column 2 matches column 9, column 3 matches 8, 4 matches 7, and 5
matches 6.

The second pattern reflects across a horizontal line instead:

1 #...##..# 1
2 #....#..# 2
3 ..##..### 3
4v#####.##.v4
5^#####.##.^5
6 ..##..### 6
7 #....#..# 7

This pattern reflects across the horizontal line between rows 4 and 5. Row 1
would reflect with a hypothetical row 8, but since that's not in the pattern,
row 1 doesn't need to match anything. The remaining rows match: row 2 matches
row 7, row 3 matches row 6, and row 4 matches row 5.

To summarize your pattern notes, add up the number of columns to the left of
each vertical line of reflection; to that, also add 100 multiplied by the number
of rows above each horizontal line of reflection. In the above example, the
first pattern's vertical line has 5 columns to its left and the second pattern's
horizontal line has 4 rows above it, a total of 405.

Find the line of reflection in each of the patterns in your notes. What number
do you get after summarizing all of your notes?
#>

# Get the input data
$InputData = Get-Content "$PSScriptRoot\InputData.txt"

# Create a list of grids/patterns
$Grids = @()

# Keep track of the last blank line we saw
$LastBlankLine = 0

# Loop over all the lines of the input data.
for ($i = 0; $i -lt $InputData.Count; $i++) {
    $Line = $InputData[$i]
    $IsLastLine = $i -eq $InputData.Count - 1

    # When we are on a blank line, or the last line, we create a new grid
    # based on the lines we have seen since the last blank line.
    if ([string]::IsNullOrWhiteSpace($Line) -or $IsLastLine){
        $EndOn = if ($IsLastLine) { $i } else { $i - 1 }
        $Grids += [PSCustomObject]@{
            Pattern = $InputData[$LastBlankLine..$EndOn]
            Symmetry = 'Unknown'
            MirrorNum = -1
            NumbersBefore = -1
        }
        $LastBlankLine = $i + 1
    }
}

# Check over all the grids
:GridLoop foreach ($Grid in $Grids) {
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

    # Check for vertical symmetry (left/right)
    $NumCols = $Grid.Pattern[0].Length
    $MirrorPositions = $NumCols - 1
    :MirrorPosLoop for ($MirrorPos = 0; $MirrorPos -lt $MirrorPositions; $MirrorPos++) {
        # How many numbers are to the left and right of the mirror?
        $NumbersToLeft = $MirrorPos + 1
        $NumbersToRight = $NumCols - $NumbersToLeft

        # Take the lesser of the 2 numbers
        $NumbersToCheck = [Math]::Min($NumbersToLeft, $NumbersToRight)

        :PatternLines foreach ($Line in $Grid.Pattern) {
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
        $Grid.MirrorNum = $MirrorPos
        $Grid.NumbersBefore = $MirrorPos + 1
        $Grid.Symmetry = 'Vertical'
        continue GridLoop
    }

    # Check for horizontal symmetry (top/bottom)
    $NumRows = $Grid.Pattern.Count
    $MirrorPositions = $NumRows - 1
    :MirrorPosLoop for ($MirrorPos = 0; $MirrorPos -lt $MirrorPositions; $MirrorPos++) {
        # How many numbers are to the left and right of the mirror?
        $NumbersToLeft = $MirrorPos + 1
        $NumbersToRight = $NumRows - $NumbersToLeft

        # Take the lesser of the 2 numbers
        $NumbersToCheck = [Math]::Min($NumbersToLeft, $NumbersToRight)

        for ($i = 0; $i -lt $NumbersToCheck; $i++) {
            $LineBefore = $Grid.Pattern[$MirrorPos - $i]
            $LineAfter = $Grid.Pattern[$MirrorPos + $i + 1]
            if ($LineBefore -ne $LineAfter) {
                # The numbers don't match, so this mirror position is not
                # valid. Move onto the next mirror position.
                continue MirrorPosLoop
            }
        }

        # If we get here, then the mirror position is valid for all the lines
        $Grid.MirrorNum = $MirrorPos
        $Grid.NumbersBefore = $MirrorPos + 1
        $Grid.Symmetry = 'Horizontal'
        continue GridLoop
    }
}

$Total = 0

foreach ($Grid in $Grids) {
    if ($Grid.Symmetry -eq 'Vertical') {
        $Total += $Grid.NumbersBefore
    } elseif ($Grid.Symmetry -eq 'Horizontal') {
        $Total += 100 * $Grid.NumbersBefore
    }
}

$Total