package rounds;

import Random;
import components.PowerupType;
import world.Entity;

class Round5 implements Round {
  public var id:Int = 5;
  public var backgroundColor:Int = 0xff000080;

  public var ballBaseSpeedAdjust:Null<Float> = null;
  public var ballSpeedNormalisationRateAdjust:Null<Float> = null;

  public var bricks:Array<String> = [
    '',
    '   Y     Y',
    '   Y     Y',
    '    Y   Y',
    '    Y   Y',
    '   SSSSSSS',
    '   SSSSSSS',
    '  SSRSSSRSS',
    '  SSRSSSRSS',
    ' SSSSSSSSSSS',
    ' SSSSSSSSSSS',
    ' SSSSSSSSSSS',
    ' S SSSSSSS S',
    ' S S     S S',
    ' S S     S S',
    '    SS SS',
    '    SS SS',
  ];

  public function new() {
  }

  public function powerupBuilder(bricks:Array<Entity>):Void {
    var p:Array<PowerupType> = [
      Catch, Catch, Catch,
      Duplicate, Duplicate,
      Expand, Expand,
      Laser, Laser, Laser,
      Slow, Slow
    ];
    var r = Random.sample(p.length, bricks.length);
    for (i in 0...r.length) {
      bricks[r[i]].powerupType = p[i];
    }
  }
}
