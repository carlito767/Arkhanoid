package sprites;

typedef Brick = {
  > Sprite,
  color:BrickColor,
  life:Int,
  value:Int,
  ?powerupType:PowerupType,
}
