package rounds;

import components.EnemyType;
import world.Entity;

class Round3 implements Round {
  public var id:Int = 3;
  public var backgroundColor:Int = 0xff000080;

  public var ballBaseSpeedAdjust:Null<Float> = -2.0;
  public var ballSpeedNormalisationRateAdjust:Null<Float> = 0.05;

  public var bricks:Array<String> = [
    '',
    '',
    '',
    'GGGGGGGGGGGGG',
    '',
    'WWW**********',
    '',
    'RRRRRRRRRRRRR',
    '',
    '**********WWW',
    '',
    'PPPPPPPPPPPPP',
    '',
    'BBB**********',
    '',
    'CCCCCCCCCCCCC',
    '',
    '**********CCC',
  ];

  public var enemiesType:EnemyType = TriSphere;
  public var enemiesNumber:Int = 3;

  public function new() {
  }

  public function powerupBuilder(bricks:Array<Entity>):Void {
    bricks[31].powerupType = Duplicate;
    bricks[56].powerupType = Duplicate;
    bricks[60].powerupType = Life;
    bricks[80].powerupType = Catch;
    bricks[84].powerupType = Life;
    bricks[101].powerupType = Life;
  }
}
