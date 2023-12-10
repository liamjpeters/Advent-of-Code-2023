<#
You use the hang glider to ride the hot air from Desert Island all the way up to
the floating metal island. This island is surprisingly cold and there definitely
aren't any thermals to glide on, so you leave your hang glider behind.

You wander around for a while, but you don't find any people or animals.
However, you do occasionally find signposts labeled "Hot Springs" pointing in a
seemingly consistent direction; maybe you can find someone at the hot springs
and ask them where the desert-machine parts are made.

The landscape here is alien; even the flowers and trees are made of metal. As
you stop to admire some metal grass, you notice something metallic scurry away
in your peripheral vision and jump into a big pipe! It didn't look like any
animal you've ever seen; if you want a better look, you'll need to get ahead of
it.

Scanning the area, you discover that the entire field you're standing on is
densely packed with pipes; it was hard to tell at first because they're the same
metallic silver color as the "ground". You make a quick sketch of all of the
surface pipes you can see (your puzzle input).

The pipes are arranged in a two-dimensional grid of tiles:

- | is a vertical pipe connecting north and south.
- - is a horizontal pipe connecting east and west.
- L is a 90-degree bend connecting north and east.
- J is a 90-degree bend connecting north and west.
- 7 is a 90-degree bend connecting south and west.
- F is a 90-degree bend connecting south and east.
- . is ground; there is no pipe in this tile.
- S is the starting position of the animal; there is a pipe on this tile, but
  your sketch doesn't show what shape the pipe has.

Based on the acoustics of the animal's scurrying, you're confident the pipe that
contains the animal is one large, continuous loop.

For example, here is a square loop of pipe:

.....
.F-7.
.|.|.
.L-J.
.....

If the animal had entered this loop in the northwest corner, the sketch would
instead look like this:

.....
.S-7.
.|.|.
.L-J.
.....

In the above diagram, the S tile is still a 90-degree F bend: you can tell
because of how the adjacent pipes connect to it.

Unfortunately, there are also many pipes that aren't connected to the loop!
This sketch shows the same loop as above:

-L|F7
7S-7|
L|7||
-L-J|
L|-JF

In the above diagram, you can still figure out which pipes form the main loop:
they're the ones connected to S, pipes those pipes connect to, pipes those pipes
connect to, and so on. Every pipe in the main loop connects to its two neighbors
(including S, which will have exactly two pipes connecting to it, and which is
assumed to connect back to those two pipes).

Here is a sketch that contains a slightly more complex main loop:

..F7.
.FJ|.
SJ.L7
|F--J
LJ...

Here's the same example sketch with the extra, non-main-loop pipe tiles also
shown:

7-F7-
.FJ|7
SJLL7
|F--J
LJ.LJ

If you want to get out ahead of the animal, you should find the tile in the loop
that is farthest from the starting position. Because the animal is in the pipe,
it doesn't make sense to measure this by direct distance. Instead, you need to
find the tile that would take the longest number of steps along the loop to
reach from the starting point - regardless of which way around the loop the
animal went.

In the first example with the square loop:

.....
.S-7.
.|.|.
.L-J.
.....

You can count the distance each tile in the loop is from the starting point like
this:

.....
.012.
.1.3.
.234.
.....

In this example, the farthest point from the start is 4 steps away.

Here's the more complex loop again:

..F7.
.FJ|.
SJ.L7
|F--J
LJ...

Here are the distances for each tile on that loop:

..45.
.236.
01.78
14567
23...

Find the single giant loop starting at S. How many steps along the loop does it
take to get from the starting position to the point farthest from the starting
position?
#>

$InputData = Get-Content "$PSScriptRoot\InputData.txt"

class PipeSection {
    [char] $Char

    [int] $X = 0
    [int] $Y = 0

    [bool] $IsStart = $false
    [bool] $MainLoop = $false
    [int] $DistanceFromStart = -1

    [bool] $ConnectsNorth = $false
    [bool] $ConnectsEast = $false
    [bool] $ConnectsSouth = $false
    [bool] $ConnectsWest = $false


    PipeSection([int]$X, [int]$Y, [char]$Char) {
        $this.X = $X
        $this.Y = $Y
        $this.Char = $Char
        if ($Char -eq 'S') {
            $this.IsStart = $true
            $this.DistanceFromStart = 0
            $this.MainLoop = $true
        }
        switch ($Char) {
            '|' {
                $this.ConnectsNorth = $true
                $this.ConnectsSouth = $true
            }
            '-' {
                $this.ConnectsEast = $true
                $this.ConnectsWest = $true
            }
            'L' {
                $this.ConnectsNorth = $true
                $this.ConnectsEast = $true
            }
            'J' {
                $this.ConnectsNorth = $true
                $this.ConnectsWest = $true
            }
            '7' {
                $this.ConnectsSouth = $true
                $this.ConnectsWest = $true
            }
            'F' {
                $this.ConnectsSouth = $true
                $this.ConnectsEast = $true
            }
        }
    }
}

class PipeMap {
    [int] $Width = 0
    [int] $Height = 0
    [PipeSection[]] $PipeSections
    [int[]] $StartLocation = 0,0

    PipeMap([int]$Width, [int]$Height) {
        [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") | Out-Null
        $this.Width = $Width
        $this.Height = $Height
        $this.PipeSections = [PipeSection[]]::new($Width * $Height)
    }

    [void] AddPipeSection([PipeSection]$PipeSection) {
        $Loc = $PipeSection.X + $PipeSection.Y * $this.Width
        $this.PipeSections[$Loc] = $PipeSection
        if ($PipeSection.IsStart) {
            $this.StartLocation = $PipeSection.X, $PipeSection.Y
        }
    }

    [PipeSection] GetAt([int]$X, [int]$Y) {
        # If we asked for something out of bounds, return null.
        if ($X -lt 0 -or $X -ge $this.Width -or 
            $Y -lt 0 -or $Y -ge $this.Height) {
            return $null
        }
        $Loc = $X + $Y * $this.Width
        return $this.PipeSections[$Loc]
    }

    [void] Print() {
        for ($y = 0; $y -lt $this.Height; $y++) {
            for ($x = 0; $x -lt $this.Width; $x++) {
                $Loc = $x + $y * $this.Width
                $PipeSection = $this.PipeSections[$Loc]
                $Char = switch ($PipeSection.Char) {
                    '|' {
                       "║"
                    }
                    '-' {
                        "═"
                    }
                    'L' {
                        "╚"
                    }
                    'J' {
                        "╝"
                    }
                    '7' {
                        "╗"
                    }
                    'F' {
                        "╔"
                    }
                    '.' {
                        "."
                    }
                    'S' {
                        "S"
                    }
                }
                Write-Host -NoNewline $Char
            }
            Write-Host ""
        }
    
    }

    [void] DrawToFile([string]$File) {
        $Scale = 5
        $Bitmap = [System.Drawing.Bitmap]::new(($this.Width * $Scale), ($this.Height * $Scale))
        $Graphics = [System.Drawing.Graphics]::FromImage($Bitmap)
        foreach ($Section in $this.PipeSections) {
            $ScaledX = $Section.X * $Scale
            $ScaledY = $Section.Y * $Scale
            $Graphics.FillRectangle([System.Drawing.Brushes]::Brown, $ScaledX, $ScaledY, $Scale, $Scale)
            switch ($Section.Char) {
                '|' {
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 1, $ScaledY, $ScaledX + 1, $ScaledY + $Scale - 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX + 2, $ScaledY, $ScaledX + 2, $ScaledY + $Scale - 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 3, $ScaledY, $ScaledX + 3, $ScaledY + $Scale - 1)
                    break
                }
                '-' {
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX, $ScaledY + 1, $ScaledX + $Scale - 1, $ScaledY + 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX, $ScaledY + 2, $ScaledX + $Scale - 1, $ScaledY + 2)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX, $ScaledY + 3, $ScaledX + $Scale - 1, $ScaledY + 3)
                    break
                }
                'L' {
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 1, $ScaledY, $ScaledX + 1, $ScaledY + $Scale - 2)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX + 2, $ScaledY, $ScaledX + 2, $ScaledY + $Scale - 3)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 3, $ScaledY, $ScaledX + 3, $ScaledY + 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 3, $ScaledY + 1, $ScaledX + 4, $ScaledY + 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX + 3, $ScaledY + 2, $ScaledX + 4, $ScaledY + 2)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 2, $ScaledY + 3, $ScaledX + 4, $ScaledY + 3)
                    break
                }
                'J' {
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 3, $ScaledY, $ScaledX + 3, $ScaledY + $Scale - 2)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX + 2, $ScaledY, $ScaledX + 2, $ScaledY + $Scale - 3)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 1, $ScaledY, $ScaledX + 1, $ScaledY + 1)

                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX, $ScaledY + 1, $ScaledX + 1, $ScaledY + 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX, $ScaledY + 2, $ScaledX + 2, $ScaledY + 2)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX, $ScaledY + 3, $ScaledX + 2, $ScaledY + 3)
                    break
                }
                '7' {
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 1, $ScaledY + 3, $ScaledX + 1, $ScaledY + $Scale - 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX + 2, $ScaledY + 2, $ScaledX + 2, $ScaledY + $Scale - 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 3, $ScaledY + 1, $ScaledX + 3, $ScaledY + $Scale - 1)
                    
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX, $ScaledY + 3, $ScaledX + 1, $ScaledY + 3)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX, $ScaledY + 2, $ScaledX + 2, $ScaledY + 2)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX, $ScaledY + 1, $ScaledX + 2, $ScaledY + 1)
                    break
                }
                'F' {
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 1, $ScaledY + 1, $ScaledX + 1, $ScaledY + $Scale - 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX + 2, $ScaledY + 2, $ScaledX + 2, $ScaledY + $Scale - 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 3, $ScaledY + 3, $ScaledX + 3, $ScaledY + $Scale - 1)
                    
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 2, $ScaledY + 1, $ScaledX + 4, $ScaledY + 1)
                    $Graphics.DrawLine([System.Drawing.Pens]::Blue, $ScaledX + 3, $ScaledY + 2, $ScaledX + 4, $ScaledY + 2)
                    $Graphics.DrawLine([System.Drawing.Pens]::Black, $ScaledX + 3, $ScaledY + 3, $ScaledX + 4, $ScaledY + 3)
                    break
                }
                'S' {
                    $Graphics.FillRectangle([System.Drawing.Brushes]::Green, $ScaledX, $ScaledY, $Scale, $Scale)
                    break
                }
            }
            if ($Section.IsStart) {
                $Bitmap.SetPixel($ScaledX+2, $ScaledY+2, [System.Drawing.Color]::Green)
            }
        }
        $Bitmap.Save("$File")
    }

    [void] DetermineStartLocationType() {
        $StartSection = $this.GetAt($this.StartLocation[0], $this.StartLocation[1])
        # Get pipe 'north' of start. If it connects south, the start pipe
        # connects north.
        $NorthSection = $this.GetAt($this.StartLocation[0], $this.StartLocation[1] - 1)
        if ($NorthSection -and $NorthSection.ConnectsSouth) {
            $StartSection.ConnectsNorth = $true
        }
        
        # Get pipe 'east' of start. If it connects west, the start pipe
        # connects east.
        $EastSection = $this.GetAt($this.StartLocation[0] + 1, $this.StartLocation[1])
        if ($EastSection -and $EastSection.ConnectsWest) {
            $StartSection.ConnectsEast = $true
        }

        # Get pipe 'south' of start. If it connects north, the start pipe
        # connects south.
        $SouthSection = $this.GetAt($this.StartLocation[0], $this.StartLocation[1] + 1)
        if ($SouthSection -and $SouthSection.ConnectsNorth) {
            $StartSection.ConnectsSouth = $true
        }

        # Get pipe 'west' of start. If it connects east, the start pipe
        # connects west.
        $WestSection = $this.GetAt($this.StartLocation[0] - 1, $this.StartLocation[1])
        if ($WestSection -and $WestSection.ConnectsEast) {
            $StartSection.ConnectsWest = $true
        }

        $StartSection.Char = if ($StartSection.ConnectsNorth -and $StartSection.ConnectsSouth) {
            '|'
        } elseif ($StartSection.ConnectsEast -and $StartSection.ConnectsWest) {
            '-'
        } elseif ($StartSection.ConnectsNorth -and $StartSection.ConnectsEast) {
            'L'
        } elseif ($StartSection.ConnectsNorth -and $StartSection.ConnectsWest) {
            'J'
        } elseif ($StartSection.ConnectsSouth -and $StartSection.ConnectsWest) {
            '7'
        } elseif ($StartSection.ConnectsSouth -and $StartSection.ConnectsEast) {
            'F'
        } else {
            '.'
        }

        $this.AddPipeSection($StartSection)
    }

    [void] FollowLoop() {
        $StartSection = $this.GetAt($this.StartLocation[0], $this.StartLocation[1])
        $CurrentSection = $StartSection
        $LastMove = $null
        do {
            if ($CurrentSection.ConnectsNorth -and $LastMove -ne 'S') {
                $CurrentSection = $this.GetAt($CurrentSection.X, $CurrentSection.Y - 1)
                $LastMove = 'N'
            } elseif ($CurrentSection.ConnectsEast -and $LastMove -ne 'W') {
                $CurrentSection = $this.GetAt($CurrentSection.X + 1, $CurrentSection.Y)
                $LastMove = 'E'
            } elseif ($CurrentSection.ConnectsSouth -and $LastMove -ne 'N') {
                $CurrentSection = $this.GetAt($CurrentSection.X, $CurrentSection.Y + 1)
                $LastMove = 'S'
            } elseif ($CurrentSection.ConnectsWest -and $LastMove -ne 'E') {
                $CurrentSection = $this.GetAt($CurrentSection.X - 1, $CurrentSection.Y)
                $LastMove = 'W'
            } else {
                throw "No valid move from $($CurrentSection.X), $($CurrentSection.Y)"
            }
            $CurrentSection.MainLoop = $true
        } while ($CurrentSection -ne $StartSection)
    }

    [void] CalculateDistanceToStart() {
        $StartSection = $this.GetAt($this.StartLocation[0], $this.StartLocation[1])
        $CurrentSection = $StartSection
        $LastMove = $null
        $Distance = 1
        do {
            if ($CurrentSection.ConnectsNorth -and $LastMove -ne 'S') {
                $CurrentSection = $this.GetAt($CurrentSection.X, $CurrentSection.Y - 1)
                $LastMove = 'N'
            } elseif ($CurrentSection.ConnectsEast -and $LastMove -ne 'W') {
                $CurrentSection = $this.GetAt($CurrentSection.X + 1, $CurrentSection.Y)
                $LastMove = 'E'
            } elseif ($CurrentSection.ConnectsSouth -and $LastMove -ne 'N') {
                $CurrentSection = $this.GetAt($CurrentSection.X, $CurrentSection.Y + 1)
                $LastMove = 'S'
            } elseif ($CurrentSection.ConnectsWest -and $LastMove -ne 'E') {
                $CurrentSection = $this.GetAt($CurrentSection.X - 1, $CurrentSection.Y)
                $LastMove = 'W'
            } else {
                throw "No valid move from $($CurrentSection.X), $($CurrentSection.Y)"
            }
            $CurrentSection.MainLoop = $true
            if (-not $CurrentSection.IsStart) {
                $CurrentSection.DistanceFromStart = $Distance
            }
            $Distance++
        } while ($CurrentSection -ne $StartSection)

        $CurrentSection = $StartSection
        $LastMove = $null
        $Distance = 1
        do {
            if ($CurrentSection.ConnectsWest -and $LastMove -ne 'E') {
                $CurrentSection = $this.GetAt($CurrentSection.X - 1, $CurrentSection.Y)
                $LastMove = 'W'
            } elseif ($CurrentSection.ConnectsSouth -and $LastMove -ne 'N') {
                $CurrentSection = $this.GetAt($CurrentSection.X, $CurrentSection.Y + 1)
                $LastMove = 'S'
            } elseif ($CurrentSection.ConnectsEast -and $LastMove -ne 'W') {
                $CurrentSection = $this.GetAt($CurrentSection.X + 1, $CurrentSection.Y)
                $LastMove = 'E'
            } elseif ($CurrentSection.ConnectsNorth -and $LastMove -ne 'S') {
                $CurrentSection = $this.GetAt($CurrentSection.X, $CurrentSection.Y - 1)
                $LastMove = 'N'
            } else {
                throw "No valid move from $($CurrentSection.X), $($CurrentSection.Y)"
            }
            if (-not $CurrentSection.IsStart -and $Distance -lt $CurrentSection.DistanceFromStart) {
                $CurrentSection.DistanceFromStart = $Distance
            }
            $Distance++
        } while ($CurrentSection -ne $StartSection)
    }

    [void] CullNotOnMainLoop() {
        $this.FollowLoop()
        foreach ($Section in $this.PipeSections) {
            if (-not $Section.MainLoop) {
                $Section.Char = '.'
                $Section.ConnectsNorth = $false
                $Section.ConnectsEast = $false
                $Section.ConnectsSouth = $false
                $Section.ConnectsWest = $false
            }
        }
    }

    [PipeSection] GetFarthestFromStart() {
        $Farthest = $null
        foreach ($Section in $this.PipeSections) {
            if ($Section.DistanceFromStart -gt $Farthest.DistanceFromStart) {
                $Farthest = $Section
            }
        }
        return $Farthest
    }

}

$PipeMap = [PipeMap]::new($InputData[0].Length, $InputData.Length)

for ($LineNumber = 0; $LineNumber -lt $InputData.Length; $LineNumber++) {
    $LineChars = $InputData[$LineNumber].ToCharArray()
    for ($i = 0; $i -lt $LineChars.Length; $i++) {
        $PipeSection = [PipeSection]::new($i, $LineNumber, $LineChars[$i])
        $PipeMap.AddPipeSection($PipeSection)
    }
}

$PipeMap.DetermineStartLocationType()
$PipeMap.CullNotOnMainLoop()
$PipeMap.CalculateDistanceToStart()
$PipeMap.DrawToFile("$PSScriptRoot\Map.bmp")
$PipeMap.GetFarthestFromStart().DistanceFromStart