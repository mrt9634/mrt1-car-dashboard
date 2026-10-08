import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: dashboard
    anchors.fill: parent

    // ─── Theme ─────────────────────────────────────────────────
    readonly property color bgBase:     "#05080d"
    readonly property color bgPanel:    "#0a0f18"
    readonly property color bgCard:     "#0f1520"
    readonly property color accent:     "#00d9ff"
    readonly property color accentSoft: "#0088aa"
    readonly property color accentWarm: "#ffb74d"
    readonly property color danger:     "#ff5252"
    readonly property color success:    "#4cd7a0"
    readonly property color textHi:     "#f5f7fa"
    readonly property color textMid:    "#8b97a8"
    readonly property color textLo:     "#4a5666"
    readonly property color stroke:     "#1a2433"

    // ─── Lifecycle ─────────────────────────────────────────────
    Component.onCompleted: {
        if (setupManager.firstRun) setupManager.runInitialSetup()
        gpsSpeed.start()
        speedRouter.update(vehicleData.speed, gpsSpeed.speedKmh,
                           vehicleData.connected, gpsSpeed.available)
    }

    Connections {
        target: gpsSpeed
        function onSpeedChanged() {
            speedRouter.update(vehicleData.speed, gpsSpeed.speedKmh,
                               vehicleData.connected, gpsSpeed.available)
        }
        function onStateChanged() {
            speedRouter.update(vehicleData.speed, gpsSpeed.speedKmh,
                               vehicleData.connected, gpsSpeed.available)
        }
    }

    Connections {
        target: vehicleData
        function onSpeedChanged() {
            speedRouter.update(vehicleData.speed, gpsSpeed.speedKmh,
                               vehicleData.connected, gpsSpeed.available)
        }
        function onConnectedChanged() {
            speedRouter.update(vehicleData.speed, gpsSpeed.speedKmh,
                               vehicleData.connected, gpsSpeed.available)
        }
    }

    // ─── Background ────────────────────────────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: dashboard.bgBase }
            GradientStop { position: 0.5; color: "#070b13" }
            GradientStop { position: 1.0; color: dashboard.bgBase }
        }
    }

    // Ambient glow behind speedometer
    Rectangle {
        width: 520; height: 520
        radius: 260
        anchors.horizontalCenter: speedCluster.horizontalCenter
        anchors.verticalCenter: speedCluster.verticalCenter
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0.85, 1, 0.10) }
            GradientStop { position: 0.6; color: Qt.rgba(0, 0.85, 1, 0.02) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // ─── Main layout ───────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ═══ TOP BAR ═══════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            radius: 14
            color: dashboard.bgPanel
            border.color: dashboard.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 16

                // Logo + accent dot
                RowLayout {
                    spacing: 10
                    Rectangle {
                        width: 8; height: 8; radius: 4
                        color: dashboard.accent
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.4; duration: 900 }
                            NumberAnimation { to: 1.0; duration: 900 }
                        }
                    }
                    ColumnLayout {
                        spacing: 0
                        Label {
                            text: "MRT1"
                            color: dashboard.textHi
                            font.pixelSize: 22
                            font.bold: true
                            font.letterSpacing: 2
                        }
                        Label {
                            text: "DIGITAL COCKPIT"
                            color: dashboard.textLo
                            font.pixelSize: 9
                            font.letterSpacing: 3
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Status chips
                RowLayout {
                    spacing: 10
                    StatusChip {
                        label: "CAN"
                        active: canProvider.connected
                    }
                    StatusChip {
                        label: "GPS"
                        active: gpsSpeed.available
                    }
                    StatusChip {
                        label: "AI"
                        active: openai.enabled && !openai.busy
                    }
                }

                // Divider
                Rectangle {
                    width: 1; height: 32
                    color: dashboard.stroke
                }

                // Clock
                ColumnLayout {
                    spacing: 0
                    Label {
                        id: clockText
                        text: Qt.formatTime(new Date(), "HH:mm")
                        color: dashboard.textHi
                        font.pixelSize: 24
                        font.bold: true
                        font.letterSpacing: 1
                        horizontalAlignment: Text.AlignRight
                        Layout.alignment: Qt.AlignRight
                    }
                    Label {
                        text: Qt.formatDate(new Date(), "yyyy/MM/dd")
                        color: dashboard.textMid
                        font.pixelSize: 10
                        font.letterSpacing: 1
                        Layout.alignment: Qt.AlignRight
                    }
                }
            }
        }

        // ═══ MAIN AREA ═════════════════════════════════════════
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // ─── LEFT: Speed cluster ───────────────────────────
            Rectangle {
                id: speedCluster
                Layout.fillHeight: true
                Layout.preferredWidth: 360
                radius: 18
                color: dashboard.bgPanel
                border.color: dashboard.stroke
                border.width: 1

                SpeedGauge {
                    id: gauge
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -20
                    width: 280
                    height: 280
                    currentSpeed: speedRouter.displaySpeedKmh >= 0
                                  ? speedRouter.displaySpeedKmh : 0
                    maxSpeed: 240
                }

                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -20
                    spacing: 0

                    Label {
                        text: speedRouter.displaySpeedKmh >= 0
                              ? Math.round(speedRouter.displaySpeedKmh)
                              : "--"
                        color: dashboard.textHi
                        font.pixelSize: 68
                        font.bold: true
                        font.letterSpacing: -2
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Label {
                        text: "km/h"
                        color: dashboard.textMid
                        font.pixelSize: 13
                        font.letterSpacing: 2
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                }

                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 18
                    width: sourceLabel.width + 24
                    height: 26
                    radius: 13
                    color: Qt.rgba(0, 0.85, 1, 0.10)
                    border.color: dashboard.accentSoft
                    border.width: 1

                    Label {
                        id: sourceLabel
                        anchors.centerIn: parent
                        text: speedRouter.source === "NONE"
                              ? "NO SOURCE" : speedRouter.source
                        color: dashboard.accent
                        font.pixelSize: 10
                        font.letterSpacing: 2
                        font.bold: true
                    }
                }
            }

            // ─── CENTER: Info cards ────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    InfoCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "RPM"
                        value: vehicleData.connected
                               ? Math.round(vehicleData.rpm).toString()
                               : "--"
                        unit: "rpm"
                        accentColor: dashboard.accentWarm
                        progress: vehicleData.connected
                                  ? Math.min(vehicleData.rpm / 7000, 1) : 0
                    }

                    InfoCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "COOLANT"
                        value: vehicleData.connected
                               ? Math.round(vehicleData.coolant).toString()
                               : "--"
                        unit: "°C"
                        accentColor: vehicleData.coolant > 105
                                     ? dashboard.danger : dashboard.success
                        progress: vehicleData.connected
                                  ? Math.min(vehicleData.coolant / 130, 1) : 0
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    InfoCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "FUEL"
                        value: vehicleData.connected
                               ? Math.round(vehicleData.fuel).toString()
                               : "--"
                        unit: "%"
                        accentColor: vehicleData.fuel < 15
                                     ? dashboard.danger : dashboard.accent
                        progress: vehicleData.connected
                                  ? vehicleData.fuel / 100 : 0
                    }

                    InfoCard {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        title: "BATTERY"
                        value: vehicleData.connected
                               ? vehicleData.batteryVoltage.toFixed(1)
                               : "--"
                        unit: "V"
                        accentColor: vehicleData.batteryVoltage > 0
                                     && vehicleData.batteryVoltage < 11.5
                                     ? dashboard.danger : dashboard.success
                        progress: vehicleData.connected
                                  ? Math.min(Math.max((vehicleData.batteryVoltage - 10) / 5, 0), 1)
                                  : 0
                    }
                }
            }

            // ─── RIGHT: Jarvis panel ───────────────────────────
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 260
                radius: 18
                color: dashboard.bgPanel
                border.color: dashboard.stroke
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    Label {
                        text: "JARVIS"
                        color: dashboard.textHi
                        font.pixelSize: 14
                        font.bold: true
                        font.letterSpacing: 3
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: dashboard.stroke
                    }

                    Label {
                        text: speechManager.listening
                              ? "● LISTENING"
                              : speechManager.speaking
                                ? "● SPEAKING"
                                : "○ IDLE"
                        color: speechManager.listening || speechManager.speaking
                               ? dashboard.accent : dashboard.textMid
                        font.pixelSize: 11
                        font.letterSpacing: 1
                    }

                    Label {
                        Layout.fillWidth: true
                        text: openai.reply.length > 0
                              ? openai.reply
                              : "Ready. Tap the JARVIS button below."
                        color: dashboard.textMid
                        font.pixelSize: 12
                        wrapMode: Text.WordWrap
                        elide: Text.ElideRight
                        maximumLineCount: 6
                        lineHeight: 1.3
                    }

                    Item { Layout.fillHeight: true }

                    Label {
                        text: "SYSTEM"
                        color: dashboard.textLo
                        font.pixelSize: 10
                        font.letterSpacing: 2
                    }
                    Label {
                        text: vehicleData.connected
                              ? "Vehicle: LIVE"
                              : "Vehicle: NO DATA"
                        color: vehicleData.connected
                               ? dashboard.success : dashboard.accentWarm
                        font.pixelSize: 11
                    }
                    Label {
                        text: "Setup: " + (setupManager.setupComplete
                                           ? "OK" : "PENDING")
                        color: dashboard.textMid
                        font.pixelSize: 11
                    }
                }
            }
        }

        // ═══ BOTTOM NAV ═══════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 58
            radius: 14
            color: dashboard.bgPanel
            border.color: dashboard.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Repeater {
                    model: [
                        { label: "DASHBOARD", icon: "⌂", page: "" },
                        { label: "VEHICLE",   icon: "⚙", page: "Vehicle.qml" },
                        { label: "NAV",       icon: "◈", page: "Navigation.qml" },
                        { label: "MUSIC",     icon: "♪", page: "Music.qml" },
                        { label: "PHONE",     icon: "☎", page: "Phone.qml" },
                        { label: "JARVIS",    icon: "✦", page: "Jarvis.qml" },
                        { label: "SETTINGS",  icon: "⚙", page: "Settings.qml" }
                    ]

                    delegate: Rectangle {
                        id: navBtn
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 10
                        color: navArea.pressed
                               ? Qt.rgba(0, 0.85, 1, 0.25)
                               : Qt.rgba(1, 1, 1, 0.02)
                        border.color: navArea.pressed
                                      ? dashboard.accent : "transparent"
                        border.width: 1

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Label {
                                text: modelData.icon
                                color: navArea.pressed
                                       ? dashboard.accent : dashboard.textMid
                                font.pixelSize: 14
                            }
                            Label {
                                text: modelData.label
                                color: navArea.pressed
                                       ? dashboard.textHi : dashboard.textMid
                                font.pixelSize: 10
                                font.letterSpacing: 1
                                font.bold: navArea.pressed
                            }
                        }

                        MouseArea {
                            id: navArea
                            anchors.fill: parent
                            onClicked: {
                                if (modelData.page === "") return
                                StackView.view.push(
                                    Qt.resolvedUrl(modelData.page))
                            }
                        }
                    }
                }
            }
        }
    }

    // ─── Clock timer ───────────────────────────────────────────
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
    }

    // ═══════════════════════════════════════════════════════════
    // COMPONENTS
    // ═══════════════════════════════════════════════════════════

    // ─── Speed Gauge ───────────────────────────────────────────
    component SpeedGauge: Canvas {
        id: gaugeRoot

        property real currentSpeed: 0
        property real maxSpeed: 240
        property real progress: Math.min(currentSpeed / maxSpeed, 1)

        antialiasing: true

        Behavior on progress {
            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
        }

        onProgressChanged: requestPaint()
        onCurrentSpeedChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var cx = width / 2
            var cy = height / 2
            var r  = Math.min(width, height) / 2 - 24

            var startAngle = Math.PI * 0.75
            var endAngle   = Math.PI * 2.25
            var span       = endAngle - startAngle

            // Track
            ctx.beginPath()
            ctx.arc(cx, cy, r, startAngle, endAngle)
            ctx.lineWidth = 10
            ctx.lineCap = "round"
            ctx.strokeStyle = "#1a2433"
            ctx.stroke()

            // Progress arc
            if (progress > 0.001) {
                ctx.beginPath()
                ctx.arc(cx, cy, r, startAngle, startAngle + span * progress)
                ctx.lineWidth = 10
                ctx.lineCap = "round"
                ctx.strokeStyle = "#00d9ff"
                ctx.shadowColor = "#00d9ff"
                ctx.shadowBlur = 18
                ctx.stroke()
                ctx.shadowBlur = 0
            }

            // Ticks
            for (var i = 0; i <= 12; i++) {
                var a  = startAngle + span * (i / 12)
                var r1 = r - 18
                var r2 = (i % 3 === 0) ? r - 30 : r - 24
                ctx.beginPath()
                ctx.moveTo(cx + Math.cos(a) * r1, cy + Math.sin(a) * r1)
                ctx.lineTo(cx + Math.cos(a) * r2, cy + Math.sin(a) * r2)
                ctx.lineWidth   = (i % 3 === 0) ? 2 : 1
                ctx.strokeStyle = (i % 3 === 0) ? "#8b97a8" : "#3d4855"
                ctx.stroke()
            }

            // Center dot
            ctx.beginPath()
            ctx.arc(cx, cy, 2, 0, Math.PI * 2)
            ctx.fillStyle = "#00d9ff"
            ctx.fill()
        }
    }

    // ─── Status Chip ───────────────────────────────────────────
    component StatusChip: Rectangle {
        id: chip
        property string label: ""
        property bool active: false

        width: chipRow.width + 20
        height: 26
        radius: 13
        color: active ? Qt.rgba(0, 0.85, 1, 0.10) : Qt.rgba(1, 1, 1, 0.03)
        border.color: active ? "#0088aa" : "#1a2433"
        border.width: 1

        RowLayout {
            id: chipRow
            anchors.centerIn: parent
            spacing: 6

            Rectangle {
                width: 7; height: 7; radius: 4
                color: chip.active ? "#00d9ff" : "#4a5666"
            }
            Label {
                text: chip.label
                color: chip.active ? "#00d9ff" : "#8b97a8"
                font.pixelSize: 10
                font.letterSpacing: 1
                font.bold: true
            }
        }
    }

    // ─── Info Card ─────────────────────────────────────────────
    component InfoCard: Rectangle {
        id: card
        property string title: ""
        property string value: "--"
        property string unit: ""
        property color  accentColor: "#00d9ff"
        property real   progress: 0

        radius: 14
        color: dashboard.bgCard
        border.color: dashboard.stroke
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 6

            Label {
                text: card.title
                color: dashboard.textMid
                font.pixelSize: 10
                font.letterSpacing: 2
                font.bold: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                Label {
                    text: card.value
                    color: dashboard.textHi
                    font.pixelSize: 34
                    font.bold: true
                    font.letterSpacing: -1
                }
                Label {
                    text: card.unit
                    color: dashboard.textMid
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 6
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                height: 4
                radius: 2
                color: dashboard.stroke

                Rectangle {
                    width: parent.width * Math.min(Math.max(card.progress, 0), 1)
                    height: parent.height
                    radius: 2
                    color: card.accentColor

                    Behavior on width {
                        NumberAnimation {
                            duration: 300
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
