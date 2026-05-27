# Z.ai Limits Monitor

A lightweight macOS menu bar app that displays your Z.ai API usage and quota limits at a glance.

![macOS 14+](https://img.shields.io/badge/macOS-14.0%2B-blue)
![Swift 6](https://img.shields.io/badge/Swift-6.0-orange)
![License: MIT](https://img.shields.io/badge/license-MIT-green)

## Features

- Menu bar popover showing token usage and time-based quotas
- Per-period breakdown (5-hour, weekly, other tools)
- Sub-usage details (Web Search, Web Reader, Zread)
- Auto-refresh with manual refresh option
- API key stored securely in macOS Keychain
- Plan level badge display

## Installation

### Homebrew

```bash
brew tap DmitryReztsov/tap
brew install --cask zailimits
```

### Manual

1. Generate the Xcode project:
   ```bash
   brew install xcodegen
   xcodegen generate
   ```
2. Open `ZAILimitsMonitor.xcodeproj` in Xcode
3. Build and run

## Setup

1. Launch Z.ai Limits Monitor from your Applications folder
2. Click the menu bar icon, then click the gear icon
3. Paste your Z.ai API key and click **Save**

Get your API key from [z.ai API keys](https://z.ai/manage-apikey/apikey-list).

> **Note:** On first launch you may need to right-click the app and select **Open**, or allow it in **System Settings > Privacy & Security**, since the app is not signed with an Apple developer certificate.

## Development

Requires Xcode 26.5+ and macOS 14.0+.

```bash
xcodegen generate
xcodebuild build -project ZAILimitsMonitor.xcodeproj -scheme ZAILimitsMonitor
```

## License

[MIT](LICENSE)
