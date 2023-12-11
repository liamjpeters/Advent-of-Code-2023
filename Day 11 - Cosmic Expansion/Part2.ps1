<#
The galaxies are much older (and thus much farther apart) than the researcher
initially estimated.

Now, instead of the expansion you did before, make each empty row or column one
million times larger. That is, each empty row should be replaced with 1000000
empty rows, and each empty column should be replaced with 1000000 empty columns.

(In the example above, if each empty row or column were merely 10 times larger,
the sum of the shortest paths between every pair of galaxies would be 1030. If
each empty row or column were merely 100 times larger, the sum of the shortest
paths between every pair of galaxies would be 8410. However, your universe will
need to expand far beyond these values.)

Starting with the same initial image, expand the universe according to these new
rules, then find the length of the shortest path between every pair of galaxies.
What is the sum of these lengths?
#>

# Get the input Data
$InputData = Get-Content "$PSScriptRoot/InputData.txt"

class GalaxyMap {
    [int] $Width = 0
    [int] $Height = 0
    [int[]] $EmptyRows = @()
    [int[]] $EmptyColumns = @()
    [Object[]] $Map
    [PSCustomObject[]] $Galaxies = @()
    [int] $GalaxyCount = 0
    [int] $UniquePairings = 0
    [hashtable] $GalaxyPairings = @{}

    GalaxyMap([Object[]] $InputData) {
        $this.Map = $InputData
        $this.Width = $this.Map[0].Length
        $this.Height = $this.Map.Length
        $this.Galaxies = [GalaxyMap]::FindAllGalaxies($this.Map)
        $this.GalaxyCount = $this.Galaxies.Count
        $this.FindEmptyRowsAndColumns()
    }

    [void] FindEmptyRowsAndColumns() {
        for ($Row = 0; $Row -lt $this.Height; $Row++) {
            $RowHasGalaxy = $false
            for ($Column = 0; $Column -lt $this.Width; $Column++) {
                if ($this.Map[$Row][$Column] -eq '#') {
                    $RowHasGalaxy = $true
                    break
                }
            }
            if (-not $RowHasGalaxy) {
                $this.EmptyRows += $Row
            }
        }

        for ($Column = 0; $Column -lt $this.Width; $Column++) {
            $ColumnHasGalaxy = $false
            for ($Row = 0; $Row -lt $this.Height; $Row++) {
                if ($this.Map[$Row][$Column] -eq '#') {
                    $ColumnHasGalaxy = $true
                    break
                }
            }
            if (-not $ColumnHasGalaxy) {
                $this.EmptyColumns += $Column
            }
        }
    }

    static [Object[]] ExpandUniverse([Object[]] $InputData) {
        $GalaxyWidth = $InputData[0].Length
        $GalaxyHeight = $InputData.Length

        $EmptyRws = @()
        $EmptyClumns = @()

        for ($Row = 0; $Row -lt $GalaxyHeight; $Row++) {
            $RowHasGalaxy = $false
            for ($Column = 0; $Column -lt $GalaxyWidth; $Column++) {
                if ($InputData[$Row][$Column] -eq '#') {
                    $RowHasGalaxy = $true
                    break
                }
            }
            if (-not $RowHasGalaxy) {
                $EmptyRws += $Row
            }
        }

        for ($Column = 0; $Column -lt $GalaxyWidth; $Column++) {
            $ColumnHasGalaxy = $false
            for ($Row = 0; $Row -lt $GalaxyHeight; $Row++) {
                if ($InputData[$Row][$Column] -eq '#') {
                    $ColumnHasGalaxy = $true
                    break
                }
            }
            if (-not $ColumnHasGalaxy) {
                $EmptyClumns += $Column
            }
        }

        [Array]::Reverse($EmptyRws)
        [Array]::Reverse($EmptyClumns)

        $InputDataArrayList = [System.Collections.ArrayList]::new($InputData)

        foreach ($Row in $EmptyRws) {
            $InputDataArrayList.Insert($Row, $InputData[$Row])
        }
        $GalaxyHeight = $InputDataArrayList.Count
        foreach ($Col in $EmptyClumns) {
            for ($Row = 0; $Row -lt $GalaxyHeight; $Row++) {
                $InputDataArrayList[$Row] = $InputDataArrayList[$Row].Insert($Col, '.')
            }
        }
        return $InputDataArrayList.ToArray()
    }

    static [PSCustomObject[]] FindAllGalaxies([Object[]] $Map) {
        $Gals = @()
        $GalaxyNumber = 1
        for ($Row = 0; $Row -lt $Map.Length; $Row++) {
            for ($Column = 0; $Column -lt $Map[$Row].Length; $Column++) {
                if ($Map[$Row][$Column] -eq '#') {
                    $Galaxy = [PSCustomObject]@{
                        Number = $GalaxyNumber
                        Row = $Row
                        Column = $Column
                    }
                    $Gals += $Galaxy
                    $GalaxyNumber++
                }
            }
        }
        return $Gals
    }

    [int] GetEmptyRows([int] $RowA, [int] $RowB) {
        # If there's not at least one row between the two rows, there cannot be
        # an empty row between them.
        if ([Math]::Abs($RowA - $RowB) -le 1) {
            return 0
        }
        $Num = 0
        foreach ($EmptyRow in $this.EmptyRows) {
            if (
                ($EmptyRow -lt $RowA -and $EmptyRow -gt $RowB) -or 
                ($EmptyRow -gt $RowA -and $EmptyRow -lt $RowB)
            ) {
                $Num++
            }
        }
        return $Num
    }

    [int] GetEmptyCols([int] $ColA, [int] $ColB) {
        # If there's not at least one col between the two cols, there cannot be
        # an empty col between them.
        if ([Math]::Abs($ColA - $ColB) -le 1) {
            return 0
        }
        $Num = 0
        foreach ($EmptyCol in $this.EmptyColumns) {
            if (
                ($EmptyCol -lt $ColA -and $EmptyCol -gt $ColB) -or 
                ($EmptyCol -gt $ColA -and $EmptyCol -lt $ColB)
            ) {
                $Num++
            }
        }
        return $Num
    }

    [void] FindPairings() {
        # Loop over every galaxy.
        # For each galaxy, loop over every other galaxy.
        # Check if we've already seen this galaxy pairing (based on hashtable 
        # key). If we haven't, add it to the hashtable with they key 
        # "(smallest galaxy number), (largest galaxy number)"
        # If we have, skip it.
        $ExtraRows = 1000000
        $ExtraCols = 1000000
        for ($GalaxyIndex = 0; $GalaxyIndex -lt $this.GalaxyCount; $GalaxyIndex++) {
            $Galaxy = $this.Galaxies[$GalaxyIndex]
            for ($OtherGalaxyIndex = $GalaxyIndex + 1; $OtherGalaxyIndex -lt $this.GalaxyCount; $OtherGalaxyIndex++) {
                $OtherGalaxy = $this.Galaxies[$OtherGalaxyIndex]
                $GalaxyPairing = "$($Galaxy.number), $($OtherGalaxy.number)"
                if (-not $this.GalaxyPairings.ContainsKey($GalaxyPairing)) {
                    $HDist = [Math]::Abs($Galaxy.Column - $OtherGalaxy.Column) + (($ExtraCols - 1) * $this.GetEmptyCols($Galaxy.Column, $OtherGalaxy.Column))
                    $VDist = [Math]::Abs($Galaxy.Row - $OtherGalaxy.Row) + (($ExtraRows - 1) * $this.GetEmptyRows($Galaxy.Row, $OtherGalaxy.Row))
                    $Distance = $HDist + $VDist
                    $this.GalaxyPairings.Add($GalaxyPairing, $Distance)
                }
            }
        }
    }

}

$GalaxyMap = [GalaxyMap]::new($InputData)

$GalaxyMap.FindPairings()

$GalaxyMap.GalaxyPairings.Values | 
    Measure-Object -Sum | 
    Select-Object -ExpandProperty Sum