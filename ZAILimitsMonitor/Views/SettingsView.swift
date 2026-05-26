import SwiftUI

struct SettingsView: View {
    @Bindable var viewModel: QuotaViewModel
    @State private var apiKey = ""
    @State private var saveMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Z.ai API Key")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)

            SecureField("Enter your Z.ai API key", text: $apiKey)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 12, design: .monospaced))

            HStack {
                Button("Save") {
                    viewModel.saveApiKey(apiKey)
                    saveMessage = "Saved!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        saveMessage = ""
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(apiKey.isEmpty)

                Button("Delete") {
                    viewModel.saveApiKey("")
                    apiKey = ""
                    saveMessage = "Deleted!"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        saveMessage = ""
                    }
                }
                .buttonStyle(.bordered)
                .tint(.red)

                if !saveMessage.isEmpty {
                    Text(saveMessage)
                        .font(.system(size: 11))
                        .foregroundStyle(.green)
                }
            }

            Divider()

            Text("The API key is stored securely in your macOS Keychain.")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)

            HStack(spacing: 4) {
                Text("Get your API key from:")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                HoverLink(destination: URL(string: "https://z.ai/manage-apikey/apikey-list")!) {
                    Text("z.ai API keys")
                        .font(.system(size: 10))
                }
            }

            Spacer()

            HStack {
                Spacer()
                Text("v\(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?.?.?")")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                Button("Exit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            apiKey = viewModel.loadApiKey()
        }
    }
}
