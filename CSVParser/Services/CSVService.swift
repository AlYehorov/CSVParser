//
//  CSVService.swift
//  CSVParser
//
//  Created by Alex Yehorov on 10/4/24.
//

import Foundation
import Combine

protocol PaginationProtocol {
    func loadNextPage()
}

protocol CSVParserProtocol {
    func loadCSV(from url: URL)
    func parseCSV(_ content: String) -> [CSVRow]
    func getCSVRows() -> [CSVRow]
    
    var error: String? { get }
    var columsCount: Int { get }
}

typealias FileProtocol = CSVParserProtocol & PaginationProtocol

@Observable
class CSVService: FileProtocol {
    
    // MARK: - Observable Properties
    var rows: [CSVRow] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private var fileHandle: FileHandle?
    private let chunkSize = 1_024 * 1_024 // Define the size of each chunk in bytes
    private var remainingData = Data() // Store incomplete row data from chunk
    private var endOfFile = false

    // MARK: - Computed Properties
    var error: String? {
        return errorMessage
    }
    
    var columsCount: Int {
        return rows.first?.columns.count ?? 0
    }
    
    // MARK: - Load CSV
    func loadCSV(from url: URL) {
        clearAllData()
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                self.fileHandle = try FileHandle(forReadingFrom: url)
                self.loadNextPage()
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Failed to load file: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func loadNextPage() {
        guard !isLoading, !endOfFile else { return }
        
        isLoading = true
        DispatchQueue.global(qos: .userInitiated).async {
            let chunk = self.fileHandle?.readData(ofLength: self.chunkSize) ?? Data()
            
            if chunk.isEmpty {
                self.endOfFile = true
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            self.remainingData.append(chunk)
            if let chunkString = String(data: self.remainingData, encoding: .utf8) {
                let rowsData = chunkString.components(separatedBy: "\n")
                
                // Handle incomplete row data for the next chunk
                if let lastLine = rowsData.last, !lastLine.hasSuffix("\n") {
                    self.remainingData = Data(lastLine.utf8) // Keep incomplete line for next chunk
                } else {
                    self.remainingData = Data()
                }
                
                let parsedRows = self.parseCSV(chunkString)
                
                DispatchQueue.main.async {
                    self.rows.append(contentsOf: parsedRows)
                    self.isLoading = false
                }
            }
        }
    }
    
    // MARK: - Parse CSV
    func parseCSV(_ content: String) -> [CSVRow] {
        var parsedRows: [CSVRow] = []
        let lines = content.components(separatedBy: "\n")
        
        let regex = try! NSRegularExpression(pattern: #"(?:(?<=^)|(?<=,))(?:"([^"]*)"|([^,]*))(?=,|$)"#)
        
        for line in lines {
            var columns: [String] = []
            let range = NSRange(location: 0, length: line.utf16.count)
            
            regex.enumerateMatches(in: line, options: [], range: range) { match, _, _ in
                if let match = match {
                    let range1 = Range(match.range(at: 1), in: line) // Quoted field
                    let range2 = Range(match.range(at: 2), in: line) // Unquoted field
                    
                    if let range1 = range1 {
                        columns.append(String(line[range1]))
                    } else if let range2 = range2 {
                        columns.append(String(line[range2]))
                    }
                }
            }
            
            if !columns.isEmpty {
                parsedRows.append(CSVRow(columns: columns))
            }
        }
        
        return parsedRows
    }
    
    func getCSVRows() -> [CSVRow] {
        return rows
    }
    
    // MARK: - Clear Data
    
    private func clearAllData() {
        endOfFile = false
        rows.removeAll()
        remainingData = Data()
        fileHandle = nil
    }
}
