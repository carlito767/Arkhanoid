package world;

import components.Anchor;
import components.Animation;
import components.BounceStrategy;
import components.Image;
import components.Position;
import components.PowerupType;

class Entity {
  @:isVar public var anchor(get,set):Null<Anchor>;
  inline function get_anchor() { return world.anchor.get(id); }
  inline function set_anchor(value) { world.anchor.set(id, value); return anchor = value; }

  public inline function anchorTo(e:Entity):Void {
    var offset:Position = {x:0.0, y:0.0};
    if (hasPosition() && e.hasPosition() && e.image != null) {
      var middle = e.image.width * 0.5;
      offset.x = x - e.x - middle;
    }
    x = null;
    y = null;
    anchor = {e:e, offset:offset};
  }

  public inline function anchorPosition():Null<Position> {
    if (anchor == null || image == null) return null;
    if (!anchor.e.hasPosition() || anchor.e.image == null) return null;

    var offset = anchor.offset;
    var middle = anchor.e.image.width * 0.5;
    var dx = Math.min(Math.abs(offset.x), middle);
    var x = anchor.e.x + middle + ((offset.x > 0) ? dx : -dx);
    var y = anchor.e.y - image.height;

    return {x:x, y:y};
  }

  // Position
  inline public function hasPosition():Bool { return x != null && y != null; };
  @:isVar public var x(get,set):Null<Float>;
  inline function get_x() { return world.x.get(id); }
  inline function set_x(value) { world.x.set(id, value); return x = value; }
  @:isVar public var y(get,set):Null<Float>;
  inline function get_y() { return world.y.get(id); }
  inline function set_y(value) { world.y.set(id, value); return y = value; }

  // Velocity
  inline public function hasVelocity():Bool { return speed != null && angle != null; };
  @:isVar public var speed(get,set):Null<Float>;
  inline function get_speed() { return world.speed.get(id); }
  inline function set_speed(value) { world.speed.set(id, value); return speed = value; }
  @:isVar public var angle(get,set):Null<Float>;
  inline function get_angle() { return world.angle.get(id); }
  inline function set_angle(value) { world.angle.set(id, value); return angle = value; }

  @:isVar public var animation(get,set):Null<Animation>;
  inline function get_animation() { return world.animation.get(id); }
  inline function set_animation(value) { world.animation.set(id, value); return animation = value; }

  @:isVar public var bounceStrategy(get,set):Null<BounceStrategy>;
  inline function get_bounceStrategy() { return world.bounceStrategy.get(id); }
  inline function set_bounceStrategy(value) { world.bounceStrategy.set(id, value); return bounceStrategy = value; }

  @:isVar public var health(get,set):Null<Int>;
  inline function get_health() { return world.health.get(id); }
  inline function set_health(value) { world.health.set(id, value); return health = value; }

  @:isVar public var image(get,set):Null<Image>;
  inline function get_image() { return world.image.get(id); }
  inline function set_image(value) { world.image.set(id, value); return image = value; }

  @:isVar public var powerupType(get,set):Null<PowerupType>;
  inline function get_powerupType() { return world.powerupType.get(id); }
  inline function set_powerupType(value) { world.powerupType.set(id, value); return powerupType = value; }

  @:isVar public var value(get,set):Null<Int>;
  inline function get_value() { return world.value.get(id); }
  inline function set_value(v) { world.value.set(id, v); return value = v; }

  public var kind(get,null):Null<Kind>;
  inline function get_kind() { return world.kinds.get(id); }

  public var id(default,null):EntityId;

  var world:World;

  public function new(world:World, id:EntityId) {
    this.world = world;
    this.id = id;
  }

  public inline function remove():Void {
    world.remove(id);
  }

  public inline function reset():Void {
    world.reset(id);
  }
}
