import Foundation

typealias Table = [[Int]]

enum Result {
    case solution(Table)
    case noSolution
}

let allDigits = Set([1, 2, 3, 4, 5, 6, 7, 8, 9])

func usedDigitsInRow(_ i: Int, _ table: Table) -> Set<Int> {
    Set(table[i].filter { $0 != 0 })
}

func usedDigitsInColumn(_ j: Int, _ table: Table) -> Set<Int> {
    var result = [Int]()
    for row in table where row[j] != 0 {
        result.append(row[j])
    }
    return Set(result)
}

func usedDigitsInRelatedBlock(_ i: Int, _ j: Int, _ table: Table) -> Set<Int> {
    let i0 = (i / 3) * 3
    let i1 = (i / 3) * 3 + 2
    let j0 = (j / 3) * 3
    let j1 = (j / 3) * 3 + 2
    
    var result = [Int]()
    for ri in i0...i1 {
        for ci in j0...j1 {
            let v = table[ri][ci]
            if v != 0 {
                result.append(v)
            }
        }
    }
    return Set(result)
}

func candidates(_ i: Int, _ j: Int, _ table: Table) -> Set<Int> {
    allDigits
        .subtracting(usedDigitsInRow(i, table))
        .subtracting(usedDigitsInColumn(j, table))
        .subtracting(usedDigitsInRelatedBlock(i, j, table))
}


func printSudokuTable(_ table: Table) {
    for row in table {
        print(row)
    }
}

typealias CellIndexWithCandidates = ((Int, Int), Set<Int>)

func solveSudoku(table: Table) -> Result {
    var table = table
    var cellWithMinCandidates: CellIndexWithCandidates?
    
    // Step 1. Fill "trivial" cells
    while true {
        var noCellsWithMultipleCandidates = true
        var foundNewDigitOnCurrentIteration = false
        for i in 0...8 {
            for j in 0...8 where table[i][j] == 0 {
                let cand = candidates(i, j, table)
                if cand.isEmpty {
                    return .noSolution
                }
                if cand.count == 1, let digit = cand.first {
                    table[i][j] = digit
                    print("Trivial (\(i), \(j)) = \(digit)")
                    foundNewDigitOnCurrentIteration = true
                } else {
                    noCellsWithMultipleCandidates = false
                    if cellWithMinCandidates == nil || cand.count < cellWithMinCandidates!.1.count {
                        cellWithMinCandidates = ((i, j), cand)
                    }
                }
            }
        }
        printSudokuTable(table)
        print("-----------------")
        if noCellsWithMultipleCandidates {
            return .solution(table)
        }
        if foundNewDigitOnCurrentIteration == false {
            break
        }
    }
    print("No trivial solution found. Start backtracking")
    // Step 2. Backtracking. Make assumption and proceed to solve with new table recursively
    if let ((i, j), candidates) = cellWithMinCandidates {
        for candidate in candidates {
            var assumptionTable = table
            assumptionTable[i][j] = candidate
            print("Assume (\(i), \(j)) = \(candidate)")
            switch solveSudoku(table: assumptionTable) {
            case .noSolution:
                print("Dead end for assumption (\(i), \(j)) = \(candidate)")
            case let .solution(solutionTable):
                return .solution(solutionTable)
            }
        }
    }
    return .noSolution
}

func verifySudokuSolution(table: Table) -> Bool {
    for i in 0...8 {
        for j in 0...8 {
            if usedDigitsInRow(i, table) != allDigits
                || usedDigitsInColumn(j, table) != allDigits
                || usedDigitsInRelatedBlock(i, j, table) != allDigits {
                return false
            }
        }
    }
    return true
}

// Testing

let table = [
    [0, 0, 0, 0, 0, 0, 0, 9, 0],
    [0, 0, 3, 0, 0, 0, 7, 0, 8],
    [0, 0, 0, 6, 0, 0, 0, 0, 5],
    [0, 0, 0, 5, 9, 0, 0, 0, 6],
    [1, 0, 0, 7, 0, 0, 0, 0, 0],
    [8, 5, 0, 0, 0, 2, 0, 4, 0],
    [0, 0, 9, 0, 7, 0, 0, 0, 0],
    [0, 0, 8, 3, 0, 0, 6, 0, 0],
    [0, 0, 4, 0, 0, 0, 1, 8, 0]
]
let result = solveSudoku(table: table)
print("\nFound result:")
switch result {
case .noSolution:
    print("No solution")
case let .solution(solution):
    printSudokuTable(solution)
    print("Is correct: \(verifySudokuSolution(table: solution))")
}
