import UIKit

struct DrawingStore {
    static var shared = DrawingStore() // Singleton instance

    var storedLines: [Line] = []

    mutating func addLines(_ lines: [Line]) {
        storedLines.append(contentsOf: lines)
    }

    mutating func clearStoredLines() {
        storedLines.removeAll()
    }
    
    
}
