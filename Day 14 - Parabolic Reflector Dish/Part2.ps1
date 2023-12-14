<#
The parabolic reflector dish deforms, but not in a way that focuses the beam. To
do that, you'll need to move the rocks to the edges of the platform.
Fortunately, a button on the side of the control panel labeled "spin cycle"
attempts to do just that!

Each cycle tilts the platform four times so that the rounded rocks roll north,
then west, then south, then east. After each tilt, the rounded rocks roll as far
as they can before the platform tilts in the next direction. After one cycle,
the platform will have finished rolling the rounded rocks in those four
directions in that order.

Here's what happens in the example above after each of the first few cycles:

After 1 cycle:
.....#....
....#...O#
...OO##...
.OO#......
.....OOO#.
.O#...O#.#
....O#....
......OOOO
#...O###..
#..OO#....

After 2 cycles:
.....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#..OO###..
#.OOO#...O

After 3 cycles:
.....#....
....#...O#
.....##...
..O#......
.....OOO#.
.O#...O#.#
....O#...O
.......OOO
#...O###.O
#.OOO#...O

This process should work if you leave it running long enough, but you're still
worried about the north support beams. To make sure they'll survive for a while,
you need to calculate the total load on the north support beams after 1000000000
cycles.

In the above example, after 1000000000 cycles, the total load on the north
support beams is 64.

Run the spin cycle for 1000000000 cycles. Afterward, what is the total load on
the north support beams?
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
            $this.Rocks = $this.RollCache[$HashKey].ToCharArray()
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
        $this.RollCache[$HashKey] = $this.Rocks -join ''
    }

    [void] RollSouth() {
        $HashKey = "S$($this.ToString())"
        if ($this.RollCache.ContainsKey($HashKey)) {
            $this.Rocks = $this.RollCache[$HashKey].ToCharArray()
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
        $this.RollCache[$HashKey] = $this.Rocks -join ''
    }

    [void] RollEast() {
        $HashKey = "E$($this.ToString())"
        if ($this.RollCache.ContainsKey($HashKey)) {
            $this.Rocks = $this.RollCache[$HashKey].ToCharArray()
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
        $this.RollCache[$HashKey] = $this.Rocks -join ''
    }

    [void] RollWest() {
        $HashKey = "W$($this.ToString())"
        if ($this.RollCache.ContainsKey($HashKey)) {
            $this.Rocks = $this.RollCache[$HashKey].ToCharArray()
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
        $this.RollCache[$HashKey] = $this.Rocks -join ''
    }

    [void] Tumble([int] $Cycles) {
        $FirstCacheHit = ''
        $FirstCacheHitCycle = -1
        for ($i = 0; $i -lt $Cycles; $i++) {
            Write-Host "Cycle $i"
            $HashKey = "N$($this.ToString())"
            if ($this.RollCache.ContainsKey($HashKey)) {
                if ($HashKey -eq $FirstCacheHit) {
                    # Work out how many cycle into the repeating pattern we'd be
                    # after the number of cycles we've been asked to do
                    $CyclesIntoTheRepeat = ($Cycles - $FirstCacheHitCycle) % ($i - $FirstCacheHitCycle)

                    # We're currently on the first repeat of the pattern, so set
                    # cycle to be the number of cycles into the repeat we'd be
                    # at the end of the number of cycles we've been asked to do
                    $Cycles = $i + $CyclesIntoTheRepeat
                    Write-Host "Repeats every $($i - $FirstCacheHitCycle) cycles after cycle $FirstCacheHitCycle. Setting cycles to $Cycles"
                }
                if ($FirstCacheHitCycle -eq -1) {
                    $FirstCacheHit = $HashKey
                    $FirstCacheHitCycle = $i
                }
            }
            $this.RollNorth()
            $this.RollWest()
            $this.RollSouth()
            $this.RollEast()
        }
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

$RockField = [RockField]::new((Get-Content "$PSScriptRoot\InputData.txt"))

$RockField.Tumble(1000000000)

$RockField.CalculateLoadOnNorthBeam()