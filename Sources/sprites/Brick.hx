package sprites;

import components.BrickColor;
import components.Life;
import components.PowerupType;
import components.Value;

typedef Brick = {
  > Sprite,
  color:BrickColor,
  life:Life,
  value:Value,
  ?powerupType:PowerupType,
}
