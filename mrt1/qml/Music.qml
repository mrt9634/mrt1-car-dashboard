import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
Item {
 anchors.fill:parent
 Rectangle{anchors.fill:parent;color:"#05070a"}
 MediaPlayer{id:player;audioOutput:AudioOutput{};source:localMusic.currentIndex>=0&&localMusic.currentIndex<localMusic.tracks.length?localMusic.tracks[localMusic.currentIndex].url:"";onPlaybackStateChanged:localMusic.setPlaying(playbackState===MediaPlayer.PlayingState)}
 ColumnLayout{anchors.fill:parent;anchors.margins:22;spacing:12
  RowLayout{Layout.fillWidth:true;Label{text:"MUSIC";color:"white";font.pixelSize:26;font.bold:true};Item{Layout.fillWidth:true};Button{text:"BACK";onClicked:StackView.view.pop()}}
  RowLayout{Layout.fillWidth:true
   Button{text:"SCAN /MUSIC";onClicked:localMusic.scan()}
   Button{text:"PLAY";enabled:localMusic.currentIndex>=0;onClicked:player.play()}
   Button{text:"PAUSE";enabled:localMusic.currentIndex>=0;onClicked:player.pause()}
   Button{text:"STOP";onClicked:player.stop()}
   Label{text:localMusic.status;color:"#7d8994";Layout.fillWidth:true;elide:Text.ElideRight}
  }
  ListView{Layout.fillWidth:true;Layout.fillHeight:true;model:localMusic.tracks;clip:true
   delegate:Rectangle{width:ListView.view.width;height:52;color:index===localMusic.currentIndex?"#14201a":"#0b0f14";border.color:"#1c2731"
    RowLayout{anchors.fill:parent;anchors.margins:10
     Label{text:(index+1)+". "+modelData.title;color:"white";Layout.fillWidth:true;elide:Text.ElideRight}
     Button{text:"SELECT";onClicked:localMusic.select(index)}
    }
   }
  }
  Label{text:"Native local playback • offline • no browser • no downloader";color:"#65717d";font.pixelSize:11}
 }
}