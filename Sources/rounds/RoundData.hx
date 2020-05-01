package rounds;

import kha.Color;

import sprites.Brick;

typedef RoundData = {
  backgroundColor:Color,
  ?ballBaseSpeedAdjust:Float,
  ?ballSpeedNormalisationRateAdjust:Float,
  bricks:List<Brick>,
}
