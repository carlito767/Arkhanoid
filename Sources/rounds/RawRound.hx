package rounds;

typedef RawRound = {
  id:Int,
  backgroundColor:Int,
  ?ballBaseSpeedAdjust:Float,
  ?ballSpeedNormalisationRateAdjust:Float,
  bricks:Array<String>,
  powerupsBuilder:String,
}
