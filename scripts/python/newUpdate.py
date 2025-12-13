#!/usr/bin/env python3
"""
updateTray.py – System‑updates tray icon with context menu

Features added:
* Right‑click context menu with “Check for updates”, “Update system” and “Exit”
* Menu items automatically enable/disable and change text depending on whether
  there are pending updates.
"""

import subprocess
import sys

from qtpy.QtWidgets import (
    QApplication,
    QSystemTrayIcon,
    QMenu,
    QAction,
)
from qtpy.QtGui import QIcon
from qtpy.QtCore import QTimer

# --------------------------------------------------------------------------- #
# Icon locations (adjust if your icons live elsewhere)
UTD_ICON = "/usr/share/icons/breeze-dark/status/64/security-high.svg"
UA_ICON = "/usr/share/icons/breeze-dark/status/64/security-medium.svg"

utdIcon = QIcon(UTD_ICON)          # “up‑to‑date”
uaIcon = QIcon(UA_ICON)           # “updates available”

app = QApplication(sys.argv)
tray = QSystemTrayIcon(utdIcon, parent=app)

# --------------------------------------------------------------------------- #
# State
global Update_Status
Update_Status = False
timerInterval: int = 30 * 60 * 1000   # 30 min

# --------------------------------------------------------------------------- #
# Menu items – we keep them global so the helper can touch them later
checkAction = QAction("Check for updates")
updateAction = QAction("Update system")
exitAction = QAction("Exit")

menu = QMenu()
menu.addAction(checkAction)
menu.addSeparator()
menu.addAction(updateAction)
menu.addSeparator()
menu.addAction(exitAction)

tray.setContextMenu(menu)


# --------------------------------------------------------------------------- #
# Helper – keep the menu in sync with `status`


def update_menu() -> None:
    print("update_menu called")
    """
    Enable/disable and rename actions based on whether updates are pending.
    """
    if Update_Status:  # Updates are available
        checkAction.isVisible = False
        updateAction.isVisible = True
    else:      # System is up‑to‑date
        checkAction.isVisible = True
        updateAction.isVisible = False

# --------------------------------------------------------------------------- #
# Core logic ---------------------------------------------------------------


def clicked(whichClick):
    print("clicked called")
    """
    Left‑click behaviour – keeps the old “quick” actions.
    Middle‑click exits the app (kept for backward compatibility).
    """
    if whichClick == QSystemTrayIcon.ActivationReason.Trigger:
        # If updates are available, start updating; otherwise do a quick check
        if Update_Status:
            openUpdates()
        else:
            checkForUpdates()
    # elif whichClick == QSystemTrayIcon.ActivationReason.MiddleClick:
    #     app.exit()


def checkForUpdates():
    print("checkForUpdates called")
    """
    Query the system for pending AUR/Flatpak updates.
    """
    tray.setToolTip("Checking for updates…")
    # `checkupdates` prints a list of packages; we only care if it returns
    # something.  The command is run in a shell because we want to use the user
    # environment (e.g., $PATH).
    result = subprocess.run(
        "checkupdates",
        capture_output=True,
        text=True,          # return string instead of bytes
        shell=True,
    )
    Update_Status = bool(result.stdout.strip())
    if Update_Status:
        tray.setIcon(uaIcon)
        tray.setToolTip("Updates are available! Click to update!")
        # send_notification("Updates are available!", UA_ICON)
    else:
        tray.setIcon(utdIcon)
        tray.setToolTip("System is up‑to‑date. Click to check for updates…")
        # send_notification("System is up‑to‑date.", UTD_ICON)

    # Update the menu items
    update_menu()


def openUpdates():
    print("openUpdates called")
    """
    Launch a terminal that runs `paru && flatpak update` and waits for the user.
    After finishing, re‑check for new updates so the icon/menu stay in sync.
    """
    cmd = "alacritty -e /home/vince/Scripts/bash/archSysUpdates.sh"
    subprocess.run(cmd, shell=True)
    checkForUpdates()


def timer_func() -> None:
    print("timer_func called")
    """Periodic background check."""
    checkForUpdates()

# --------------------------------------------------------------------------- #
# Notifications ---------------------------------------------------------------


def send_notification(message: str, icon_path: str) -> None:
    print("send_notification called")
    """
    Simple wrapper around `dunstify`.  The ``-r`` flag reuses the same
    notification ID so that successive notifications replace each other.
    """
    cmd = f'dunstify "System Updates" -i "{icon_path}" -r 127 "{message}"'
    subprocess.run(cmd, shell=True)


# --------------------------------------------------------------------------- #
# Hook up actions -----------------------------------------------
checkAction.triggered.connect(checkForUpdates)
updateAction.triggered.connect(openUpdates)
exitAction.triggered.connect(app.exit)

# The menu must be attached to the tray icon
tray.setContextMenu(menu)

# --------------------------------------------------------------------------- #
# Startup -------------------------------------------------------------
# Show the icon and perform an initial check so the user sees something.
tray.show()
checkForUpdates()

# Periodic timer – every 30 minutes
timer = QTimer()
timer.timeout.connect(timer_func)
timer.start(timerInterval)

sys.exit(app.exec_())
