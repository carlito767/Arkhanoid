package rounds;

import kha.Color;

import components.Brick;

typedef RoundData = {
  id:Int,
  backgroundColor:Color,
  ?ballBaseSpeedAdjust:Float,
  ?ballSpeedNormalisationRateAdjust:Float,
  bricks:Array<Brick>,
}
