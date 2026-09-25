# MarketPulse Go

Flutter mobile client wired to the MarketPulse FastAPI backend
(`https://marketpulse-uols.onrender.com`).

## What's included
- Login / Register screens → `/auth/login`, `/auth/register`
- Dashboard screen → `/market/crypto`, `/market/stocks`
- AI Agent chat screen → `/agent/ask`
- JWT stored securely via `flutter_secure_storage`, auto-attached to
  every request via a Dio interceptor
- Provider-based state management (`AuthProvider`, `MarketProvider`, `AgentProvider`)

## Setup

```bash
flutter pub get
flutter run
```

Point at a physical device or emulator — no other config needed, the
API base URL is already set to the deployed Render backend.

