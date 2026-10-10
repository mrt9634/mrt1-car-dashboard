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
                    text: "✦"
                    color: root.gold
                    font.pixelSize: 22
                }

                Text {
                    text: "OPTIONAL MODULES"
                    color: root.textHi
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 4
                }

                Item { Layout.fillWidth: true }

                // Disabled by default badge
                Rectangle {
                    width: 180
                    height: 26
                    radius: 13
                    color: Qt.rgba(1, 0.72, 0.30, 0.1)
                    border.color: root.gold
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        text: "DISABLED BY DEFAULT"
                        color: root.gold
                        font.pixelSize: 8
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
            columns: 2
            columnSpacing: 12
            rowSpacing: 12

            // ═══ CARD 1: 3D VEHICLE VIEW ═══════════════════════
            ModuleCard {
                Layout.fillWidth: true
                Layout.fillHeight: true

                icon: "🚗"
                title: "3D VEHICLE VIEW"
                subtitle: "Quick3D · Optional"
                description: "Interactive 3D model of the vehicle with live telemetry. Requires OpenGL ES 3.0+ and 512MB free RAM."
                status: "AVAILABLE"
                statusColor: root.techBlue
                accentColor: root.techBlue

                features: [
                    "Real-time rotation",
                    "Live sensor overlay",
                    "Multiple camera angles",
                    "Requires 512MB free RAM"
                ]
            }

            // ═══ CARD 2: PHONE MIRRORING ═══════════════════════
            ModuleCard {
                Layout.fillWidth: true
                Layout.fillHeight: true

                icon: "📱"
                title: "PHONE MIRRORING"
                subtitle: "scrcpy / vendor bridge"
                description: "Mirror your phone's screen to the head unit via USB or Wi-Fi. Requires explicit Android integration."
                status: "EXPERIMENTAL"
                statusColor: root.gold
                accentColor: root.gold

                features: [
                    "USB or Wi-Fi connection",
                    "Touch passthrough",
                    "Requires phone app",
                    "Root may be required"
                ]
            }

            // ═══ CARD 3: QUICK3D VEHICLE ═══════════════════════
            ModuleCard {
                Layout.fillWidth: true
                Layout.fillHeight: true

                icon: "🎨"
                title: "QUICK3D VEHICLE"
                subtitle: "Test module"
                description: "High-fidelity 3D rendering of the dashboard vehicle. Never required by the core. Purely for showcase."
                status: "TEST MODULE"
                statusColor: "#b366ff"
                accentColor: "#b366ff"

                features: [
                    "High-quality PBR materials",
                    "Reflections + shadows",
                    "Custom paint colors",
                    "Showcase only"
                ]
            }

            // ═══ CARD 4: MRT1 CORE INFO ════════════════════════
            ModuleCard {
                Layout.fillWidth: true
                Layout.fillHeight: true

                icon: "🛡"
                title: "MRT1 CORE"
                subtitle: "Always active"
                description: "Native Android/QML cockpit. Offline-first. Read-only CAN/MCU. All optional modules never block startup."
                status: "ALWAYS ON"
                statusColor: root.success
                accentColor: root.success

                features: [
                    "Offline-first design",
                    "Read-only diagnostics",
                    "No simulated data",
                    "Vendor-safe by design"
                ]
            }
        }

        // ─── INFO BAR ──────────────────────────────────────────
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 48
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
                    color: root.gold
                    font.pixelSize: 14
                }

                Text {
                    Layout.fillWidth: true
                    text: "Core MRT1 remains native Android/QML and offline-first. Optional modules are isolated and never block startup."
                    color: root.textMid
                    font.pixelSize: 9
                    elide: Text.ElideRight
                }

                Text {
                    text: "● CORE ONLINE"
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

    component ModuleCard: Rectangle {
        id: card
        property string icon: ""
        property string title: ""
        property string subtitle: ""
        property string description: ""
        property string status: ""
        property color  statusColor: root.gold
        property color  accentColor: root.gold
        property var    features: []

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
                    color: card.accentColor
                }
                GradientStop {
                    position: 1.0
                    color: "transparent"
                }
            }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 10

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: card.icon
                    font.pixelSize: 28
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                        text: card.title
                        color: root.textHi
                        font.pixelSize: 15
                        font.bold: true
                        font.letterSpacing: 1
                    }

                    Text {
                        text: card.subtitle
                        color: root.textMid
                        font.pixelSize: 9
                        letterSpacing: 1
                    }
                }

                // Status pill
                Rectangle {
                    width: statusText.width + 20
                    height: 24
                    radius: 12
                    color: Qt.rgba(card.statusColor.r,
                                   card.statusColor.g,
                                   card.statusColor.b, 0.15)
                    border.color: card.statusColor
                    border.width: 1

                    Text {
                        id: statusText
                        anchors.centerIn: parent
                        text: card.status
                        color: card.statusColor
                        font.pixelSize: 8
                        font.bold: true
                        font.letterSpacing: 2
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: root.stroke
            }

            // Description
            Text {
                Layout.fillWidth: true
                text: card.description
                color: root.textMid
                font.pixelSize: 10
                wrapMode: Text.WordWrap
                lineHeight: 1.5
            }

            // Features list
            ColumnLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 4

                Repeater {
                    model: card.features

                    delegate: RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "✓"
                            color: card.accentColor
                            font.pixelSize: 11
                            font.bold: true
                        }

                        Text {
                            Layout.fillWidth: true
                            text: modelData
                            color: root.textMid
                            font.pixelSize: 9
                            elide: Text.ElideRight
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
