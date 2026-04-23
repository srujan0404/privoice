import SwiftUI
import PrivoiceCore

struct LoginView: View {
    @Environment(AppState.self) private var appState
    @State private var vm: AuthViewModel?

    var body: some View {
        NavigationStack {
            Group {
                if let vm {
                    form(vm: vm)
                } else {
                    ProgressView()
                }
            }
            .navigationTitle("Privoice")
            .navigationBarTitleDisplayMode(.large)
        }
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
