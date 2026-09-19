import QtQuick
import Quickshell
import qs.core
import qs.services
import "widgets"

// Generic container for anything shown directly over the wallpaper
// (no windows open, nothing else on screen)  -  visualizer+lyrics.
// Gated only on "is the wallpaper actually showing" (see ScreenBorder.qml).
Item {
    id: root

    anchors.fill: parent

    // ── Music section (visualizer + track info + lyrics) ──────────
    Item {
        id: musicSection

        readonly property int visualizerSize: 600

        anchors.fill: parent
        visible: MediaService.isPlaying
        opacity: MediaService.isPlaying ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        // Circular Visualizer  -  anchored at the screen's absolute center
        Loader {
            id: visualizerLoader
            anchors.centerIn: parent
            width: musicSection.visualizerSize
            height: musicSection.visualizerSize
            active: MediaService.isPlaying
            sourceComponent: Component {
                WallpaperVisualizer {}
            }
        }

        // Track Title & Artist  -  anchored below the visualizer
        Column {
            id: trackMeta
            anchors.top: visualizerLoader.bottom
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4
            width: Math.min(parent.width * 0.8, 550)

            Text {
                text: MediaService.title
                font.pixelSize: 22
                font.weight: Font.Bold
                color: Theme.foreground
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                width: parent.width
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.85)
            }

            Text {
                text: MediaService.artist
                font.pixelSize: 15
                color: Theme.foregroundAlt
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                width: parent.width
                visible: text !== ""
                style: Text.Outline
                styleColor: Qt.rgba(0, 0, 0, 0.85)
            }
        }

        // Synchronized Lyrics  -  anchored below track metadata
        Loader {
            id: lyricsLoader
            anchors {
                top: trackMeta.bottom
                topMargin: 20
                left: parent.left
                right: parent.right
            }
            height: item ? item.implicitHeight : 0
            active: LyricsService.hasLyrics
            sourceComponent: Component {
                WallpaperLyrics {}
            }
        }
    }
}
