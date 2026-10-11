import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia

Item {
    id: root
    anchors.fill: parent

    readonly property color bgDeep:  "#030405"
    readonly property color bgPanel: "#0a0a0c"
    readonly property color gold:    "#ffb84d"
    readonly property color textHi:  "#f5f5f5"
    readonly property color textMid: "#808080"
    readonly property color textLo:  "#404040"
    readonly property color stroke:  "#1a1a1f"

    Rectangle { anchors.fill: parent; color: root.bgDeep }

    MediaPlayer {
        id: player
        audioOutput: AudioOutput { volume: 0.8 }
        source: (localMusic.currentIndex >= 0
                 && localMusic.currentIndex < localMusic.tracks.length)
                ? localMusic.tracks[localMusic.currentIndex].url
                : ""
        onPlaybackStateChanged: {
            localMusic.setPlaying(playbackState === MediaPlayer.PlayingState)
        }
        onPositionChanged: positionBar.value = position
        onDurationChanged: positionBar.to = duration
    }

    Connections {
        target: player
        function onMediaStatusChanged() {
            if (player.mediaStatus === MediaPlayer.EndOfMedia) {
                const next = localMusic.currentIndex + 1
                if (next < localMusic.tracks.length) {
                    localMusic.select(next)
                    player.play()
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 56
            radius: 14
            color: root.bgPanel
            border.color: root.stroke
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 14

                Text { text: "♪"; color: root.gold; font.pixelSize: 22 }
                Text {
                    text: "LUXURY MEDIA"
                    color: root.textHi
                    font.pixelSize: 14
                    font.bold: true
                    font.letterSpacing: 4
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: localMusic.status
                    color: root.textMid
                    font.pixelSize: 10
                }
                Rectangle {
                    width: 110; height: 34; radius: 8
                    color: scanArea.containsMouse
                           ? Qt.rgba(1, 0.72, 0.30, 0.2)
                           : Qt.rgba(1, 0.72, 0.30, 0.1)
                    border.color: root.gold
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "SCAN /MUSIC"
                        color: root.gold
                        font.pixelSize: 10
                        font.bold: true
                    }
                    MouseArea {
                        id: scanArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: localMusic.scan()
                    }
                }
                Rectangle {
                    width: 80; height: 34; radius: 8
                    color: Qt.rgba(1, 1, 1, 0.03)
                    border.color: root.stroke
                    border.width: 1
                    Text {
                        anchors.centerIn: parent
                        text: "BACK"
                        color: root.textHi
                        font.pixelSize: 10
                        font.bold: true
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: StackView.view.pop()
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            Rectangle {
                Layout.preferredWidth: 380
                Layout.fillHeight: true
                radius: 18
                color: root.bgPanel
                border.color: root.stroke
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 22
                    spacing: 14

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 240
                        radius: 16
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#ff6b00" }
                            GradientStop { position: 0.5; color: "#8b3a00" }
                            GradientStop { position: 1.0; color: "#3a1500" }
                        }
                        border.color: root.gold
                        border.width: 2
                        Text {
                            anchors.centerIn: parent
                            text: "♪"
                            color: "#fff"
                            font.pixelSize: 110
                            opacity: 0.3
                        }
                    }

                    Text {
                        Layout.fillWidth: true
                        text: localMusic.currentIndex >= 0
                              ? localMusic.tracks[localMusic.currentIndex].title
                              : "—"
                        color: root.textHi
                        font.pixelSize: 18
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    Text {
                        text: "LOCAL MUSIC LIBRARY"
                        color: root.gold
                        font.pixelSize: 9
                        font.letterSpacing: 3
                        font.bold: true
                    }

                    Slider {
                        id: positionBar
                        Layout.fillWidth: true
                        from: 0
                        to: 100
                        value: 0
                        onMoved: player.position = value
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: root.formatTime(player.position)
                            color: root.textMid
                            font.pixelSize: 10
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: root.formatTime(player.duration)
                            color: root.textMid
                            font.pixelSize: 10
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 22

                        Text {
                            text: "⏮"
                            color: root.textHi
                            font.pixelSize: 26
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -10
                                onClicked: {
                                    const prev = localMusic.currentIndex - 1
                                    if (prev >= 0) {
                                        localMusic.select(prev)
                                        player.play()
                                    }
                                }
                            }
                        }

                        Rectangle {
                            width: 60; height: 60; radius: 30
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: root.gold }
                                GradientStop { position: 1.0; color: "#ff6b00" }
                            }
                            Text {
                                anchors.centerIn: parent
                                text: localMusic.playing ? "⏸" : "▶"
                                color: "#fff"
                                font.pixelSize: 24
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    if (localMusic.playing) player.pause()
                                    else player.play()
                                }
                            }
                        }

                        Text {
                            text: "⏭"
                            color: root.textHi
                            font.pixelSize: 26
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -10
                                onClicked: {
                                    const next = localMusic.currentIndex + 1
                                    if (next < localMusic.tracks.length) {
                                        localMusic.select(next)
                                        player.play()
                                    }
                                }
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 18
                color: root.bgPanel
                border.color: root.stroke
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 8

                    Text {
                        text: "TRACKS · " + localMusic.tracks.length
                        color: root.gold
                        font.pixelSize: 11
                        font.bold: true
                        font.letterSpacing: 3
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: root.stroke
                    }

                    ListView {
                        id: trackView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        spacing: 4
                        model: localMusic.tracks

                        delegate: Rectangle {
                            width: trackView.width
                            height: 56
                            radius: 10
                            color: index === localMusic.currentIndex
                                   ? Qt.rgba(1, 0.72, 0.30, 0.15)
                                   : "transparent"
                            border.color: index === localMusic.currentIndex
                                          ? root.gold : "transparent"
                            border.width: 1

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 12

                                Text {
                                    text: index + 1
                                    color: index === localMusic.currentIndex
                                           ? root.gold : root.textMid
                                    font.pixelSize: 14
                                    font.bold: true
                                    Layout.preferredWidth: 30
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.title
                                    color: index === localMusic.currentIndex
                                           ? root.gold : root.textHi
                                    font.pixelSize: 13
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    localMusic.select(index)
                                    player.play()
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            visible: localMusic.tracks.length === 0
                            text: "NO TRACKS\n\nPress SCAN /MUSIC"
                            color: root.textLo
                            font.pixelSize: 13
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                }
            }
        }
    }

    function formatTime(ms) {
        if (!ms || ms < 0) return "0:00"
        const s = Math.floor(ms / 1000)
        const m = Math.floor(s / 60)
        const r = s % 60
        return m + ":" + (r < 10 ? "0" : "") + r
    }
}
