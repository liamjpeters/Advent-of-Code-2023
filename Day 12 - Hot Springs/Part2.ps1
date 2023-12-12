<#
As you look out at the field of springs, you feel like there are way more
springs than the condition records list. When you examine the records, you
discover that they were actually folded up this whole time!

To unfold the records, on each row, replace the list of spring conditions with
five copies of itself (separated by ?) and replace the list of contiguous groups
of damaged springs with five copies of itself (separated by ,).

So, this row:

.# 1
Would become:

.#?.#?.#?.#?.# 1,1,1,1,1

The first line of the above example would become:

???.###????.###????.###????.###????.### 1,1,3,1,1,3,1,1,3,1,1,3,1,1,3

In the above example, after unfolding, the number of possible arrangements for
some rows is now much larger:

???.### 1,1,3 - 1 arrangement
.??..??...?##. 1,1,3 - 16384 arrangements
?#?#?#?#?#?#?#? 1,3,1,6 - 1 arrangement
????.#...#... 4,1,1 - 16 arrangements
????.######..#####. 1,6,5 - 2500 arrangements
?###???????? 3,2,1 - 506250 arrangements
After unfolding, adding all of the possible arrangement counts together produces
525152.

Unfold your condition records; what is the new sum of possible arrangement 
counts?
#>


# Get the input data
$InputData = Get-Content -Path "$PSScriptRoot\InputData.txt"

# Caching is used to speed up the calculation by not having to recalculate for
# the same input multiple times
$Cache = @{}

function Calculate($Springs, $Groups) {
    # Cache key: spring pattern + group lengths
    $Key = "$Springs,$($Groups -join ',')"

    # If the result is already cached, return it directly
    if ($Cache.ContainsKey($key)) {
        return $cache[$key]
    }
    
    # If the result is not in the cache - work it out and add it to the cache
    $Value = GetCount $Springs $Groups
    $Cache[$Key] = $Value

    # Return the calculated value
    return $Value
}

function GetCount($Springs, $Groups) {
    while ($true) {
        if ($Groups.Count -eq 0) {
            # No more groups to match - if there are no springs left, we have a
            # match
            if ($Springs.Contains('#')) { 
                return 0 
            } else { 
                return 1 
            } 
        }

        if ([string]::IsNullOrEmpty($Springs)) {
            # No more springs to match, although we still have groups to match
            return 0
        }

        if ($Springs.StartsWith('.')) {
            $Springs = $Springs.TrimStart('.')
            continue
        }

        if ($Springs.StartsWith('?')) {
            # Try both options, recursively
            return (
                Calculate ".$($Springs.Substring(1))" $Groups
            ) + (
                Calculate "#$($Springs.Substring(1))" $Groups
            )
        }

        if ($Springs.StartsWith('#')) {  # Start of a group
            if ($Groups.Count -eq 0) {
                # No more groups to match, although we still have a spring in 
                # the input
                return 0
            }

            if ($Springs.Length -lt $Groups[0]) {
                # Not enough characters to match the group
                return 0
            }

            if ($Springs.Substring(0, $Groups[0]).Contains('.')) {
                # Group cannot contain dots for the given length
                return 0
            }

            if ($Groups.Count -gt 1) {
                if (
                    $Springs.Length -lt ($Groups[0] + 1) -or 
                    $Springs[$Groups[0]] -eq '#'
                ) {
                    # Group cannot be followed by a spring, and there must be
                    # enough characters left
                    return 0
                }

                $Springs = $Springs.Substring($Groups[0] + 1)
                $Groups = $Groups[1..$Groups.Count]
                continue
            }

            $Springs = $Springs.Substring($Groups[0])
            $Groups = $Groups[1..$Groups.Count]
            continue
        }
        throw "Invalid input - we should never get here..."
    }
}

$Total = 0L

foreach ($Line in $InputData) {
    $Springs, $Groups = $Line -split ' '
    $Groups = $Groups -split ',' | ForEach-Object { [int]$_ }
    
    $SpringsArray = @()
    foreach ($Index in 1..5) {
        $SpringsArray += $Springs
    }
    $Springs = $SpringsArray -Join '?'
    $Groups = ($Groups * 5) -join ',' -split ',' | ForEach-Object { [int]$_ }

    $Total += Calculate $springs $groups
}

$Total