import SwiftUI
import AppKit

struct HoverButtonStyle: ButtonStyle {
    let cornerRadius: CGFloat

    init(cornerRadius: CGFloat = 6) {
        self.cornerRadius = cornerRadius
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(configuration.isPressed ? 0.8 : 0))
            )
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.6 : 1.0)
    }
}

struct HoverIconButton: View {
    let systemName: String
    let action: () -> Void

    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 15))
                .foregroundStyle(isHovered ? .primary : .secondary)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 0.8 : 0))
                )
                .contentShape(Rectangle())
                .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct HoverLink<Content: View>: View {
    let destination: URL
    let content: () -> Content

    @State private var isHovered = false

    init(destination: URL, @ViewBuilder content: @escaping () -> Content) {
        self.destination = destination
        self.content = content
    }

    var body: some View {
        Link(destination: destination) {
            content()
                .foregroundStyle(isHovered ? Color.primary : Color.blue)
                .padding(2)
                .background(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(isHovered ? 0.8 : 0))
                )
                .contentShape(Rectangle())
                .animation(.easeInOut(duration: 0.15), value: isHovered)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovered = hovering
        }
    }
}

struct PopoverView: View {
    @Bindable var viewModel: QuotaViewModel
    @State private var showSettings = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header

            Divider()

            if showSettings {
                SettingsView(viewModel: viewModel)
            } else {
                quotaContent
            }
        }
        .frame(width: 320)
        .background(.regularMaterial)
        .compositingGroup()
        .onAppear {
            viewModel.startAutoRefresh()
        }
        .onDisappear {
            viewModel.stopAutoRefresh()
        }
    }

    private var header: some View {
        HStack {
            if showSettings {
                HoverIconButton(systemName: "chevron.left") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings.toggle()
                    }
                }

                Text("Settings")
                    .font(.system(size: 13, weight: .semibold))
            } else {
                Image(systemName: "bolt.horizontal")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                Text("Z.ai Limits")
                    .font(.system(size: 13, weight: .semibold))

                if !viewModel.quotaItems.isEmpty {
                    Text(viewModel.planLevel.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15))
                        .clipShape(Capsule())
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if viewModel.isLoading {
                    ProgressView()
                        .controlSize(.small)
                }

                Text(viewModel.timeSinceUpdate)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if !showSettings {
                HoverIconButton(systemName: "gearshape") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showSettings.toggle()
                    }
                }

                HoverIconButton(systemName: "arrow.clockwise") {
                    viewModel.refresh()
                }
                .disabled(viewModel.isLoading)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .frame(height: 36)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    @ViewBuilder
    private var quotaContent: some View {
        if let error = viewModel.errorMessage {
            errorView(error)
        } else if viewModel.quotaItems.isEmpty && !viewModel.isLoading {
            emptyState
        } else {
            quotaList
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundStyle(.orange)
            Text(message)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
            Button("Retry") {
                viewModel.refresh()
            }
            .buttonStyle(HoverButtonStyle())
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "circle.dashed")
                .font(.system(size: 24))
                .foregroundStyle(.secondary)
            Text("No quota data")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
            Text("Set your API key in Settings to get started")
                .font(.system(size: 11))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
    }

    private var quotaList: some View {
        VStack(spacing: 8) {
            ForEach(viewModel.quotaItems) { item in
                QuotaRowView(item: item)
            }
        }
        .padding(12)
        .fixedSize(horizontal: false, vertical: true)
    }
}
