package components;

typedef Brick = {
  > Position,
  animation:Animation,
  image:Image,
  life:Int,
  value:Int,
  ?powerupType:PowerupType,
}
