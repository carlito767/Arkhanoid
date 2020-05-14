package rounds;

import world.Entity;

interface Round {
  public var id:Int;
  public var backgroundColor:Int;
  public var ballBaseSpeedAdjust:Null<Float>;
  public var ballSpeedNormalisationRateAdjust:Null<Float>;
  public var bricks:Array<String>;
  public function powerupBuilder(bricks:Array<Entity>):Void;
}
