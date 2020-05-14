package rounds;

import components.EnemyType;
import world.Entity;

class Round4 implements Round {
  public var id:Int = 4;
  public var backgroundColor:Int = 0xff800000;

  public var ballBaseSpeedAdjust:Null<Float> = null;
  public var ballSpeedNormalisationRateAdjust:Null<Float> = null;

  public var bricks:Array<String> = [
    '',
    '',
    '',
    ' OCGSB YWOCG',
    ' CGSBP WOCGS',
    ' GSBPY OCGSB',
    ' SBPYW CGSBP',
    ' BPYWO GSBPY',
    ' PYWOC SBPYW',
    ' YWOCG BPYWO',
    ' WOCGS PYWOC',
    ' OCGSB YWOCG',
    ' CGSBP WOCGS',
    ' GSBPY OCGSB',
    ' SBPYW CGSBP',
    ' BPYWO GSBPY',
    ' PYWOC SBPYW',
  ];

  public var enemiesType:EnemyType = Opopo;
  public var enemiesNumber:Int = 3;

  public function new() {
  }

  public function powerupBuilder(bricks:Array<Entity>):Void {
    bricks[6].powerupType = Duplicate;
    bricks[10].powerupType = Duplicate;
    bricks[31].powerupType = Catch;
    bricks[43].powerupType = Life;
    bricks[57].powerupType = Laser;
    bricks[78].powerupType = Life;
    bricks[102].powerupType = Laser;
    bricks[115].powerupType = Expand;
  }
}
