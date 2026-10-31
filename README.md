# Data Usage

A small Linux desktop app for keeping an eye on internet data when you're on a limited plan.
It's a GTK window over [vnStat](https://humdi.net/vnstat/), which records traffic in the
background and keeps totals across reboots.

## Features

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
copies the app to `~/.local/bin/data-usage` and adds **Data Usage** to your app menu.

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
- Warnings appear only while the window is open; counting always runs in the background.
