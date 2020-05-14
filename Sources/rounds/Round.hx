package rounds;

import components.EnemyType;
import world.Entity;

interface Round {
  public var id:Int;
  public var backgroundColor:Int;
  public var ballBaseSpeedAdjust:Null<Float>;
  public var ballSpeedNormalisationRateAdjust:Null<Float>;
  public var bricks:Array<String>;
  public var enemiesType:EnemyType;
  public var enemiesNumber:Int;
  public function powerupBuilder(bricks:Array<Entity>):Void;
}
