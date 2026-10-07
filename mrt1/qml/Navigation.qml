import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item { anchors.fill: parent
 Rectangle{anchors.fill:parent;color:"#05070a"}
 ColumnLayout{anchors.fill:parent;anchors.margins:22;spacing:14
  RowLayout{Layout.fillWidth:true;Label{text:"NAVIGATION";color:"white";font.pixelSize:26;font.bold:true};Item{Layout.fillWidth:true};Button{text:"BACK";onClicked:pages.pop()}}
  Rectangle{Layout.fillWidth:true;Layout.fillHeight:true;radius:18;color:"#0b0f14";border.color:"#1c2731"
   ColumnLayout{anchors.centerIn:parent;spacing:10
    Label{text:"OFFLINE-FIRST NAVIGATION";color:"white";font.pixelSize:24;font.bold:true;Layout.alignment:Qt.AlignHCenter}
    Label{text:"Navigation engine is modular and can be attached without changing the cockpit core.";color:"#7d8994";wrapMode:Text.Wrap;Layout.maximumWidth:600;horizontalAlignment:Text.AlignHCenter}
    Label{text:"GPS: "+(gpsSpeed.available?"AVAILABLE":"WAITING");color:gpsSpeed.available?"#73f5a0":"#ffad66";Layout.alignment:Qt.AlignHCenter}
    Button{text:"BACK TO COCKPIT";onClicked:pages.pop()}
   }
  }
 }
}