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

## ⚠️ Things to verify / fix once you check the real backend code

1. **`/market/crypto` and `/market/stocks` field names are guessed.**
   `PriceItem.fromJson` in `lib/models/market_models.dart` tries
   `symbol`/`name`/`ticker` and `price`/`current_price`/`close` defensively,
   but you should open `services/data_fetcher.py` and confirm the exact
   keys being saved to MongoDB, then tighten that model to match exactly.

2. **`/auth/register` body fields are assumed to be `username`, `email`,
   `password`** based on the `register_user(username, email, password)`
   call in `auth_service.py`. Confirm against `models/user.py`
   (`UserRegister` / `UserLogin`) — if field names differ, update
   `lib/services/auth_service.dart`.

3. **`/agent/ask` returns a plain text `answer`, not structured
   risk/trend/confidence fields.** The chat screen renders it as a plain
   text bubble. If you want structured cards (risk badges etc.), that
   needs a backend change to `ask_agent()` first — the Flutter side can't
   invent fields the API doesn't send.

4. **CORS is irrelevant here** — that only applies to browsers. Dio on
   a real device isn't blocked by the `allow_origins` list in `main.py`.

## Folder structure
```
lib/
  main.dart
  models/       -> auth_models, market_models, agent_models
  services/     -> api_client (Dio + token interceptor), auth/market/agent services
  providers/    -> AuthProvider, MarketProvider, AgentProvider
  screens/      -> login, register, home (bottom nav), dashboard, agent_chat
  widgets/      -> price_card
  theme/        -> app_theme
```

## Next steps (do these in order)
1. `flutter pub get` and confirm it builds on your device
2. Test login/register against the real backend
3. Fix field names per the ⚠️ list above once you've confirmed them
4. Add `fl_chart` price trend chart to the dashboard
5. Add Hive caching for offline price viewing
