pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules.common
import qs.modules.common.functions

Singleton {
    id: root

    Connections {
        target: Config.options.background
        function onLockWallChanged() {
            if (!Config.options.background.lockWall || Config.options.background.lockWall.length === 0) {
                // "Same wallpaper for both": point SDDM back at the desktop image
                genProc.command = [
                    "bash", Directories.wallpaperSwitchScriptPath,
                    "--sddm-sync", FileUtils.trimFileProtocol(Config.options.background.wallpaperPath)
                ]
                genProc.running = true
                return
            }
            genProc.command = [
                "bash", Directories.wallpaperSwitchScriptPath,
                "--colors_lock", "--image", FileUtils.trimFileProtocol(Config.options.background.lockWall)
            ]
            genProc.running = true
        }
    }

    Process {
        id: genProc
        onExited: (exitCode) => {
            if (exitCode !== 0) console.warn("[LockWallpaperColorGen] switchwall.sh --colors_lock failed")
        }
    }
}