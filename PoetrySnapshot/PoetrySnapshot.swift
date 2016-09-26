import XCTest

class PoetrySnapshot: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        snapshot("01main")
    }
    
}
