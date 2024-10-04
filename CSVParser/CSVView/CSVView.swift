//
//  CSVView.swift
//  CSVParser
//
//  Created by Alex Yehorov on 9/24/24.
//

import SwiftUI

struct CSVView: View {
    @State var viewModel = CSVViewModel() // Use the CSVViewModel
    @State private var isPickerViewPresented = false

    var body: some View {
        NavigationStack {
            VStack {
                if let error = viewModel.error {
                    Text(error).foregroundColor(.red)
                } else {
                    ScrollView([.horizontal, .vertical]) {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.adaptive(minimum: 120)), count: viewModel.columnsCount), // Bind to viewModel's columnsCount
                            spacing: 10
                        ) {
                            ForEach(viewModel.rows, id: \.id) { row in // Bind to viewModel's rows
                                ForEach(Array(row.columns.enumerated()), id: \.0) { index, column in
                                    Text(column)
                                        .padding(10)
                                        .frame(width: 120, height: 50)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(5)
                                        .id("\(row.id.uuidString)-\(index)")
                                }
                            }
                        }
                        .padding([.leading, .trailing, .top, .bottom], 16)
                    }
                    ActionButtonView(action: {
                        isPickerViewPresented = true
                    }, buttonText: "Load CSV")
                    .padding()
                    .fileImporter(isPresented: $isPickerViewPresented, allowedContentTypes: [.commaSeparatedText], onCompletion: { result in
                        switch result {
                        case .success(let url):
                            if url.startAccessingSecurityScopedResource() {
                                viewModel.loadCSV(from: url) // Use viewModel's loadCSV method
                                url.stopAccessingSecurityScopedResource()
                            }
                        case .failure(let failure):
                            print(failure)
                        }
                    })
                }
            }
            .navigationTitle("CSV Viewer")
        }
    }
}

#Preview {
    CSVView(viewModel: CSVViewModel())
}
