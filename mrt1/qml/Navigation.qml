import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    // ─── Theme (BMW Luxury) ────────────────────────────────────
    readonly property color bgDeep:  "#030405"
    readonly property color bgPanel: "#0a0a0c"
    readonly property color gold:    "#ffb84d"
    readonly property color textHi:  "#f5f5f5"
    readonly property color textMid: "#808080"
    readonly property color textLo:  "#404040"
    readonly property color stroke:  "#1a1a1f"
    readonly property color success: "#4cd7a0"
    readonly property color techBlue: "#00d4ff"

    Rectangle {
        anchors.fill: parent
        color: root.bgDeep
    }

    // ═══ MAIN LAYOUT ═══════════════════════════════════════════
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ─── TOP BAR ───────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 14
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 14

                Text {
                    text: "◈"
                    color: root.techBlue
                    font.pixelSize: 22
                }

                Text {
                    text: "NAVIGATION"
                    color: root.textHi
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 4
                }

                Item { Layout.fillWidth: true }

                // GPS status
                RowLayout {
                    spacing: 6

                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: gpsSpeed.available
                               ? root.success
                               : "#404040"

                        SequentialAnimation on opacity {
                            running: gpsSpeed.available
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0.4
                                duration: 900
                            }
                            NumberAnimation {
                                to: 1.0
                                duration: 900
                            }
                        }
                    }

                    Text {
                        text: gpsSpeed.available
                              ? "GPS ACTIVE"
                              : "GPS WAITING"
                        color: gpsSpeed.available
                               ? root.success
                               : root.gold
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 2
                    }
                }

                Rectangle {
                    width: 1
                    height: 24
                    color: root.stroke
                }

                // Back button
                Rectangle {
                    width: 80
                    height: 34
                    radius: 8
                    color: backArea.containsMouse
                           ? Qt.rgba(1, 1, 1, 0.08)
                           : Qt.rgba(1, 1, 1, 0.03)
                    border.color: root.stroke
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "BACK"
                        color: root.textHi
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    MouseArea {
                        id: backArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: StackView.view.pop()
                    }
                }
            }
        }

        // ─── MAIN MAP AREA ─────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1
            clip: true

            // Fake map background
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: "#050a12"
                    }
                    GradientStop {
                        position: 1.0
                        color: "#020406"
                    }
                }
            }

            // Map grid
            Canvas {
                anchors.fill: parent
                opacity: 0.4

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.strokeStyle = "#0f2030"
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

            // Route line
            Canvas {
                anchors.fill: parent
                antialiasing: true

                onPaint: {
                    var ctx = getContext("2d")

                    // Route
                    ctx.beginPath()
                    ctx.moveTo(width * 0.15, height * 0.85)
                    ctx.quadraticCurveTo(
                        width * 0.35, height * 0.6,
                        width * 0.5, height * 0.5
                    )
                    ctx.quadraticCurveTo(
                        width * 0.7, height * 0.4,
                        width * 0.85, height * 0.2
                    )
                    ctx.lineWidth = 6
                    ctx.lineCap = "round"
                    ctx.strokeStyle = root.techBlue
                    ctx.shadowColor = root.techBlue
                    ctx.shadowBlur = 20
                    ctx.stroke()
                    ctx.shadowBlur = 0

                    // Current position dot
                    ctx.beginPath()
                    ctx.arc(width * 0.5, height * 0.5, 8, 0, Math.PI * 2)
                    ctx.fillStyle = root.gold
                    ctx.shadowColor = root.gold
                    ctx.shadowBlur = 25
                    ctx.fill()
                    ctx.shadowBlur = 0

                    // Destination dot
                    ctx.beginPath()
                    ctx.arc(width * 0.85, height * 0.2, 6, 0, Math.PI * 2)
                    ctx.fillStyle = "#ff4040"
                    ctx.shadowColor = "#ff4040"
                    ctx.shadowBlur = 20
                    ctx.fill()
                    ctx.shadowBlur = 0
                }
            }

            // Center info panel
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "◈"
                    color: root.techBlue
                    font.pixelSize: 44
                    Layout.alignment: Qt.AlignHCenter
                    opacity: 0.6
                }

                Text {
                    text: "OFFLINE-FIRST NAVIGATION"
                    color: root.textHi
                    font.pixelSize: 22
                    font.bold: true
                    font.letterSpacing: 2
                    Layout.alignment: Qt.AlignHCenter
                }

                Text {
                    text: "Navigation engine is modular and can be attached\nwithout changing the cockpit core."
                    color: root.textMid
                    font.pixelSize: 12
                    horizontalAlignment: Text.AlignHCenter
                    lineHeight: 1.5
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 8
                    width: gpsStatusText.width + 40
                    height: 36
                    radius: 18
                    color: gpsSpeed.available
                           ? Qt.rgba(0.3, 0.84, 0.62, 0.15)
                           : Qt.rgba(1, 0.72, 0.30, 0.15)
                    border.color: gpsSpeed.available
                                  ? root.success
                                  : root.gold
                    border.width: 1

                    Text {
                        id: gpsStatusText
                        anchors.centerIn: parent
                        text: gpsSpeed.available
                              ? "GPS: AVAILABLE"
                              : "GPS: WAITING"
                        color: gpsSpeed.available
                               ? root.success
                               : root.gold
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 2
                    }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 4
                    width: 200
                    height: 40
                    radius: 10
                    color: backBtnArea.containsMouse
                           ? Qt.rgba(0, 0.83, 1, 0.2)
                           : Qt.rgba(0, 0.83, 1, 0.1)
                    border.color: root.techBlue
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "BACK TO COCKPIT"
                        color: root.techBlue
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    MouseArea {
                        id: backBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: StackView.view.pop()
                    }
                }
            }

            // Top-left: Speed panel
            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 20
                width: 200
                height: 100
                radius: 14
                color: Qt.rgba(10, 10, 12, 0.85)
                border.color: root.stroke
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "SPEED"
                        color: root.textMid
                        font.pixelSize: 9
                        font.letterSpacing: 3
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4

                        Text {
                            text: speedRouter.displaySpeedKmh >= 0
                                  ? Math.round(speedRouter.displaySpeedKmh)
                                  : "--"
                            color: root.textHi
                            font.pixelSize: 44
                            font.weight: Font.Light
                            Layout.alignment: Qt.AlignBottom
                        }

                        Text {
                            text: "km/h"
                            color: root.gold
                            font.pixelSize: 10
                            font.bold: true
                            Layout.alignment: Qt.AlignBottom
                            Layout.bottomMargin: 10
                        }
                    }

                    Text {
                        text: "SOURCE: " + speedRouter.source
                        color: root.techBlue
                        font.pixelSize: 8
                        letterSpacing: 1
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Top-right: ETA panel
            Rectangle {
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 20
                width: 180
                height: 100
                radius: 14
                color: Qt.rgba(10, 10, 12, 0.85)
                border.color: root.stroke
                border.width: 1

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "DESTINATION"
                        color: root.textMid
                        font.pixelSize: 9
                        letterSpacing: 2
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "—"
                        color: root.textHi
                        font.pixelSize: 28
                        font.weight: Font.Light
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "NOT SET"
                        color: root.textLo
                        font.pixelSize: 8
                        letterSpacing: 2
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            // Bottom info strip
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: 20
                height: 44
                radius: 12
                color: Qt.rgba(10, 10, 12, 0.85)
                border.color: root.stroke
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12

                    Text {
                        text: "🛰"
                        color: root.techBlue
                        font.pixelSize: 16
                    }

                    Text {
                        text: "Waiting for GPS lock..."
                        color: root.textMid
                        font.pixelSize: 10
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "MRT1 NAVIGATION · OFFLINE FIRST"
                        color: root.textLo
                        font.pixelSize: 9
                        font.letterSpacing: 2
                    }
                }
            }
        }
    }
}
