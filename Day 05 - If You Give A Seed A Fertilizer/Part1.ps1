<#
You take the boat and find the gardener right where you were told he would be:
managing a giant "garden" that looks more to you like a farm.

"A water source? Island Island is the water source!" You point out that Snow
Island isn't receiving any water.

"Oh, we had to stop the water because we ran out of sand to filter it with! 
Can't make snow with dirty water. Don't worry, I'm sure we'll get more sand
soon; we only turned off the water a few days... weeks... oh no." His face sinks
into a look of horrified realization.

"I've been so busy making sure everyone here has food that I completely forgot
to check why we stopped getting more sand! There's a ferry leaving soon that is
headed over in that direction - it's much faster than your boat. Could you
please go check it out?"

You barely have time to agree to this request when he brings up another. "While
you wait for the ferry, maybe you can help us with our food production problem.
The latest Island Island Almanac just arrived and we're having trouble making
sense of it."

The almanac (your puzzle input) lists all of the seeds that need to be planted.
It also lists what type of soil to use with each kind of seed, what type of
fertilizer to use with each kind of soil, what type of water to use with each
kind of fertilizer, and so on. Every type of seed, soil, fertilizer and so on is
identified with a number, but numbers are reused by each category - that is,
soil 123 and fertilizer 123 aren't necessarily related to each other.

For example:

seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4

The almanac starts by listing which seeds need to be planted: seeds 79, 14, 55,
and 13.

The rest of the almanac contains a list of maps which describe how to convert
numbers from a source category into numbers in a destination category. That is,
the section that starts with seed-to-soil map: describes how to convert a seed
number (the source) to a soil number (the destination). This lets the gardener
and his team know which soil to use with which seeds, which water to use with
which fertilizer, and so on.

Rather than list every source number and its corresponding destination number
one by one, the maps describe entire ranges of numbers that can be converted.
Each line within a map contains three numbers: the destination range start, the
source range start, and the range length.

Consider again the example seed-to-soil map:

50 98 2
52 50 48

The first line has a destination range start of 50, a source range start of 98,
and a range length of 2. This line means that the source range starts at 98 and
contains two values: 98 and 99. The destination range is the same length, but it
starts at 50, so its two values are 50 and 51. With this information, you know
that seed number 98 corresponds to soil number 50 and that seed number 99
corresponds to soil number 51.

The second line means that the source range starts at 50 and contains 48 values:
50, 51, ..., 96, 97. This corresponds to a destination range starting at 52 and
also containing 48 values: 52, 53, ..., 98, 99. So, seed number 53 corresponds
to soil number 55.

Any source numbers that aren't mapped correspond to the same destination number.
So, seed number 10 corresponds to soil number 10.

So, the entire list of seed numbers and their corresponding soil numbers looks
like this:

seed  soil
0     0
1     1
...   ...
48    48
49    49
50    52
51    53
...   ...
96    98
97    99
98    50
99    51

With this map, you can look up the soil number required for each initial seed
number:

Seed number 79 corresponds to soil number 81.
Seed number 14 corresponds to soil number 14.
Seed number 55 corresponds to soil number 57.
Seed number 13 corresponds to soil number 13.

The gardener and his team want to get started as soon as possible, so they'd
like to know the closest location that needs a seed. Using these maps, find the
lowest location number that corresponds to any of the initial seeds. To do this,
you'll need to convert each seed number through other categories until you can
find its corresponding location number. In this example, the corresponding types
are:

Seed 79, soil 81, fertilizer 81, water 81, light 74, temperature 78, humidity 78, location 82.
Seed 14, soil 14, fertilizer 53, water 49, light 42, temperature 42, humidity 43, location 43.
Seed 55, soil 57, fertilizer 57, water 53, light 46, temperature 82, humidity 82, location 86.
Seed 13, soil 13, fertilizer 52, water 41, light 34, temperature 34, humidity 35, location 35.

So, the lowest location number in this example is 35.

What is the lowest location number that corresponds to any of the initial seed
numbers?
#>

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
}

class Almanac {
    [int64[]] $Seeds
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
                $this.Seeds = $Line.Replace('seeds: ','').Split(' ')| ForEach-Object { [int64]$_ }
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

    [string] ToString() {
        $StringBuilder = [System.Text.StringBuilder]::new()
        $StringBuilder.AppendLine("Seeds: $($this.Seeds -join ', ')") | Out-Null
        $StringBuilder.AppendLine("SeedToSoilMap:") | Out-Null
        $this.SeedToSoilMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine("SoilToFertilizerMap:") | Out-Null
        $this.SoilToFertilizerMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine("FertilizerToWaterMap:") | Out-Null
        $this.FertilizerToWaterMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine("WaterToLightMap:") | Out-Null
        $this.WaterToLightMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine("LightToTemperatureMap:") | Out-Null
        $this.LightToTemperatureMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine("TemperatureToHumidityMap:") | Out-Null
        $this.TemperatureToHumidityMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        $StringBuilder.AppendLine("HumidityToLocationMap:") | Out-Null
        $this.HumidityToLocationMap | ForEach-Object { 
            $StringBuilder.AppendLine($_.ToString()) 
        } | Out-Null
        return $StringBuilder.ToString()
    }

}

$InputData = Get-Content "$PSScriptRoot\Inputs.txt"

$Almanac = [Almanac]::new($InputData)

$Locations = $Almanac.Seeds | ForEach-Object { 
    $Almanac.ConvertSeedToLocation($_) 
}

$Locations | Sort-Object | Select-Object -First 1