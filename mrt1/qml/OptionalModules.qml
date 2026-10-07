import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item { anchors.fill:parent
 Rectangle{anchors.fill:parent;color:"#05070a"}
 ColumnLayout{anchors.fill:parent;anchors.margins:22;spacing:12
  RowLayout{Layout.fillWidth:true;Label{text:"OPTIONAL MODULES";color:"white";font.pixelSize:25;font.bold:true};Item{Layout.fillWidth:true};Button{text:"BACK";onClicked:pages.pop()}}
  Repeater{model:[
   ["3D VEHICLE VIEW","Quick3D • optional / disabled by default on low-RAM units"],
   ["PHONE MIRRORING","scrcpy / vendor bridge • requires explicit Android integration"],
   ["QUICK3D VEHICLE","Test module • never required by the dashboard core"]
  ];delegate:Rectangle{Layout.fillWidth:true;Layout.preferredHeight:72;radius:12;color:"#0b0f14";border.color:"#1c2731"
   Column{anchors.fill:parent;anchors.margins:14;spacing:4;Label{text:modelData[0];color:"white";font.bold:true};Label{text:modelData[1];color:"#7d8994";font.pixelSize:12}}
  }}
  Label{text:"Core MRT1 remains native Android/QML and offline-first.";color:"#73f5a0"}
 }
}