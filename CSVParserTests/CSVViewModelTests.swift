//
//  CSVViewModelTests.swift
//  CSVParserTests
//
//  Created by Alex Yehorov on 9/29/24.
//

import XCTest
@testable import CSVParser

final class CSVViewModelTests: XCTestCase {
    var viewModel: CSVViewModel!
    
    override func setUp() {
        super.setUp()
        viewModel = CSVViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    func testCSVParser_ValidData() {
        let csvContent = "Alex,Yehorov,5,1990-02-10\nAnna,Yehorova,10,1990-02-25"
        let parsedRows = viewModel.parseCSV(csvContent)
        
        XCTAssertEqual(parsedRows.count, 2)
        XCTAssertEqual(parsedRows[0].columns[0], "Alex")
        XCTAssertEqual(parsedRows[0].columns[1], "Yehorov")
        XCTAssertEqual(parsedRows[1].columns[0], "Anna")
        XCTAssertEqual(parsedRows[1].columns[1], "Yehorova")
    }
    
    func testCSVParser_MalformedData() {
        let csvContent = "Alex,Yehorov\nAnna"
        let parsedRows = viewModel.parseCSV(csvContent)
        
        XCTAssertEqual(parsedRows.count, 2)
        XCTAssertEqual(parsedRows[0].columns[0], "Alex")
        XCTAssertEqual(parsedRows[0].columns[1], "Yehorov")
    }
    
    func testCleanCSVField() {
        let rawField = "\"Alex \"\r"
        let cleanedField = viewModel.cleanCSVField(rawField)
        
        XCTAssertEqual(cleanedField, "Alex")
    }
    
    func testLoadCSV_InvalidURL() {
        let invalidURL = URL(fileURLWithPath: "/invalid/path")
        viewModel.loadCSV(from: invalidURL)
        
        let expectation = self.expectation(description: "Loading CSV")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertNotNil(self.viewModel.error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2)
    }
    
    func testLoadCSV_ValidData_UpdatesMainThread() {
        if let url = Bundle.main.url(forResource: "issues", withExtension: "csv") {
            viewModel.loadCSV(from: url)
            
            let expectation = self.expectation(description: "Loading CSV")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                XCTAssertEqual(self.viewModel.getCSVRows().count, 4)
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 2)
        } else {
            XCTAssertTrue(false)
        }
    }
}
