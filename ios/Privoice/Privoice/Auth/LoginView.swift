import SwiftUI
import PrivoiceCore

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var vm: AuthViewModel?

    var body: some View {
        Group {
            if let vm {
                form(vm: vm)
            } else {
                ProgressView()
            }
        }
        .navigationTitle("Privoice")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            if vm == nil {
                vm = AuthViewModel { response in
                    appState.signIn(with: response)
                }
            }
        }
    }

    @ViewBuilder
    private func form(vm: AuthViewModel) -> some View {
        @Bindable var vm = vm

        VStack(spacing: 20) {
            Button {
                Task { await vm.signInWithGoogle() }
            } label: {
                HStack(spacing: 10) {
                    Image("GoogleLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                    Text("Continue with Google")
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.background, in: .rect(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).strokeBorder(.gray.opacity(0.3), lineWidth: 1))
            }
            .disabled(vm.isSubmitting)
            .padding(.horizontal)

            HStack(spacing: 8) {
                Rectangle().fill(.gray.opacity(0.25)).frame(height: 1)
                Text("or").font(.caption).foregroundStyle(.secondary)
                Rectangle().fill(.gray.opacity(0.25)).frame(height: 1)
            }
            .padding(.horizontal)

            Picker("", selection: $vm.mode) {
                Text("Sign In").tag(AuthViewModel.Mode.signIn)
                Text("Register").tag(AuthViewModel.Mode.register)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            VStack(spacing: 12) {
                if vm.mode == .register {
                    TextField("Display name", text: $vm.displayName)
                        .textContentType(.name)
                        .autocapitalization(.words)
                        .padding(12)
                        .background(.gray.opacity(0.1), in: .rect(cornerRadius: 10))
                }

                TextField("Email", text: $vm.email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(.gray.opacity(0.1), in: .rect(cornerRadius: 10))

                SecureField("Password", text: $vm.password)
                    .textContentType(vm.mode == .register ? .newPassword : .password)
                    .padding(12)
                    .background(.gray.opacity(0.1), in: .rect(cornerRadius: 10))

                if vm.mode == .register {
                    Text("Password must be at least 8 characters")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal)

            if let error = vm.errorMessage {
                Text(error)
                    .font(.callout)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Button {
                Task { await vm.submit() }
            } label: {
                HStack {
                    if vm.isSubmitting {
                        ProgressView().tint(.white)
                    }
                    Text(vm.mode == .signIn ? "Sign In" : "Create Account")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!vm.canSubmit)
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 20)
    }
}
