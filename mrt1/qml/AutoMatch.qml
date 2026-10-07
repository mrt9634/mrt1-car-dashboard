import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent
    Rectangle { anchors.fill: parent; color:"#080b10" }
    ColumnLayout {
        anchors.fill: parent; anchors.margins: 24; spacing: 14
        Label { text:"MRT1 AUTO MATCH"; color:"white"; font.pixelSize:28; font.bold:true }
        Label { text:"Monitor hardware / audio / CAN / display / vehicle profile"; color:"#8d98a6"; font.pixelSize:14 }
        ProgressBar { Layout.fillWidth:true; from:0; to:100; value:autoMatch.progress }
        Label { text:autoMatch.status; color:"#b8c2ce" }
        RowLayout {
            Layout.fillWidth:true
            Button { text:autoMatch.running ? "SCANNING..." : "SCAN & MATCH"; enabled:!autoMatch.running; onClicked:autoMatch.scan() }
            Button { text:"BACK"; onClicked:stackView.pop() }
        }
        ScrollView {
            Layout.fillWidth:true; Layout.fillHeight:true
            Column {
                width: parent.width; spacing:10
                Label { text:"MATCHED"; color:"#70d69b"; font.bold:true }
                Repeater { model:autoMatch.matched; delegate:Label { text:"✓ "+modelData; color:"#d7e1ea"; wrapMode:Text.WordWrap } }
                Label { text:"DIFFERENT"; color:"#e8c56b"; font.bold:true; visible:autoMatch.different.length>0 }
                Repeater { model:autoMatch.different; delegate:Label { text:"! "+modelData; color:"#e8c56b" } }
                Label { text:"UNKNOWN / NEEDS VENDOR API"; color:"#8eb7e8"; font.bold:true }
                Repeater { model:autoMatch.unknown; delegate:Label { text:"? "+modelData; color:"#b7c9dd" } }
                Label { text:"PROTECTED — NEVER AUTO-WRITE"; color:"#ef8f8f"; font.bold:true }
                Repeater { model:autoMatch.protectedItems; delegate:Label { text:"🔒 "+modelData; color:"#efb0b0" } }
            }
        }
    }
}
