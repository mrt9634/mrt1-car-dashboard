import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item {
 anchors.fill:parent
 Rectangle{anchors.fill:parent;color:"#05070a"}
 ColumnLayout{anchors.fill:parent;anchors.margins:22;spacing:12
  RowLayout{Layout.fillWidth:true;Label{text:"VEHICLE DATA";color:"white";font.pixelSize:26;font.bold:true};Item{Layout.fillWidth:true};Button{text:"BACK";onClicked:StackView.view.pop()}}
  GridLayout{Layout.fillWidth:true;Layout.fillHeight:true;columns:3;columnSpacing:10;rowSpacing:10
   Repeater{model:[["SPEED",vehicleData.connected?Math.round(vehicleData.speed)+" km/h":"--"],["RPM",vehicleData.connected?Math.round(vehicleData.rpm)+" rpm":"--"],["COOLANT",vehicleData.connected?Math.round(vehicleData.coolant)+" °C":"--"],["FUEL",vehicleData.connected?Math.round(vehicleData.fuel)+" %":"--"],["BATTERY",vehicleData.connected?vehicleData.batteryVoltage.toFixed(1)+" V":"--"],["SOURCE",vehicleData.source]]
    delegate:Rectangle{Layout.fillWidth:true;Layout.fillHeight:true;radius:14;color:"#0b0f14";border.color:"#1c2731"
     Column{anchors.centerIn:parent;spacing:5;Label{text:modelData[0];color:"#65717d";font.pixelSize:12;horizontalAlignment:Text.AlignHCenter;anchors.horizontalCenter:parent.horizontalCenter};Label{text:modelData[1];color:"white";font.pixelSize:25;font.bold:true;horizontalAlignment:Text.AlignHCenter;anchors.horizontalCenter:parent.horizontalCenter}}
    }}
  }
  Label{text:vehicleData.connected?"LIVE VEHICLE DATA":"NO REAL VEHICLE DATA CONNECTED";color:vehicleData.connected?"#73f5a0":"#ffad66";font.bold:true}
  Label{text:"MRT1 never displays simulated sensor values.";color:"#596671";font.pixelSize:11}
 }
}