package world;

import components.Position;

class EntityExtension {
  public static function anchorPosition(e:Entity):Null<Position> {
    if (e.anchor == null || e.image == null) return null;
    if (!hasPosition(e.anchor.e) || e.anchor.e.image == null) return null;

    var offset = e.anchor.offset;
    var middle = e.anchor.e.image.width * 0.5;
    var dx = Math.min(Math.abs(offset.x), middle);
    var x = e.anchor.e.x + middle + ((offset.x > 0) ? dx : -dx);
    var y = e.anchor.e.y - e.image.height;

    return {x:x, y:y};
  }

  public static function anchorTo(e:Entity, anchor:Entity):Void {
    var offset:Position = {x:0.0, y:0.0};
    if (hasPosition(e) && hasPosition(anchor) && anchor.image != null) {
      var middle = anchor.image.width * 0.5;
      offset.x = e.x - anchor.x - middle;
    }
    e.x = null;
    e.y = null;
    e.anchor = {e:anchor, offset:offset};
  }

  public static function hasPosition(e:Entity):Bool {
    return e.x != null && e.y != null;
  }

  public static function hasVelocity(e:Entity):Bool {
    return e.speed != null && e.angle != null;
  }

  public static function reset(e:Entity):Void {
    // Position
    e.x = null;
    e.y = null;

    // Velocity
    e.speed = null;
    e.angle = null;

    e.anchor = null;
    e.animation = null;
    e.bounceStrategy = null;
    e.health = null;
    e.image = null;
    e.powerupType = null;
    e.value = null;
  }
}
