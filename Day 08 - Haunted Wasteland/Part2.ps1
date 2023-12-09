<#
The sandstorm is upon you and you aren't any closer to escaping the wasteland.
You had the camel follow the instructions, but you've barely left your starting
position. It's going to take significantly more steps to escape!

What if the map isn't for people - what if the map is for ghosts? Are ghosts
even bound by the laws of spacetime? Only one way to find out.

After examining the maps a bit longer, your attention is drawn to a curious
fact: the number of nodes with names ending in A is equal to the number ending
in Z! If you were a ghost, you'd probably just start at every node that ends
with A and follow all of the paths at the same time until they all
simultaneously end up at nodes that end with Z.

For example:

LR

11A = (11B, XXX)
11B = (XXX, 11Z)
11Z = (11B, XXX)
22A = (22B, XXX)
22B = (22C, 22C)
22C = (22Z, 22Z)
22Z = (22B, 22B)
XXX = (XXX, XXX)

Here, there are two starting nodes, 11A and 22A (because they both end with A).
As you follow each left/right instruction, use that instruction to
simultaneously navigate away from both nodes you're currently on. Repeat this
process until all of the nodes you're currently on end with Z. (If only some of
the nodes you're on end with Z, they act like any other node and you continue as
normal.) In this example, you would proceed as follows:

Step 0: You are at 11A and 22A.
Step 1: You choose all of the left paths, leading you to 11B and 22B.
Step 2: You choose all of the right paths, leading you to 11Z and 22C.
Step 3: You choose all of the left paths, leading you to 11B and 22Z.
Step 4: You choose all of the right paths, leading you to 11Z and 22B.
Step 5: You choose all of the left paths, leading you to 11B and 22C.
Step 6: You choose all of the right paths, leading you to 11Z and 22Z.
So, in this example, you end up entirely on nodes that end in Z after 6 steps.

Simultaneously start on every node that ends with A. How many steps does it take
before you're only on nodes that end with Z?
#>

$InputData = Get-Content "$PSScriptRoot\InputData.txt"

function Find-LeastCommonMultiple {
    # Function to find the least common multiple of an array of numbers
    # http://www.wikipedia.org/wiki/Least_common_multiple#Reduction_by_the_greatest_common_divisor
    param (
        [Parameter()]
        [double[]] $Numbers
    )
    $Array = @()
    foreach ($Number in $Numbers) {
        $Sqrt = [Math]::sqrt($Number)
        $Factor = 2
        $Count = 0
        while ( ($Number % $Factor) -eq 0) {
            $count += 1
            $Number = $Number / $Factor
            if (($Array | Where-Object { $_ -eq $Factor }).Count -lt $Count) {
                $Array += $Factor
            }
        }
        $Count = 0
        $Factor = 3
        while ($Factor -le $Sqrt) {
            while ( ($Number % $Factor) -eq 0) {
                $Count += 1
                $Number = $Number / $Factor
                if (($Array | Where-Object { $_ -eq $Factor }).Count -lt $Count) {
                    $Array += $Factor
                }
            }           
            $Factor += 2
            $Count = 0
        }
        if ($Array -notcontains $Number) {
            $Array += $Number
        }
    }
    $Product = 1 -as [double]
    foreach ($Elem in $Array) {
        $Product *= $Elem
    }
    return $Product
}

$LeftRightInstructions = $InputData[0].ToCharArray()

$Paths = @()
$Nodes = @{}
$InputData[2..($InputData.Count - 1)] | ForEach-Object {
    $NodeName, $NodeDirs = $_ -split ' = '
    $NodeL,$NodeR = $NodeDirs.Replace('(', '').Replace(')', '').Split(',') | 
        ForEach-Object {$_.Trim()}
    $Nodes.Add($NodeName, @($NodeL, $NodeR))
    if ($NodeName.EndsWith('A')) {
        $Paths += $NodeName
    }
}

$PathToFinish = @()
foreach ($Path in $Paths) {
    $Steps = 0
    $Location = $Path
    $AtDestination = $false
    $Cursor = 0

    while ($AtDestination -eq $false) {
        $Steps++

        $Instruction = $LeftRightInstructions[$Cursor]
        $Cursor = (++$Cursor) % $LeftRightInstructions.Count

        $CurrentNode = $Nodes[$Location]
        if ($Instruction -eq 'L') {
            $Location = $CurrentNode[0]
        } else {
            $Location = $CurrentNode[1]
        }
        if ($Location.EndsWith('Z')) {
            $AtDestination = $true
            $PathToFinish += [PSCustomObject]@{
                StartingPath = $Path
                Steps = $Steps
            }
        }
    }
}

Find-LeastCommonMultiple $PathToFinish.Steps