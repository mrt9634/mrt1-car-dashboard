import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent

    Rectangle { anchors.fill: parent; color: "#05070a" }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 22
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            Label {
                text: "DIAGNOSTICS"
                color: "white"
                font.pixelSize: 25
                font.bold: true
            }
            Item { Layout.fillWidth: true }
            Button { text: "BACK"; onClicked: StackView.view.pop() }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: "#0b0f14"
                border.color: "#1c2731"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    Label { text: "CAN INFORMATION"; color: "#73f5a0"; font.pixelSize: 18; font.bold: true }
                    Label { text: "Status: " + factoryDiagnostics.canStatus; color: "white" }
                    Label { text: "Interface: " + factoryDiagnostics.canInterface; color: "#aab4c0" }

                    Item { Layout.fillHeight: true }

                    Label {
                        text: "READ ONLY"
                        color: "#65717d"
                        font.pixelSize: 11
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 14
                color: "#0b0f14"
                border.color: "#1c2731"

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 18
                    spacing: 10

                    Label { text: "MCU INFORMATION"; color: "#73f5a0"; font.pixelSize: 18; font.bold: true }
                    Label { text: "Status: " + factoryDiagnostics.mcuStatus; color: "white" }
                    Label { text: "Version: " + factoryDiagnostics.mcuVersion; color: "#aab4c0" }
                    Label { text: "Model: " + factoryDiagnostics.mcuModel; color: "#aab4c0" }

                    Item { Layout.fillHeight: true }

                    Label {
                        text: "READ ONLY • NO FLASH / NO WRITE"
                        color: "#65717d"
                        font.pixelSize: 11
                    }
                }
            }
        }
    }
}
