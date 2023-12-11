<#
You continue following signs for "Hot Springs" and eventually come across an
observatory. The Elf within turns out to be a researcher studying cosmic
expansion using the giant telescope here.

He doesn't know anything about the missing machine parts; he's only visiting for
this research project. However, he confirms that the hot springs are the
next-closest area likely to have people; he'll even take you straight there once
he's done with today's observation analysis.

Maybe you can help him with the analysis to speed things up?

The researcher has collected a bunch of data and compiled the data into a single
giant image (your puzzle input). The image includes empty space (.) and galaxies
(#). For example:

...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#.....

The researcher is trying to figure out the sum of the lengths of the shortest
path between every pair of galaxies. However, there's a catch: the universe
expanded in the time it took the light from those galaxies to reach the
observatory.

Due to something involving gravitational effects, only some space expands. In
fact, the result is that any rows or columns that contain no galaxies should all
actually be twice as big.

In the above example, three columns and two rows contain no galaxies:

   v  v  v
 ...#......
 .......#..
 #.........
>..........<
 ......#...
 .#........
 .........#
>..........<
 .......#..
 #...#.....
   ^  ^  ^

These rows and columns need to be twice as big; the result of cosmic expansion
therefore looks like this:

....#........
.........#...
#............
.............
.............
........#....
.#...........
............#
.............
.............
.........#...
#....#.......

Equipped with this expanded universe, the shortest path between every pair of
galaxies can be found. It can help to assign every galaxy a unique number:

....1........
.........2...
3............
.............
.............
........4....
.5...........
............6
.............
.............
.........7...
8....9.......

In these 9 galaxies, there are 36 pairs. Only count each pair once; order within
the pair doesn't matter. For each pair, find any shortest path between the two
galaxies using only steps that move up, down, left, or right exactly one . or #
at a time. (The shortest path between two galaxies is allowed to pass through
another galaxy.)

For example, here is one of the shortest paths between galaxies 5 and 9:

....1........
.........2...
3............
.............
.............
........4....
.5...........
.##.........6
..##.........
...##........
....##...7...
8....9.......

This path has length 9 because it takes a minimum of nine steps to get from
galaxy 5 to galaxy 9 (the eight locations marked # plus the step onto galaxy 9
itself). Here are some other example shortest path lengths:

Between galaxy 1 and galaxy 7: 15
Between galaxy 3 and galaxy 6: 17
Between galaxy 8 and galaxy 9: 5

In this example, after expanding the universe, the sum of the shortest path
between all 36 pairs of galaxies is 374.

Expand the universe, then find the length of the shortest path between every
pair of galaxies. What is the sum of these lengths?
#>

# Get the input Data
$InputData = Get-Content "$PSScriptRoot/InputData.txt"

class GalaxyMap {
    [int] $Width = 0
    [int] $Height = 0
    [int[]] $EmptyRows = @()
    [int[]] $EmptyColumns = @()
    [Object[]] $Map
    [PSCustomObject[]] $Galaxies = @()
    [int] $GalaxyCount = 0
    [int] $UniquePairings = 0
    [hashtable] $GalaxyPairings = @{}

    GalaxyMap([Object[]] $InputData) {
        $this.Map = $InputData
        $this.Width = $this.Map[0].Length
        $this.Height = $this.Map.Length
        $this.Galaxies = [GalaxyMap]::FindAllGalaxies($this.Map)
        $this.GalaxyCount = $this.Galaxies.Count
        $this.FindEmptyRowsAndColumns()
    }

    [void] FindEmptyRowsAndColumns() {
        for ($Row = 0; $Row -lt $this.Height; $Row++) {
            $RowHasGalaxy = $false
            for ($Column = 0; $Column -lt $this.Width; $Column++) {
                if ($this.Map[$Row][$Column] -eq '#') {
                    $RowHasGalaxy = $true
                    break
                }
            }
            if (-not $RowHasGalaxy) {
                $this.EmptyRows += $Row
            }
        }

        for ($Column = 0; $Column -lt $this.Width; $Column++) {
            $ColumnHasGalaxy = $false
            for ($Row = 0; $Row -lt $this.Height; $Row++) {
                if ($this.Map[$Row][$Column] -eq '#') {
                    $ColumnHasGalaxy = $true
                    break
                }
            }
            if (-not $ColumnHasGalaxy) {
                $this.EmptyColumns += $Column
            }
        }
    }

    static [Object[]] ExpandUniverse([Object[]] $InputData) {
        $GalaxyWidth = $InputData[0].Length
        $GalaxyHeight = $InputData.Length

        $EmptyRws = @()
        $EmptyClumns = @()

        for ($Row = 0; $Row -lt $GalaxyHeight; $Row++) {
            $RowHasGalaxy = $false
            for ($Column = 0; $Column -lt $GalaxyWidth; $Column++) {
                if ($InputData[$Row][$Column] -eq '#') {
                    $RowHasGalaxy = $true
                    break
                }
            }
            if (-not $RowHasGalaxy) {
                $EmptyRws += $Row
            }
        }

        for ($Column = 0; $Column -lt $GalaxyWidth; $Column++) {
            $ColumnHasGalaxy = $false
            for ($Row = 0; $Row -lt $GalaxyHeight; $Row++) {
                if ($InputData[$Row][$Column] -eq '#') {
                    $ColumnHasGalaxy = $true
                    break
                }
            }
            if (-not $ColumnHasGalaxy) {
                $EmptyClumns += $Column
            }
        }

        [Array]::Reverse($EmptyRws)
        [Array]::Reverse($EmptyClumns)

        $InputDataArrayList = [System.Collections.ArrayList]::new($InputData)

        foreach ($Row in $EmptyRws) {
            $InputDataArrayList.Insert($Row, $InputData[$Row])
        }
        $GalaxyHeight = $InputDataArrayList.Count
        foreach ($Col in $EmptyClumns) {
            for ($Row = 0; $Row -lt $GalaxyHeight; $Row++) {
                $InputDataArrayList[$Row] = $InputDataArrayList[$Row].Insert($Col, '.')
            }
        }
        return $InputDataArrayList.ToArray()
    }

    static [PSCustomObject[]] FindAllGalaxies([Object[]] $Map) {
        $Gals = @()
        $GalaxyNumber = 1
        for ($Row = 0; $Row -lt $Map.Length; $Row++) {
            for ($Column = 0; $Column -lt $Map[$Row].Length; $Column++) {
                if ($Map[$Row][$Column] -eq '#') {
                    $Galaxy = [PSCustomObject]@{
                        Number = $GalaxyNumber
                        Row = $Row
                        Column = $Column
                    }
                    $Gals += $Galaxy
                    $GalaxyNumber++
                }
            }
        }
        return $Gals
    }

    [int] GetEmptyRows([int] $RowA, [int] $RowB) {
        # If there's not at least one row between the two rows, there cannot be
        # an empty row between them.
        if ([Math]::Abs($RowA - $RowB) -le 1) {
            return 0
        }
        $Num = 0
        foreach ($EmptyRow in $this.EmptyRows) {
            if (
                ($EmptyRow -lt $RowA -and $EmptyRow -gt $RowB) -or 
                ($EmptyRow -gt $RowA -and $EmptyRow -lt $RowB)
            ) {
                $Num++
            }
        }
        return $Num
    }

    [int] GetEmptyCols([int] $ColA, [int] $ColB) {
        # If there's not at least one col between the two cols, there cannot be
        # an empty col between them.
        if ([Math]::Abs($ColA - $ColB) -le 1) {
            return 0
        }
        $Num = 0
        foreach ($EmptyCol in $this.EmptyColumns) {
            if (
                ($EmptyCol -lt $ColA -and $EmptyCol -gt $ColB) -or 
                ($EmptyCol -gt $ColA -and $EmptyCol -lt $ColB)
            ) {
                $Num++
            }
        }
        return $Num
    }

    [void] FindPairings() {
        # Loop over every galaxy.
        # For each galaxy, loop over every other galaxy.
        # Check if we've already seen this galaxy pairing (based on hashtable 
        # key). If we haven't, add it to the hashtable with they key 
        # "(smallest galaxy number), (largest galaxy number)"
        # If we have, skip it.
        $ExtraRows = 2
        $ExtraCols = 2
        for ($GalaxyIndex = 0; $GalaxyIndex -lt $this.GalaxyCount; $GalaxyIndex++) {
            $Galaxy = $this.Galaxies[$GalaxyIndex]
            for ($OtherGalaxyIndex = $GalaxyIndex + 1; $OtherGalaxyIndex -lt $this.GalaxyCount; $OtherGalaxyIndex++) {
                $OtherGalaxy = $this.Galaxies[$OtherGalaxyIndex]
                $GalaxyPairing = "$($Galaxy.number), $($OtherGalaxy.number)"
                if (-not $this.GalaxyPairings.ContainsKey($GalaxyPairing)) {
                    $HDist = [Math]::Abs($Galaxy.Column - $OtherGalaxy.Column) + (($ExtraCols - 1) * $this.GetEmptyCols($Galaxy.Column, $OtherGalaxy.Column))
                    $VDist = [Math]::Abs($Galaxy.Row - $OtherGalaxy.Row) + (($ExtraRows - 1) * $this.GetEmptyRows($Galaxy.Row, $OtherGalaxy.Row))
                    $Distance = $HDist + $VDist
                    $this.GalaxyPairings.Add($GalaxyPairing, $Distance)
                }
            }
        }
    }

}

$GalaxyMap = [GalaxyMap]::new($InputData)

$GalaxyMap.FindPairings()

$GalaxyMap.GalaxyPairings.Values | 
    Measure-Object -Sum | 
    Select-Object -ExpandProperty Sum