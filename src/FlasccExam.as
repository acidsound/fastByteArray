package {

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.events.Event;
import flash.events.SampleDataEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.system.System;
import flash.text.TextField;
import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.getTimer;

import sample.bytelib.CModule;

public class FlasccExam extends Sprite {
  [Embed(source="../assets/mp3/Bass.mp3")]
  private const BassSound:Class;
  [Embed(source="../assets/mp3/Drums.mp3")]
  private const DrumsSound:Class;
  [Embed(source="../assets/mp3/Guitar.mp3")]
  private const GuitarSound:Class;
  [Embed(source="../assets/mp3/Keyboard.mp3")]
  private const KeyboardSound:Class;
  [Embed(source="../assets/mp3/Vocal.mp3")]
  private const VocalSound:Class;
  [Embed(source="../assets/mp3/Metronome.mp3")]
  private const MetronomeSound:Class;
  private const TrackSources:Vector.<Sound> = Vector.<Sound>([
    new VocalSound,
    new GuitarSound,
    new BassSound,
    new KeyboardSound,
    new DrumsSound,
//    new MetronomeSound
  ]);
  private var Tracks:Vector.<ByteArray> = new Vector.<ByteArray>();
  private var mixdownTrack:ByteArray = new ByteArray();
  private var tf:TextField;
  private var t:Number;
  private const CHUNK_LENGTH:int = 4096;
  private var soundChannel:SoundChannel;

  public function FlasccExam() {
    stage.align = StageAlign.TOP_LEFT;
    addEventListener(Event.ADDED_TO_STAGE, initCode);
  }

  private function initCode(e:Event):void {
    tf = new TextField();
    addChild(tf);
    tf.appendText("SWC Output:\n");
    trace("extract Sound");
    t = getTimer();
    var track:ByteArray;
    var l:uint;
    for each (var sound:Sound in TrackSources) {
      track = Tracks[Tracks.push(new ByteArray()) - 1];
      l = sound.bytesTotal;
      track.endian=Endian.LITTLE_ENDIAN;
      trace(Tracks.indexOf(track)+":" + l);
      sound.extract(track, l, 0);
    }
    trace("extract Sound Done: " + (getTimer() - t));
    var i:uint;

    trace("convert C Binary");
    t = getTimer();
    var trackLength = Tracks[0].length;
    var TracksPtr:int = CModule.malloc(Tracks.length * trackLength);
    for (i = 0; i < Tracks.length; i++) {
      Tracks[i].position = 0;
      CModule.writeBytes(TracksPtr + (i * Tracks[0].length), trackLength, Tracks[i]);
    }
    trace("convert C Binary Done: " + (getTimer() - t));

    mixdownTrack.length = trackLength;
    mixdownTrack.endian = Endian.LITTLE_ENDIAN;

    trace("mixdownTrack length : " + mixdownTrack.length);

    mixdownTrack.position = 0;
    var mixdownTrackPtr:int = CModule.malloc(mixdownTrack.length);
    CModule.writeBytes(mixdownTrackPtr, mixdownTrack.length, mixdownTrack);

    t = getTimer();
    bytelib.summingFloats(TracksPtr, trackLength, Tracks.length, mixdownTrackPtr);
    trace("6track summing time : " + (getTimer() - t));

    mixdownTrack.position = 0;
    CModule.readBytes(mixdownTrackPtr, mixdownTrack.length, mixdownTrack);

    CModule.free(mixdownTrackPtr);
    CModule.free(TracksPtr);

    var sound:Sound = new Sound();
    sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onMixdownPlayHandler);
    mixdownTrack.position = 0;
    soundChannel=sound.play();
    soundChannel.addEventListener(Event.SOUND_COMPLETE, onSoundCompleteHandler);

    var mem:String = Number( System.totalMemory / 1024 / 1024 ).toFixed( 2 ) + 'Mb';
    trace( mem ); // eg traces “24.94Mb”
  }

  private function onSoundCompleteHandler(event:Event):void {
    trace("End of Sound");
  }

  private function onMixdownPlayHandler(event:SampleDataEvent):void {
    var l:Number;
    var r:Number;
//    trace(l,r);
    for (var c:int = 0; c < CHUNK_LENGTH && mixdownTrack.bytesAvailable > 0; c++) {
      l = mixdownTrack.readFloat();
      r = mixdownTrack.readFloat();
      event.data.writeFloat(l);
      event.data.writeFloat(r);
    }
  }

}
}