package rounds;

import kha.Color;

import components.Brick;

typedef RoundData = {
  backgroundColor:Color,
  ?ballBaseSpeedAdjust:Float,
  ?ballSpeedNormalisationRateAdjust:Float,
  bricks:List<Brick>,
}
