package rounds;

import Random;
import components.PowerupType;
import world.Entity;

class Round1 implements Round {
  public var id:Int = 1;
  public var backgroundColor:Int = 0xff000080;

  public var ballBaseSpeedAdjust:Null<Float> = null;
  public var ballSpeedNormalisationRateAdjust:Null<Float> = null;

  public var bricks:Array<String> = [
    '',
    '',
    '',
    '',
    'SSSSSSSSSSSSS',
    'RRRRRRRRRRRRR',
    'YYYYYYYYYYYYY',
    'BBBBBBBBBBBBB',
    'PPPPPPPPPPPPP',
    'GGGGGGGGGGGGG',
  ];

  public function new() {
  }

  public function powerupBuilder(bricks:Array<Entity>):Void {
    var p:Array<PowerupType> = [
      Catch, Catch, Catch,
      Expand, Expand, Expand, Expand,
      Laser, Laser, Laser, Laser,
      Life, Life, Life,
      Slow, Slow
    ];
    Random.shuffle(p);
    // 4 powerups in the bottom row
    var r = Random.sample(p.length - 4, bricks.length - 13);
    r = r.concat(Random.sample(4, bricks.length, bricks.length - 13));
    for (i in 0...r.length) {
      bricks[r[i]].powerupType = p[i];
    }
  }
}
