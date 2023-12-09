<#
To make things a little more interesting, the Elf introduces one additional
rule. Now, J cards are jokers - wildcards that can act like whatever card would
make the hand the strongest type possible.

To balance this, J cards are now the weakest individual cards, weaker even than
2. The other cards stay in the same order: 

A, K, Q, T, 9, 8, 7, 6, 5, 4, 3, 2, J.

J cards can pretend to be whatever card is best for the purpose of determining
hand type; for example, QJJQ2 is now considered four of a kind. However, for the
purpose of breaking ties between two hands of the same type, J is always treated
as J, not the card it's pretending to be: JKKK2 is weaker than QQQQ2 because J
is weaker than Q.

Now, the above example goes very differently:

32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483

32T3K is still the only one pair; it doesn't contain any jokers, so its strength
doesn't increase.

KK677 is now the only two pair, making it the second-weakest hand.
T55J5, KTJJT, and QQQJA are now all four of a kind! T55J5 gets rank 3, QQQJA
gets rank 4, and KTJJT gets rank 5.
With the new joker rule, the total winnings in this example are 5905.

Using the new joker rule, find the rank of every hand in your set. What are the
new total winnings?
#>

# Get the input data
$InputData = Get-Content -Path "$PSScriptRoot\InputData.txt"

# List out the various types of hands
$FiveOfAKind = '5'
$FourOfAkind = '4,1'
$FullHouse = '3,2'
$ThreeOfAKind = '3,1,1'
$TwoPair = '2,2,1'
$OnePair = '2,1,1,1'
$HighCard = '1,1,1,1,1'

$Hands = @()
foreach ($Line in $InputData) {
	# Split the input line into the cards and the bid
	$Cards, $Bid = $Line.Split(' ')

	# Convert the cards to digits and sort the descending
	$CardsAsDigits = $Cards.ToCharArray() | ForEach-Object {
		switch ($_) {
			'A' { 14 }
			'K' { 13 }
			'Q' { 12 }
			'J' { 11 }
			'T' { 10 }
			default { [int]"$_" }
		}
	}

	# Generate a handtype string. i.e. if we have 'AAAKQ' and we group these,
	# we have 3 aces, 1 king, and 1 queen. So the handtype string would be
	# 3,1,1. This maps to the $ThreeOfAKind variable above.
	$CardDigitsGrouped = $CardsAsDigits | 
		Group-Object -NoElement
    
    # Jacks (11) are now wildcards. Count how many Jacks we have.
    $WildCardCount = $CardDigitsGrouped | 
        Where-Object Name -eq 11 |
        Select-Object -expand Count

    # If we have 1-4 wildcards, we take however many Jacks we have and 
    # add it onto the most common card. This will give us the best hand
    if ($WildCardCount -gt 0 -and $WildCardCount -lt 5) {
        $CardDigitsGrouped = $CardDigitsGrouped.Where({$_.Name -ne 11})
        $CardDigitsGrouped = $CardDigitsGrouped | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Count = $_.Count
            }
        } | Sort-Object Count, Name -Descending
        $CardDigitsGrouped[0].Count += $WildCardCount
    }

    # Build the handtype string
    $HandTypeString = $CardDigitsGrouped |
		Select-Object -Expand Count | 
		Sort-Object -Descending |
		Join-String -Separator ','
	
	# Give a numerical value to the handtype so we can do the initial sort
	$HandType = switch ($HandTypeString) {
		$HighCard { 1; break }
		$OnePair { 2; break }
		$TwoPair { 3; break }
		$ThreeOfAKind { 4; break }
		$FullHouse { 5; break }
		$FourOfAkind { 6; break }
		$FiveOfAKind { 7; break }
		default { 0; break }
	}

	# If we have two hands of the same type, we need to then sort them based on
	# their cards. So we convert the cards to a string array, padding any single
	# digits to 2 characters, with leading zeros. This ensures they sort
	# correctly.
	$HandSort = $CardsAsDigits | ForEach-Object {
        # Devalue Jacks (11) to 01 for sorting purposes
        if ($_ -eq '11') {
            '01'
        } else {
			'{0:d2}' -f [int32]$_
        }
		} | Join-String -Separator ','
	
	# Build the hand object.
	$Hand = [PSCustomObject]@{
		Cards = $Line.Split(' ')[0]
		CardsAsDigits = $CardsAsDigits
		Bid   = [int]$Line.Split(' ')[1] -as [int]
		HandType = $HandType
		HandSort = $HandSort
		HandRank = 0
		Winnings = 0
	}
	$Hands += $Hand
}

# Sort the hands, first on their Hand Type (descending) so the best hands are
# at the top and the worst hands are at the bottom. Then sort on the Hand Sort
# value, descending. This sorts the hands within the same hand type. So all of
# the four of a kind hands are sorted by comparing the value of each card.
$Hands = $Hands | Sort-Object -Property @(
	@{
		Expression={$_.HandType}
		Descending=$true
	}
	@{
		Expression={$_.HandSort}
		Descending=$true
	}
)

# Determine the number of hands. We can use this as our max value and assign
# the rank to each hand as we go through the list.
$NumItems = $Hands.Count
for ($i = 0; $i -lt $Hands.Count; $i++) {
	$Hands[$i].HandRank = $NumItems - $i
	$Hands[$i].Winnings = $Hands[$i].Bid * $Hands[$i].HandRank
}

$Hands | Measure-Object -Sum Winnings | Select-Object -Expand Sum