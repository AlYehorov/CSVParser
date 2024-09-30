//
//  CSVEntities.swift
//  CSVParser
//
//  Created by Alex Yehorov on 9/29/24.
//

import Foundation

struct CSVRow: Hashable, Identifiable {
    var id = UUID()
    let columns: [String]
}

struct CSVFile {
    let rows: [CSVRow]
}
