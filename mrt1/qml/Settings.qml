import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item {
 anchors.fill: parent
 Rectangle{anchors.fill:parent;color:"#080b10"}
 ColumnLayout{
  anchors.fill:parent;anchors.margins:24;spacing:12
  Label{text:"MRT1 SETTINGS";color:"white";font.pixelSize:28;font.bold:true}
  Button{text:"JARVIS / OPENAI";onClicked:pages.push(Qt.resolvedUrl("JarvisSettings.qml"))}
  Button{text:"AUTO MATCH MONITOR";onClicked:pages.push(Qt.resolvedUrl("AutoMatch.qml"))}
  Button{text:"DIAGNOSTICS";onClicked:pages.push(Qt.resolvedUrl("Diagnostics.qml"))}
  Button{text:"BACK";onClicked:pages.pop()}
 }
}
