<#
You quickly reach the farthest point of the loop, but the animal never emerges.
Maybe its nest is within the area enclosed by the loop?

To determine whether it's even worth taking the time to search for such a nest,
you should calculate how many tiles are contained within the loop. For example:

...........
.S-------7.
.|F-----7|.
.||.....||.
.||.....||.
.|L-7.F-J|.
.|..|.|..|.
.L--J.L--J.
...........

The above loop encloses merely four tiles - the two pairs of . in the southwest
and southeast (marked I below). The middle . tiles (marked O below) are not in
the loop. Here is the same loop again with those regions marked:

...........
.S-------7.
.|F-----7|.
.||OOOOO||.
.||OOOOO||.
.|L-7OF-J|.
.|II|O|II|.
.L--JOL--J.
.....O.....

In fact, there doesn't even need to be a full tile path to the outside for tiles
to count as outside the loop - squeezing between pipes is also allowed! Here, I
is still within the loop and O is still outside the loop:

..........
.S------7.
.|F----7|.
.||OOOO||.
.||OOOO||.
.|L-7F-J|.
.|II||II|.
.L--JL--J.
..........

In both of the above examples, 4 tiles are enclosed by the loop.

Here's a larger example:

.F----7F7F7F7F-7....
.|F--7||||||||FJ....
.||.FJ||||||||L7....
FJL7L7LJLJ||LJ.L-7..
L--J.L7...LJS7F-7L7.
....F-J..F7FJ|L7L7L7
....L7.F7||L7|.L7L7|
.....|FJLJ|FJ|F7|.LJ
....FJL-7.||.||||...
....L---J.LJ.LJLJ...

The above sketch has many random bits of ground, some of which are in the loop
(I) and some of which are outside it (O):

OF----7F7F7F7F-7OOOO
O|F--7||||||||FJOOOO
O||OFJ||||||||L7OOOO
FJL7L7LJLJ||LJIL-7OO
L--JOL7IIILJS7F-7L7O
OOOOF-JIIF7FJ|L7L7L7
OOOOL7IF7||L7|IL7L7|
OOOOO|FJLJ|FJ|F7|OLJ
OOOOFJL-7O||O||||OOO
OOOOL---JOLJOLJLJOOO

In this larger example, 8 tiles are enclosed by the loop.

Any tile that isn't part of the main loop can count as being enclosed by the
loop. Here's another example with many bits of junk pipe lying around that
aren't connected to the main loop at all:

FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJ7F7FJ-
L---JF-JLJ.||-FJLJJ7
|F|F-JF---7F7-L7L|7|
|FFJF7L7F-JF7|JL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L

Here are just the tiles that are enclosed by the loop marked with I:

FF7FSF7F7F7F7F7F---7
L|LJ||||||||||||F--J
FL-7LJLJ||||||LJL-77
F--JF--7||LJLJIF7FJ-
L---JF-JLJIIIIFJLJJ7
|F|F-JF---7IIIL7L|7|
|FFJF7L7F-JF7IIL---7
7-L-JL7||F7|L7F-7F7|
L.L7LFJ|||||FJL7||LJ
L7JLJL-JLJLJL--JLJ.L

In this last example, 10 tiles are enclosed by the loop.

Figure out whether you have time to search for the nest by calculating the area
within the loop. How many tiles are enclosed by the loop?
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

    [bool] $Enclosed = $false


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
            $Colour = if ($Section.Y % 2 + $Section.X % 2 -eq 1) {
                [System.Drawing.Brushes]::LightGray
            } else {
                [System.Drawing.Brushes]::DarkGray
            }
            $Graphics.FillRectangle($Colour, $ScaledX, $ScaledY, $Scale, $Scale)
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
            if ($Section.Enclosed) {
                $Graphics.FillRectangle([System.Drawing.Brushes]::Red, $ScaledX, $ScaledY, $Scale, $Scale)
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

    [int] GetEnclosedArea() {
        $Area = 0
        $Corner = ''
        for ($y = 0; $y -lt $this.Height; $y++) {
            $Enclosed = $false
            for ($x = 0; $x -lt $this.Width; $x++) {
                $Loc = $x + $y * $this.Width
                $PipeSection = $this.PipeSections[$Loc]

                if ($Enclosed -and -not $PipeSection.MainLoop) {
                    $PipeSection.Enclosed = $true
                    $Area++
                }

                if ($PipeSection.MainLoop) {
                    if ($PipeSection.Char -eq 'L' -or $PipeSection.Char -eq 'F') {
                        $Corner = $PipeSection.Char
                    } elseif ($PipeSection.Char -eq 'J') {
                        if ($Corner -eq 'L') {
                            continue
                        } elseif ($Corner -eq 'F') {
                            $Enclosed = -not $Enclosed
                        }
                        $Corner = ''
                    } elseif ($PipeSection.Char -eq '7') {
                        if ($Corner -eq 'L') {
                            $Enclosed = -not $Enclosed
                        } elseif ($Corner -eq 'F') {
                            continue
                        }
                        $Corner = ''
                    } elseif ($PipeSection.Char -eq '-') {
                        if ($Corner -ne '') {
                            continue
                        }
                    } elseif ($PipeSection.Char -eq '|') {
                        $Enclosed = -not $Enclosed
                    }
                }
            }
        }

        return $Area
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
$PipeMap.GetEnclosedArea()
$PipeMap.DrawToFile("$PSScriptRoot\Part2-Area.bmp")