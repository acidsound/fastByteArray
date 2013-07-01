package {

import flash.display.Sprite;
import flash.display.StageAlign;
import flash.events.Event;
import flash.text.TextField;

public class FlasccExam extends Sprite {
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
    /* Ready to Start */
  }

}
}