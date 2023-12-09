function Find-LCM {
    PARAM (
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