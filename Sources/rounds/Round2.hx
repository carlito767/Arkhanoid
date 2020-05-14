package rounds;

import Random;
import components.EnemyType;
import components.PowerupType;
import world.Entity;

class Round2 implements Round {
  public var id:Int = 2;
  public var backgroundColor:Int = 0xff008000;

  public var ballBaseSpeedAdjust:Null<Float> = null;
  public var ballSpeedNormalisationRateAdjust:Null<Float> = null;

  public var bricks:Array<String> = [
    '',
    '',
    'W',
    'WO',
    'WOC',
    'WOCG',
    'WOCGR',
    'WOCGRB',
    'WOCGRBP',
    'WOCGRBPY',
    'WOCGRBPYW',
    'WOCGRBPYWO',
    'WOCGRBPYWOC',
    'WOCGRBPYWOCG',
    'SSSSSSSSSSSSR',
  ];

  public var enemiesType:EnemyType = Pyradok;
  public var enemiesNumber:Int = 3;

  public function new() {
  }

  public function powerupBuilder(bricks:Array<Entity>):Void {
    // Create slow ball and catch for the bottom row (except red brick),
    // given the lack of space beneath
    var pBottom:Array<PowerupType> = [ Catch, Catch, Slow, Slow ];
    var rBottom = Random.sample(pBottom.length, bricks.length - 1, bricks.length - 13);
    for (i in 0...rBottom.length) {
      bricks[rBottom[i]].powerupType = pBottom[i];
    }
    // Red brick
    bricks[bricks.length - 1].powerupType = Slow;
    // Powerups for the other rows
    var p:Array<PowerupType> = [
      Catch, Catch,
      Duplicate, Duplicate,
      Expand, Expand, Expand, Expand,
      Laser, Laser, Laser, Laser,
      Life, Life, Life,
      Slow, Slow,
    ];
    var r = Random.sample(p.length, bricks.length - 13);
    for (i in 0...r.length) {
      bricks[r[i]].powerupType = p[i];
    }
  }
}
