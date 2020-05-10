package components;

typedef Brick = {
  > Position,
  animation:Animation,
  image:Image,
  health:Int,
  value:Int,
  ?powerupType:PowerupType,
}
