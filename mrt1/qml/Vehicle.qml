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

    // Ambient glow
    Rectangle {
        width: 500
        height: 500
        radius: 250
        anchors.right: parent.right
        anchors.rightMargin: -150
        anchors.verticalCenter: parent.verticalCenter
        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: Qt.rgba(1, 0.72, 0.30, 0.08)
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
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
                    text: "⚙"
                    color: root.gold
                    font.pixelSize: 20
                }

                Text {
                    text: "VEHICLE DATA"
                    color: root.textHi
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 4
                }

                Item { Layout.fillWidth: true }

                // Status
                RowLayout {
                    spacing: 6
                    Rectangle {
                        width: 6
                        height: 6
                        radius: 3
                        color: vehicleData.connected
                               ? root.success
                               : "#404040"
                    }
                    Text {
                        text: vehicleData.connected
                              ? "LIVE DATA"
                              : "NO DATA"
                        color: vehicleData.connected
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

        // ─── MAIN GRID ─────────────────────────────────────────
        GridLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            columns: 3
            columnSpacing: 12
            rowSpacing: 12

            // ═══ ROW 1 ═════════════════════════════════════════

            // SPEED
            VehicleCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "🏎"
                title: "SPEED"
                value: vehicleData.connected
                       ? Math.round(vehicleData.speed).toString()
                       : "—"
                unit: "km/h"
                accent: root.gold
                progress: vehicleData.connected
                          ? Math.min(vehicleData.speed / 260, 1)
                          : 0
            }

            // RPM
            VehicleCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "⚡"
                title: "RPM"
                value: vehicleData.connected
                       ? Math.round(vehicleData.rpm).toString()
                       : "—"
                unit: "rpm"
                accent: "#b366ff"
                progress: vehicleData.connected
                          ? Math.min(vehicleData.rpm / 8000, 1)
                          : 0
            }

            // COOLANT
            VehicleCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "🌡"
                title: "COOLANT"
                value: vehicleData.connected
                       ? Math.round(vehicleData.coolant).toString()
                       : "—"
                unit: "°C"
                accent: vehicleData.coolant > 105
                        ? root.danger
                        : root.success
                progress: vehicleData.connected
                          ? Math.min(vehicleData.coolant / 130, 1)
                          : 0
            }

            // ═══ ROW 2 ═════════════════════════════════════════

            // FUEL
            VehicleCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "⛽"
                title: "FUEL"
                value: vehicleData.connected
                       ? Math.round(vehicleData.fuel).toString()
                       : "—"
                unit: "%"
                accent: vehicleData.fuel < 15
                        ? root.danger
                        : root.gold
                progress: vehicleData.connected
                          ? vehicleData.fuel / 100
                          : 0
            }

            // BATTERY
            VehicleCard {
                Layout.fillWidth: true
                Layout.fillHeight: true
                icon: "🔋"
                title: "BATTERY"
                value: vehicleData.connected
                       ? vehicleData.batteryVoltage.toFixed(1)
                       : "—"
                unit: "V"
                accent: vehicleData.batteryVoltage > 0
                        && vehicleData.batteryVoltage < 11.5
                        ? root.danger
                        : root.success
                progress: vehicleData.connected
                          ? Math.min(Math.max(
                                (vehicleData.batteryVoltage - 10) / 5,
                                0), 1)
                          : 0
            }

            // SOURCE
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 16
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
                    color: "#00d4ff"
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "📡"
                        font.pixelSize: 32
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: "SOURCE"
                        color: root.textMid
                        font.pixelSize: 10
                        font.bold: true
                        font.letterSpacing: 3
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Text {
                        text: vehicleData.source
                        color: "#00d4ff"
                        font.pixelSize: 16
                        font.bold: true
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }

        // ─── INFO BAR ──────────────────────────────────────────
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
                    text: vehicleData.connected
                          ? "✓ LIVE VEHICLE DATA"
                          : "⚠ NO REAL VEHICLE DATA CONNECTED"
                    color: vehicleData.connected
                           ? root.success
                           : root.gold
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 2
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "MRT1 never displays simulated sensor values."
                    color: root.textLo
                    font.pixelSize: 9
                }
            }
        }
    }

    // ═══════════════════════════════════════════════════════════
    // COMPONENTS
    // ═══════════════════════════════════════════════════════════

    component VehicleCard: Rectangle {
        id: card
        property string icon: ""
        property string title: ""
        property string value: "—"
        property string unit: ""
        property color accent: root.gold
        property real progress: 0

        radius: 16
        color: root.bgPanel
        border.color: root.stroke
        border.width: 1

        // Top accent bar
        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 1
            height: 2
            radius: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop {
                    position: 0.0
                    color: "transparent"
                }
                GradientStop {
                    position: 0.5
                    color: card.accent
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 8

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    text: card.icon
                    font.pixelSize: 16
                }

                Text {
                    text: card.title
                    color: root.textMid
                    font.pixelSize: 10
                    font.bold: true
                    font.letterSpacing: 3
                }

                Item { Layout.fillWidth: true }
            }

            Item { Layout.fillHeight: true }

            // Value
            RowLayout {
                Layout.fillWidth: true
                spacing: 4
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: card.value
                    color: root.textHi
                    font.pixelSize: 48
                    font.weight: Font.Light
                    font.letterSpacing: -2
                    Layout.alignment: Qt.AlignBottom
                }

                Text {
                    text: card.unit
                    color: card.accent
                    font.pixelSize: 12
                    font.bold: true
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 8
                }
            }

            Item { Layout.fillHeight: true }

            // Progress bar
            Rectangle {
                Layout.fillWidth: true
                height: 4
                radius: 2
                color: root.stroke

                Rectangle {
                    width: parent.width * Math.min(
                        Math.max(card.progress, 0), 1)
                    height: parent.height
                    radius: 2
                    color: card.accent

                    Behavior on width {
                        NumberAnimation {
                            duration: 400
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }
    }
}
