import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MRT1

ApplicationWindow {
    id: root
    visible: true
    visibility: Window.FullScreen
    width: 1024
    height: 600
    title: "MRT1"
    color: "#05070a"

    StackView {
        id: pages
        anchors.fill: parent
        initialItem: Dashboard {}
    }
}
