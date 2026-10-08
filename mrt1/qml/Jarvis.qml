import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    // ─── Theme (هماهنگ با Dashboard) ──────────────────────────
    readonly property color bgBase:     "#05080d"
    readonly property color bgPanel:    "#0a0f18"
    readonly property color bgCard:     "#0f1520"
    readonly property color accent:     "#00d9ff"
    readonly property color accentSoft: "#0088aa"
    readonly property color textHi:     "#f5f7fa"
    readonly property color textMid:    "#8b97a8"
    readonly property color textLo:     "#4a5666"
    readonly property color stroke:     "#1a2433"
    readonly property color danger:     "#ff5252"
    readonly property color success:    "#4cd7a0"

    Rectangle { anchors.fill: parent; color: root.bgBase }

    // ─── State ────────────────────────────────────────────────
    ListModel { id: chatModel }
    property string lastSentText: ""

    Timer {
        id: sendResetTimer
        interval: 5000
        onTriggered: root.lastSentText = ""
    }

    Component.onCompleted: {
        chatModel.append({
            sender: "jarvis",
            text: "سلام! من JARVIS هستم. چطور می‌تونم کمکت کنم؟",
            time: Qt.formatTime(new Date(), "HH:mm")
        })
    }

    // ─── Speech → OpenAI ──────────────────────────────────────
    Connections {
        target: speechManager
        function onRecognizedTextChanged() {
            const t = speechManager.recognizedText.trim()
            if (t.length === 0) return
            if (t.startsWith("ERROR:")) {
                addMessage("system", "خطای تشخیص صدا: " + t, root.danger)
                return
            }
            if (t === root.lastSentText) return
            root.lastSentText = t
            sendResetTimer.restart()
            sendMessage(t)
        }
    }

    // ─── OpenAI reply → Chat + TTS ────────────────────────────
    Connections {
        target: openai
        function onReplyChanged() {
            const r = openai.reply.trim()
            if (r.length === 0) return
            addMessage("jarvis", r, root.accent)
            speechManager.speak(r)
        }
    }

    // ─── Helpers ──────────────────────────────────────────────
    function addMessage(sender, text, color) {
        chatModel.append({
            sender: sender,
            text: text,
            time: Qt.formatTime(new Date(), "HH:mm")
        })
        chatView.positionViewAtEnd()
    }

    function sendMessage(text) {
        const t = text.trim()
        if (t.length === 0) return
        addMessage("user", t, root.textHi)
        openai.ask(t)
    }

    // ─── Layout ───────────────────────────────────────────────
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // ═══ TOP BAR ═════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 62
            radius: 14
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 14

                Rectangle {
                    width: 10; height: 10; radius: 5
                    color: speechManager.listening ? root.accent
                         : speechManager.speaking  ? root.success
                         : openai.busy             ? "#ffb74d"
                         : root.textLo
                    SequentialAnimation on opacity {
                        running: speechManager.listening || openai.busy
                        loops: Animation.Infinite
                        NumberAnimation { to: 0.3; duration: 700 }
                        NumberAnimation { to: 1.0; duration: 700 }
                    }
                }

                ColumnLayout {
                    spacing: 0
                    Label {
                        text: "JARVIS"
                        color: root.textHi
                        font.pixelSize: 22
                        font.bold: true
                        font.letterSpacing: 3
                    }
                    Label {
                        text: speechManager.listening ? "LISTENING"
                            : speechManager.speaking  ? "SPEAKING"
                            : openai.busy             ? "THINKING"
                            : "READY"
                        color: root.textMid
                        font.pixelSize: 9
                        font.letterSpacing: 2
                    }
                }

                Item { Layout.fillWidth: true }

                Label {
                    text: openai.status
                    color: root.textMid
                    font.pixelSize: 11
                    elide: Text.ElideRight
                    Layout.maximumWidth: 400
                }

                Button {
                    text: "SETTINGS"
                    onClicked: StackView.view.push(Qt.resolvedUrl("JarvisSettings.qml"))
                }

                Button {
                    text: "BACK"
                    onClicked: StackView.view.pop()
                }
            }
        }

        // ═══ CHAT AREA ════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 14
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            ListView {
                id: chatView
                anchors.fill: parent
                anchors.margins: 12
                spacing: 10
                clip: true
                model: chatModel

                delegate: Item {
                    width: chatView.width
                    height: bubble.height + 6

                    Rectangle {
                        id: bubble
                        anchors.right: model.sender === "user" ? parent.right : undefined
                        anchors.left: model.sender === "user" ? undefined : parent.left
                        width: Math.min(chatView.width * 0.72, msgText.implicitWidth + 28)
                        height: msgText.implicitHeight + 42
                        radius: 14
                        color: model.sender === "user"   ? Qt.rgba(0, 0.85, 1, 0.15)
                             : model.sender === "jarvis" ? root.bgCard
                             : Qt.rgba(1, 0.3, 0.3, 0.15)
                        border.color: model.sender === "user"   ? root.accentSoft
                                    : model.sender === "jarvis" ? root.stroke
                                    : root.danger
                        border.width: 1

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 4

                            RowLayout {
                                Layout.fillWidth: true
                                Label {
                                    text: model.sender === "user"   ? "شما"
                                        : model.sender === "jarvis" ? "JARVIS"
                                        : "سیستم"
                                    color: model.sender === "user"   ? root.accent
                                         : model.sender === "jarvis" ? root.success
                                         : root.danger
                                    font.pixelSize: 10
                                    font.bold: true
                                    font.letterSpacing: 1
                                }
                                Item { Layout.fillWidth: true }
                                Label {
                                    text: model.time
                                    color: root.textLo
                                    font.pixelSize: 9
                                }
                            }

                            Label {
                                id: msgText
                                Layout.fillWidth: true
                                text: model.text
                                color: root.textHi
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                                lineHeight: 1.3
                            }
                        }
                    }
                }
            }
        }

        // ═══ INPUT BAR ════════════════════════════════════════
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 68
            radius: 14
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 10

                TextField {
                    id: input
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    placeholderText: "فرمان یا سؤال را به فارسی بنویس..."
                    font.pixelSize: 15
                    color: root.textHi
                    placeholderTextColor: root.textLo
                    background: Rectangle {
                        color: root.bgCard
                        radius: 10
                        border.color: input.activeFocus ? root.accent : root.stroke
                        border.width: 1
                    }
                    onAccepted: {
                        sendMessage(text)
                        text = ""
                    }
                }

                Button {
                    id: micBtn
                    text: speechManager.listening ? "■ STOP" : "🎤 VOICE"
                    Layout.preferredWidth: 130
                    Layout.fillHeight: true
                    enabled: !speechManager.speaking && !openai.busy
                    onClicked: {
                        if (speechManager.listening)
                            speechManager.stopListening()
                        else
                            speechManager.startListening()
                    }
                    background: Rectangle {
                        radius: 10
                        color: speechManager.listening ? Qt.rgba(1, 0.3, 0.3, 0.2)
                             : micBtn.enabled ? Qt.rgba(0, 0.85, 1, 0.15)
                             : Qt.rgba(1, 1, 1, 0.03)
                        border.color: speechManager.listening ? root.danger
                                    : micBtn.enabled ? root.accentSoft
                                    : root.stroke
                        border.width: 1
                    }
                }

                Button {
                    id: sendBtn
                    text: "SEND"
                    Layout.preferredWidth: 100
                    Layout.fillHeight: true
                    enabled: !openai.busy && input.text.trim().length > 0
                    onClicked: {
                        sendMessage(input.text)
                        input.text = ""
                    }
                    background: Rectangle {
                        radius: 10
                        color: sendBtn.enabled ? Qt.rgba(0, 0.85, 1, 0.2)
                                               : Qt.rgba(1, 1, 1, 0.03)
                        border.color: sendBtn.enabled ? root.accent : root.stroke
                        border.width: 1
                    }
                }
            }
        }
    }
}
