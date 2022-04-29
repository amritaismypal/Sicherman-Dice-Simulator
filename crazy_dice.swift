import Foundation

let usageString =
"""
OVERVIEW: A program of finding Sicherman Dice

USAGE: swift crazy-dice.swift

OPTIONS
    <k>: Number of sides on dice (6 if no value is given)
"""

let numberOfSides: Int
if CommandLine.arguments.count <= 2 {
    if CommandLine.arguments.count == 2,
       let arg = Int(CommandLine.arguments[1]),
       arg > 0 {
        numberOfSides = arg
    } else {
        numberOfSides = 6
    }
} else {
    print(usageString)
    exit(1)
}
let smallestDie = Array(repeating: 1, count: numberOfSides)
let largestDie = Array(repeating: 2 * numberOfSides - 1, count: numberOfSides)
let standardDie = Array((1...numberOfSides).reversed())
let standardDistribution = distribution(standardDie, standardDie)

let startTime = ProcessInfo.processInfo.systemUptime
searchAndDisplayCrazyDice()
// searchAndDisplayCrazyDiceFast() // REPLACE LINE ABOVE WITH THIS TO TEST PART 6
let totalTime = ProcessInfo.processInfo.systemUptime - startTime
print("Search took \(totalTime) seconds")

func distribution(_ die1: [Int], _ die2: [Int]) -> [Int: Int] {
    var dict: [Int: Int] = [:]
    for side1 in die1 {
        for side2 in die2 {
            let sum = side1 + side2
            if dict[sum] != nil {
                dict[sum]! += 1
            } else {
                dict[sum] = 1
            }
        }
    }
    return dict
}

print(standardDistribution)

print(distribution(smallestDie, smallestDie))

print(distribution(largestDie, largestDie))

print(distribution(smallestDie, largestDie))

func nextDie(after die: [Int]) -> [Int] {
    var dieCopy = die
    let dieLength = die.count
    if dieCopy == largestDie {
        return dieCopy
    }
    var incrementIndex = 0
    var counter: Int = dieLength - 1
    while counter > 0 {
        if die[counter] < die[counter - 1] {
            incrementIndex = counter
            break
        }
        counter -= 1
    }

    dieCopy[incrementIndex] += 1

    if incrementIndex < (dieLength - 1) && dieCopy[incrementIndex + 1] != 1 {
        for index in (incrementIndex + 1)...(dieLength - 1) {
            dieCopy[index] = 1
        }
    }
    return dieCopy
}

// YOU CAN UNCOMMENT THESE ASSERTIONS TO TEST
// I WOULD RECOMMEND WRITING A COUPLE OF YOUR OWN, BUT IT'S NOT REQUIRED
assert(nextDie(after: [1, 1, 1, 1]) == [2, 1, 1, 1])
assert(nextDie(after: [2, 1, 1, 1]) == [2, 2, 1, 1])
assert(nextDie(after: [2, 2, 1, 1]) == [2, 2, 2, 1])
assert(nextDie(after: [2, 2, 2, 1]) == [2, 2, 2, 2])
assert(nextDie(after: [2, 2, 2, 2]) == [3, 1, 1, 1])
assert(nextDie(after: [24, 14, 5, 5]) == [24, 14, 6, 1])
assert(nextDie(after: [9, 8, 7, 6, 6, 5, 2]) == [9, 8, 7, 6, 6, 5, 3])
assert(nextDie(after: [11, 11, 11, 11, 10, 10, 10]) == [11, 11, 11, 11, 11, 1, 1])
assert(nextDie(after: [11, 11, 11, 11, 11, 1, 1]) == [11, 11, 11, 11, 11, 2, 1])
assert(nextDie(after: [11, 10, 4, 3, 2, 2]) == [11, 10, 4, 3, 3, 1])

func searchAndDisplayCrazyDice() {
    var currentDice1 = smallestDie
    var currentDice2 = smallestDie
    while currentDice1 != largestDie {
        currentDice2 = currentDice1
        while currentDice2 != largestDie {
            if distribution(currentDice1, currentDice2) == standardDistribution && currentDice1 != standardDie {
                print("Crazy Dice Found: \(currentDice1) and \(currentDice2)")
            }
            currentDice2 = nextDie(after: currentDice2)
        }
        currentDice1 = nextDie(after: currentDice1)
    }
} // For the function in part 4 above, it took about 45 minutes to find the crazy dice pair for a 6-sided die, while it only took 26 seconds for the 5-sided die and 0.5 seconds for the 4-sided die. I couldn't find any way to reduce the time to roughly 5 minutes. I talked to Nathan about it and he told me that my times for the 5-sided die and the 4-sided die seemed normal, so I'm not really sure what else I can change about my function to fix the issue with the 6-sided die (outside of the optimizations for part 6).

func searchAndDisplayCrazyDiceFast() {
    var currentDice1 = smallestDie
    var currentDice2 = smallestDie
    var leftmostSum: Int = 0
    var rightmostSum: Int = 0
    let diceLength = currentDice1.count
    while currentDice1 != largestDie {
        if !(diceLength >= 2 && ((currentDice1[diceLength - 2] == 1) || (currentDice1[0] >= (2 * diceLength - 3)))) {
            currentDice2 = nextDie(after: currentDice1)
            while currentDice2 != largestDie {
                if !(diceLength >= 2 && ((currentDice2[diceLength - 2] == 1) || (currentDice2[0] >= (2 * diceLength - 3)))) {
                    leftmostSum = currentDice1[0] + currentDice2[0]
                    rightmostSum = currentDice1[diceLength - 1] + currentDice2[diceLength - 1]
                    if !((leftmostSum > (2 * diceLength)) || (rightmostSum > 2)) {
                        if distribution(currentDice1, currentDice2) == standardDistribution && currentDice1 != standardDie {
                            print("Crazy Dice Found: \(currentDice1) and \(currentDice2)")
                        }
                    }
                }
                currentDice2 = nextDie(after: currentDice2)
            }
        }
        currentDice1 = nextDie(after: currentDice1)
    }
}
/*
====================
Part 6: Optimization
====================

// After optimization, my 4-sided die went from 0.4 seconds to 0.005 seconds. My 5-sided die went from 26 seconds to 0.2 seconds. My 6-sided die went from 45 minutes to 10 seconds. I wasn't able to test a 7-sided die for my normal function, but, after optimization, it took about 8 minutes to find the crazy dice pair.
 
// I changed "currentDice2 = currentDice1" (LINE 103) to "currentDice2 = nextDie(after: currentDice1)" (LINE 122) to take out checking for duplicate pairs. Duplicate pairs will never have the same distribution of sums as the standard die because all of the sums will occur in even numbers like two or four times, for example. In a standard die, there exist some sums that occur in odd numbers, including occurring only once.

// I added "if !(diceLength >= 2 && ((currentDice1[diceLength - 2] == 1) || (currentDice1[0] >= (2 * diceLength - 3))))" (LINE 121) and "if !(diceLength >= 2 && ((currentDice2[diceLength - 2] == 1) || (currentDice2[0] >= (2 * diceLength - 3))))" (LINE 124) to check each individual dice. Having more than one of the smallest value (1) will never result in a crazy dice pair because the smallest sum (2) will occur more than once. When making sure that the largest sum also doesn't occur more than once, I decided to remove any dice that had ((2 * number of sides) - 3) in the 0th index. I chose this value because, in order to maintain the condition of the largest sum not occurring more than once, the dice has to have more than one "1" in its array, which breaks the rule mentioned in sentence 2 of this paragraph. As an example, let's use a 6-sided die. I'm going to jump to the situation in which the dice has its largest value as 9: [9, ..., ..., ..., ..., ...]. The other die can only have one "3" as its largest value in the 0th index in order to satisfy the rule about the largest sum not occurring more than once. It also can have a maximum of two "2"s because, in a standard distribution for 6-sided die, the sum of 11 only occurs twice. That leaves three spaces that have to be occupied with "1"s, which breaks the rule about having only one "1" per dice.

// I added "if !((leftmostSum > (2 * diceLength)) || (rightmostSum > 2))" (LINE 127) to check each pair of dice. If the sum of the 2 largest values (the values in the 0th, leftmost index of each array) add up to more than (2 * number of sides), then the dice pair already stops fitting the conditions for the standard distribution since there is no sum greater than (2 * number of sides). In a similar manner, if the sum of the smallest values (the values in the rightmost index of each array) is greater than 2, then the dice pair already stops fitting the conditions for the standard distribution since there has to be 1 occurrence of the sum being 2 (when both rightmost values are equal to 1).

*/
