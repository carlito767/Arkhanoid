package rounds;

import kha.Assets;

import sprites.Brick;
import sprites.BrickColor;
import sprites.PowerupType;

typedef RawRound = {
  backgroundColor:Int,
  ?ballBaseSpeedAdjust:Float,
  ?ballSpeedNormalisationRateAdjust:Float,
  bricks:Array<String>,
}

class RoundsBuilder {
  static final POWERUP_TYPES = AbstractEnumTools.getValues(PowerupType);

  public static function rounds() {
    var rounds:Array<RoundDataFactory> = [];

    // Load rounds from JSON files (Assets/round*.json)
    var id = 1;
    while (true) {
      var blob = Assets.blobs.get('round${id}_json');
      if (blob == null) break;
      trace('Loading round $id...');

      // TODO: check data
      var data = null;
      try {
        data = haxe.Json.parse(blob.toString());
      }
      catch (e:Dynamic) {
        trace('Parsing error: $e');
        break;
      }
      if (data == null) break;

      rounds.push(()->{ return cook(id, data); });

      id++;
    }

    return rounds;
  }

  static function cook(id:Int, rawRound:RawRound):RoundData {
    // Bricks
    var bricks:List<Brick> = new List();
    for (y in 0...rawRound.bricks.length) {
      var row = rawRound.bricks[y];
      for (x in 0...row.length) {
        var value = row.charAt(x);
        var color:Null<BrickColor> = switch value {
          case 'B': blue;
          case 'C': cyan;
          case '*': gold;
          case 'G': green;
          case 'O': orange;
          case 'P': pink;
          case 'R': red;
          case 'S': silver;
          case 'W': white;
          case 'Y': yellow;
          case _: null;
        };
        if (color != null) {
          var image = Assets.images.get('brick_${color}');
          bricks.add({
            image:image,
            x:x * image.width,
            y:y * image.height,
            color:color,
            life:brickLife(id, color),
            value:brickValue(id, color),
          });
        }
      }
    }

    // Powerups
    // TODO: use a powerup strategy
    for (brick in bricks) {
      var powerType = Math.floor(Math.random() * POWERUP_TYPES.length);
      brick.powerupType = POWERUP_TYPES[powerType];
    }

    return {
      backgroundColor:rawRound.backgroundColor,
      ballBaseSpeedAdjust:rawRound.ballBaseSpeedAdjust,
      ballSpeedNormalisationRateAdjust:rawRound.ballSpeedNormalisationRateAdjust,
      bricks:bricks
    };
  }

  static function brickLife(id:Int, color:BrickColor):Int {
    return switch color {
      case gold: 0; // indestructable
      case silver: Math.ceil(id / 8) + 1;
      case _: 1;
    }
  }

  static function brickValue(id:Int, color:BrickColor):Int {
    return switch color {
      case blue: 100;
      case cyan: 70;
      case gold: 0;
      case green: 80;
      case orange: 60;
      case pink: 110;
      case red: 90;
      case silver: 50 * id;
      case white: 50;
      case yellow: 120;
    }
  }
}
