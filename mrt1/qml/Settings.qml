import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item {
 anchors.fill: parent
 Rectangle{anchors.fill:parent;color:"#080b10"}
 ColumnLayout{
  anchors.fill:parent;anchors.margins:24;spacing:12
  Label{text:"MRT1 SETTINGS";color:"white";font.pixelSize:28;font.bold:true}
  Button{text:"JARVIS / OPENAI";onClicked:StackView.view.push(Qt.resolvedUrl("JarvisSettings.qml"))}
  Button{text:"AUTO MATCH MONITOR";onClicked:StackView.view.push(Qt.resolvedUrl("AutoMatch.qml"))}
  Button{text:"DIAGNOSTICS";onClicked:StackView.view.push(Qt.resolvedUrl("Diagnostics.qml"))}
  Button{text:"CAN / MCU RAW CAPTURE";onClicked:StackView.view.push(Qt.resolvedUrl("CanCapture.qml"))}
  Button{text:"CAN DECODER";onClicked:StackView.view.push(Qt.resolvedUrl("CanDecoder.qml"))}
  Button{text:"OPTIONAL 3D / MIRRORING";onClicked:StackView.view.push(Qt.resolvedUrl("OptionalModules.qml"))}
  Button{text:"CHECK UPDATES";onClicked:setupManager.checkForUpdates()}
  Label{text:setupManager.status;color:"#7d8994";Layout.fillWidth:true;wrapMode:Text.Wrap}
  Button{text:"BACK";onClicked:StackView.view.pop()}
 }
}
