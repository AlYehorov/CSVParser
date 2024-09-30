//
//  CSVViewModel.swift
//  CSVParser
//
//  Created by Alex Yehorov on 9/24/24.
//

import SwiftUI
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
class CSVViewModel: FileProtocol {
    var error: String? {
        get {
            errorMessage
        }
    }
    
    var columsCount: Int {
        get {
            rows.first?.columns.count ?? 0
        }
    }
    
    private var rows: [CSVRow] = []
    private var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    private var fileHandle: FileHandle?
    private let chunkSize = 100 // Define how many rows to load per page
    private var remainingData = Data() // Store incomplete row data from chunk
    private var endOfFile = false
    var isLoading: Bool = false
    
    private func clearAllData() {
        endOfFile = false
        rows.removeAll()
        remainingData = Data()
    }

    // Load the file and start streaming data
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
            let chunkSizeBytes = 1_024 * 1_024
            guard let fileHandle = self.fileHandle else { return }
            
            let chunk = fileHandle.readData(ofLength: chunkSizeBytes)
            if chunk.isEmpty {
                self.endOfFile = true // No more data to read
                DispatchQueue.main.async {
                    self.isLoading = false
                }
                return
            }
            
            // Process the chunk
            self.remainingData.append(chunk)
            if let chunkString = String(data: self.remainingData, encoding: .utf8) {
                let rowsData = chunkString
                
                // Remove the incomplete line and keep it for the next chunk
                if let utf8 = rowsData.last?.utf8 {
                    self.remainingData = Data(utf8)
                }
                
                let parsedRows = self.parseCSV(chunkString)
                
                DispatchQueue.main.async {
                    self.rows.append(contentsOf: parsedRows)
                    self.isLoading = false
                }
            }
        }
    }
    
    func cleanCSVField(_ field: String) -> String {
        return field.trimmingCharacters(in: CharacterSet(charactersIn: "\"").union(.whitespacesAndNewlines))
    }
    
    // parser which can handle malformed content
    func parseCSV(_ content: String) -> [CSVRow] {
        var rows: [CSVRow] = []
        
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
                rows.append(CSVRow(columns: columns))
            }
        }
        
        return rows
    }
    
    func getCSVRows() -> [CSVRow] {
        rows
    }
}
