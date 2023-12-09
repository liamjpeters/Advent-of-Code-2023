<#
Everyone will starve if you only plant such a small number of seeds. Re-reading
the almanac, it looks like the seeds: line actually describes ranges of seed 
numbers.

The values on the initial seeds: line come in pairs. Within each pair, the first
value is the start of the range and the second value is the length of the range.
So, in the first line of the example above:

seeds: 79 14 55 13

This line describes two ranges of seed numbers to be planted in the garden. The
first range starts with seed number 79 and contains 14 values: 

79, 80, ..., 91, 92. 

The second range starts with seed number 55 and contains 13 values: 

55, 56, ..., 66, 67.

Now, rather than considering four seed numbers, you need to consider a total of
27 seed numbers.

In the above example, the lowest location number can be obtained from seed
number 82, which corresponds to soil 84, fertilizer 84, water 84, light 77, 
temperature 45, humidity 46, and location 46. So, the lowest location number is
46.

Consider all of the initial seed numbers listed in the ranges on the first line
of the almanac. What is the lowest location number that corresponds to any of
the initial seed numbers?
#>

class SeedRange {
    [int64]$Start
    [int64]$Length

    SeedRange([int64]$Start, [int64]$Length) {
        $this.Start = $Start
        $this.Length = $Length
    }

    [bool] Contains([int64]$Value) {
        return $Value -ge $this.Start -and $Value -lt ($this.Start + $this.Length)
    }

    [string] ToString() {
        return "Start: $($this.Start), Length: $($this.Length)"
    }

    [int64[]] GetFullRange() {
        return $this.Start..($this.Start + $this.Length - 1)
    }
}

class AlmanacRange {
    [int64]$DestinationStart
    [int64]$SourceStart
    [int64]$Length

    AlmanacRange([int64]$DestinationStart, [int64]$SourceStart, [int64]$Length) {
        $this.DestinationStart = $DestinationStart
        $this.SourceStart = $SourceStart
        $this.Length = $Length
    }

    [string] ToString() {
        return "DestinationStart: $($this.DestinationStart), SourceStart: $($this.SourceStart), Length: $($this.Length)"
    }

    [bool] Contains([int64]$Value) {
        return $Value -ge $this.SourceStart -and $Value -lt ($this.SourceStart + $this.Length)
    }

    [int64] Convert([int64]$Value) {
        if ($this.Contains($Value)) {
            return $this.DestinationStart + ($Value - $this.SourceStart)
        }
        return $Value
    }

    [bool] ReverseContains([int64]$Value) {
        return $Value -ge $this.DestinationStart -and $Value -lt ($this.DestinationStart + $this.Length)
    }

    [int64] ReverseConvert([int64]$Value) {
        if ($this.ReverseContains($Value)) {
            return $this.SourceStart + ($Value - $this.DestinationStart)
        }
        return $Value
    }

    static [AlmanacRange[]] GetOverlappingRanges ([AlmanacRange[]]$Source, [AlmanacRange[]]$Destination) {
        $OverlappingRanges = @()
        foreach ($SourceRange in $Source) {
            foreach ($DestinationRange in $Destination) {
                if ($SourceRange.Contains($DestinationRange.SourceStart) -or $SourceRange.Contains($DestinationRange.SourceStart + $DestinationRange.Length - 1)) {
                    $OverlappingRanges += $SourceRange
                }
            }
        }
        return $OverlappingRanges
    }

}


class Almanac {
    [SeedRange[]] $Seeds
    [AlmanacRange[]] $SeedToSoilMap = @()
    [AlmanacRange[]] $SoilToFertilizerMap = @()
    [AlmanacRange[]] $FertilizerToWaterMap = @()
    [AlmanacRange[]] $WaterToLightMap = @()
    [AlmanacRange[]] $LightToTemperatureMap = @()
    [AlmanacRange[]] $TemperatureToHumidityMap = @()
    [AlmanacRange[]] $HumidityToLocationMap = @()

    Almanac([string[]]$InputData) {
        $CurrentMap = ''
        foreach ($Line in $InputData) {
            if ($Line.StartsWith('seeds:')) {
                $this.Seeds = @()
                $SplitLine = $Line.Replace('seeds: ','').Split(' ')
                for ($i = 0; $i -lt $SplitLine.Count; $i+=2) {
                    $this.Seeds += [SeedRange]::new($SplitLine[$i], $SplitLine[$i+1])
                }
            } elseif ($Line.StartsWith('seed-to-soil map:')) {
                $CurrentMap = 'SeedToSoilMap'
            } elseif ($Line.StartsWith('soil-to-fertilizer map:')) {
                $CurrentMap = 'SoilToFertilizerMap'
            } elseif ($Line.StartsWith('fertilizer-to-water map:')) {
                $CurrentMap = 'FertilizerToWaterMap'
            } elseif ($Line.StartsWith('water-to-light map:')) {
                $CurrentMap = 'WaterToLightMap'
            } elseif ($Line.StartsWith('light-to-temperature map:')) {
                $CurrentMap = 'LightToTemperatureMap'
            } elseif ($Line.StartsWith('temperature-to-humidity map:')) {
                $CurrentMap = 'TemperatureToHumidityMap'
            } elseif ($Line.StartsWith('humidity-to-location map:')) {
                $CurrentMap = 'HumidityToLocationMap'
            } elseif ($Line -match '(\d+) (\d+) (\d+)') {
                $AlmanacRange = [AlmanacRange]::new($Matches[1], $Matches[2], $Matches[3])
                switch ($CurrentMap) {
                    'SeedToSoilMap' { $this.SeedToSoilMap += $AlmanacRange }
                    'SoilToFertilizerMap' { $this.SoilToFertilizerMap += $AlmanacRange }
                    'FertilizerToWaterMap' { $this.FertilizerToWaterMap += $AlmanacRange }
                    'WaterToLightMap' { $this.WaterToLightMap += $AlmanacRange }
                    'LightToTemperatureMap' { $this.LightToTemperatureMap += $AlmanacRange }
                    'TemperatureToHumidityMap' { $this.TemperatureToHumidityMap += $AlmanacRange }
                    'HumidityToLocationMap' { $this.HumidityToLocationMap += $AlmanacRange }
                    Default {
                        Write-Error "Unknown map: $CurrentMap"
                    }
                }
            }
        }
    }

    [AlmanacRange[]] GetOverlappingRanges([SeedRange[]] $SeedRanges, [AlmanacRange[]] $Maps) {
        $OverlappingRanges = @()
        foreach ($SeedRange in $SeedRanges) {
            foreach ($Map in $Maps) {
                if ($Map.Contains($SeedRange.Start)) {
                    $SourceStart = $SeedRange.Start
                    $DestinationStart = $Map.Convert($SourceStart)
                    $Length = if ($Map.Contains($SeedRange.Start + $SeedRange.Length - 1)) {
                        $SeedRange.Length
                    } else {
                        $Map.DestinationStart + $Map.Length - 1

                    }
                    $OverlappingRanges += [AlmanacRange]::new(
                        $SourceStart, 
                        $DestinationStart,
                        $Length
                    )
                } elseif ($Map.Contains($SeedRange.Start + $SeedRange.Length - 1)) {
                    $SourceStart = $Map.SourceStart
                    $DestinationStart = $Map.DestinationStart
                    $Length = $SeedRange.Start + $SeedRange.Length - 1 - $SourceStart
                    $OverlappingRanges += [AlmanacRange]::new(
                        $SourceStart, 
                        $DestinationStart,
                        $Length
                    )
                }
            }
        }
        return $OverlappingRanges
    }

    [AlmanacRange[]] GetOverlappingRanges([AlmanacRange[]] $Source, [AlmanacRange[]] $Destination) {
        $OverlappingRanges = @()
        foreach ($SeedRange in $Source) {
            foreach ($Map in $Destination) {
                if ($Map.Contains($SeedRange.Start)) {
                    $SourceStart = $SeedRange.Start
                    $DestinationStart = $Map.Convert($SourceStart)
                    $Length = if ($Map.Contains($SeedRange.Start + $SeedRange.Length - 1)) {
                        $SeedRange.Length
                    } else {
                         $Map.DestinationStart + $Map.Length - 1

                    }
                    $OverlappingRanges += [AlmanacRange]::new(
                        $SourceStart, 
                        $DestinationStart,
                        $Length
                    )
                } elseif ($Map.Contains($SeedRange.Start + $SeedRange.Length - 1)) {
                    $SourceStart = $Map.SourceStart
                    $DestinationStart = $Map.DestinationStart
                    $Length = $SeedRange.Start + $SeedRange.Length - 1 - $SourceStart
                    $OverlappingRanges += [AlmanacRange]::new(
                        $SourceStart, 
                        $DestinationStart,
                        $Length
                    )
                }
            }
        }
        return $OverlappingRanges
    }

    [AlmanacRange[]] FlattenMappings() {
        $SeedsToSoil = $this.GetOverlappingRanges($this.Seeds, $this.SeedToSoilMap)
        $SeedsToFertilizer = $this.GetOverlappingRanges($SeedsToSoil, $this.SoilToFertilizerMap)
        $SeedsToWater = $this.GetOverlappingRanges($SeedsToFertilizer, $this.FertilizerToWaterMap)
        $SeedsToLight = $this.GetOverlappingRanges($SeedsToWater, $this.WaterToLightMap)
        $SeedsToTemperature = $this.GetOverlappingRanges($SeedsToLight, $this.LightToTemperatureMap)
        $SeedsToHumidity = $this.GetOverlappingRanges($SeedsToTemperature, $this.TemperatureToHumidityMap)
        $SeedsToLocation = $this.GetOverlappingRanges($SeedsToHumidity, $this.HumidityToLocationMap)
        return $SeedsToLocation
        
    }

    [int64] ConvertSeedToSoil([int64]$Seed) {
        foreach ($Range in $this.SeedToSoilMap) {
            if ($Range.Contains($Seed)) {
                return $Range.Convert($Seed)
            }
        }
        return $Seed
    }

    [int64] ConvertSoilToFertilizer([int64]$Soil) {
        foreach ($Range in $this.SoilToFertilizerMap) {
            if ($Range.Contains($Soil)) {
                return $Range.Convert($Soil)
            }
        }
        return $Soil
    }

    [int64] ConvertFertilizerToWater([int64]$Fertilizer) {
        foreach ($Range in $this.FertilizerToWaterMap) {
            if ($Range.Contains($Fertilizer)) {
                return $Range.Convert($Fertilizer)
            }
        }
        return $Fertilizer
    }

    [int64] ConvertWaterToLight([int64]$Water) {
        foreach ($Range in $this.WaterToLightMap) {
            if ($Range.Contains($Water)) {
                return $Range.Convert($Water)
            }
        }
        return $Water
    }

    [int64] ConvertLightToTemperature([int64]$Light) {
        foreach ($Range in $this.LightToTemperatureMap) {
            if ($Range.Contains($Light)) {
                return $Range.Convert($Light)
            }
        }
        return $Light
    }

    [int64] ConvertTemperatureToHumidity([int64]$Temperature) {
        foreach ($Range in $this.TemperatureToHumidityMap) {
            if ($Range.Contains($Temperature)) {
                return $Range.Convert($Temperature)
            }
        }
        return $Temperature
    }

    [int64] ConvertHumidityToLocation([int64]$Humidity) {
        foreach ($Range in $this.HumidityToLocationMap) {
            if ($Range.Contains($Humidity)) {
                return $Range.Convert($Humidity)
            }
        }
        return $Humidity
    }

    [int64] ConvertSeedToLocation([int64]$Seed) {
        $Soil = $this.ConvertSeedToSoil($Seed)
        $Fertilizer = $this.ConvertSoilToFertilizer($Soil)
        $Water = $this.ConvertFertilizerToWater($Fertilizer)
        $Light = $this.ConvertWaterToLight($Water)
        $Temperature = $this.ConvertLightToTemperature($Light)
        $Humidity = $this.ConvertTemperatureToHumidity($Temperature)
        $Location = $this.ConvertHumidityToLocation($Humidity)
        return $Location
    }

    [int64] ConvertSoilToSeed([int64]$Soil) {
        foreach ($Range in $this.SeedToSoilMap) {
            if ($Range.ReverseContains($Soil)) {
                return $Range.ReverseConvert($Soil)
            }
        }
        return $Soil
    }

    [int64] ConvertFertilizerToSoil([int64]$Fertilizer) {
        foreach ($Range in $this.SoilToFertilizerMap) {
            if ($Range.ReverseContains($Fertilizer)) {
                return $Range.ReverseConvert($Fertilizer)
            }
        }
        return $Fertilizer
    }

    [int64] ConvertWaterToFertilizer([int64]$Water) {
        foreach ($Range in $this.FertilizerToWaterMap) {
            if ($Range.ReverseContains($Water)) {
                return $Range.ReverseConvert($Water)
            }
        }
        return $Water
    }

    [int64] ConvertLightToWater([int64]$Light) {
        foreach ($Range in $this.WaterToLightMap) {
            if ($Range.ReverseContains($Light)) {
                return $Range.ReverseConvert($Light)
            }
        }
        return $Light
    }

    [int64] ConvertTemperatureToLight([int64]$Temperature) {
        foreach ($Range in $this.LightToTemperatureMap) {
            if ($Range.ReverseContains($Temperature)) {
                return $Range.ReverseConvert($Temperature)
            }
        }
        return $Temperature
    }

    [int64] ConvertHumidityToTemperature([int64]$Humidity) {
        foreach ($Range in $this.TemperatureToHumidityMap) {
            if ($Range.ReverseContains($Humidity)) {
                return $Range.ReverseConvert($Humidity)
            }
        }
        return $Humidity
    }

    [int64] ConvertLocationToHumidity([int64]$Location) {
        foreach ($Range in $this.HumidityToLocationMap) {
            if ($Range.ReverseContains($Location)) {
                return $Range.ReverseConvert($Location)
            }
        }
        return $Location
    }

    [int64] ConvertLocationToSeed([int64]$Location) {
        $Humidity = $this.ConvertLocationToHumidity($Location)
        $Temperature = $this.ConvertHumidityToTemperature($Humidity)
        $Light = $this.ConvertTemperatureToLight($Temperature)
        $Water = $this.ConvertLightToWater($Light)
        $Fertilizer = $this.ConvertWaterToFertilizer($Water)
        $Soil = $this.ConvertFertilizerToSoil($Fertilizer)
        $Seed = $this.ConvertSoilToSeed($Soil)
        return $Seed
    }

    [string] ToString() {
        $StringBuilder = [System.Text.StringBuilder]::new()
        $StringBuilder.AppendLine("Seeds:") | Out-Null
        $this.Seeds | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine() | Out-Null
        $StringBuilder.AppendLine("SeedToSoilMap:") | Out-Null
        $this.SeedToSoilMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine() | Out-Null
        $StringBuilder.AppendLine("SoilToFertilizerMap:") | Out-Null
        $this.SoilToFertilizerMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine() | Out-Null
        $StringBuilder.AppendLine("FertilizerToWaterMap:") | Out-Null
        $this.FertilizerToWaterMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine() | Out-Null
        $StringBuilder.AppendLine("WaterToLightMap:") | Out-Null
        $this.WaterToLightMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine() | Out-Null
        $StringBuilder.AppendLine("LightToTemperatureMap:") | Out-Null
        $this.LightToTemperatureMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine() | Out-Null
        $StringBuilder.AppendLine("TemperatureToHumidityMap:") | Out-Null
        $this.TemperatureToHumidityMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine() | Out-Null
        $StringBuilder.AppendLine("HumidityToLocationMap:") | Out-Null
        $this.HumidityToLocationMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine() | Out-Null
        return $StringBuilder.ToString()
    }

}

$InputData = Get-Content "$PSScriptRoot\TestInputs.txt"

$Almanac = [Almanac]::new($InputData)

# for ([int64] $i = 0; $i -lt [int64]::MaxValue; $i++) {
#     $Seed = $Almanac.ConvertLocationToSeed($i)
#     $Almanac.Seeds | ForEach-Object {
#         if ($_.Contains($Seed)) {
#             Write-Host "Found lowest location $i for seed $Seed"
#             exit
#         }
#     }
# }
