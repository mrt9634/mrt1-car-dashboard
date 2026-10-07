import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Item { anchors.fill:parent
 Rectangle{anchors.fill:parent;color:"#05070a"}
 ColumnLayout{anchors.fill:parent;anchors.margins:22;spacing:14
  RowLayout{Layout.fillWidth:true;Label{text:"MUSIC";color:"white";font.pixelSize:26;font.bold:true};Item{Layout.fillWidth:true};Button{text:"BACK";onClicked:pages.pop()}}
  Rectangle{Layout.fillWidth:true;Layout.fillHeight:true;radius:18;color:"#0b0f14"
   ColumnLayout{anchors.centerIn:parent;spacing:12
    Label{text:"LOCAL MUSIC PLAYER";color:"white";font.pixelSize:24;font.bold:true}
    Label{text:"Native Qt Multimedia • no browser • no downloader";color:"#7d8994"}
    Label{text:"Ready for local files on the head unit.";color:"#73f5a0"}
   }
  }
 }
}