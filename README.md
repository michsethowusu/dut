# DUT — Data Usage Tracker

DUT (**D**ata **U**sage **T**racker) is a small Linux desktop app for people on limited internet plans: mobile data
bundles, capped home broadband, or tethering from your phone. It sits in your top bar,
shows how much you've used today against your own cap, warns you before you run out, and
(optionally) shows which apps used the data.

<p align="center">
  <img src="docs/screenshot.png" alt="DUT main window" width="420"><br>
  <img src="docs/topbar.png" alt="DUT in the GNOME top bar" width="320">
</p>

## Features

- **Lives in the top bar.** Shows today's usage at a glance, for example `312 MB / 5 GB`.
  Click it for a quick menu; the icon turns into a warning sign as you near your limit.
- **Daily cap.** Set how much you want to use per day and watch a progress bar that goes
  green → amber → red.
- **Monthly plan.** Track usage across your billing cycle (any reset day), with data left,
  daily average, a projection for the whole cycle and a safe daily budget.
- **Warnings.** Desktop notifications at 80% (adjustable) and 100% of your daily cap and plan.
- **Per-app usage (optional).** See which apps used the most data today or this cycle.
- **History.** The last 7 days at a glance, and live download/upload speed.
- **Counts only what costs you money.** Tracks Wi-Fi, Ethernet, mobile modems and USB
  tethering, and ignores Docker, LXC, VPN bridges and other virtual interfaces.
- **Lightweight.** A single Python file over [vnStat](https://humdi.net/vnstat/), which does
  the counting in the background and keeps totals across reboots.

## Requirements

- Ubuntu 22.04 or newer, or another Debian-based distro (tested on Ubuntu 22.04 with GNOME)
- Everything else (vnStat, NetHogs, Python GTK bindings, top-bar icon support) is installed
  automatically by `apt`. See [`packaging/debian/control`](packaging/debian/control).

## Install

### Ubuntu / Debian (recommended)

1. Download **`dut_<version>_all.deb`** from the
   [latest release](https://github.com/michsethowusu/dut/releases/latest).
2. Install it, either by double-clicking it (opens Ubuntu Software), or in a terminal:

   ```bash
   sudo apt install ./dut_*_all.deb
   ```

3. Open **DUT** from your app menu. From then on it starts by itself at login, in the top bar.

`apt` installs everything DUT needs (vnStat, NetHogs, GTK bindings) and starts the background
services: vnStat for total usage and `dut-apps` for per-app usage.

> vnStat only counts from the moment it's installed, so the first day shows only part of the
> day's usage.

To turn per-app tracking off: `sudo systemctl disable --now dut-apps`

### Build the .deb yourself

```bash
git clone https://github.com/michsethowusu/dut.git
cd dut
packaging/build-deb.sh                       # → dist/dut_<version>_all.deb
sudo apt install ./dist/dut_*_all.deb
```

Publishing a GitHub release also builds the `.deb` and attaches it automatically
(see `.github/workflows/release.yml`).

## Using DUT

| What you want | How |
|---|---|
| Open the window | Click the top-bar label → **Open DUT** (or middle-click it), or launch DUT from the app menu |
| Set your daily cap or monthly plan | Click ⚙ in the window |
| See which apps used data | **Apps** tab → choose *Today* or *This cycle* |
| Hide the window | Close it; DUT keeps running in the top bar |
| Quit completely | Top-bar menu → **Quit** |

### Settings

| Setting | Meaning |
|---|---|
| Monthly plan (GB) | Size of your monthly plan; `0` means no limit |
| Daily cap (GB) | How much you want to use per day; `0` means no limit |
| Plan resets on day | Day of the month your plan renews (clamped for short months) |
| Warn me at (%) | When to show the first warning |

Settings are saved in `~/.config/dut/config.json`.

## How it works

```
 network card ──► vnStat daemon ──► vnstat --json ──┐
                                                    ├──► DUT (GTK window + top-bar icon)
 network card ──► NetHogs ──► dut-collector ────┘
                  (optional)   /var/lib/dut/apps.json
```

- **vnStat** records totals per interface. DUT reads them every minute and adds up the
  real (physical) interfaces.
- **dut-collector** (optional) runs NetHogs in trace mode, turns its per-process
  counters into per-app daily totals, and keeps 62 days of history.

### Accuracy notes

- vnStat writes to disk about every 5 minutes, so totals can be a few minutes behind.
  Live speed updates every 2 seconds.
- Your provider's meter may differ slightly: it can count protocol overhead differently or
  round up per session.
- App totals usually add up to a bit less than the overall total. Traffic NetHogs can't tie to
  a program (DNS, some system traffic) goes under *Other*, and all browser tabs count as the
  browser.

## Tips for saving data on Ubuntu

- Mark your connection as metered: **Settings → Wi-Fi → ⚙ next to your network → Details →
  Metered connection**. Ubuntu then holds back automatic updates and other background downloads.
- Use the **Apps** tab to catch background hogs: cloud sync, Snap refreshes, Docker pulls,
  browser auto-updates.
- Hold back snap refreshes: `sudo snap refresh --hold=72h`.

## Uninstall

```bash
sudo apt remove dut           # keeps per-app history in /var/lib/dut
sudo apt purge dut            # also deletes per-app history
```

Your settings stay in `~/.config/dut` (delete that folder to remove them). vnStat and NetHogs
stay installed; remove them with `sudo apt autoremove` if nothing else uses them.

## Project layout

| Path | Purpose | Installed to |
|---|---|---|
| `dut` | The app (GTK window, top-bar icon, notifications) | `/usr/bin/dut` |
| `dut-collector` | Per-app collector run by the `dut-apps` service | `/usr/lib/dut/dut-collector` |
| `packaging/dut-apps.service` | systemd unit for the collector (runs as root) | `/lib/systemd/system/` |
| `packaging/dut.desktop` | App menu entry (also used for autostart with `--hidden`) | `/usr/share/applications/`, `/etc/xdg/autostart/` |
| `packaging/debian/` | Package metadata, dependencies and install/remove scripts | — |
| `packaging/build-deb.sh` | Builds `dist/dut_<version>_all.deb` | — |
| `.github/workflows/release.yml` | Builds the `.deb` and attaches it to each GitHub release | — |
| `requirements.txt` | Dependency reference | — |
| `CHANGELOG.md` | Release notes | — |

## License

[MIT](LICENSE) © 2026 Mich-Seth Owusu
