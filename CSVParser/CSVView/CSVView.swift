//
//  CSVView.swift
//  CSVParser
//
//  Created by Alex Yehorov on 9/24/24.
//

import SwiftUI

struct CSVView: View {
    @State private var viewModel = CSVViewModel() // Using StateObject for the view model
    @State private var isPickerViewPresented = false

    var body: some View {
        NavigationStack {
            VStack {
                if let error = viewModel.error {
                    Text(error).foregroundColor(.red)
                } else if viewModel.isLoading {
                    ProgressView("Loading...") // Show a loading indicator while the CSV is loading
                } else {
                    ScrollView([.horizontal, .vertical]) {
                        LazyVGrid(
                            columns: Array(repeating: GridItem(.adaptive(minimum: 120)), count: viewModel.columsCount),
                            spacing: 10
                        ) {
                            ForEach(viewModel.getCSVRows(), id: \.id) { row in
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
                }
                ActionButtonView(action: {
                    isPickerViewPresented = true
                }, buttonText: "Load CSV")
                .padding(.bottom, 40)
                .fileImporter(isPresented: $isPickerViewPresented, allowedContentTypes: [.commaSeparatedText]) { result in
                    switch result {
                    case .success(let url):
                        viewModel.loadCSV(from: url)
                    case .failure(let failure):
                        print("Failed to load file: \(failure.localizedDescription)")
                    }
                }
            }
            .navigationTitle("CSV Viewer")
            .padding()
        }
    }
}

#Preview {
    CSVView()
}
