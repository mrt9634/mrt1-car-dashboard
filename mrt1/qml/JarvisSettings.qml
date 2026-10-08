import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    anchors.fill: parent

    // ─── Theme ────────────────────────────────────────────────
    readonly property color bgBase:     "#05080d"
    readonly property color bgPanel:    "#0a0f18"
    readonly property color bgCard:     "#0f1520"
    readonly property color accent:     "#00d9ff"
    readonly property color accentSoft: "#0088aa"
    readonly property color success:    "#4cd7a0"
    readonly property color danger:     "#ff5252"
    readonly property color textHi:     "#f5f7fa"
    readonly property color textMid:    "#8b97a8"
    readonly property color textLo:     "#4a5666"
    readonly property color stroke:     "#1a2433"

    // ─── State ────────────────────────────────────────────────
    property bool keySaved: false
    property string keyStatusText: ""
    property color  keyStatusColor: root.textMid

    Rectangle { anchors.fill: parent; color: root.bgBase }

    // ─── Save feedback timer ──────────────────────────────────
    Timer {
        id: feedbackTimer
        interval: 3000
        onTriggered: {
            root.keyStatusText = ""
        }
    }

    // ─── Watch for API key save events ────────────────────────
    Connections {
        target: openai
        function onStateChanged() {
            const s = openai.status
            if (s.indexOf("saved") !== -1 || s.indexOf("API key") !== -1) {
                root.keyStatusText = s
                root.keyStatusColor = s.indexOf("missing") !== -1 ||
                                      s.indexOf("Could not") !== -1
                                      ? root.danger : root.success
                feedbackTimer.restart()
            }
        }
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

                Label {
                    text: "JARVIS / OPENAI"
                    color: root.textHi
                    font.pixelSize: 22
                    font.bold: true
                    font.letterSpacing: 3
                }

                Item { Layout.fillWidth: true }

                Button {
                    text: "BACK"
                    onClicked: StackView.view.pop()
                }
            }
        }

        // ═══ SCROLL CONTENT ═══════════════════════════════════
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true

            ColumnLayout {
                width: parent.width
                spacing: 14

                // ─── API KEY CARD ─────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 200
                    radius: 14
                    color: root.bgPanel
                    border.color: root.stroke
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        RowLayout {
                            Label {
                                text: "API KEY"
                                color: root.accent
                                font.pixelSize: 13
                                font.bold: true
                                font.letterSpacing: 2
                            }
                            Item { Layout.fillWidth: true }
                            Label {
                                text: "Stored in Android Keystore (AES-256-GCM)"
                                color: root.textLo
                                font.pixelSize: 10
                            }
                        }

                        Label {
                            Layout.fillWidth: true
                            text: "کلید OpenAI خود را اینجا وارد کنید. این کلید فقط روی این دستگاه ذخیره می‌شود و هرگز به گیت‌هاب ارسال نمی‌شود."
                            color: root.textMid
                            font.pixelSize: 11
                            wrapMode: Text.WordWrap
                        }

                        TextField {
                            id: keyField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 44
                            echoMode: TextInput.Password
                            placeholderText: "sk-..."
                            font.pixelSize: 14
                            color: root.textHi
                            placeholderTextColor: root.textLo
                            background: Rectangle {
                                color: root.bgCard
                                radius: 10
                                border.color: keyField.activeFocus ? root.accent : root.stroke
                                border.width: 1
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Button {
                                text: "💾 SAVE KEY"
                                Layout.preferredWidth: 140
                                Layout.preferredHeight: 40
                                enabled: keyField.text.trim().length > 0
                                onClicked: {
                                    openai.setApiKey(keyField.text)
                                    keyField.text = ""
                                }
                                background: Rectangle {
                                    radius: 10
                                    color: parent.enabled ? Qt.rgba(0, 0.85, 1, 0.15)
                                                          : Qt.rgba(1, 1, 1, 0.03)
                                    border.color: parent.enabled ? root.accent : root.stroke
                                    border.width: 1
                                }
                            }

                            Button {
                                text: "🗑 CLEAR"
                                Layout.preferredWidth: 120
                                Layout.preferredHeight: 40
                                onClicked: {
                                    openai.clearApiKey()
                                    keyField.text = ""
                                }
                                background: Rectangle {
                                    radius: 10
                                    color: Qt.rgba(1, 0.3, 0.3, 0.1)
                                    border.color: root.danger
                                    border.width: 1
                                }
                            }

                            Button {
                                text: openai.busy ? "⏳ TESTING..." : "🧪 TEST"
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 40
                                enabled: !openai.busy
                                onClicked: openai.ask("سلام. فقط پاسخ بده: JARVIS آنلاین است.")
                                background: Rectangle {
                                    radius: 10
                                    color: parent.enabled ? Qt.rgba(0.3, 0.85, 0.6, 0.15)
                                                          : Qt.rgba(1, 1, 1, 0.03)
                                    border.color: parent.enabled ? root.success : root.stroke
                                    border.width: 1
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Label {
                                text: root.keyStatusText
                                color: root.keyStatusColor
                                font.pixelSize: 11
                                elide: Text.ElideRight
                            }
                        }
                    }
                }

                // ─── MODEL CARD ───────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 180
                    radius: 14
                    color: root.bgPanel
                    border.color: root.stroke
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        Label {
                            text: "MODEL / ENDPOINT"
                            color: root.accent
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        Label {
                            text: "Model"
                            color: root.textMid
                            font.pixelSize: 11
                        }
                        ComboBox {
                            id: modelBox
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            model: [
                                "gpt-4o-mini",
                                "gpt-4o",
                                "gpt-4-turbo",
                                "gpt-3.5-turbo"
                            ]
                            Component.onCompleted: {
                                const i = model.indexOf(openai.model)
                                if (i >= 0) currentIndex = i
                            }
                            onActivated: openai.model = currentText
                        }

                        Label {
                            text: "API URL"
                            color: root.textMid
                            font.pixelSize: 11
                        }
                        TextField {
                            id: urlField
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            text: openai.apiUrl
                            placeholderText: "https://api.openai.com/v1/responses"
                            color: root.textHi
                            placeholderTextColor: root.textLo
                            font.pixelSize: 12
                            onEditingFinished: openai.apiUrl = text
                            background: Rectangle {
                                color: root.bgCard
                                radius: 10
                                border.color: urlField.activeFocus ? root.accent : root.stroke
                                border.width: 1
                            }
                        }
                    }
                }

                // ─── VOICE CARD ───────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 140
                    radius: 14
                    color: root.bgPanel
                    border.color: root.stroke
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 10

                        Label {
                            text: "VOICE LANGUAGE"
                            color: root.accent
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        Label {
                            text: "Current: " + speechManager.locale
                            color: root.textMid
                            font.pixelSize: 12
                        }

                        RowLayout {
                            spacing: 10

                            Button {
                                text: "🇮🇷 فارسی"
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 40
                                onClicked: speechManager.locale = "fa-IR"
                                background: Rectangle {
                                    radius: 10
                                    color: speechManager.locale === "fa-IR"
                                           ? Qt.rgba(0, 0.85, 1, 0.2)
                                           : Qt.rgba(1, 1, 1, 0.03)
                                    border.color: speechManager.locale === "fa-IR"
                                                  ? root.accent : root.stroke
                                    border.width: 1
                                }
                            }

                            Button {
                                text: "🇬🇧 English"
                                Layout.preferredWidth: 130
                                Layout.preferredHeight: 40
                                onClicked: speechManager.locale = "en-US"
                                background: Rectangle {
                                    radius: 10
                                    color: speechManager.locale === "en-US"
                                           ? Qt.rgba(0, 0.85, 1, 0.2)
                                           : Qt.rgba(1, 1, 1, 0.03)
                                    border.color: speechManager.locale === "en-US"
                                                  ? root.accent : root.stroke
                                    border.width: 1
                                }
                            }

                            Item { Layout.fillWidth: true }
                        }
                    }
                }

                // ─── STATUS CARD ──────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    radius: 14
                    color: root.bgPanel
                    border.color: root.stroke
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 18
                        spacing: 6

                        Label {
                            text: "STATUS"
                            color: root.accent
                            font.pixelSize: 13
                            font.bold: true
                            font.letterSpacing: 2
                        }

                        Label {
                            Layout.fillWidth: true
                            text: openai.status
                            color: root.textMid
                            font.pixelSize: 12
                            wrapMode: Text.WordWrap
                        }

                        Label {
                            text: openai.busy
                                  ? "⏳ Processing..."
                                  : (openai.enabled ? "● Enabled" : "○ Disabled")
                            color: openai.busy ? "#ffb74d"
                                 : openai.enabled ? root.success : root.textLo
                            font.pixelSize: 11
                            font.bold: true
                        }
                    }
                }

                Item { Layout.preferredHeight: 20 }
            }
        }
    }
}
