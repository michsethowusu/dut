# Data Usage

A small Linux desktop app for keeping an eye on internet data when you're on a limited plan.
It's a GTK window over [vnStat](https://humdi.net/vnstat/), which records traffic in the
background and keeps totals across reboots.

## Features

- **Top-bar icon** showing today's usage (e.g. `128 MB / 5 GB`). Click it for a menu with
  **Open Data Usage**, today's and this cycle's totals, and **Quit**. The icon changes to a
  warning sign near your limit. Closing the window hides it to the top bar.
- **Starts at login**, hidden in the top bar, so warnings work even when the window is closed
- **Daily cap**: today's usage against a cap, with a green/amber/red progress bar
- **Monthly plan**: usage this billing cycle, data left, daily average, projection for the
  cycle, and a safe daily budget (set your plan size and reset day)
- **Desktop notifications** at a warning level (default 80%) and at 100%, once each per day/cycle
- Live download/upload speed and the last 7 days of usage
- Counts only real connections (Wi-Fi `wl*`, Ethernet `en*`/`eth*`, mobile `ww*`, USB
  tethering `usb*`) and ignores Docker, LXC and other virtual interfaces

## Install

Tested on Ubuntu 22.04 (GNOME).

```bash
git clone https://github.com/michsethowusu/data-usage.git
cd data-usage
./install.sh
```

The installer adds vnStat and the GTK Python bindings if they're missing (this needs sudo),
copies the app to `~/.local/bin/data-usage`, adds **Data Usage** to your app menu, sets it to
start at login, and starts it in the top bar.

On GNOME the top-bar icon needs the AppIndicator extension, which Ubuntu enables by default.
Without it the app works as a normal window. To stop it starting at login, delete
`~/.config/autostart/data-usage.desktop`.

## Settings

Click the ⚙ button to set:

| Setting | Meaning |
|---|---|
| Monthly plan (GB) | Size of your monthly plan; 0 means no limit |
| Daily cap (GB) | How much you want to use per day; 0 means no limit |
| Plan resets on day | Day of the month your plan renews |
| Warn me at (%) | When to show the first warning |

Settings are saved in `~/.config/data-usage/config.json`.

## Notes

- vnStat only counts from the moment it's installed, so earlier usage isn't included.
- vnStat writes to disk about every 5 minutes and the window refreshes every minute, so
  totals can be a few minutes behind. Live speed updates every 2 seconds.
- Running the app again (for example from the app menu) opens the existing window rather than
  starting a second copy.
