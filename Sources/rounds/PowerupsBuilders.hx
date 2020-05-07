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

  public static function round2(bricks:Array<Brick>):Void {
    // Create slow ball and catch for the bottom row (except red brick),
    // given the lack of space beneath
    var pBottom:Array<PowerupType> = [ Catch, Catch, Slow, Slow ];
    Random.shuffle(pBottom);
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
    Random.shuffle(p);
    var r = Random.sample(p.length, bricks.length - 13);
    for (i in 0...r.length) {
      bricks[r[i]].powerupType = p[i];
    }
  }

  public static function round3(bricks:Array<Brick>):Void {
    bricks[31].powerupType = Duplicate;
    bricks[56].powerupType = Duplicate;
    bricks[60].powerupType = Life;
    bricks[80].powerupType = Catch;
    bricks[84].powerupType = Life;
    bricks[101].powerupType = Life;
  }
}
