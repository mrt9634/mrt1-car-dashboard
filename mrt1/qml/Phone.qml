import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item { anchors.fill:parent
 Rectangle{anchors.fill:parent;color:"#05070a"}
 ColumnLayout{anchors.fill:parent;anchors.margins:22;spacing:14
  RowLayout{Layout.fillWidth:true;Label{text:"PHONE";color:"white";font.pixelSize:26;font.bold:true};Item{Layout.fillWidth:true};Button{text:"BACK";onClicked:pages.pop()}}
  Rectangle{Layout.fillWidth:true;Layout.fillHeight:true;radius:18;color:"#0b0f14"
   ColumnLayout{anchors.centerIn:parent;spacing:12
    Label{text:"PHONE / CALLS";color:"white";font.pixelSize:24;font.bold:true}
    Label{text:"Native Android phone integration is kept separate from CAN/MCU.";color:"#7d8994";wrapMode:Text.Wrap;Layout.maximumWidth:600}
    Label{text:"No factory caller/CAN settings are modified by MRT1.";color:"#73f5a0"}
   }
  }
 }
}