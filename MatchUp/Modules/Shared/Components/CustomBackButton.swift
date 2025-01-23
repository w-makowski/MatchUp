//
//  CustomBackButton.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 14/12/2024.
//

import SwiftUI

struct CustomBackButton: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.font) var environmentFont
    
    var image: String = "chevron.left"
    var text: String? = "Go Back"
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                HStack {
                    Image(systemName: image)
                    if let buttonText = text {
                        Text(buttonText)
                    }
                }
                .foregroundColor(.white)
                .font(environmentFont ?? .body)
            }
            
            Spacer()
        }
        .padding(.vertical)
    }
}

#Preview {
    CustomBackButton()
}
