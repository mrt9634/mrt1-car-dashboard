import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent
    Rectangle { anchors.fill: parent; color:"#080b10" }
    ColumnLayout {
        anchors.fill: parent; anchors.margins:24; spacing:14
        Label { text:"JARVIS"; color:"white"; font.pixelSize:30; font.bold:true }
        Label { text:"Persian AI • Offline-first • OpenAI"; color:"#8d98a6" }
        TextField {
            id: input
            Layout.fillWidth:true
            placeholderText:"فرمان یا سؤال را به فارسی بنویس..."
            onAccepted: if (text.length > 0) { openai.ask(text); text="" }
        }
        RowLayout {
            Layout.fillWidth:true
            Button { text:"SEND"; enabled:!openai.busy; onClicked: { openai.ask(input.text); input.text="" } }
            Button { text:"VOICE"; enabled:!speechManager.listening; onClicked:speechManager.startListening() }
            Button { text:"BACK"; onClicked:pages.pop() }
        }
        Label { text:openai.status; color:"#9fb2c6" }
        ScrollView {
            Layout.fillWidth:true; Layout.fillHeight:true
            Label { width:parent.width; text:openai.reply; color:"white"; wrapMode:Text.WordWrap; font.pixelSize:18 }
        }
    }
}
