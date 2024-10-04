//
//  CSVModel.swift
//  CSVParser
//
//  Created by Alex Yehorov on 10/4/24.
//

import Foundation
import Combine

// Model that interacts with CSVService
@Observable
class CSVModel {
    private var csvService = CSVService()
    private var errorMessage: String?
    
    var error: String? {
        errorMessage ?? csvService.error
    }

    var columsCount: Int {
        csvService.columsCount
    }
    
    var isLoading: Bool {
        csvService.isLoading
    }

    // MARK: - Load CSV

    func loadCSV(from url: URL) {
        Task {
            await loadCSVAsync(from: url)
        }
    }

    private func loadCSVAsync(from url: URL) async {
        guard url.startAccessingSecurityScopedResource() else {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to access the file."
            }
            return
        }
        
        defer {
            url.stopAccessingSecurityScopedResource()
        }

        do {
            try await csvService.loadCSV(from: url)
        } catch {
            // Handle any error that might occur while loading
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load file: \(error.localizedDescription)"
            }
        }
    }

    func getCSVRows() -> [CSVRow] {
        return csvService.getCSVRows()
    }
}
