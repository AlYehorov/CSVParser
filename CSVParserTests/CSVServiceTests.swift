//
//  CSVViewModelTests.swift
//  CSVParserTests
//
//  Created by Alex Yehorov on 9/29/24.
//

import XCTest
@testable import CSVParser

final class CSVServiceTests: XCTestCase {
    var csvService: CSVService!
    
    override func setUp() {
        super.setUp()
        csvService = CSVService()
    }
    
    override func tearDown() {
        csvService = nil
        super.tearDown()
    }
    
    func testCSVParser_ValidData() {
        let csvContent = "Alex,Yehorov,5,1990-02-10\nAnna,Yehorova,10,1990-02-25"
        let parsedRows = csvService.parseCSV(csvContent)
        
        XCTAssertEqual(parsedRows.count, 2)
        XCTAssertEqual(parsedRows[0].columns[0], "Alex")
        XCTAssertEqual(parsedRows[0].columns[1], "Yehorov")
        XCTAssertEqual(parsedRows[1].columns[0], "Anna")
        XCTAssertEqual(parsedRows[1].columns[1], "Yehorova")
    }
    
    func testCSVParser_MalformedData() {
        let csvContent = "Alex,Yehorov\nAnna"
        let parsedRows = csvService.parseCSV(csvContent)
        
        XCTAssertEqual(parsedRows.count, 2)
        XCTAssertEqual(parsedRows[0].columns[0], "Alex")
        XCTAssertEqual(parsedRows[0].columns[1], "Yehorov")
    }
    
    func testLoadCSV_ValidData_UpdatesMainThread() async {
        guard let url = Bundle.main.url(forResource: "issues", withExtension: "csv") else {
            XCTFail("Valid CSV file not found.")
            return
        }
        
        do {
            try await csvService.loadCSV(from: url)
            
            // Expectation for loading the CSV
            let expectation = self.expectation(description: "Loading CSV")
            
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
            } catch {
                XCTFail("Sleep interrupted with error: \(error.localizedDescription)")
            }
            
            // Validate the number of rows
            XCTAssertEqual(csvService.getCSVRows().count, 4)
            expectation.fulfill()
            
            await fulfillment(of: [expectation], timeout: 2)
        } catch {
            // If an error occurs, fail the test
            XCTFail("Failed to load CSV: \(error.localizedDescription)")
        }
    }
    
    func testLoadCSV_InvalidURL() async {
        let invalidURL = URL(fileURLWithPath: "/invalid/path")
        
        do {
            try await csvService.loadCSV(from: invalidURL)
            
            // If the function completes successfully, the test should fail
            XCTFail("Expected loadCSV to throw an error for invalid URL")
        } catch {
            let expectation = self.expectation(description: "Loading CSV")
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000) // Wait for 1 second
            } catch {
                XCTFail("Sleep interrupted with error: \(error.localizedDescription)")
            }
            XCTAssertNotNil(csvService.error)
            expectation.fulfill()
            
            // Wait for the expectation to be fulfilled
            await fulfillment(of: [expectation], timeout: 2)
        }
    }

}
