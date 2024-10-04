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
    private let service: CSVService
    
    // Observable properties that reflect the state of the service
    var rows: [CSVRow] = []
    var isLoading: Bool = false
    var error: String? = nil
    
    init(service: CSVService = CSVService()) {
        self.service = service
        setupBindings()
    }
    
    // Bind service properties to the model's observable properties
    private func setupBindings() {
        // The service's rows will update the model's rows
        self.rows = service.rows
        self.isLoading = service.isLoading
        self.error = service.errorMessage
    }
    
    // Load CSV from a URL
    func loadCSV(from url: URL) {
        service.loadCSV(from: url)
        // Reflect the service's state in the model
        updateModelState()
    }
    
    // Load the next page (for pagination)
    func loadNextPage() {
        service.loadNextPage()
        // Reflect the service's state in the model
        updateModelState()
    }
    
    // Get the current rows (for easier access)
    func getCSVRows() -> [CSVRow] {
        return service.getCSVRows()
    }
    
    // Get column count (for easier access)
    var columnsCount: Int {
        return service.columsCount
    }
    
    // Update the observable state
    private func updateModelState() {
        self.rows = service.rows
        self.isLoading = service.isLoading
        self.error = service.errorMessage
    }
}
