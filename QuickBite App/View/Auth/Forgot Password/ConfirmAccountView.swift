import SwiftUI

struct ConfirmAccountView: View {
    @StateObject var viewModel = OTPViewModel()
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Confirm your account")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("We sent a code to your email. Enter that code to confirm your account.")
                        .font(.headline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 12) {
                    ForEach(0..<6, id: \.self) { index in
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(.systemGray6))
                                .frame(width: 50, height: 50)
                            
                            Text(viewModel.digit(at: index))
                                .font(.title2)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                .overlay(
                    TextField("", text: $viewModel.code)
                        .keyboardType(.numberPad)
                        .focused($isFocused)
                        .frame(width: 0, height: 0)
                        .opacity(0.01)
                        .onChange(of: viewModel.code) { _, newValue in
                            if newValue.count > 6 {
                                viewModel.code = String(newValue.prefix(6))
                            }
                        }
                )
                .onTapGesture {
                    isFocused = true
                }

                if viewModel.timerActive {
                    Text("Resend code in \(viewModel.timeRemaining)s")
                        .foregroundColor(.gray)
                        .onAppear(perform: viewModel.startTimer)
                } else {
                    Button("Resend code") {
                        viewModel.resendCode()
                    }
                    .foregroundColor(.orange)
                }

                NavigationLink(destination: CreateNewPasswordView()) {
                    Text("Continue")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(viewModel.code.count < 6 ? Color(.systemGray4) : Color.orange)
                        .cornerRadius(24)
                }
                .disabled(viewModel.code.count < 6)

                Spacer()
            }
            .padding(.horizontal, 24)
            .onAppear { isFocused = true }
        }
    }
}
