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
                    text: "🔍"
                    color: root.techBlue
                    font.pixelSize: 20
                }

                Text {
                    text: "CAN DECODER"
                    color: root.textHi
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 4
                }

                Item { Layout.fillWidth: true }

                // Protocol selector
                RowLayout {
                    spacing: 8

                    Text {
                        text: "PROTOCOL"
                        color: root.textMid
                        font.pixelSize: 9
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    ComboBox {
                        id: protocolBox
                        Layout.preferredWidth: 220
                        Layout.preferredHeight: 32
                        model: [
                            "AUTO / UNKNOWN",
                            "PEUGEOT / PSA — NOT MAPPED",
                            "RAW ONLY"
                        ]
                        font.pixelSize: 10
                        onCurrentTextChanged: {
                            canDecoder.setProtocol(currentText)
                        }
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

        // ─── STATUS BAR ────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: 12
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Rectangle {
                    width: 8
                    height: 8
                    radius: 4
                    color: root.techBlue

                    SequentialAnimation on opacity {
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
                    text: "STATUS"
                    color: root.textMid
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 2
                }

                Text {
                    text: canDecoder.status
                    color: root.textHi
                    font.pixelSize: 11
                    font.bold: true
                }

                Rectangle {
                    width: 1
                    height: 20
                    color: root.stroke
                }

                Text {
                    text: "PROTOCOL"
                    color: root.textMid
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 2
                }

                Text {
                    text: canDecoder.protocol
                    color: root.gold
                    font.pixelSize: 11
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "READ ONLY"
                    color: root.success
                    font.pixelSize: 9
                    font.bold: true
                    font.letterSpacing: 2
                }
            }
        }

        // ─── MAIN CONTENT ──────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            // Info pattern grid
            Canvas {
                anchors.fill: parent
                opacity: 0.15

                onPaint: {
                    var ctx = getContext("2d")
                    ctx.strokeStyle = "#0f2030"
                    ctx.lineWidth = 1

                    for (var x = 0; x < width; x += 60) {
                        ctx.beginPath()
                        ctx.moveTo(x, 0)
                        ctx.lineTo(x, height)
                        ctx.stroke()
                    }
                    for (var y = 0; y < height; y += 60) {
                        ctx.beginPath()
                        ctx.moveTo(0, y)
                        ctx.lineTo(width, y)
                        ctx.stroke()
                    }
                }
            }

            // Center content
            ColumnLayout {
                anchors.centerIn: parent
                spacing: 20

                // Icon circle
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    width: 100
                    height: 100
                    radius: 50
                    color: Qt.rgba(0, 0.83, 1, 0.08)
                    border.color: root.techBlue
                    border.width: 2

                    Text {
                        anchors.centerIn: parent
                        text: "🔍"
                        font.pixelSize: 42
                    }

                    // Pulse ring
                    Rectangle {
                        anchors.fill: parent
                        radius: 50
                        color: "transparent"
                        border.color: root.techBlue
                        border.width: 1
                        opacity: 0

                        SequentialAnimation on opacity {
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 0.5
                                duration: 1500
                            }
                            NumberAnimation {
                                to: 0.0
                                duration: 1500
                            }
                        }

                        SequentialAnimation on scale {
                            loops: Animation.Infinite
                            NumberAnimation {
                                to: 1.3
                                duration: 1500
                            }
                            NumberAnimation {
                                to: 1.0
                                duration: 1500
                            }
                        }
                    }
                }

                // Title
                Text {
                    text: "No Guessed Signal IDs"
                    color: root.textHi
                    font.pixelSize: 28
                    font.bold: true
                    font.letterSpacing: 1
                    Layout.alignment: Qt.AlignHCenter
                }

                // Subtitle
                Text {
                    text: "Capture real frames first, then map Speed / RPM / Coolant / Fuel / Voltage."
                    color: root.textMid
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: 600
                    wrapMode: Text.WordWrap
                }

                // Warning badge
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 12
                    width: warnText.width + 40
                    height: 40
                    radius: 20
                    color: Qt.rgba(1, 0.72, 0.30, 0.1)
                    border.color: root.gold
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "⚠"
                            color: root.gold
                            font.pixelSize: 16
                        }

                        Text {
                            id: warnText
                            text: "NEVER AUTO-WRITES TO CAN / MCU"
                            color: root.gold
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 2
                        }
                    }
                }

                // Info cards row
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 20
                    spacing: 12

                    InfoChip {
                        icon: "📡"
                        title: "RAW FRAMES"
                        desc: "Capture first"
                    }

                    InfoChip {
                        icon: "🔬"
                        title: "ANALYZE"
                        desc: "Identify signals"
                    }

                    InfoChip {
                        icon: "🗺"
                        title: "MAP"
                        desc: "After verification"
                    }
                }

                // Back to capture button
                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 16
                    width: 260
                    height: 44
                    radius: 12
                    color: captureBtnArea.containsMouse
                           ? Qt.rgba(0, 0.83, 1, 0.2)
                           : Qt.rgba(0, 0.83, 1, 0.1)
                    border.color: root.techBlue
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "📡"
                            font.pixelSize: 16
                        }

                        Text {
                            text: "GO TO RAW CAPTURE"
                            color: root.techBlue
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 2
                        }
                    }

                    MouseArea {
                        id: captureBtnArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            StackView.view.pop()
                            StackView.view.push(
                                Qt.resolvedUrl("CanCapture.qml"))
                        }
                    }
                }
            }
        }

        // ─── BOTTOM INFO ───────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 44
            radius: 12
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 12

                Text {
                    text: "ℹ"
                    color: root.techBlue
                    font.pixelSize: 14
                }

                Text {
                    Layout.fillWidth: true
                    text: "Safety first: This decoder will never guess IDs. Use the raw capture tool to collect real frames, then add verified mappings."
                    color: root.textMid
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }

                Text {
                    text: "NO GUESSING"
                    color: root.success
                    font.pixelSize: 8
                    font.bold: true
                    font.letterSpacing: 2
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════
    // COMPONENTS
    // ═══════════════════════════════════════════════════════════

    component InfoChip: Rectangle {
        property string icon: ""
        property string title: ""
        property string desc: ""

        width: 150
        height: 100
        radius: 12
        color: Qt.rgba(1, 1, 1, 0.02)
        border.color: root.stroke
        border.width: 1

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 6

            Text {
                text: parent.parent.icon
                font.pixelSize: 24
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: parent.parent.title
                color: root.textHi
                font.pixelSize: 10
                font.bold: true
                font.letterSpacing: 1
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: parent.parent.desc
                color: root.textMid
                font.pixelSize: 9
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }
}
