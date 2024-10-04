//
//  CSVService.swift
//  CSVParser
//
//  Created by Alex Yehorov on 10/4/24.
//

import Foundation
import Combine

protocol PaginationProtocol {
    func loadNextPage() async throws
}

protocol CSVParserProtocol {
    func loadCSV(from url: URL) async throws
    func parseCSV(_ content: String) -> [CSVRow]
    func getCSVRows() -> [CSVRow]
    
    var error: String? { get }
    var columsCount: Int { get }
}

enum CSVServiceError: Error {
    case fileNotFound
    case readError(String)
}

typealias FileProtocol = CSVParserProtocol & PaginationProtocol

@Observable
class CSVService: FileProtocol {
    private var rows: [CSVRow] = []
    private var errorMessage: String?
    private var fileHandle: FileHandle?
    private var endOfFile = false
    var isLoading: Bool = false
    
    var error: String? {
        errorMessage
    }
    
    var columsCount: Int {
        rows.first?.columns.count ?? 0
    }

    // MARK: - Load CSV
    
    func loadCSV(from url: URL) async throws {
        clearAllData()
        do {
            // Ensure the file exists at the specified URL
            guard FileManager.default.fileExists(atPath: url.path) else {
                errorMessage = "File not found"
                throw CSVServiceError.fileNotFound
            }
            
            fileHandle = try FileHandle(forReadingFrom: url)
            try await loadNextPage() // Call loadNextPage as an async method
        } catch {
            throw CSVServiceError.readError(error.localizedDescription)
        }
    }

    func loadNextPage() async throws {
        guard !isLoading, !endOfFile else { return }
        isLoading = true
        
        guard let fileHandle = self.fileHandle else {
            throw CSVServiceError.fileNotFound
        }
        
        let chunkSize = 1_024 * 1_024 // Size of each chunk in bytes
        let chunk = fileHandle.readData(ofLength: chunkSize)
        
        if chunk.isEmpty {
            endOfFile = true
            isLoading = false
            return
        }
        
        let chunkString = String(data: chunk, encoding: .utf8) ?? ""
        let parsedRows = parseCSV(chunkString)

        DispatchQueue.main.async {
            self.rows.append(contentsOf: parsedRows)
            self.isLoading = false
        }
    }

    // MARK: - Parse CSV

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
        return rows
    }
    
    // MARK: - Clear Data

    private func clearAllData() {
        endOfFile = false
        rows.removeAll()
        fileHandle = nil
    }
}
