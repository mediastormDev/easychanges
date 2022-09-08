import XCTest
@testable import EasyChanges

struct TestElement: Identifiable, Equatable, Hashable {
    var id: String
    var content: String
}

let a = TestElement(id: "A", content: "Hello, A!")
let b = TestElement(id: "B", content: "Hello, B!")
let c = TestElement(id: "C", content: "Hello, C!")
let d = TestElement(id: "D", content: "Hello, D!")

let bm = TestElement(id: "B", content: "Hello, B!!!")
let cm = TestElement(id: "C", content: "Hello, C!!!")
let dm = TestElement(id: "D", content: "Hello, D!!!")

typealias Elements = [TestElement]
typealias Changes = [EasyChange<TestElement>]

func runEasyChanges(from old: Elements, to new: Elements) -> Changes {
    new.difference(from: old).inferringMoves().easyChanges()
}

final class EasyChangesTests: XCTestCase {
    func testAppend() throws {
        let old = [a, b]
        let new = [a, b, c]
        
        let expectedChanges: Changes = [.insert(offset: 2, element: c)]
        
        XCTAssertEqual(runEasyChanges(from: old, to: new), expectedChanges)
    }
    func testAppendMultiple() throws {
        let old = [a]
        let new = [a, b, c]
        
        let expectedChanges: Changes = [
            .insert(offset: 1, element: b),
            .insert(offset: 2, element: c)
        ]
        
        XCTAssertEqual(runEasyChanges(from: old, to: new), expectedChanges)
    }
    func testInsert() throws {
        let old = [a, c]
        let new = [a, b, c]
        
        let expectedChanges: Changes = [.insert(offset: 1, element: b)]
        
        XCTAssertEqual(runEasyChanges(from: old, to: new), expectedChanges)
    }
    func testInsertMultiple() throws {
        let old = [a, d]
        let new = [a, b, c, d]
        
        let expectedChanges: Changes = [
            .insert(offset: 1, element: b),
            .insert(offset: 2, element: c)
        ]
        
        XCTAssertEqual(runEasyChanges(from: old, to: new), expectedChanges)
    }
    func testRemove() throws {
        let old = [a, b, c]
        let new = [a, b]
        
        let expectedChanges: Changes = [.remove(offset: 2, element: c)]
        
        XCTAssertEqual(runEasyChanges(from: old, to: new), expectedChanges)
    }
    func testRemoveMultiple() throws {
        let old = [a, b, c]
        let new = [a]
        
        // Must use this order, or out of bounds errors will happen.
        let expectedChanges: Changes = [
            .remove(offset: 2, element: c),
            .remove(offset: 1, element: b)
        ]
        
        XCTAssertEqual(runEasyChanges(from: old, to: new), expectedChanges)
    }
    func testMove() throws {
        let old = [a, b, c]
        let new = [b, c, a]
        
        let expectedChanges: Changes = [.move(from: 0, to: 2, element: a)]
        
        XCTAssertEqual(runEasyChanges(from: old, to: new), expectedChanges)
    }
    func testChange() throws {
        let old = [a, b, c]
        let new = [a, bm, c]
        
        let expectedChanges: Changes = [.change(offset: 1, oldElement: b, newElement: bm)]
        
        XCTAssertEqual(runEasyChanges(from: old, to: new), expectedChanges)
    }
    func testMoveAndChange() throws {
        let old = [a, b, c, d]
        let new = [dm, a, b, c]
        
        let expectedChanges: Changes = [
            .change(offset: 3, oldElement: d, newElement: dm),
            .move(from: 3, to: 0, element: dm)
        ]
        
        XCTAssertEqual(runEasyChanges(from: old, to: new), expectedChanges)
    }
}
