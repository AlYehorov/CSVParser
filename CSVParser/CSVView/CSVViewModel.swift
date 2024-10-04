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
    private var csvModel = CSVModel()

    var error: String? {
        csvModel.error
    }
    
    var columsCount: Int {
        csvModel.columsCount
    }

    var isLoading: Bool {
        csvModel.isLoading
    }

    // MARK: - Load CSV
    func loadCSV(from url: URL) {
        csvModel.loadCSV(from: url)
    }

    func getCSVRows() -> [CSVRow] {
        return csvModel.getCSVRows()
    }
}
