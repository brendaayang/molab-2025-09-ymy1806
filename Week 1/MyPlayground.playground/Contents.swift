//: Playground - Demonstrating variables, for-loops, and functions
import Foundation

// A string of characters to choose from
let symbols = "⭐️🌙☀️🔥"

// Function to safely get a character at a given index
func charAt(_ str: String, _ offset: Int) -> String {
    let index = str.index(str.startIndex, offsetBy: offset)
    return String(str[index])
}

// Function to generate one random line of symbols
func generateLine(_ length: Int) {
    var line = ""  // variable that will hold the new line
    for _ in 0..<length {  // for-loop runs 'length' times
        let randomIndex = Int.random(in: 0..<symbols.count)
        line += charAt(symbols, randomIndex) // append random symbol
    }
    print(line)
}

// Function to generate a block of lines
func generateBlock(_ size: Int) {
    for _ in 0..<size {
        generateLine(size)  // call function inside a loop
    }
}

// Call the function to test it
generateBlock(5)
