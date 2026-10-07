import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item { anchors.fill: parent
    Rectangle { anchors.fill: parent; color: "#05070a" }
    Timer { interval: 1000; running: true; repeat: true; onTriggered: phoneManager.refresh() }
    Component.onCompleted: phoneManager.refresh()

    ColumnLayout {
        anchors.fill: parent; anchors.margins: 22; spacing: 14
        RowLayout {
            Layout.fillWidth: true
            Label { text: "PHONE"; color: "white"; font.pixelSize: 26; font.bold: true }
            Item { Layout.fillWidth: true }
            Button { text: "BACK"; onClicked: StackView.view.pop() }
        }
        Rectangle {
            Layout.fillWidth: true; Layout.fillHeight: true; radius: 18
            color: "#0b0f14"; border.color: "#1c2731"
            ColumnLayout {
                anchors.centerIn: parent; spacing: 12
                Label { text: "PHONE / CALLS"; color: "white"; font.pixelSize: 24; font.bold: true }
                Label { text: phoneManager.status; color: "#7d8994"; wrapMode: Text.Wrap; Layout.maximumWidth: 600 }
                Label { text: phoneManager.stateText; color: phoneManager.inCall ? "#73f5a0" : "#aab4c0"; font.pixelSize: 22; font.bold: true }
                RowLayout {
                    Button { text: "CHECK"; onClicked: phoneManager.refresh() }
                    Button { text: "REQUEST PERMISSION"; visible: !phoneManager.permissionGranted; onClicked: phoneManager.requestPermission() }
                }
                Label { text: "Native Android telephony status • no CAN/MCU/factory writes"; color: "#65717d"; font.pixelSize: 11 }
            }
        }
    }
}