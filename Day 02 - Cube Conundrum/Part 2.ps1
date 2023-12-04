<#
The Elf says they've stopped producing snow because they aren't getting any
water! He isn't sure why the water stopped; however, he can show you how to get
to the water source to check it out for yourself. It's just up ahead!

As you continue your walk, the Elf poses a second question: in each game you
played, what is the fewest number of cubes of each color that could have been in
the bag to make the game possible?

Again consider the example games from earlier:

Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green

In game 1, the game could have been played with as few as 4 red, 2 green, and 6
blue cubes. If any color had even one fewer cube, the game would have been
impossible.

Game 2 could have been played with a minimum of 1 red, 3 green, and 4 blue cubes.
Game 3 must have been played with at least 20 red, 13 green, and 6 blue cubes.
Game 4 required at least 14 red, 3 green, and 15 blue cubes.
Game 5 needed no fewer than 6 red, 3 green, and 2 blue cubes in the bag.

The power of a set of cubes is equal to the numbers of red, green, and blue
cubes multiplied together. The power of the minimum set of cubes in game 1 is
48. In games 2-5 it was 12, 1560, 630, and 36, respectively. Adding up these
five powers produces the sum 2286.

For each game, find the minimum set of cubes that must have been present. What
is the sum of the power of these sets?
#>

# Get the input data
$InputData = Get-Content "$PSScriptRoot\Inputs.txt"

# Calculate the sum of the game numbers that are possible
$InputData | ForEach-Object {
    # Split the game number and the game data
    $GameAndNum, $GameDataStr = $_ -split ': '

    # Remove the word Game and leading space, and convert to an integer to get
    # the ID of the current game.
    $GameNum = ($GameAndNum -replace 'Game ', '') -as [int64]

    # Split the game data into an array of 'cube reveals'.
    $GameData = $GameDataStr -split '; '

    # Start by assuming the game is possible
    $IsPossible = $true

    # Keep track of the maximum number of each colour of cube
    # for the current game.
    $MaxRed = 0
    $MaxGreen = 0
    $MaxBlue = 0

    # Loop over the 'cube reveals' to find the largest count of each colour.
    foreach ($Game in $GameData) {
        $Red = 0
        $Green = 0
        $Blue = 0

        # Check the count of each colour of cube
        $Game -split ', ' | ForEach-Object {
            $Num, $Color = $_ -split ' '
            switch ($Color) {
                'red' { $Red = $Num -as [int64] }
                'green' { $Green = $Num -as [int64]  }
                'blue' { $Blue = $Num -as [int64]  }
            }
        }

        # If any of the colours are larger than the current maximum, update the
        # maximum
        if ($Red -gt $MaxRed) { $MaxRed = $Red }
        if ($Green -gt $MaxGreen) { $MaxGreen = $Green }
        if ($Blue -gt $MaxBlue) { $MaxBlue = $Blue }
    }

    # Calculate the 'Cube Power' and pass it down the pipelien for summation.
    $MaxRed * $MaxGreen * $MaxBlue
} | Measure-Object -Sum | Select-Object -ExpandProperty Sum