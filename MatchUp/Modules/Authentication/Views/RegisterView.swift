//
//  RegisterView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 28/11/2024.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var registerViewModel: RegisterViewModel
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    init(authState: AuthState, appState: AppState){
        _registerViewModel = StateObject(wrappedValue: RegisterViewModel(authState: authState, appState: appState))
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Sign Up")
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.top, 50)
                
                    CustomTextField(name: "Name", textImage: "person", xOffset: 73, textFieldValue: $registerViewModel.name)
                    
                    CustomTextField(name: "Surname", textImage: "person", textFieldValue: $registerViewModel.surname)
                    
                    CustomTextField(name: "Username", textImage: "person.crop.circle", textFieldValue: $registerViewModel.username)
                    
                    CustomTextField(name: "Email", textImage: "envelope", xOffset: 70, textFieldValue: $registerViewModel.email, keyboardType: .emailAddress)
                    
                    CustomPasswordField(name: "Password", textImage: "lock", textFieldValue: $registerViewModel.password)
                    
                    CustomPasswordField(name: "Repeat Password", textImage: "lock", xOffset: 120, textFieldValue: $registerViewModel.repeatPassword)
                       
                    if let errorMessage = registerViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            
                    } else {
                        Text("No Error")
                            .foregroundStyle(.black)
                    }
                
                Button(action: {
                    registerViewModel.signUp()
                }) {
                    Text("Sign Up")
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.white, lineWidth: 2))
                }
                .background(Color.black)
                .cornerRadius(40)
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                
                
                Spacer()
                
                
            }
            //.padding(.bottom, keyboardResponder.currentHeight) // Dynamiczne przesunięcie
            //.animation(.easeOut, value: keyboardResponder.currentHeight)
        }
        .navigationBarBackButtonHidden(true)
    }
}

import Combine
import SwiftUI

class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .merge(with: NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
            .compactMap { notification in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
                return notification.name == UIResponder.keyboardWillHideNotification ? 0 : frame.height
            }
            .assign(to: \.currentHeight, on: self)
    }
}


#Preview {
    RegisterView(authState: AuthState(), appState: AppState())
}
