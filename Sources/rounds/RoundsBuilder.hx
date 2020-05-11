package rounds;

import kha.Assets;

import components.Brick;
import components.BrickColor;
import components.PowerupsBuilder;
import rounds.PowerupsBuilders;
using AnimationExtension;

class RoundsBuilder {
  public static function rounds():Array<RawRound> {
    var rounds:Array<RawRound> = [];

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

      data.id = id;
      rounds.push(data);

      id++;
    }

    return rounds;
  }

  public static function cook(rawRound:RawRound):Round {
    // Bricks
    var bricks:Array<Brick> = [];
    for (y in 0...rawRound.bricks.length) {
      var row = rawRound.bricks[y];
      for (x in 0...row.length) {
        var value = row.charAt(x);
        var color:Null<BrickColor> = switch value {
          case 'B': Blue;
          case 'C': Cyan;
          case '*': Gold;
          case 'G': Green;
          case 'O': Orange;
          case 'P': Pink;
          case 'R': Red;
          case 'S': Silver;
          case 'W': White;
          case 'Y': Yellow;
          case _: null;
        };
        if (color != null) {
          var name = color.getName().toLowerCase();
          var animation = 'brick_${name}'.loadAnimation(2, -1);
          var image = animation.tick();
          animation.paused = true;
          bricks.push({
            animation:animation,
            image:image,
            x:x * image.width,
            y:y * image.height,
            health:brickHealth(rawRound.id, color),
            value:brickValue(rawRound.id, color),
          });
        }
      }
    }

    // Powerups
    var powerupsBuilder:PowerupsBuilder = switch rawRound.powerupsBuilder {
      case 'round1': PowerupBuilders.round1;
      case 'round2': PowerupBuilders.round2;
      case 'round3': PowerupBuilders.round3;
      case 'round4': PowerupBuilders.round4;
      case 'round5': PowerupBuilders.round5;
      case _: PowerupBuilders.fullRandom;
    }
    powerupsBuilder(bricks);

    return {
      id:rawRound.id,
      backgroundColor:rawRound.backgroundColor,
      ballBaseSpeedAdjust:rawRound.ballBaseSpeedAdjust,
      ballSpeedNormalisationRateAdjust:rawRound.ballSpeedNormalisationRateAdjust,
      bricks:bricks
    };
  }

  static function brickHealth(id:Int, color:BrickColor):Int {
    return switch color {
      case Gold: 0; // indestructable
      case Silver: Math.ceil(id / 8) + 1;
      case _: 1;
    }
  }

  static function brickValue(id:Int, color:BrickColor):Int {
    return switch color {
      case Blue: 100;
      case Cyan: 70;
      case Gold: 0;
      case Green: 80;
      case Orange: 60;
      case Pink: 110;
      case Red: 90;
      case Silver: 50 * id;
      case White: 50;
      case Yellow: 120;
    }
  }
}
