import QtQuick
import Qt5Compat.GraphicalEffects
import qs.core
import qs.services

// Dense Circular Radial Bars Visualizer: Compact rotating CD disc in center,
// filled backdrop circle, and dense radial spectrum bars radiating outward.
Item {
    id: root

    anchors.fill: parent

    readonly property real centerX: width / 2
    readonly property real centerY: height / 2

    // ── Configuration & Dimensions ────────────────────────────────
    property real centerDiameter: 190
    property real innerRadius: centerDiameter / 2
    // Filled backdrop ring radius (126px radius = 252px base circle diameter)
    property real baseCircleRadius: innerRadius + 31
    // Bold, dense radial spectrum bars radiating around the perimeter
    property int barCount: 72
    property real barWidth: 3.6
    property real minBarHeight: 7.0
    property real maxBarHeight: 95.0
    property real rawMax: 550
    property int fadeInMs: 250

    opacity: 0
    Component.onCompleted: opacity = 1
    Behavior on opacity {
        NumberAnimation {
            duration: root.fadeInMs
            easing.type: Easing.OutCubic
        }
    }

    // ── Dynamic Theme Pack Color Interpolation ─────────────────────
    function getThemeColorForRatio(ratio) {
        const stops = [
            Theme.color3,  // Yellow / Amber / Gold
            Theme.color1,  // Red / Coral / Pink
            Theme.color5,  // Magenta / Purple
            Theme.color4,  // Blue / Indigo
            Theme.color6,  // Cyan / Aqua / Electric Blue
            Theme.color2,  // Green / Emerald
            Theme.color3   // Wrap back to Yellow
        ];

        const scaled = ratio * (stops.length - 1);
        const idx = Math.floor(scaled);
        const t = Math.max(0, Math.min(1.0, scaled - idx));

        const c1 = stops[Math.min(idx, stops.length - 1)];
        const c2 = stops[Math.min(idx + 1, stops.length - 1)];

        return Qt.rgba(
            c1.r + t * (c2.r - c1.r),
            c1.g + t * (c2.g - c1.g),
            c1.b + t * (c2.b - c1.b),
            1.0
        );
    }

    function getColorForAngle(angleDeg) {
        const ratio = (((angleDeg % 360) + 360) % 360) / 360.0;
        return getThemeColorForRatio(ratio);
    }

    // ── Cava Audio Spectrum Mapping with Smooth Interpolation ─────
    function getRawAudioValue(i) {
        const bars = AudioVisualizer.bars;
        if (!bars || bars.length === 0)
            return 0;

        // Symmetric frequency mapping: Bass at bottom, mids on sides, treble at top
        const normIdx = Math.abs((i / root.barCount) * 2.0 - 1.0);
        const barPos = normIdx * (bars.length - 1);
        const idx0 = Math.floor(barPos);
        const idx1 = Math.min(bars.length - 1, idx0 + 1);
        const frac = barPos - idx0;

        const v0 = bars[idx0] ?? 0;
        const v1 = bars[idx1] ?? 0;
        return v0 * (1.0 - frac) + v1 * frac;
    }

    property var _smoothedAmps: []

    // ── 1. Filled Circle with Dense Radial Spectrum Bars (Canvas) ─
    Canvas {
        id: visualizerCanvas
        anchors.fill: parent

        renderTarget: Canvas.FramebufferObject
        renderStrategy: Canvas.Threaded

        Connections {
            target: AudioVisualizer
            function onBarsChanged() {
                visualizerCanvas.requestPaint();
            }
        }

        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();

            const cx = root.centerX;
            const cy = root.centerY;
            const count = root.barCount;
            const baseR = root.baseCircleRadius;

            if (!root._smoothedAmps || root._smoothedAmps.length !== count) {
                root._smoothedAmps = new Array(count).fill(0);
            }

            // ── Pass 1: Filled Circle Body behind the CD ───────────────
            ctx.beginPath();
            ctx.arc(cx, cy, baseR, 0, Math.PI * 2);
            ctx.fillStyle = Qt.rgba(Theme.background.r, Theme.background.g, Theme.background.b, 0.75);
            ctx.fill();

            ctx.fillStyle = Qt.rgba(Theme.selected.r, Theme.selected.g, Theme.selected.b, 0.22);
            ctx.fill();

            // Glowing boundary ring
            ctx.beginPath();
            ctx.arc(cx, cy, baseR, 0, Math.PI * 2);
            ctx.strokeStyle = Theme.selected;
            ctx.lineWidth = 2.4;
            ctx.stroke();

            // ── Pass 2: High-Visibility Dense Radial Spectrum Bars ────
            for (let i = 0; i < count; i++) {
                const rawVal = root.getRawAudioValue(i);
                // Vivid non-linear scaling for rich dynamic visualization
                const targetNorm = Math.min(1.0, Math.pow(Math.max(0, rawVal) / root.rawMax, 0.72));

                // Punchy attack & smooth decay envelope follower
                if (targetNorm > root._smoothedAmps[i]) {
                    root._smoothedAmps[i] += (targetNorm - root._smoothedAmps[i]) * 0.75;
                } else {
                    root._smoothedAmps[i] += (targetNorm - root._smoothedAmps[i]) * 0.18;
                }
                const norm = root._smoothedAmps[i];

                const angle = (i / count) * 2 * Math.PI - (Math.PI / 2);
                const cos = Math.cos(angle);
                const sin = Math.sin(angle);

                const barLen = root.minBarHeight + (norm * root.maxBarHeight);
                const rStart = baseR + 3;
                const rEnd = rStart + barLen;

                const x1 = cx + rStart * cos;
                const y1 = cy + rStart * sin;
                const x2 = cx + rEnd * cos;
                const y2 = cy + rEnd * sin;

                const color = root.getThemeColorForRatio(i / count);

                // Layer A: Dark contrasting shadow outline (ensures 100% visibility on light & dark wallpapers)
                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
                ctx.strokeStyle = Qt.rgba(0, 0, 0, 0.75);
                ctx.lineWidth = root.barWidth + 2.4;
                ctx.lineCap = "round";
                ctx.globalAlpha = 0.85;
                ctx.stroke();

                // Layer B: Luminous color aura
                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
                ctx.strokeStyle = color;
                ctx.lineWidth = root.barWidth + 2.0;
                ctx.lineCap = "round";
                ctx.globalAlpha = 0.40;
                ctx.stroke();

                // Layer C: Solid vibrant themed radial bar
                ctx.beginPath();
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
                ctx.strokeStyle = color;
                ctx.lineWidth = root.barWidth;
                ctx.lineCap = "round";
                ctx.globalAlpha = 0.98;
                ctx.stroke();

                // Layer D: Brilliant white electric tip on active bars
                if (norm > 0.35) {
                    const tipLen = Math.min(barLen * 0.40, 9.0);
                    const tx1 = cx + (rEnd - tipLen) * cos;
                    const ty1 = cy + (rEnd - tipLen) * sin;

                    ctx.beginPath();
                    ctx.moveTo(tx1, ty1);
                    ctx.lineTo(x2, y2);
                    ctx.strokeStyle = "#ffffff";
                    ctx.lineWidth = root.barWidth * 0.85;
                    ctx.lineCap = "round";
                    ctx.globalAlpha = Math.min(1.0, (norm - 0.35) * 2.2);
                    ctx.stroke();
                }
            }
        }
    }

    // ── Floating Ambient Electric Sparks Data ─────────────────────
    readonly property var sparksData: {
        const list = [];
        const count = 36;
        for (let k = 0; k < count; k++) {
            const angle = (k * 137.5) % 360;
            const rOffset = 15 + ((k * 41) % 40);
            const pSize = 1.8 + ((k * 13) % 3) * 0.8;
            const baseOpacity = 0.35 + ((k * 31) % 45) / 100.0;
            list.push({
                angle: angle,
                rOffset: rOffset,
                pSize: pSize,
                baseOpacity: baseOpacity
            });
        }
        return list;
    }

    // ── 2. Floating Sparks along the Perimeter ─────────────────────
    Repeater {
        id: sparksRepeater
        model: root.sparksData

        delegate: Item {
            id: sparkItem
            required property int index
            required property var modelData

            x: root.centerX
            y: root.centerY
            rotation: modelData.angle - 90

            Rectangle {
                x: root.baseCircleRadius + root.maxBarHeight * 0.65 + modelData.rOffset + (AudioVisualizer.bass / 2000)
                y: -modelData.pSize / 2
                width: modelData.pSize
                height: modelData.pSize
                radius: width / 2
                color: (index % 3 === 0) ? "#ffffff" : root.getColorForAngle(modelData.angle)
                opacity: Math.min(1.0, modelData.baseOpacity + (AudioVisualizer.level / 1000))

                Behavior on opacity {
                    NumberAnimation { duration: 90 }
                }
                Behavior on x {
                    NumberAnimation { duration: 70 }
                }
            }
        }
    }

    // ── 3. Rotating CD Disc (Centered Inside the Circle) ───────────
    Item {
        id: centerContainer
        anchors.centerIn: parent
        width: root.centerDiameter
        height: root.centerDiameter

        // Bass-reactive breathing scale pulse
        scale: 1.0 + Math.min(0.04, AudioVisualizer.bass / 15000)
        Behavior on scale {
            NumberAnimation {
                duration: 80
                easing.type: Easing.OutQuad
            }
        }

        // Radiant Outer Glow Ring around the smaller CD
        Rectangle {
            id: outerGlowRing
            anchors.centerIn: parent
            width: parent.width + 6
            height: parent.height + 6
            radius: width / 2
            color: "transparent"
            border.width: 3.0
            border.color: Theme.selected
            opacity: 0.85 + Math.min(0.15, AudioVisualizer.bass / 1200)

            Behavior on opacity {
                NumberAnimation { duration: 90 }
            }
        }

        // Rotating CD Disc Container
        Item {
            id: discItem
            anchors.fill: parent

            // Continuous vinyl CD spin
            NumberAnimation on rotation {
                from: 0
                to: 360
                duration: 20000
                loops: Animation.Infinite
                running: MediaService.isPlaying
                paused: !MediaService.isPlaying
            }

            // Cover Art Image
            Image {
                id: coverImage
                anchors.fill: parent
                source: MediaService.albumArt
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                visible: false
            }

            // Circular Mask
            Rectangle {
                id: circleMask
                anchors.fill: parent
                color: "black"
                radius: width / 2
                visible: false
            }

            OpacityMask {
                anchors.fill: parent
                maskSource: circleMask
                source: coverImage
                visible: MediaService.albumArt !== ""
            }

            // Fallback disc styling when no album art
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: Theme.background
                visible: MediaService.albumArt === ""

                // Concentric vinyl groove rings
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.76
                    height: width
                    radius: width / 2
                    color: "transparent"
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                }
                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width * 0.52
                    height: width
                    radius: width / 2
                    color: "transparent"
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                }

                LucideIcon {
                    anchors.centerIn: parent
                    icon: "music"
                    size: 48
                    color: Theme.selected
                    opacity: 0.8
                }
            }

            // Concentric vinyl reflection sheen
            Rectangle {
                anchors.centerIn: parent
                width: parent.width * 0.72
                height: width
                radius: width / 2
                color: "transparent"
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.08)
                visible: MediaService.albumArt !== ""
            }

            // Center vinyl spindle hole
            Rectangle {
                anchors.centerIn: parent
                width: 26
                height: 26
                radius: width / 2
                color: "#16161e"
                border.color: Theme.selected
                border.width: 2.5
                visible: MediaService.albumArt !== ""
                opacity: 0.95

                Rectangle {
                    anchors.centerIn: parent
                    width: 10
                    height: 10
                    radius: width / 2
                    color: "#0c0c14"
                }
            }
        }

        // Inner glossy rim border over the artwork
        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: "transparent"
            border.width: 2.0
            border.color: Qt.rgba(1, 1, 1, 0.25)
        }

        // Interactive play/pause click handler with hover feedback
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: MediaService.togglePlayPause()

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "black"
                opacity: parent.containsMouse ? 0.35 : 0.0
                Behavior on opacity { NumberAnimation { duration: 150 } }

                LucideIcon {
                    anchors.centerIn: parent
                    icon: MediaService.isPlaying ? "pause" : "play"
                    size: 38
                    color: "white"
                    opacity: parent.parent.containsMouse ? 0.95 : 0.0
                    Behavior on opacity { NumberAnimation { duration: 150 } }
                }
            }
        }
    }
}
