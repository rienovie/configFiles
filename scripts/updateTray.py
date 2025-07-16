import subprocess
import sys

from sys import argv
from qtpy.QtWidgets import QApplication, QSystemTrayIcon
from qtpy.QtGui import QIcon
from qtpy.QtCore import QTimer

utdIcon = QIcon("/usr/share/icons/breeze-dark/status/22@3x/update-none.svg")
uaIcon = QIcon("/usr/share/icons/breeze-dark/status/22@3x/update-medium.svg")
chkIcon = QIcon("/usr/share/icons/breeze-dark/actions/32/view-refresh.svg")

app = QApplication(argv)
tray = QSystemTrayIcon(chkIcon, parent=app)
global status
status = False
global timerInterval
timerInterval = 30 * 60 * 1000  # min * sec * miliseconds


def clicked(whichClick):
    if whichClick == QSystemTrayIcon.ActivationReason.Trigger:
        if status:
            openUpdates()
        else:
            checkForUpdates()
    # elif whichClick == QSystemTrayIcon.ActivationReason.MiddleClick:
    #     app.exit()


def checkForUpdates():
    tray.setIcon(chkIcon)
    tray.setToolTip("Checking for updates...")
    global status
    status = (
        subprocess.run("checkupdates", capture_output=True, shell=True).stdout.__len__()
        > 0
    )
    if status:
        tray.setIcon(uaIcon)
        tray.setToolTip("Updates are avaiable! Click to update!")
        tray.showMessage("System Updates", "Updates are available!", uaIcon)
    else:
        tray.setIcon(utdIcon)
        tray.setToolTip("System is up-to-date. Click to check for updates...")
        tray.showMessage("System Updates", "System is up-to-date.", utdIcon)


def openUpdates():
    subprocess.run(
        "kitty --class updater sh -c \"paru && read -p 'Updates have finished...'\"",
        shell=True,
    )
    checkForUpdates()


def timerFunc():
    checkForUpdates()


tray.activated.connect(clicked)
tray.show()
checkForUpdates()

timerVar = QTimer()
timerVar.timeout.connect(timerFunc)
timerVar.start(timerInterval)

sys.exit(app.exec_())
