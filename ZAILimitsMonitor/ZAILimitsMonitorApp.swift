import SwiftUI

@main
struct ZAILimitsMonitorApp: App {
    @State private var viewModel = QuotaViewModel()

    var body: some Scene {
        MenuBarExtra {
            PopoverView(viewModel: viewModel)
        } label: {
            Label("Z", systemImage: "z.square")
                .labelStyle(.titleOnly)
        }
        .menuBarExtraStyle(.window)
        .defaultSize(width: 320, height: 100)
    }
}
