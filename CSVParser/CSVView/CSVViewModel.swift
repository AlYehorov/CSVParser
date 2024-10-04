//
//  CSVViewModel.swift
//  CSVParser
//
//  Created by Alex Yehorov on 9/24/24.
//

import SwiftUI
import Combine

@Observable
class CSVViewModel {
    // The model containing the CSV parsing logic
    private let model: CSVModel
    
    // Observable properties that will be used in the view
    var rows: [CSVRow] = []
    var isLoading: Bool = false
    var error: String? = nil
    var columnsCount: Int = 0
    
    init(model: CSVModel = CSVModel()) {
        self.model = model
        setupBindings()
    }
    
    // Bind the model's observable properties to the view model's properties
    private func setupBindings() {
        // Bind rows, isLoading, and error to the model
        self.rows = model.rows
        self.isLoading = model.isLoading
        self.error = model.error
        self.columnsCount = model.columnsCount
    }
    
    // Load CSV file through the model
    func loadCSV(from url: URL) {
        model.loadCSV(from: url)
        // Update view model state
        updateViewModelState()
    }
    
    // Load next page of CSV (for pagination)
    func loadNextPage() {
        model.loadNextPage()
        // Update view model state
        updateViewModelState()
    }
    
    // Update view model state from the model
    private func updateViewModelState() {
        self.rows = model.rows
        self.isLoading = model.isLoading
        self.error = model.error
        self.columnsCount = model.columnsCount
    }
}
