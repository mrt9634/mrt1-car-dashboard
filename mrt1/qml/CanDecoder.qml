import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item{anchors.fill:parent
 Rectangle{anchors.fill:parent;color:"#05070a"}
 ColumnLayout{anchors.fill:parent;anchors.margins:18;spacing:10
  RowLayout{Layout.fillWidth:true;Label{text:"CAN DECODER";color:"white";font.pixelSize:23;font.bold:true};Item{Layout.fillWidth:true};Button{text:"BACK";onClicked:pages.pop()}}
  Label{text:canDecoder.status+" • "+canDecoder.protocol;color:"#7d8994"}
  ComboBox{id:p;model:["AUTO / UNKNOWN","PEUGEOT / PSA — NOT MAPPED","RAW ONLY"];Layout.fillWidth:true;onCurrentTextChanged:canDecoder.setProtocol(currentText)}
  Rectangle{Layout.fillWidth:true;Layout.fillHeight:true;radius:12;color:"#0b0f14";border.color:"#1c2731"
   Column{anchors.centerIn:parent;spacing:8
    Label{text:"No guessed signal IDs";color:"white";font.pixelSize:22;font.bold:true;anchors.horizontalCenter:parent.horizontalCenter}
    Label{text:"Capture real frames first, then map Speed / RPM / Coolant / Fuel / Voltage.";color:"#7d8994";wrapMode:Text.Wrap;horizontalAlignment:Text.AlignHCenter}
    Label{text:"READ ONLY";color:"#73f5a0";font.bold:true;anchors.horizontalCenter:parent.horizontalCenter}
   }
  }
 }
}