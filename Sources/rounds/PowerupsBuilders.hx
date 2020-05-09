package rounds;

import Random;
import components.Brick;
import components.PowerupType;

typedef Bricks = Array<Brick>;

class PowerupBuilders {
  static final POWERUP_TYPES = Type.allEnums(PowerupType);

  public static function fullPowerup(bricks:Bricks, powerupType:PowerupType):Void {
    for (brick in bricks) {
      brick.powerupType = powerupType;
    }
  }

  public static function fullPowerupCatch(bricks:Bricks):Void { fullPowerup(bricks, Catch); }
  public static function fullPowerupDuplicate(bricks:Bricks):Void { fullPowerup(bricks, Duplicate); }
  public static function fullPowerupExpand(bricks:Bricks):Void { fullPowerup(bricks, Expand); }
  public static function fullPowerupLaser(bricks:Bricks):Void { fullPowerup(bricks, Laser); }
  public static function fullPowerupLife(bricks:Bricks):Void { fullPowerup(bricks, Life); }
  public static function fullPowerupSlow(bricks:Bricks):Void { fullPowerup(bricks, Slow); }

  public static function fullRandom(bricks:Bricks):Void {
    for (brick in bricks) {
      var powerupType = Std.random(POWERUP_TYPES.length);
      brick.powerupType = POWERUP_TYPES[powerupType];
    }
  }

  public static function round1(bricks:Bricks):Void {
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

  public static function round2(bricks:Bricks):Void {
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

  public static function round3(bricks:Bricks):Void {
    bricks[31].powerupType = Duplicate;
    bricks[56].powerupType = Duplicate;
    bricks[60].powerupType = Life;
    bricks[80].powerupType = Catch;
    bricks[84].powerupType = Life;
    bricks[101].powerupType = Life;
  }

  public static function round4(bricks:Bricks):Void {
    bricks[6].powerupType = Duplicate;
    bricks[10].powerupType = Duplicate;
    bricks[31].powerupType = Catch;
    bricks[43].powerupType = Life;
    bricks[57].powerupType = Laser;
    bricks[78].powerupType = Life;
    bricks[102].powerupType = Laser;
    bricks[115].powerupType = Expand;
  }

  public static function round5(bricks:Bricks):Void {
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
