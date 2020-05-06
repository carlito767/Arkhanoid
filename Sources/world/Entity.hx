package world;

import components.Anchor;
import components.Animation;
import components.BounceStrategy;
import components.Image;
import components.Position;
import components.PowerupType;
import components.Velocity;

// TODO: build with macros
class Entity {
  @:isVar public var anchor(get,set):Null<Anchor>;
  inline function get_anchor() { return world.anchors.get(id); }
  inline function set_anchor(value) { world.anchors.set(id, value); return anchor = value; }

  public inline function anchorTo(e:Entity, ?offset:Position):Void {
    if (offset == null) offset = {x:0.0, y:0.0};
    anchor = {e:e, offset:offset};
  }

  @:isVar public var animation(get,set):Null<Animation>;
  inline function get_animation() { return world.animations.get(id); }
  inline function set_animation(value) { world.animations.set(id, value); return animation = value; }

  @:isVar public var bounceStrategy(get,set):Null<BounceStrategy>;
  inline function get_bounceStrategy() { return world.bounceStrategies.get(id); }
  inline function set_bounceStrategy(value) { world.bounceStrategies.set(id, value); return bounceStrategy = value; }

  @:isVar public var image(get,set):Null<Image>;
  inline function get_image() { return world.images.get(id); }
  inline function set_image(value) { world.images.set(id, value); return image = value; }

  @:isVar public var life(get,set):Null<Int>;
  inline function get_life() { return world.lives.get(id); }
  inline function set_life(value) { world.lives.set(id, value); return life = value; }

  @:isVar public var position(get,set):Null<Position>;
  inline function get_position() { return world.positions.get(id); }
  inline function set_position(value) { world.positions.set(id, value); return position = value; }

  @:isVar public var powerupType(get,set):Null<PowerupType>;
  inline function get_powerupType() { return world.powerupTypes.get(id); }
  inline function set_powerupType(value) { world.powerupTypes.set(id, value); return powerupType = value; }

  @:isVar public var value(get,set):Null<Int>;
  inline function get_value() { return world.values.get(id); }
  inline function set_value(v) { world.values.set(id, v); return value = v; }

  @:isVar public var velocity(get,set):Null<Velocity>;
  inline function get_velocity() { return world.velocities.get(id); }
  inline function set_velocity(value) { world.velocities.set(id, value); return velocity = value; }

  public var kind(get,null):Null<Kind>;
  inline function get_kind() { return world.kinds.get(id); }

  public var id(default,null):EntityId;

  var world:World;

  public function new(world:World, id:EntityId) {
    this.world = world;
    this.id = id;
  }
}
