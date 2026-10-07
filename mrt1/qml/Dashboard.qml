import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: "#05070a"
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 18

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Label {
                text: "MRT1"
                color: "white"
                font.pixelSize: 28
                font.bold: true
            }

            Label {
                text: Qt.formatTime(new Date(), "HH:mm")
                color: "white"
                font.pixelSize: 54
                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: parent.text = Qt.formatTime(new Date(), "HH:mm")
                }
            }

            Label {
                text: Qt.formatDate(new Date(), "yyyy/MM/dd")
                color: "#aab4c0"
                font.pixelSize: 20
            }

            Item { Layout.fillHeight: true }

            Label {
                text: vehicleData.connected ? "CAN / OBD CONNECTED" : "CAN / OBD OFFLINE"
                color: vehicleData.connected ? "#7CFF9B" : "#ffb86b"
                font.pixelSize: 18
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 420
            Layout.fillHeight: true
            spacing: 14

            Label {
                text: Math.round(vehicleData.speed) + " km/h"
                color: "white"
                font.pixelSize: 58
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Label {
                text: Math.round(vehicleData.rpm) + " RPM"
                color: "#c7d0da"
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Button { text: "VEHICLE" }
            Button { text: "NAVIGATION" }
            Button { text: "MUSIC" }
            Button { text: "PHONE" }
            Button { text: "JARVIS" }
            Button { text: "SETTINGS" }
        }
    }
}
