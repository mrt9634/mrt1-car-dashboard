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

    property real scaleFactor: Math.max(0.4, Math.min(3.0,
        Math.min(width, height) / 600.0))

    color: "#05070a"

    StackView {
        id: pages
        anchors.fill: parent
        initialItem: Dashboard {}
    }

    Component {
        id: dashboardPage
        Dashboard {}
    }
}
