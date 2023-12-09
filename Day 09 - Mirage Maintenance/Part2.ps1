<#
Of course, it would be nice to have even more history included in your report.
Surely it's safe to just extrapolate backwards as well, right?

For each history, repeat the process of finding differences until the sequence 
of differences is entirely zero. Then, rather than adding a zero to the end and
filling in the next values of each previous sequence, you should instead add a
zero to the beginning of your sequence of zeroes, then fill in new first values
for each previous sequence.

In particular, here is what the third example history looks like when
extrapolating back in time:

5  10  13  16  21  30  45
  5   3   3   5   9  15
   -2   0   2   4   6
      2   2   2   2
        0   0   0

Adding the new values on the left side of each sequence from bottom to top
eventually reveals the new left-most history value: 5.

Doing this for the remaining example data above results in previous values of -3
for the first history and 0 for the second history. Adding all three new values
together produces 2.

Analyze your OASIS report again, this time extrapolating the previous value for
each history. What is the sum of these extrapolated values?
#>


# Get the input data
$InputData = Get-Content "$PSScriptRoot\InputData.txt"

# Running total of the predicted values
$SumOfPredictedValues = 0

foreach ($Line in $InputData) {

    # Parse the line into an array of integers
    $Dataset = $Line.Split(' ').ForEach{[int]$_}
    
    # Create a list of arrays, at least long enough to hold a number of arrays equal
    # to the number of elements in the dataset.
    $Sequences = [System.Collections.ArrayList]::new($Dataset.Count)
    
    # Add the original dataset to the list
    $Sequences.Add($Dataset) | Out-Null
    
    # Continue through the sequences until we have a sequence of all zeros
    $AllZeros = $false
    while (-not $AllZeros) {
        $LastSequence = $Sequences[-1]

        # Create a new array that is 1 shorter than the previous array
        $NewSequence = [int[]]::new($LastSequence.Count - 1)

        # Calculate the value of the new sequence with the difference of 
        # adjacent values in the previous sequence
        for ($i = 1; $i -lt $LastSequence.Count; $i++) {
            $NewSequence[$i-1] = $LastSequence[$i] - $LastSequence[$i - 1]
        }

        # Add the new sequence to the list
        $Sequences.Add($NewSequence) | Out-Null

        # Check if the last sequence was a list of all zeros by counting how
        # many of the elements were zero and comparing that to the length of
        # the array
        $NumElements = $NewSequence.Count
        $NumZeros = ($NewSequence -eq 0).count
        $AllZeros = $NumElements -eq $NumZeros
    }
    
    $PredictedValue = 0
    # Iterate backwards over the sequence
    for ($i = $Sequences.Count - 2; $i -ge 0; $i--) {
        $PredictedValue = $Sequences[$i][0] - $PredictedValue
    }
    # Add this predicted value to the running total
    $SumOfPredictedValues += $PredictedValue
}

$SumOfPredictedValues