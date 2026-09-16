import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import QtMultimedia
import qs.core
import qs.services

Item {
    id: root
    property real uiScale: 1.0

    property string searchText: ""

    // ── Content-driven sizing ──────────────────────────────────
    readonly property real cardHeight: 140 * uiScale
    readonly property real cardWidth: cardHeight * 16 / 9
    readonly property int visibleCards: 4
    readonly property real listSpacing: 10 * uiScale
    readonly property real outerMargins: 12 * uiScale

    implicitWidth: (root.cardWidth * root.visibleCards) + (root.listSpacing * (root.visibleCards - 1)) + (root.outerMargins * 2)
    implicitHeight: headerRow.implicitHeight + dividerRect.height + root.cardHeight + (mainColumn.spacing * 2) + (mainColumn.anchors.margins * 2)

    property bool applyColors: true
    property string selectedMode: "auto"
    property string confirmedPath: Colors.wallpaper
    property string previewPath: ""
    property bool loading: true

    readonly property var filteredWallpapers: root.searchText === "" ? ThemeActions.liveWallpapers : ThemeActions.liveWallpapers.filter(w => w.name.toLowerCase().includes(root.searchText.toLowerCase()))

    function navigate(delta) {
        wallpaperList.keyboardNavigating = true;
        keyboardLockTimer.restart();
        if (delta < 0)
            wallpaperList.decrementCurrentIndex();
        else
            wallpaperList.incrementCurrentIndex();
    }
    function activateSelected() {
        wallpaperList._confirmCurrent();
    }

    onSearchTextChanged: {
        if (wallpaperList.currentIndex >= root.filteredWallpapers.length)
            wallpaperList.currentIndex = 0;
    }

    Component.onCompleted: {
        ThemeActions.fetchLiveWallpapers();
    }
    Component.onDestruction: {
        if (root.confirmedPath !== "")
            ThemeActions.previewWallpaper(root.confirmedPath);
    }

    Connections {
        target: ThemeActions
        function onLiveWallpapersLoaded() {
            root.loading = false;
        }
    }

    Timer {
        id: previewTimer
        interval: 350
        onTriggered: {
            if (root.previewPath !== "")
                ThemeActions.previewWallpaper(root.previewPath);
        }
    }

    Timer {
        id: restoreTimer
        interval: 150
        onTriggered: {
            if (root.previewPath === "" && root.confirmedPath !== "")
                ThemeActions.previewWallpaper(root.confirmedPath);
        }
    }

    ColumnLayout {
        id: mainColumn
        anchors.fill: parent
        anchors.margins: root.outerMargins
        spacing: root.outerMargins

        // ── Header ────────────────────────────────────────────────
        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            spacing: 12 * root.uiScale

            Column {
                spacing: 2 * root.uiScale
                Row {
                    spacing: 6 * root.uiScale
                    Text {
                        text: "Live Wallpapers"
                        color: Theme.foreground
                        font.family: Theme.fontName
                        font.pixelSize: 14 * root.uiScale
                        font.bold: true
                    }
                    Rectangle {
                        width: 38 * root.uiScale
                        height: 16 * root.uiScale
                        radius: 4 * root.uiScale
                        color: Qt.rgba(0.9, 0.2, 0.3, 0.2)
                        border.width: 1
                        border.color: Qt.rgba(0.9, 0.2, 0.3, 0.5)
                        anchors.verticalCenter: parent.verticalCenter
                        Text {
                            anchors.centerIn: parent
                            text: "LIVE"
                            color: "#ff5252"
                            font.pixelSize: 9 * root.uiScale
                            font.bold: true
                        }
                    }
                }
                Text {
                    text: root.loading ? "Loading..." : root.filteredWallpapers.length + " found"
                    color: Theme.foreground
                    font.family: Theme.fontName
                    font.pixelSize: 10 * root.uiScale
                    opacity: 0.45
                }
            }

            // Segmented Switcher (Static / Live)
            Rectangle {
                height: 28 * root.uiScale
                width: switchRow.implicitWidth + 8 * root.uiScale
                radius: 14 * root.uiScale
                color: Qt.rgba(Theme.borderColor.r, Theme.borderColor.g, Theme.borderColor.b, 0.2)
                border.width: 1
                border.color: Theme.borderColor

                RowLayout {
                    id: switchRow
                    anchors.centerIn: parent
                    spacing: 4 * root.uiScale

                    Rectangle {
                        height: 22 * root.uiScale
                        width: staticTxt.implicitWidth + 16 * root.uiScale
                        radius: 11 * root.uiScale
                        color: "transparent"

                        Text {
                            id: staticTxt
                            anchors.centerIn: parent
                            text: "Static"
                            color: Theme.foreground
                            font.family: Theme.fontName
                            font.pixelSize: 10 * root.uiScale
                            opacity: staticMa.containsMouse ? 0.9 : 0.6
                        }
                        MouseArea {
                            id: staticMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: ShellState.openWallpapers(ShellState.activeScreenName)
                        }
                    }

                    Rectangle {
                        height: 22 * root.uiScale
                        width: liveTxt.implicitWidth + 16 * root.uiScale
                        radius: 11 * root.uiScale
                        color: Theme.selected

                        Text {
                            id: liveTxt
                            anchors.centerIn: parent
                            text: "Live"
                            color: "white"
                            font.family: Theme.fontName
                            font.pixelSize: 10 * root.uiScale
                            font.bold: true
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 6 * root.uiScale
                visible: root.applyColors
                opacity: root.applyColors ? 1.0 : 0.0
                Behavior on opacity {
                    Anim {
                        type: Anim.DefaultEffects
                    }
                }

                Rectangle {
                    height: 24 * root.uiScale
                    width: modeSwitchRow.implicitWidth + 6 * root.uiScale
                    radius: 12 * root.uiScale
                    color: Qt.rgba(Theme.borderColor.r, Theme.borderColor.g, Theme.borderColor.b, 0.2)
                    border.width: 1
                    border.color: Theme.borderColor

                    RowLayout {
                        id: modeSwitchRow
                        anchors.centerIn: parent
                        spacing: 2 * root.uiScale

                        Rectangle {
                            height: 18 * root.uiScale
                            width: autoModeTxt.implicitWidth + 12 * root.uiScale
                            radius: 9 * root.uiScale
                            color: root.selectedMode === "auto" ? Theme.selected : "transparent"
                            Text {
                                id: autoModeTxt
                                anchors.centerIn: parent
                                text: "Auto"
                                color: root.selectedMode === "auto" ? "white" : Theme.foreground
                                font.family: Theme.fontName
                                font.pixelSize: 9 * root.uiScale
                                font.bold: root.selectedMode === "auto"
                                opacity: root.selectedMode === "auto" ? 1.0 : 0.6
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedMode = "auto"
                            }
                        }

                        Rectangle {
                            height: 18 * root.uiScale
                            width: lightModeTxt.implicitWidth + 12 * root.uiScale
                            radius: 9 * root.uiScale
                            color: root.selectedMode === "light" ? Theme.selected : "transparent"
                            Text {
                                id: lightModeTxt
                                anchors.centerIn: parent
                                text: "Light"
                                color: root.selectedMode === "light" ? "white" : Theme.foreground
                                font.family: Theme.fontName
                                font.pixelSize: 9 * root.uiScale
                                font.bold: root.selectedMode === "light"
                                opacity: root.selectedMode === "light" ? 1.0 : 0.6
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedMode = "light"
                            }
                        }

                        Rectangle {
                            height: 18 * root.uiScale
                            width: darkModeTxt.implicitWidth + 12 * root.uiScale
                            radius: 9 * root.uiScale
                            color: root.selectedMode === "dark" ? Theme.selected : "transparent"
                            Text {
                                id: darkModeTxt
                                anchors.centerIn: parent
                                text: "Dark"
                                color: root.selectedMode === "dark" ? "white" : Theme.foreground
                                font.family: Theme.fontName
                                font.pixelSize: 9 * root.uiScale
                                font.bold: root.selectedMode === "dark"
                                opacity: root.selectedMode === "dark" ? 1.0 : 0.6
                            }
                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.selectedMode = "dark"
                            }
                        }
                    }
                }

                Rectangle {
                    width: 1
                    height: 18 * root.uiScale
                    color: Theme.borderColor
                    opacity: 0.5
                }
            }

            Text {
                text: "Dynamic colors"
                color: Theme.foreground
                font.family: Theme.fontName
                font.pixelSize: 12 * root.uiScale
                opacity: 0.7
                verticalAlignment: Text.AlignVCenter
            }

            ToggleSwitch {
                uiScale: root.uiScale
                checked: root.applyColors
                onToggled: root.applyColors = !root.applyColors
            }
        }

        Rectangle {
            id: dividerRect
            Layout.fillWidth: true
            height: 1
            color: Theme.borderColor
            opacity: 0.4
        }

        // ── Live Wallpaper List ──────────────────────────────────
        ListView {
            id: wallpaperList
            Layout.fillWidth: true
            Layout.preferredHeight: root.cardHeight
            orientation: ListView.Horizontal
            spacing: root.listSpacing
            clip: true
            model: root.filteredWallpapers
            boundsBehavior: Flickable.StopAtBounds
            highlightMoveDuration: 200

            property bool keyboardNavigating: false

            Timer {
                id: keyboardLockTimer
                interval: 600
                onTriggered: wallpaperList.keyboardNavigating = false
            }

            onCurrentItemChanged: {
                if (currentItem && currentItem.itemPath) {
                    root.previewPath = currentItem.itemPath;
                    previewTimer.restart();
                    restoreTimer.stop();
                }
            }

            HoverHandler {
                onHoveredChanged: {
                    if (!hovered) {
                        root.previewPath = "";
                        previewTimer.stop();
                        restoreTimer.start();
                    }
                }
            }

            function _confirmCurrent() {
                if (currentItem && currentItem.itemPath) {
                    root.confirmedPath = currentItem.itemPath;
                    root.previewPath = "";
                    previewTimer.stop();
                    ThemeActions.setWallpaper(currentItem.itemPath, root.applyColors, root.selectedMode);
                }
            }

            delegate: Item {
                id: delegateItem

                property string itemPath: modelData.path
                property string itemThumbnail: modelData.thumbnail
                property bool isHovered: mouseArea.containsMouse
                property bool isCurrent: wallpaperList.currentIndex === index
                property bool isConfirmed: Colors.wallpaper === itemPath

                width: root.cardWidth
                height: wallpaperList.height

                Rectangle {
                    id: card
                    anchors.fill: parent
                    anchors.margins: 6 * root.uiScale
                    radius: Theme.radius
                    color: "transparent"
                    clip: false

                    border.width: isConfirmed ? 2 : 1
                    border.color: isConfirmed ? Theme.selected : Theme.borderColor
                    Behavior on border.color {
                        AnimColor {
                            type: Anim.FastEffects
                        }
                    }

                    // Static thumbnail (always loaded first)
                    Image {
                        id: sourceImage
                        anchors.fill: parent
                        anchors.margins: card.border.width
                        source: itemThumbnail ? ("file://" + itemThumbnail) : ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        cache: true
                        visible: false
                        sourceSize.width: root.cardWidth * 2
                        sourceSize.height: root.cardHeight * 2
                    }

                    Rectangle {
                        id: imgMask
                        anchors.fill: sourceImage
                        radius: Theme.radius - card.border.width
                        visible: false
                    }

                    OpacityMask {
                        id: maskedImage
                        anchors.fill: sourceImage
                        source: sourceImage
                        maskSource: imgMask
                        scale: (isHovered || isCurrent) ? 1.06 : 1.0
                        Behavior on scale {
                            Anim {
                                type: Anim.FastToggle
                            }
                        }
                    }

                    // In-card Live Video Preview (triggered on hover/focus)
                    Item {
                        id: videoContainer
                        anchors.fill: sourceImage
                        visible: isHovered || isCurrent
                        opacity: visible ? 1.0 : 0.0
                        Behavior on opacity {
                            Anim {
                                type: Anim.FastEffects
                            }
                        }

                        MediaPlayer {
                            id: inCardPlayer
                            source: (isHovered || isCurrent) ? ("file://" + delegateItem.itemPath) : ""
                            loops: MediaPlayer.Infinite
                            audioOutput: null
                            Component.onCompleted: {
                                if (isHovered || isCurrent)
                                    inCardPlayer.play();
                            }
                        }

                        VideoOutput {
                            id: inCardOutput
                            anchors.fill: parent
                            fillMode: VideoOutput.PreserveAspectCrop
                        }

                        Connections {
                            target: delegateItem
                            function onIsHoveredChanged() {
                                if (delegateItem.isHovered || delegateItem.isCurrent) {
                                    inCardPlayer.play();
                                } else {
                                    inCardPlayer.stop();
                                }
                            }
                            function onIsCurrentChanged() {
                                if (delegateItem.isHovered || delegateItem.isCurrent) {
                                    inCardPlayer.play();
                                } else {
                                    inCardPlayer.stop();
                                }
                            }
                        }
                    }

                    Rectangle {
                        anchors.fill: sourceImage
                        color: "black"
                        radius: imgMask.radius
                        opacity: (isHovered || isCurrent) ? 0.0 : 0.35
                        Behavior on opacity {
                            Anim {
                                type: Anim.DefaultEffects
                            }
                        }
                    }

                    // Top-left LIVE badge
                    Rectangle {
                        anchors.top: parent.top
                        anchors.left: parent.left
                        anchors.topMargin: 8 * root.uiScale
                        anchors.leftMargin: 8 * root.uiScale
                        height: 18 * root.uiScale
                        width: badgeRow.implicitWidth + 10 * root.uiScale
                        radius: height / 2
                        color: Qt.rgba(0, 0, 0, 0.7)
                        border.width: 1
                        border.color: Qt.rgba(1, 0.3, 0.3, 0.6)

                        Row {
                            id: badgeRow
                            anchors.centerIn: parent
                            spacing: 4 * root.uiScale
                            Rectangle {
                                width: 6 * root.uiScale
                                height: 6 * root.uiScale
                                radius: 3 * root.uiScale
                                color: "#ff4d4f"
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "LIVE"
                                color: "#ff4d4f"
                                font.bold: true
                                font.pixelSize: 8 * root.uiScale
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Top-right confirmation badge
                    Rectangle {
                        visible: isConfirmed
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.topMargin: 8 * root.uiScale
                        anchors.rightMargin: 8 * root.uiScale
                        width: 22 * root.uiScale
                        height: 22 * root.uiScale
                        radius: width / 2
                        color: Theme.selected

                        Text {
                            anchors.centerIn: parent
                            text: "✓"
                            color: "white"
                            font.pixelSize: 11 * root.uiScale
                            font.bold: true
                        }
                    }

                    // Bottom name banner
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: 28 * root.uiScale
                        color: Qt.rgba(0, 0, 0, 0.7)
                        radius: Theme.radius
                        visible: isHovered || isCurrent

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 8 * root.uiScale
                            anchors.rightMargin: 8 * root.uiScale
                            text: modelData.name
                            color: "white"
                            font.family: Theme.fontName
                            font.pixelSize: 10 * root.uiScale
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onEntered: {
                            if (wallpaperList.keyboardNavigating)
                                return;
                            restoreTimer.stop();
                            wallpaperList.currentIndex = index;
                            root.previewPath = delegateItem.itemPath;
                            previewTimer.restart();
                        }

                        onClicked: {
                            root.confirmedPath = delegateItem.itemPath;
                            root.previewPath = "";
                            previewTimer.stop();
                            ThemeActions.setWallpaper(delegateItem.itemPath, root.applyColors, root.selectedMode);
                        }
                    }
                }
            }
        }
    }

    Text {
        anchors.centerIn: parent
        visible: root.filteredWallpapers.length === 0
        text: root.loading ? "Loading live wallpapers..." : (root.searchText !== "" ? "No matching live wallpapers" : "No live wallpapers found in\n~/Pictures/Wallpapers or ~/Pictures/LiveWallpapers\n(Supports .mp4, .webm, .mkv)")
        color: Theme.foreground
        font.family: Theme.fontName
        font.pixelSize: 13 * root.uiScale
        opacity: 0.45
        horizontalAlignment: Text.AlignHCenter
    }
}
