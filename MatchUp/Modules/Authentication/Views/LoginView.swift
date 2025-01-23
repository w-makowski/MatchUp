//
//  LoginView.swift
//  MatchUp
//
//  Created by Wojciech Makowski on 26/11/2024.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @EnvironmentObject var authState: AuthState
    @Binding var isLoginView: Bool
    
    init(authState: AuthState, appState: AppState, isLoginView: Binding<Bool>){
        _viewModel = StateObject(wrappedValue: LoginViewModel(authState: authState, appState: appState))
        self._isLoginView = isLoginView
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 20) {
                Text("MatchUp")
                    .font(.system(size: 64, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.bottom, 100)
                    .padding(.top, 110)
                
                CustomTextField(name: "Username", textImage: "person.crop.circle", textFieldValue: $viewModel.username)
                CustomPasswordField(name: "Password", textImage: "lock", textFieldValue: $viewModel.password)
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                    
                } else {
                    Text("No Error")
                        .foregroundStyle(.black)
                }
                
                Button(action: { viewModel.signIn()
                }) {
                    Text("Sign In")
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(Color.black)
                        .foregroundStyle(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 40)
                                .stroke(Color.white, lineWidth: 2))
                }
                .background(Color.black)
                .cornerRadius(40)
                .presentationCornerRadius(20)
                .padding(.horizontal, 16)
                .padding(.top, 25)
                
                Button(action: {
                    isLoginView = false
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
                .padding(.top, 10)
                .padding(.bottom, 16)
             
                Spacer()
            }
        
        }
    }
}

#Preview {
    @Previewable @State var isLoginView: Bool = true
    let authState: AuthState = AuthState()
    LoginView(authState: authState, appState: AppState(), isLoginView: $isLoginView)
        .environmentObject(authState)
}
