//
//  CustomTextField.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 27/11/2024.
//

import SwiftUI
import UIKit

struct CustomTextField: View {
    var name: String = ""
    var textImage: String? = ""
    var xOffset: CGFloat = 0
    @Binding var textFieldValue: String
    var keyboardType: UIKeyboardType = .default
    private(set) var textFieldWidth: CGFloat = 400
    var textPlaceholder: String = ""
    
    var body: some View {
        ZStack {
            HStack {
                if let imageName = textImage {
                    Image(systemName: imageName)
                        .padding(.leading, 10)
                        .frame(width: 30, height: 50)
                        .colorScheme(.dark)
                }
                
                TextField(textPlaceholder, text: $textFieldValue)
                    .padding()
                    .foregroundStyle(.white)
                    .textInputAutocapitalization(.never)
                    .keyboardType(keyboardType)
            }
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .offset(y: 8)
            
            HStack(spacing: 10) {
                   Text(name)
                     .font(.system(size: 17))
                     .foregroundColor(.white)
                 }
                 .padding(.horizontal, 10)
                 .background(.black)
                 .position(x: xOffset == 0 ? calculateOffsetX(value: name) : xOffset, y: 10)

        }
        .frame(width: textFieldWidth, height: 70)
        .background(Color.black)
    }
    
    func width(_ width: CGFloat) -> CustomTextField {
        var copy = self
        copy.textFieldWidth = width
        return copy
    }
    
    private func calculateOffsetX(value: String) -> CGFloat {
        let xOffset: CGFloat = ceil("Username".size().width)
        return 90 + (ceil(name.size().width + 10) - xOffset - 10)
    }
}

struct CustomPasswordField: View {
    var name: String = ""
    var textImage: String = ""
    var xOffset: CGFloat = 0
    @Binding var textFieldValue: String
    @State private var showPassword: Bool = false
    
    var body: some View {
        ZStack {
            HStack {
                Image(systemName: textImage)
                    .padding(.leading, 10)
                    .frame(width: 30, height: 55)
                    .colorScheme(.dark)
                
                Group {
                    if showPassword {
                        TextField("", text: $textFieldValue)
                    } else {
                        SecureField("", text: $textFieldValue)
                    }
                }
                .padding()
                
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                }
                .padding(.trailing, 10)
            }
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 1.5))
            .padding(.horizontal, 16)
            .padding(.bottom, 10)
            .offset(y: 8)
            
            HStack(spacing: 10) {
                   Text(name)
                     .font(.system(size: 17))
                     .foregroundColor(.white)
                 }
                 .padding(.horizontal, 10)
                 .background(.black)
                 .position(x: xOffset == 0 ? calculateOffsetX(value: name) : xOffset, y: 10)

        }
        .frame(height: 70)
        .background(Color.black)
        .foregroundStyle(.white)
    }
    
    private func calculateOffsetX(value: String) -> CGFloat {
        let xOffset: CGFloat = ceil("Username".size().width)
        return 90 + (ceil(name.size().width + 10) - xOffset - 10)
    }
}

#Preview {
    //CustomTextField(name: "Username", textImage: "person.crop.circle")
    //CustomTextField(name: "Name", xOffset: 72)
    //CustomTextField(name: "Surname", xOffset: 83)
    //CustomTextField(name: "Email", textImage: "envelope", xOffset: 70)
    //CustomPasswordField(name: "Password", textImage: "lock")
}
