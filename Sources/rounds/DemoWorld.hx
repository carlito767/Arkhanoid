package rounds;

import world.Entity;

class DemoWorld implements Round {
  public var id:Int = 0;
  public var backgroundColor:Int = 0xff000000;

  public var ballBaseSpeedAdjust:Null<Float> = null;
  public var ballSpeedNormalisationRateAdjust:Null<Float> = null;

  public var bricks:Array<String> = [
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '*************',
  ];

  public function new() {
  }

  public function powerupBuilder(bricks:Array<Entity>):Void {
  }
}
