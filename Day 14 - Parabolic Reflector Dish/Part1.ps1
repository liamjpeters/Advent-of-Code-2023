<#
You reach the place where all of the mirrors were pointing: a massive parabolic
reflector dish attached to the side of another large mountain.

The dish is made up of many small mirrors, but while the mirrors themselves are
roughly in the shape of a parabolic reflector dish, each individual mirror seems
to be pointing in slightly the wrong direction. If the dish is meant to focus
light, all it's doing right now is sending it in a vague direction.

This system must be what provides the energy for the lava! If you focus the
reflector dish, maybe you can go where it's pointing and use the light to fix
the lava production.

Upon closer inspection, the individual mirrors each appear to be connected via
an elaborate system of ropes and pulleys to a large metal platform below the
dish. The platform is covered in large rocks of various shapes. Depending on
their position, the weight of the rocks deforms the platform, and the shape of
the platform controls which ropes move and ultimately the focus of the dish.

In short: if you move the rocks, you can focus the dish. The platform even has a
control panel on the side that lets you tilt it in one of four directions! The
rounded rocks (O) will roll when the platform is tilted, while the cube-shaped
rocks (#) will stay in place. You note the positions of all of the empty spaces
(.) and rocks (your puzzle input). For example:

O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#....

Start by tilting the lever so all of the rocks will slide north as far as they 
will go:

OOOO.#.O..
OO..#....#
OO..O##..O
O..#.OO...
........#.
..#....#.#
..O..#.O.O
..O.......
#....###..
#....#....

You notice that the support beams along the north side of the platform are 
damaged; to ensure the platform doesn't collapse, you should calculate the total
load on the north support beams.

The amount of load caused by a single rounded rock (O) is equal to the number of
rows from the rock to the south edge of the platform, including the row the rock
is on. (Cube-shaped rocks (#) don't contribute to load.) So, the amount of load
caused by each rock in each row is as follows:

OOOO.#.O.. 10
OO..#....#  9
OO..O##..O  8
O..#.OO...  7
........#.  6
..#....#.#  5
..O..#.O.O  4
..O.......  3
#....###..  2
#....#....  1

The total load is the sum of the load caused by all of the rounded rocks. In
this example, the total load is 136.

Tilt the platform so that the rounded rocks all roll north. Afterward, what is
the total load on the north support beams?
#>

class RockField {
    [int] $Width
    [int] $Height
    [char[]] $Rocks
    [hashtable] $RollCache = @{}

    RockField([string[]] $InputData) {
        $this.Width = $InputData[0].Length
        $this.Height = $InputData.Count
        $this.Rocks = [Collections.ArrayList]::new($this.Height)
        $InputData | ForEach-Object {
            $this.Rocks += $_.ToCharArray()
        }
    }

    [char] GetRock([int] $X, [int] $Y) {
        if ($X -lt 0 -or $X -ge $this.Width -or 
            $Y -lt 0 -or $Y -ge $this.Height) {
            return $null
        }
        return $this.Rocks[$this.Width * $Y + $X]
    }

    [void] SetRock([int] $X, [int] $Y, [Char] $Value) {
        if ($X -lt 0 -or $X -ge $this.Width -or
            $Y -lt 0 -or $Y -ge $this.Height) {
            return
        }
        $this.Rocks[$this.Width * $Y + $X] = $Value
    }

    [void] RollNorth() {
        $HashKey = "N$($this.ToString())"
        if ($this.RollCache.ContainsKey($HashKey)) {
            Write-Host "Cache hit rolling North"
            $this.Rocks = $this.RollCache[$HashKey]
            return
        }
        # Start at 1 - the top row cannot move up any more
        for ($Y = 1; $Y -lt $this.Height; $Y++) {
            for ($X = 0; $X -lt $this.Width; $X++) {
                if ($this.GetRock($X, $Y) -eq 'O') {

                    # Find the first non-empty space above the rock so we know
                    # how far up we can move
                    $LastEmpty = $Y
                    while ($this.GetRock($X, $LastEmpty - 1) -eq '.') {
                        $LastEmpty--
                    }
                    if ($Y -ne $LastEmpty) {
                        # We've moved
                        $this.SetRock($X, $LastEmpty, 'O')
                        $this.SetRock($X, $Y, '.')
                    }
                }
            }
        }
        $this.RollCache[$HashKey] = $this.Rocks
    }

    [void] RollSouth() {
        $HashKey = "S$($this.ToString())"
        if ($this.RollCache.ContainsKey($HashKey)) {
            Write-Host "Cache hit rolling North"
            $this.Rocks = $this.RollCache[$HashKey]
            return
        }
        # Start at the bottom row - it cannot move down any more
        for ($Y = $this.Height - 2; $Y -ge 0; $Y--) {
            for ($X = 0; $X -lt $this.Width; $X++) {
                if ($this.GetRock($X, $Y) -eq 'O') {

                    # Find the first non-empty space below the rock so we know
                    # how far down we can move
                    $LastEmpty = $Y
                    while ($this.GetRock($X, $LastEmpty + 1) -eq '.') {
                        $LastEmpty++
                    }
                    if ($Y -ne $LastEmpty) {
                        # We've moved
                        $this.SetRock($X, $LastEmpty, 'O')
                        $this.SetRock($X, $Y, '.')
                    }
                }
            }
        }
        $this.RollCache[$HashKey] = $this.Rocks
    }

    [void] RollEast() {
        $HashKey = "E$($this.ToString())"
        if ($this.RollCache.ContainsKey($HashKey)) {
            Write-Host "Cache hit rolling North"
            $this.Rocks = $this.RollCache[$HashKey]
            return
        }
        # Start at the rightmost column - it cannot move right any more
        for ($X = $this.Width - 2; $X -ge 0; $X--) {
            for ($Y = 0; $Y -lt $this.Height; $Y++) {
                if ($this.GetRock($X, $Y) -eq 'O') {

                    # Find the first non-empty space to the right of the rock
                    # so we know how far right we can move
                    $LastEmpty = $X
                    while ($this.GetRock($LastEmpty + 1, $Y) -eq '.') {
                        $LastEmpty++
                    }
                    if ($X -ne $LastEmpty) {
                        # We've moved
                        $this.SetRock($LastEmpty, $Y, 'O')
                        $this.SetRock($X, $Y, '.')
                    }
                }
            }
        }
        $this.RollCache[$HashKey] = $this.Rocks
    }

    [void] RollWest() {
        $HashKey = "W$($this.ToString())"
        if ($this.RollCache.ContainsKey($HashKey)) {
            Write-Host "Cache hit rolling North"
            $this.Rocks = $this.RollCache[$HashKey]
            return
        }
        # Start at 1 - the leftmost column cannot move left any more
        for ($X = 1; $X -lt $this.Width; $X++) {
            for ($Y = 0; $Y -lt $this.Height; $Y++) {
                if ($this.GetRock($X, $Y) -eq 'O') {

                    # Find the first non-empty space to the left of the rock
                    # so we know how far left we can move
                    $LastEmpty = $X
                    while ($this.GetRock($LastEmpty - 1, $Y) -eq '.') {
                        $LastEmpty--
                    }
                    if ($X -ne $LastEmpty) {
                        # We've moved
                        $this.SetRock($LastEmpty, $Y, 'O')
                        $this.SetRock($X, $Y, '.')
                    }
                }
            }
        }
        $this.RollCache[$HashKey] = $this.Rocks
    }

    [int64] CalculateLoadOnNorthBeam() {
        $Load = [int64] 0
        for ($Y = 0; $Y -lt $this.Height; $Y++) {
            for ($X = 0; $X -lt $this.Width; $X++) {
                if ($this.GetRock($X, $Y) -eq 'O') {
                    $Load += $this.Height - $Y
                }
            }
        }
        return $Load
    }

    [string] ToString() {
        return $this.Rocks -join ''
    }

    [string] Print() {
        $Builder = [Text.StringBuilder]::new()
        foreach ($Y in 0..($this.Height - 1)) {
            $Builder.AppendLine($this.Rocks[($this.Width * $Y)..($this.Width * ($Y + 1) - 1)] -join '') | Out-Null
        }
        return $Builder.ToString()
    }

}

$RockField = [RockField]::new((Get-Content "$PSScriptRoot\TestInputData.txt"))

$RockField.RollNorth()

$RockField.CalculateLoadOnNorthBeam()