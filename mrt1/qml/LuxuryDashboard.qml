import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    // ─── Theme ─────────────────────────────────────────────────
    readonly property color bgDeep:  "#030405"
    readonly property color bgPanel: "#0a0a0c"
    readonly property color gold:    "#ffb84d"
    readonly property color textHi:  "#f5f5f5"
    readonly property color textMid: "#808080"
    readonly property color textLo:  "#404040"
    readonly property color stroke:  "#1a1a1f"
    readonly property color success: "#4cd7a0"
    readonly property color danger:  "#ff4040"

    property string driveMode: "COMFORT"
    property real currentSpeed: 0
    property real currentRPM: 0

    Rectangle { anchors.fill: parent; color: root.bgDeep }

    // Ambient glows
    Rectangle {
        width: 600; height: 600; radius: 300
        anchors.left: parent.left
        anchors.leftMargin: -200
        anchors.verticalCenter: parent.verticalCenter
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 0.72, 0.30, 0.10) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    Rectangle {
        width: 500; height: 500; radius: 250
        anchors.right: parent.right
        anchors.rightMargin: -150
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -150
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0, 0.83, 1, 0.06) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }

    // ═══ CLOCK TIMER ═══════════════════════════════════════════
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            clockTime.text = Qt.formatTime(new Date(), "HH:mm")
        }
    }

    // ═══ MAIN LAYOUT ═══════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 10

        // ─── TOP BAR ───────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 66
            radius: 16
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 18

                // Logo
                RowLayout {
                    spacing: 12
                    Rectangle {
                        width: 40; height: 40; radius: 20
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0.0; color: "#0066b1" }
                            GradientStop { position: 0.49; color: "#0066b1" }
                            GradientStop { position: 0.51; color: "#ffffff" }
                            GradientStop { position: 1.0; color: "#ffffff" }
                        }
                        border.color: "#3a3a3a"
                        border.width: 2
                        Text {
                            anchors.centerIn: parent
                            text: "M"
                            color: "white"
                            font.pixelSize: 18
                            font.bold: true
                        }
                    }
                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: "MRT1"
                            color: root.textHi
                            font.pixelSize: 16
                            font.bold: true
                            font.letterSpacing: 5
                        }
                        Text {
                            text: "ULTIMATE COCKPIT"
                            color: root.gold
                            font.pixelSize: 8
                            font.letterSpacing: 3
                            font.bold: true
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Drive mode
                RowLayout {
                    spacing: 3
                    Repeater {
                        model: ["COMFORT", "SPORT", "ECO PRO"]
                        delegate: Rectangle {
                            width: modeText.width + 20
                            height: 30
                            radius: 15
                            color: root.driveMode === modelData
                                   ? Qt.rgba(1, 0.72, 0.30, 0.2)
                                   : "transparent"
                            border.color: root.driveMode === modelData
                                          ? root.gold : root.stroke
                            border.width: 1

                            Text {
                                id: modeText
                                anchors.centerIn: parent
                                text: modelData
                                color: root.driveMode === modelData
                                       ? root.gold : root.textMid
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 1
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: root.driveMode = modelData
                            }
                        }
                    }
                }

                // Clock
                RowLayout {
                    spacing: 12
                    Text {
                        id: clockTime
                        text: Qt.formatTime(new Date(), "HH:mm")
                        color: root.textHi
                        font.pixelSize: 26
                        font.family: "monospace"
                        font.weight: Font.Light
                    }
                    Rectangle {
                        width: 1; height: 32
                        color: root.stroke
                    }
                    Text {
                        text: "🌤 22°"
                        color: root.textHi
                        font.pixelSize: 16
                    }
                }
            }
        }

        // ─── MAIN AREA ─────────────────────────────────────────
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // ═══ SPEED CLUSTER (LEFT) ═══════════════════════════
            Rectangle {
                Layout.preferredWidth: 380
                Layout.fillHeight: true
                radius: 18
                color: root.bgPanel
                border.color: root.stroke
                border.width: 1

                // Gauge canvas
                Canvas {
                    id: gauge
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -18
                    width: 300
                    height: 300
                    antialiasing: true

                    property real rpmRatio: Math.min(
                        vehicleData.connected
                        ? (vehicleData.rpm / 8000) : 0, 1)

                    Behavior on rpmRatio {
                        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                    }

                    onRpmRatioChanged: requestPaint()
                    Component.onCompleted: requestPaint()
                    onWidthChanged: requestPaint()
                    onHeightChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.reset()
                        var cx = width / 2
                        var cy = height / 2
                        var r = Math.min(width, height) / 2 - 22

                        var startA = Math.PI * 0.75
                        var endA = Math.PI * 2.25
                        var span = endA - startA

                        // Track
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, startA, endA)
                        ctx.lineWidth = 8
                        ctx.lineCap = "round"
                        ctx.strokeStyle = "#1a1a1f"
                        ctx.stroke()

                        // Progress
                        if (rpmRatio > 0.001) {
                            var grad = ctx.createLinearGradient(0, 0, width, height)
                            grad.addColorStop(0, "#ff6b00")
                            grad.addColorStop(0.5, "#ffb84d")
                            grad.addColorStop(1, "#ffffff")

                            ctx.beginPath()
                            ctx.arc(cx, cy, r, startA, startA + span * rpmRatio)
                            ctx.lineWidth = 8
                            ctx.lineCap = "round"
                            ctx.strokeStyle = grad
                            ctx.shadowColor = "#ffb84d"
                            ctx.shadowBlur = 22
                            ctx.stroke()
                            ctx.shadowBlur = 0
                        }

                        // Redline
                        ctx.beginPath()
                        ctx.arc(cx, cy, r, startA + span * 0.85, endA)
                        ctx.lineWidth = 8
                        ctx.lineCap = "round"
                        ctx.strokeStyle = "rgba(255,60,40,0.4)"
                        ctx.stroke()

                        // Ticks
                        for (var i = 0; i <= 32; i++) {
                            var a = startA + span * (i / 32)
                            var r1 = r - 18
                            var r2 = (i % 4 === 0) ? r - 32 : r - 24
                            ctx.beginPath()
                            ctx.moveTo(cx + Math.cos(a) * r1, cy + Math.sin(a) * r1)
                            ctx.lineTo(cx + Math.cos(a) * r2, cy + Math.sin(a) * r2)
                            ctx.lineWidth = (i % 4 === 0) ? 1.5 : 0.6
                            ctx.strokeStyle = (i % 4 === 0)
                                ? "rgba(255,180,60,0.6)"
                                : "rgba(255,255,255,0.12)"
                            ctx.stroke()
                        }
                    }
                }

                // Speed digits
                ColumnLayout {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: -18
                    spacing: 0

                    Text {
                        text: speedRouter.displaySpeedKmh >= 0
                              ? Math.round(speedRouter.displaySpeedKmh)
                              : "--"
                        color: root.textHi
                        font.pixelSize: 120
                        font.weight: Font.Light
                        font.letterSpacing: -6
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "KM / H"
                        color: root.gold
                        font.pixelSize: 12
                        font.letterSpacing: 8
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: -10
                    }
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        Layout.topMargin: 18
                        spacing: 6
                        Rectangle {
                            width: 5; height: 5; radius: 3
                            color: root.gold
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.3; duration: 700 }
                                NumberAnimation { to: 1.0; duration: 700 }
                            }
                        }
                        Text {
                            text: (vehicleData.connected
                                  ? Math.round(vehicleData.rpm) : 0)
                                  .toLocaleString(Qt.locale(), 'f', 0)
                                  .replace(/,/g, " ") + " RPM"
                            color: root.gold
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 3
                        }
                    }
                }

                // Gear badge
                Rectangle {
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.margins: 22
                    width: 56; height: 56
                    radius: 12
                    color: Qt.rgba(1, 0.72, 0.30, 0.15)
                    border.color: root.gold
                    border.width: 2
                    Text {
                        anchors.centerIn: parent
                        text: "D"
                        color: root.gold
                        font.pixelSize: 26
                        font.weight: Font.Light
                    }
                }

                // READY badge
                RowLayout {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 22
                    spacing: 8
                    Text {
                        text: "⚡"
                        color: root.success
                        font.pixelSize: 18
                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.4; duration: 1200 }
                            NumberAnimation { to: 1.0; duration: 1200 }
                        }
                    }
                    Text {
                        text: vehicleData.connected ? "READY" : "NO DATA"
                        color: vehicleData.connected ? root.success : root.gold
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 3
                    }
                }
            }

            // ═══ CENTER + RIGHT ════════════════════════════════
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                // ─── CAR STAGE ─────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: parent.height * 0.58
                    radius: 18
                    color: root.bgPanel
                    border.color: root.stroke
                    border.width: 1
                    clip: true

                    // Grid pattern
                    Canvas {
                        anchors.fill: parent
                        opacity: 0.25
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.strokeStyle = "#151520"
                            ctx.lineWidth = 1
                            for (var x = 0; x < width; x += 50) {
                                ctx.beginPath()
                                ctx.moveTo(x, 0)
                                ctx.lineTo(x, height)
                                ctx.stroke()
                            }
                            for (var y = 0; y < height; y += 50) {
                                ctx.beginPath()
                                ctx.moveTo(0, y)
                                ctx.lineTo(width, y)
                                ctx.stroke()
                            }
                        }
                    }

                    // Radial glow
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 30
                        width: 380; height: 80; radius: 40
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: Qt.rgba(1, 0.42, 0, 0.25) }
                            GradientStop { position: 1.0; color: "transparent" }
                        }
                    }

                    // Car shape
                    Item {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -10
                        width: 440; height: 220

                        // Shadow
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8
                            width: 360; height: 40; radius: 20
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(1, 0.72, 0.30, 0.15) }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }

                        // Body
                        Rectangle {
                            anchors.fill: parent
                            anchors.topMargin: 40
                            anchors.bottomMargin: 40
                            radius: 60
                            gradient: Gradient {
                                orientation: Gradient.Horizontal
                                GradientStop { position: 0.0; color: "#0a0a0a" }
                                GradientStop { position: 0.3; color: "#1a1a1a" }
                                GradientStop { position: 0.5; color: "#0a0a0a" }
                                GradientStop { position: 0.7; color: "#1a1a1a" }
                                GradientStop { position: 1.0; color: "#0a0a0a" }
                            }
                            border.color: Qt.rgba(1, 0.72, 0.30, 0.15)
                            border.width: 1
                        }

                        // Cabin
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: 20
                            anchors.top: parent.top
                            anchors.topMargin: 30
                            width: 180; height: 60
                            radius: 30
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#1a1a1a" }
                                GradientStop { position: 1.0; color: "#050505" }
                            }
                        }

                        // Windshield
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: 80
                            anchors.top: parent.top
                            anchors.topMargin: 45
                            width: 80; height: 40
                            radius: 20
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(0.4, 0.7, 0.9, 0.4) }
                                GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.15, 0.25, 0.7) }
                            }
                            border.color: Qt.rgba(0.4, 0.7, 0.9, 0.3)
                            border.width: 1
                        }

                        // Front accent
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: 200
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 45
                            width: 60; height: 3; radius: 2
                            color: root.gold
                            SequentialAnimation on opacity {
                                loops: Animation.Infinite
                                NumberAnimation { to: 0.6; duration: 800 }
                                NumberAnimation { to: 1.0; duration: 800 }
                            }
                        }

                        // Headlight L
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: 210
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: -22
                            width: 20; height: 20; radius: 10
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#ffffff" }
                                GradientStop { position: 0.4; color: root.gold }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }

                        // Headlight R
                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.horizontalCenterOffset: 210
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 22
                            width: 20; height: 20; radius: 10
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#ffffff" }
                                GradientStop { position: 0.4; color: root.gold }
                                GradientStop { position: 1.0; color: "transparent" }
                            }
                        }

                        // Wheels
                        Repeater {
                            model: [
                                { x: 130, y: 55 },
                                { x: 130, y: 165 },
                                { x: -130, y: 55 },
                                { x: -130, y: 165 }
                            ]
                            delegate: Rectangle {
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.horizontalCenterOffset: modelData.x
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.verticalCenterOffset: modelData.y
                                width: 44; height: 44; radius: 22
                                color: "#050505"
                                border.color: "#2a2a2a"
                                border.width: 2
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 14; height: 14; radius: 7
                                    color: "#3a3a3a"
                                }
                            }
                        }
                    }

                    // Model label
                    ColumnLayout {
                        anchors.left: parent.left
                        anchors.bottom: parent.bottom
                        anchors.margins: 20
                        spacing: 2
                        Text {
                            text: "MRT1 · VEHICLE"
                            color: root.textHi
                            font.pixelSize: 16
                            font.weight: Font.Light
                            font.letterSpacing: 4
                        }
                        Text {
                            text: "LIVE 3D · NO DATA"
                            color: root.gold
                            font.pixelSize: 8
                            font.letterSpacing: 3
                            font.bold: true
                        }
                    }

                    // Top hint
                    Text {
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 18
                        text: "LIVE VEHICLE"
                        color: root.gold
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 3
                    }
                }

                // ─── TELEMETRY CARDS ───────────────────────────
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 4
                    columnSpacing: 8
                    rowSpacing: 8

                    TelemetryCard {
                        title: "FUEL"
                        icon: "⛽"
                        value: vehicleData.connected
                               ? Math.round(vehicleData.fuel).toString() : "—"
                        unit: "%"
                        progress: vehicleData.connected
                                  ? vehicleData.fuel / 100 : 0
                        accent: root.gold
                    }
                    TelemetryCard {
                        title: "BATTERY"
                        icon: "🔋"
                        value: vehicleData.connected
                               ? vehicleData.batteryVoltage.toFixed(1) : "—"
                        unit: "V"
                        progress: vehicleData.connected
                                  ? Math.min(Math.max(
                                        (vehicleData.batteryVoltage - 10) / 5, 0), 1)
                                  : 0
                        accent: root.success
                    }
                    TelemetryCard {
                        title: "COOLANT"
                        icon: "🌡"
                        value: vehicleData.connected
                               ? Math.round(vehicleData.coolant).toString() : "—"
                        unit: "°C"
                        progress: vehicleData.connected
                                  ? Math.min(vehicleData.coolant / 130, 1) : 0
                        accent: vehicleData.coolant > 105
                                ? root.danger : "#ff6b00"
                    }
                    TelemetryCard {
                        title: "RPM"
                        icon: "⚡"
                        value: vehicleData.connected
                               ? Math.round(vehicleData.rpm).toString() : "—"
                        unit: ""
                        progress: vehicleData.connected
                                  ? Math.min(vehicleData.rpm / 8000, 1) : 0
                        accent: "#b366ff"
                    }
                }
            }
        }

        // ─── BOTTOM NAV ────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 72
            radius: 16
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Repeater {
                    model: [
                        { icon: "⌂", label: "HOME",     page: "" },
                        { icon: "◈", label: "NAV",      page: "Navigation.qml" },
                        { icon: "♪", label: "MUSIC",    page: "Music.qml" },
                        { icon: "☎", label: "PHONE",    page: "Phone.qml" },
                        { icon: "✦", label: "JARVIS",   page: "Jarvis.qml" },
                        { icon: "⚙", label: "SETTINGS", page: "Settings.qml" }
                    ]

                    delegate: Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 12
                        color: navArea.pressed
                               ? Qt.rgba(1, 0.72, 0.30, 0.25)
                               : (navArea.containsMouse
                                  ? Qt.rgba(1, 1, 1, 0.04)
                                  : "transparent")
                        border.color: navArea.containsMouse
                                      ? root.gold : "transparent"
                        border.width: 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 3
                            Text {
                                text: modelData.icon
                                color: navArea.containsMouse
                                       ? root.gold : root.textMid
                                font.pixelSize: 20
                                Layout.alignment: Qt.AlignHCenter
                            }
                            Text {
                                text: modelData.label
                                color: navArea.containsMouse
                                       ? root.gold : root.textMid
                                font.pixelSize: 9
                                font.bold: true
                                font.letterSpacing: 2
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        MouseArea {
                            id: navArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (modelData.page === "") return
                                StackView.view.push(Qt.resolvedUrl(modelData.page))
                            }
                        }
                    }
                }

                // Restart button
                Rectangle {
                    Layout.preferredWidth: 60
                    Layout.fillHeight: true
                    radius: 12
                    color: restartArea.pressed
                           ? Qt.rgba(1, 0.25, 0.25, 0.3)
                           : Qt.rgba(1, 0.25, 0.25, 0.08)
                    border.color: restartArea.containsMouse
                                  ? root.danger : "transparent"
                    border.width: 1

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 2
                        Text {
                            text: "⟳"
                            color: root.danger
                            font.pixelSize: 20
                            Layout.alignment: Qt.AlignHCenter
                        }
                        Text {
                            text: "REBOOT"
                            color: root.danger
                            font.pixelSize: 7
                            font.bold: true
                            font.letterSpacing: 1
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }

                    MouseArea {
                        id: restartArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: restartManager.restartApp()
                    }
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════
    // COMPONENTS
    // ═══════════════════════════════════════════════════════════

    component TelemetryCard: Rectangle {
        id: card
        property string title: ""
        property string icon: ""
        property string value: "—"
        property string unit: ""
        property real progress: 0
        property color accent: root.gold

        radius: 12
        color: root.bgPanel
        border.color: root.stroke
        border.width: 1

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 2
            radius: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop { position: 0.5; color: card.accent }
                GradientStop { position: 1.0; color: "transparent" }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 4

            RowLayout {
                spacing: 5
                Text {
                    text: card.icon
                    font.pixelSize: 12
                }
                Text {
                    text: card.title
                    color: root.textMid
                    font.pixelSize: 8
                    font.bold: true
                    font.letterSpacing: 2
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 3
                Text {
                    text: card.value
                    color: root.textHi
                    font.pixelSize: 22
                    font.weight: Font.Light
                }
                Text {
                    text: card.unit
                    color: card.accent
                    font.pixelSize: 10
                    font.bold: true
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 4
                }
            }

            Item { Layout.fillHeight: true }

            Rectangle {
                Layout.fillWidth: true
                height: 3
                radius: 2
                color: root.stroke
                Rectangle {
                    width: parent.width * Math.min(Math.max(card.progress, 0), 1)
                    height: parent.height
                    radius: 2
                    color: card.accent
                    Behavior on width {
                        NumberAnimation { duration: 350; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}
