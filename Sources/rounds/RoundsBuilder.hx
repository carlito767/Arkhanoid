package rounds;

import kha.Assets;

import sprites.Brick;

typedef RawRound = {
  backgroundColor:Int,
  ?ballBaseSpeedAdjust:Float,
  ?ballSpeedNormalisationRateAdjust:Float,
  bricks:Array<String>,
}

class RoundsBuilder {
  public static function rounds() {
    var rounds:Array<RoundDataFactory> = [];

    // Load rounds from JSON files (Assets/round*.json)
    var i = 1;
    while (true) {
      var blob = Assets.blobs.get('round${i}_json');
      if (blob == null) break;
      trace('Loading round $i...');

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

      rounds.push(()->{ return cook(data); });

      i++;
    }

    return rounds;
  }

  static function cook(rawRound:RawRound):RoundData {
    // Bricks
    var bricks:List<Brick> = new List();
    for (y in 0...rawRound.bricks.length) {
      var row = rawRound.bricks[y];
      for (x in 0...row.length) {
        var value = row.charAt(x);
        var color = switch value {
          case 'B': 'blue';
          case 'C': 'cyan';
          case '*': 'gold';
          case 'G': 'green';
          case 'O': 'orange';
          case 'P': 'pink';
          case 'R': 'red';
          case 'S': 'silver';
          case 'W': 'white';
          case 'Y': 'yellow';
          case _: '';
        };
        if (color != '') {
          var image = Assets.images.get('brick_${color}');
          bricks.add({
            image:image,
            x:x * image.width,
            y:y * image.height,
            color:color,
            collisions:0,
          });
        }
      }
    }

    return {
      backgroundColor:rawRound.backgroundColor,
      ballBaseSpeedAdjust:rawRound.ballBaseSpeedAdjust,
      ballSpeedNormalisationRateAdjust:rawRound.ballSpeedNormalisationRateAdjust,
      bricks:bricks
    };
  }
}
