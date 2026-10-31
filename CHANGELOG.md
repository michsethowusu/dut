# Changelog

## v1.0.0 — 2026-10-31

First release.

- Top-bar indicator showing today's usage against your daily cap, with a warning icon near the limit
- Daily cap and monthly plan (any reset day) with progress bars, data left, daily average,
  projection and safe daily budget
- Desktop notifications at a configurable warning level and at 100%
- Per-app usage (today / this cycle) from a NetHogs-based background service
- Last 7 days of history and live download/upload speed
- Counts only real connections (Wi-Fi, Ethernet, mobile, USB tethering); ignores Docker and other virtual interfaces
- Starts at login, hidden in the top bar; single instance
- `.deb` package for Ubuntu/Debian
