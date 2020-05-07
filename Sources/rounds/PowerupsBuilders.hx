package rounds;

import Random;
import components.Brick;
import components.PowerupType;

class PowerupBuilders {
  static final POWERUP_TYPES = AbstractEnumTools.getValues(PowerupType);

  public static function fullRandom(bricks:Array<Brick>):Void {
    for (brick in bricks) {
      var powerType = Std.random(POWERUP_TYPES.length);
      brick.powerupType = POWERUP_TYPES[powerType];
    }
  }

  public static function round1(bricks:Array<Brick>):Void {
    var p:Array<PowerupType> = [
      Catch, Catch, Catch,
      Expand, Expand, Expand, Expand,
      Life, Life, Life,
      Slow, Slow,
      Laser, Laser, Laser, Laser
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
