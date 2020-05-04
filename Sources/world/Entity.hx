package world;

import components.Anchored;
import components.Animation;
import components.Image;
import components.Position;
import components.PowerupType;
import components.Velocity;

class Entity {
  @:isVar public var anchored(get,set):Null<Anchored>;
  inline function get_anchored() { return world.anchored.get(id); }
  inline function set_anchored(value) { world.anchored.set(id, value); return anchored = value; }

  @:isVar public var animation(get,set):Null<Animation>;
  inline function get_animation() { return world.animations.get(id); }
  inline function set_animation(value) { world.animations.set(id, value); return animation = value; }

  @:isVar public var image(get,set):Null<Image>;
  inline function get_image() { return world.images.get(id); }
  inline function set_image(value) { world.images.set(id, value); return image = value; }

  @:isVar public var position(get,set):Null<Position>;
  inline function get_position() { return world.positions.get(id); }
  inline function set_position(value) { world.positions.set(id, value); return position = value; }

  @:isVar public var powerupType(get,set):Null<PowerupType>;
  inline function get_powerupType() { return world.powerupTypes.get(id); }
  inline function set_powerupType(value) { world.powerupTypes.set(id, value); return powerupType = value; }

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
