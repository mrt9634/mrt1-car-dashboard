import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    Component.onCompleted: {
        if (setupManager.firstRun)
            setupManager.runInitialSetup()
    }

    Rectangle { anchors.fill: parent; color: "#05070a" }

    Timer {
        id: clockTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 64

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Label {
                    text: "MRT1"
                    color: "white"
                    font.pixelSize: 25
                    font.bold: true
                }
                Label {
                    text: "DIGITAL COCKPIT"
                    color: "#65717d"
                    font.pixelSize: 11
                }
            }

            ColumnLayout {
                spacing: 0
                Label {
                    id: clockText
                    text: Qt.formatTime(new Date(), "HH:mm")
                    color: "white"
                    font.pixelSize: 28
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    text: Qt.formatDate(new Date(), "yyyy/MM/dd")
                    color: "#7d8994"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignRight
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 18
            color: "#0b0f14"
            border.color: "#1c2731"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 22

                ColumnLayout {
                    Layout.preferredWidth: 280
                    Layout.fillHeight: true

                    Label {
                        text: "SPEED"
                        color: "#6e7b87"
                        font.pixelSize: 13
                    }

                    Label {
                        Layout.fillWidth: true
                        text: vehicleData.connected ? Math.round(vehicleData.speed) : "--"
                        color: "white"
                        font.pixelSize: 86
                        font.bold: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        text: "km/h"
                        color: "#8e9aa5"
                        font.pixelSize: 17
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item { Layout.fillHeight: true }

                    Label {
                        text: "RPM"
                        color: "#6e7b87"
                        font.pixelSize: 13
                    }
                    Label {
                        text: vehicleData.connected ? Math.round(vehicleData.rpm) : "--"
                        color: "#d8e0e7"
                        font.pixelSize: 30
                        font.bold: true
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        Label {
                            text: canProvider.connected ? "CAN ONLINE" : "CAN OFFLINE"
                            color: canProvider.connected ? "#73f5a0" : "#ffad66"
                            font.pixelSize: 14
                            font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: vehicleData.source
                            color: "#65717d"
                            font.pixelSize: 12
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 14
                        color: "#070a0e"

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 7
                            Label {
                                text: "VEHICLE DATA"
                                color: "#687681"
                                font.pixelSize: 12
                            }
                            Label {
                                text: vehicleData.connected ? "LIVE" : "NO DATA"
                                color: vehicleData.connected ? "#73f5a0" : "#ffad66"
                                font.pixelSize: 30
                                font.bold: true
                            }
                            Label {
                                text: "No simulated vehicle values"
                                color: "#596671"
                                font.pixelSize: 12
                            }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        Repeater {
                            model: ["VEHICLE","NAVIGATION","MUSIC","PHONE","JARVIS","SETTINGS"]
                            delegate: Button {
                                text: modelData
                                Layout.fillWidth: true
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 38
            Label {
                text: speechManager.status
                color: "#7d8994"
                font.pixelSize: 12
            }
            Item { Layout.fillWidth: true }
            Label {
                text: setupManager.status
                color: "#596671"
                font.pixelSize: 11
            }
        }
    }
}
