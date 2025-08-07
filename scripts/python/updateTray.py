import subprocess
import sys

from sys import argv
from qtpy.QtWidgets import QApplication, QSystemTrayIcon
from qtpy.QtGui import QIcon
from qtpy.QtCore import QTimer

utdLocation: str = "/usr/share/icons/breeze-dark/status/64/security-high.svg"
uaLocation: str = "/usr/share/icons/breeze-dark/status/64/security-medium.svg"

utdIcon = QIcon(utdLocation)
uaIcon = QIcon(uaLocation)

app = QApplication(argv)
tray = QSystemTrayIcon(utdIcon, parent=app)
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
    tray.setToolTip("Checking for updates...")
    global status
    status = (
        subprocess.run("checkupdates", capture_output=True, shell=True).stdout.__len__()
        > 0
    )
    if status:
        tray.setIcon(uaIcon)
        tray.setToolTip("Updates are avaiable! Click to update!")
        sendNotification("Updates are available!", uaLocation)
    else:
        tray.setIcon(utdIcon)
        tray.setToolTip("System is up-to-date. Click to check for updates...")
        sendNotification("System is up-to-date.", utdLocation)


def openUpdates():
    cmd = "ghostty --class=updater"
    cmd += " --background=444444"
    cmd += " --custom-shader=$HOME/Apps/ghostty-shaders/bloom.glsl"
    cmd += ' -e "paru && flatpak update'
    cmd += " && echo -ne '\\e[36mUpdates have finished...'"
    cmd += ' && read"'
    subprocess.run(
        cmd,
        shell=True,
    )
    checkForUpdates()


def timerFunc():
    checkForUpdates()


# BUG: for some reason ID is not working properly
def sendNotification(message, icon):
    cmd = 'dunstify "System Updates" -i "' + icon + '" -r 127 "' + message + '"'
    subprocess.run(
        cmd,
        shell=True,
    )


tray.activated.connect(clicked)
tray.show()
checkForUpdates()

timerVar = QTimer()
timerVar.timeout.connect(timerFunc)
timerVar.start(timerInterval)

sys.exit(app.exec_())
