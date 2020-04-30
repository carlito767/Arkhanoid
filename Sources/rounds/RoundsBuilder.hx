package rounds;

import kha.Assets;
import kha.Color;

import sprites.Brick;

typedef RawRound = {
  backgroundColor:Color,
  bricks:Array<String>,
}

class RoundsBuilder {
  static final ROUNDS:Array<Void->RawRound> = [
    round1,
    round2,
    round3,
    round4,
    round5,
  ];

  public static function rounds() {
    var rounds:Array<RoundDataFactory> = [];
    for (round in ROUNDS) {
      rounds.push(()->{ return cook(round()); });
    }
    return rounds;
  }

  static function cook(rawRound:RawRound):RoundData {
    // Background color
    var backgroundColor:Color = rawRound.backgroundColor;

    // Bricks
    var bricks:List<Brick> = new List();
    var y = 0;
    for (row in rawRound.bricks) {
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
      y++;
    }

    return {
      backgroundColor:backgroundColor,
      bricks:bricks
    };
  }

  static function round1():RawRound {
    return {
      backgroundColor:Color.fromBytes(0, 0, 128),
      bricks:[
        '',
        '',
        '',
        '',
        'SSSSSSSSSSSSS',
        'RRRRRRRRRRRRR',
        'YYYYYYYYYYYYY',
        'BBBBBBBBBBBBB',
        'PPPPPPPPPPPPP',
        'GGGGGGGGGGGGG',
      ],
    };
  }

  static function round2():RawRound {
    return {
      backgroundColor:Color.fromBytes(0, 128, 0),
      bricks:[
        '',
        '',
        'W',
        'WO',
        'WOC',
        'WOCG',
        'WOCGR',
        'WOCGRB',
        'WOCGRBP',
        'WOCGRBPY',
        'WOCGRBPYW',
        'WOCGRBPYWO',
        'WOCGRBPYWOC',
        'WOCGRBPYWOCG',
        'SSSSSSSSSSSSR',
      ],
    };
  }

  static function round3():RawRound {
    return {
      backgroundColor:Color.fromBytes(0, 0, 128),
      bricks:[
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
      ],
    };
  }

  static function round4():RawRound {
    return {
      backgroundColor:Color.fromBytes(128, 0, 0),
      bricks:[
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
      ],
    };
  }

  static function round5():RawRound {
    return {
      backgroundColor:Color.fromBytes(0, 0, 128),
      bricks:[
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
      ],
    };
  }
}
