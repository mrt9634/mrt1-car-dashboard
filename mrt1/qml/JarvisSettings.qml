import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    anchors.fill: parent
    Rectangle { anchors.fill: parent; color:"#080b10" }
    ColumnLayout {
        anchors.fill: parent; anchors.margins:24; spacing:12
        Label { text:"JARVIS / OPENAI"; color:"white"; font.pixelSize:26; font.bold:true }
        Label { text:"API key is stored locally on this device and is never committed to GitHub."; color:"#8996a3"; wrapMode:Text.WordWrap }
        TextField { id:key; Layout.fillWidth:true; echoMode:TextInput.Password; placeholderText:"OpenAI API Key" }
        TextField { id:model; Layout.fillWidth:true; text:openai.model; placeholderText:"Model"; onEditingFinished:openai.model=text }
        TextField { id:url; Layout.fillWidth:true; text:openai.apiUrl; placeholderText:"API URL"; onEditingFinished:openai.apiUrl=text }
        RowLayout {
            Button { text:"SAVE KEY"; onClicked:openai.setApiKey(key.text) }
            Button { text:"CLEAR"; onClicked:{openai.clearApiKey();key.text=""} }
            Button { text:"TEST"; enabled:!openai.busy; onClicked:openai.ask("سلام. فقط پاسخ بده: JARVIS آنلاین است.") }
        }
        Label { text:openai.status; color:"#aab7c4" }
        Label { text:"VOICE: "+speechManager.locale; color:"#aab7c4" }
        RowLayout {
            Button { text:"PERSIAN"; onClicked:speechManager.locale="fa-IR" }
            Button { text:"ENGLISH"; onClicked:speechManager.locale="en-US" }
            Button { text:"BACK"; onClicked:StackView.view.pop() }
        }
    }
}
