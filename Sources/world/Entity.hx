package world;

import components.Anchor;
import components.Animation;
import components.BounceStrategy;
import components.Travel;
import components.Image;
import components.PowerupType;

typedef Entity = {
  id:EntityId,
  kind:Kind,

  // Position
  ?x:Float,
  ?y:Float,

  // Velocity
  ?speed:Float,
  ?angle:Float,

  ?anchor:Anchor,
  ?animation:Animation,
  ?bounceStrategy:BounceStrategy,
  ?health:Int,
  ?image:Image,
  ?pendingAnimations:Array<Animation>,
  ?powerupType:PowerupType,
  ?travel:Travel,
  ?value:Int,
}
