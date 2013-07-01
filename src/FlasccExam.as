package {

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.text.TextField;
import flash.events.Event;

import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.utils.getTimer;

import sample.bytelib.CModule;
import sample.bytelib.vfs.ISpecialFile;

public class FlasccExam extends Sprite implements ISpecialFile {
  private const BUFFER_SIZE:uint = 4*1024*1024;
  private var tf:TextField;

  public function FlasccExam() {
    stage.align = StageAlign.TOP_LEFT;
    addEventListener(Event.ADDED_TO_STAGE, initCode);
  }

  private function initCode(e:Event):void {
    tf = new TextField();
    addChild(tf);
    tf.appendText("SWC Output:\n");

    // set the console before starting
    // prepare byteArray
    var i:uint = 0;
    var l:uint = BUFFER_SIZE/4;
    var t:uint = getTimer();

    trace("BUFFER LENGTH: "+ l + "/" + BUFFER_SIZE);

    var ABin1:ByteArray = new ByteArray();
    ABin1.length = BUFFER_SIZE;
    ABin1.endian = Endian.LITTLE_ENDIAN;
    for (i = 0; i < l; i++) {
      ABin1.writeFloat(i+.5);
    }
    var ABin2:ByteArray = new ByteArray();
    ABin2.length = BUFFER_SIZE;
    ABin2.endian = Endian.LITTLE_ENDIAN;
    for (i = 0; i < l; i++) {
      ABin2.writeFloat(i+0.75);
    }

    var OBin:ByteArray = new ByteArray();
    OBin.length = BUFFER_SIZE;
    OBin.endian = Endian.LITTLE_ENDIAN;
    trace("2 buffer : Loading Time >> " + (getTimer()-t));

    t=getTimer();
    ABin1.position = 0;
    var ABin1Pointer:int = CModule.malloc(ABin1.length);
    CModule.writeBytes(ABin1Pointer, ABin1.length, ABin1);

    ABin2.position = 0;
    var ABin2Pointer:int = CModule.malloc(ABin2.length);
    CModule.writeBytes(ABin2Pointer, ABin2.length, ABin2);

    OBin.position = 0;
    var OBinPointer:int = CModule.malloc(OBin.length);
    CModule.writeBytes(OBinPointer, OBin.length, OBin);

    trace("CModule loading Time: "+ (getTimer()-t));
    trace("Result : " + bytelib.checkFirstByte(ABin1Pointer, ABin2Pointer, ABin1.length));

    t=getTimer();
    bytelib.summingBytes(ABin1Pointer, ABin2Pointer, ABin1.length, OBinPointer);
    trace("summing time : " + (getTimer()-t));

    trace("total length: " + l);
    trace("Final Answer: " + CModule.readFloat(OBinPointer));
    trace("Final Answer: " + CModule.readFloat(OBinPointer+4*(l-1)));

    t=getTimer();
    OBin.position = 0;
    CModule.readBytes(OBinPointer, OBin.length, OBin);
    OBin.position = 0;
    trace("ByteArray Final : " + OBin.readFloat());
    OBin.position = 4*(l-1);
    trace("ByteArray Final : " + OBin.readFloat());
    trace("time elapsed : " + (getTimer()-t));

    CModule.free(ABin1Pointer);
    CModule.free(ABin2Pointer);
    CModule.free(OBinPointer);

    trace("-------- top line ----------");
    t=getTimer();
    var Tracks:Vector.<ByteArray>=new Vector.<ByteArray>();
    Tracks.push(new ByteArray());
    Tracks.push(new ByteArray());
    Tracks.push(new ByteArray());
    Tracks.push(new ByteArray());
    Tracks.push(new ByteArray());
    Tracks.push(new ByteArray());
    Tracks[0].writeBytes(ABin1, 0, ABin1.length);
    Tracks[1].writeBytes(ABin2, 0, ABin2.length);
    Tracks[2].writeBytes(ABin1, 0, ABin1.length);
    Tracks[3].writeBytes(ABin2, 0, ABin2.length);
    Tracks[4].writeBytes(ABin1, 0, ABin1.length);
    Tracks[5].writeBytes(ABin2, 0, ABin2.length);
    trace("stack 6tracks elapsed time : " + (getTimer()-t));

    var TracksPtr:int = CModule.malloc(Tracks.length*ABin1.length);
    for (i=0; i< Tracks.length; i++) {
      Tracks[i].position = 0;
      CModule.writeBytes(TracksPtr+(i*ABin1.length), Tracks[0].length, Tracks[i]);
    }

    var mixdownTrack:ByteArray=new ByteArray();
    mixdownTrack.length = ABin1.length;

    mixdownTrack.position = 0;
    var mixdownTrackPtr:int = CModule.malloc(mixdownTrack.length);
    CModule.writeBytes(mixdownTrackPtr, mixdownTrack.length, mixdownTrack);

    t=getTimer();
    bytelib.summingFloats(TracksPtr, ABin1.length, Tracks.length, mixdownTrackPtr);
    trace("6track summing time : " + (getTimer()-t));

    trace("Final Answer: " + CModule.readFloat(mixdownTrackPtr));
    trace("Final Answer: " + CModule.readFloat(mixdownTrackPtr+4*(l-1)));

    t=getTimer();
    mixdownTrack.position = 0;
    CModule.readBytes(mixdownTrackPtr, mixdownTrack.length, mixdownTrack);
    mixdownTrack.position = 0;
    trace("ByteArray Final : " + mixdownTrack.readFloat());
    mixdownTrack.position = 4*(l-1);
    trace("ByteArray Final : " + mixdownTrack.readFloat());
    trace("time elapsed : " + (getTimer()-t));

    CModule.free(mixdownTrackPtr);
    CModule.free(TracksPtr);
  }

  /**
   * The PlayerKernel implementation will use this function to handle
   * C IO write requests to the file "/dev/tty" (e.g. output from
   * printf will pass through this function). See the ISpecialFile
   * documentation for more information about the arguments and return value.
   */
  public function write(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int {
    var str:String = CModule.readString(bufPtr, nbyte);
    tf.appendText(str);
    trace(str);
    return nbyte;
  }

  /** See ISpecialFile */
  public function read(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int {
    return 0;
  }

  public function fcntl(fd:int, com:int, data:int, errnoPtr:int):int {
    return 0;
  }

  public function ioctl(fd:int, com:int, data:int, errnoPtr:int):int {
    return 0;
  }
}
}