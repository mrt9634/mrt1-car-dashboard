import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item{anchors.fill:parent
 Rectangle{anchors.fill:parent;color:"#05070a"}
 ColumnLayout{anchors.fill:parent;anchors.margins:18;spacing:9
  RowLayout{Layout.fillWidth:true;Label{text:"CAN / MCU RAW CAPTURE";color:"white";font.pixelSize:23;font.bold:true};Item{Layout.fillWidth:true};Button{text:"BACK";onClicked:pages.pop()}}
  Label{text:canFrameMonitor.status+" • "+canFrameMonitor.frameCount+" frames";color:"#7d8994"}
  RowLayout{Layout.fillWidth:true
   Button{text:"START";enabled:!canFrameMonitor.capturing;onClicked:canFrameMonitor.start()}
   Button{text:"STOP";enabled:canFrameMonitor.capturing;onClicked:canFrameMonitor.stop()}
   Button{text:"CLEAR";onClicked:canFrameMonitor.clear()}
   Item{Layout.fillWidth:true}
   Label{text:"READ ONLY — NO TX";color:"#73f5a0";font.bold:true}
  }
  Rectangle{Layout.fillWidth:true;Layout.fillHeight:true;color:"#080b10";radius:12;border.color:"#1c2731"
   ListView{anchors.fill:parent;anchors.margins:10;model:canFrameMonitor.frames;clip:true
    delegate:Column{width:parent.width;spacing:3
     Label{text:modelData.time+"  "+modelData.port+"  "+modelData.baud; color:"#65717d";font.pixelSize:10}
     Label{text:modelData.hex;color:"white";font.family:"monospace";font.pixelSize:13;wrapMode:Text.Wrap}
     Rectangle{width:parent.width;height:1;color:"#18212a"}
    }
   }
  }
  Label{text:"Decoder is intentionally not guessing Peugeot/CAN IDs. Real frames must be captured first.";color:"#596671";font.pixelSize:11}
 }
}