//
//  ActionButtonView.swift
//  CSVParser
//
//  Created by Alex Yehorov on 9/29/24.
//

import SwiftUI

struct ActionButtonView: View {
    var action: () -> Void
    var buttonText: String
    
    var body: some View {
        Button(action: action) {
            Text(buttonText)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing))
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 10)
        }
        .padding(.horizontal, 20)
    }
}
