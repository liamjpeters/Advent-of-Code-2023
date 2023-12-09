<#
As the race is about to start, you realize the piece of paper with race times
and record distances you got earlier actually just has very bad kerning. There's
really only one race - ignore the spaces between the numbers on each line.

So, the example from before:

Time:      7  15   30
Distance:  9  40  200

...now instead means this:

Time:      71530
Distance:  940200

Now, you have to figure out how many ways there are to win this single race. In
this example, the race lasts for 71530 milliseconds and the record distance you
need to beat is 940200 millimeters. You could hold the button anywhere from 14
to 71516 milliseconds and beat the record, a total of 71503 ways!

How many ways can you beat the record in this one much longer race?
#>

# Load the input data
$InputData = Get-Content "$PSScriptRoot\InputData.txt"

# Parse the input data
$Race = [PSCustomObject]@{
    Time = $InputData[0].Replace('Time: ', '').Replace(' ', '') -as [int64]
    Distance = $InputData[1].Replace('Distance: ', '').Replace(' ', '') -as [int64]
}

Write-Host "Time: $($Race.Time), Distance: $($Race.Distance)"

# Determine the least number of milliseconds you can hold the button for and 
# beat the record.
for ($i = 1; $i -lt $Race.Time; $i++) {
    # Distanace = Time * Speed
    $Distance = $i * ($Race.Time - $i)
    if ($Distance -gt $Race.Distance) {
        Write-Host "  Hold the button for $i milliseconds to beat the record."
        # Number of ways you can win the race is the total time, minus the
        # time you hold the button for - twice.
        $WaysToWin = $Race.Time - ($i * 2) + 1
        Write-Host "  There are $WaysToWin ways to win"
        break
    }
}