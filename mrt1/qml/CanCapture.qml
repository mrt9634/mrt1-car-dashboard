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
    readonly property color danger:  "#ff4040"

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
                    text: "📡"
                    color: root.gold
                    font.pixelSize: 20
                }

                Text {
                    text: "CAN / MCU RAW CAPTURE"
                    color: root.textHi
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 4
                }

                Item { Layout.fillWidth: true }

                // Read-only badge
                Rectangle {
                    width: 130
                    height: 26
                    radius: 13
                    color: Qt.rgba(0.3, 0.84, 0.62, 0.12)
                    border.color: root.success
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "READ ONLY · NO TX"
                        color: root.success
                        font.pixelSize: 8
                        font.bold: true
                        font.letterSpacing: 1
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

        // ─── CONTROL BAR ───────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            radius: 14
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 14

                // Status
                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "STATUS"
                        color: root.textMid
                        font.pixelSize: 8
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Text {
                        text: canFrameMonitor.status
                        color: canFrameMonitor.capturing
                               ? root.success
                               : root.gold
                        font.pixelSize: 11
                        font.bold: true
                    }
                }

                Rectangle {
                    width: 1
                    height: 40
                    color: root.stroke
                }

                // Frame count
                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "FRAMES"
                        color: root.textMid
                        font.pixelSize: 8
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    Text {
                        text: canFrameMonitor.frameCount
                        color: root.textHi
                        font.pixelSize: 20
                        font.bold: true
                        font.family: "monospace"
                    }
                }

                Rectangle {
                    width: 1
                    height: 40
                    color: root.stroke
                }

                // Baud selector
                ColumnLayout {
                    spacing: 2

                    Text {
                        text: "BAUD RATE"
                        color: root.textMid
                        font.pixelSize: 8
                        font.bold: true
                        font.letterSpacing: 2
                    }

                    ComboBox {
                        id: baudBox
                        Layout.preferredWidth: 130
                        Layout.preferredHeight: 32
                        model: [
                            "9600", "19200", "38400", "57600",
                            "115200", "125000", "250000", "500000"
                        ]
                        currentIndex: 4
                        font.pixelSize: 11

                        onCurrentTextChanged: {
                            canFrameMonitor.setSelection(
                                0, Number(currentText))
                        }
                    }
                }

                Item { Layout.fillWidth: true }

                // Buttons
                RowLayout {
                    spacing: 8

                    // START
                    Rectangle {
                        width: 100
                        height: 40
                        radius: 10
                        color: canFrameMonitor.capturing
                               ? Qt.rgba(0.3, 0.84, 0.62, 0.2)
                               : (startArea.containsMouse
                                  ? Qt.rgba(0.3, 0.84, 0.62, 0.25)
                                  : Qt.rgba(0.3, 0.84, 0.62, 0.1))
                        border.color: root.success
                        border.width: 1
                        opacity: canFrameMonitor.capturing ? 0.5 : 1

                        Text {
                            anchors.centerIn: parent
                            text: "▶ START"
                            color: root.success
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        MouseArea {
                            id: startArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: !canFrameMonitor.capturing
                            onClicked: canFrameMonitor.start()
                        }
                    }

                    // STOP
                    Rectangle {
                        width: 100
                        height: 40
                        radius: 10
                        color: !canFrameMonitor.capturing
                               ? Qt.rgba(1, 0.25, 0.25, 0.1)
                               : (stopArea.containsMouse
                                  ? Qt.rgba(1, 0.25, 0.25, 0.25)
                                  : Qt.rgba(1, 0.25, 0.25, 0.15))
                        border.color: root.danger
                        border.width: 1
                        opacity: !canFrameMonitor.capturing ? 0.5 : 1

                        Text {
                            anchors.centerIn: parent
                            text: "■ STOP"
                            color: root.danger
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        MouseArea {
                            id: stopArea
                            anchors.fill: parent
                            hoverEnabled: true
                            enabled: canFrameMonitor.capturing
                            onClicked: canFrameMonitor.stop()
                        }
                    }

                    // CLEAR
                    Rectangle {
                        width: 100
                        height: 40
                        radius: 10
                        color: clearArea.containsMouse
                               ? Qt.rgba(1, 0.72, 0.30, 0.2)
                               : Qt.rgba(1, 0.72, 0.30, 0.1)
                        border.color: root.gold
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "🗑 CLEAR"
                            color: root.gold
                            font.pixelSize: 11
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: canFrameMonitor.clear()
                        }
                    }
                }
            }
        }

        // ─── FRAMES LIST ───────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                // Header
                RowLayout {
                    Layout.fillWidth: true
                    Layout.leftMargin: 6
                    Layout.rightMargin: 6

                    Text {
                        text: "RAW FRAMES"
                        color: root.gold
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 3
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: "BUFFER · 100 MAX"
                        color: root.textLo
                        font.pixelSize: 9
                        font.letterSpacing: 2
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: root.stroke
                }

                // List
                ListView {
                    id: frameList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 6
                    model: canFrameMonitor.frames

                    delegate: Rectangle {
                        width: frameList.width
                        height: 54
                        radius: 8
                        color: Qt.rgba(1, 1, 1, 0.02)
                        border.color: root.stroke
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 12

                            // Time/Port/Baud column
                            ColumnLayout {
                                Layout.preferredWidth: 200
                                spacing: 2

                                Text {
                                    text: modelData.time
                                    color: root.gold
                                    font.pixelSize: 9
                                    font.family: "monospace"
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: modelData.port + " · "
                                          + modelData.baud
                                    color: root.textMid
                                    font.pixelSize: 8
                                    font.family: "monospace"
                                }
                            }

                            Rectangle {
                                width: 1
                                height: 30
                                color: root.stroke
                            }

                            // HEX data
                            Text {
                                Layout.fillWidth: true
                                text: modelData.hex
                                color: root.textHi
                                font.pixelSize: 12
                                font.family: "monospace"
                                font.letterSpacing: 1
                                elide: Text.ElideRight
                                wrapMode: Text.NoWrap
                            }
                        }
                    }

                    // Empty state
                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: canFrameMonitor.frameCount === 0
                        spacing: 8

                        Text {
                            text: "📭"
                            font.pixelSize: 48
                            Layout.alignment: Qt.AlignHCenter
                            opacity: 0.3
                        }

                        Text {
                            text: "NO FRAMES CAPTURED"
                            color: root.textMid
                            font.pixelSize: 14
                            font.bold: true
                            font.letterSpacing: 3
                            Layout.alignment: Qt.AlignHCenter
                        }

                        Text {
                            text: "Press START to begin capture"
                            color: root.textLo
                            font.pixelSize: 11
                            Layout.alignment: Qt.AlignHCenter
                        }
                    }
                }
            }
        }

        // ─── INFO BAR ──────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            radius: 12
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                Text {
                    text: "ℹ"
                    color: root.gold
                    font.pixelSize: 14
                }

                Text {
                    Layout.fillWidth: true
                    text: "Decoder intentionally does not guess Peugeot/CAN IDs. Capture real frames first, then map signals."
                    color: root.textMid
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }

                Text {
                    text: "READ ONLY · NEVER WRITES"
                    color: root.success
                    font.pixelSize: 8
                    font.bold: true
                    font.letterSpacing: 2
                }
            }
        }
    }
}
