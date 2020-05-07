package rounds;

import components.Brick;
import components.PowerupType;

class PowerupBuilders {
  static final POWERUP_TYPES = AbstractEnumTools.getValues(PowerupType);

  public static function fullRandom(bricks:List<Brick>):Void {
    for (brick in bricks) {
      var powerType = Std.random(POWERUP_TYPES.length);
      brick.powerupType = POWERUP_TYPES[powerType];
    }
  }
}
