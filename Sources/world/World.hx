package world;

import components.Anchor;
import components.Animation;
import components.BounceStrategy;
import components.Image;
import components.PowerupType;

typedef Entities = Array<Entity>;

class World {
  // Views
  public inline function all(?kind:Kind):Entities {
    return filter((_)->{ return true; }, kind);
  }

  // Components
  // Position
  public var x:Map<EntityId,Float> = new Map();
  public var y:Map<EntityId,Float> = new Map();

  // Velocity
  public var speed:Map<EntityId,Float> = new Map();
  public var angle:Map<EntityId,Float> = new Map();

  public var anchor:Map<EntityId,Anchor> = new Map();
  public var animation:Map<EntityId,Animation> = new Map();
  public var bounceStrategy:Map<EntityId,BounceStrategy> = new Map();
  public var health:Map<EntityId,Int> = new Map();
  public var image:Map<EntityId,Image> = new Map();
  public var powerupType:Map<EntityId,PowerupType> = new Map();
  public var value:Map<EntityId,Int> = new Map();

  public var kinds:Map<EntityId,Kind> = new Map();

  // Entities
  var entities:List<EntityId> = new List();
  var idCounter:EntityId = 0;

  public function new() {
  }

  //
  // Views
  //

  public function anchoredTo(?anchor:Entity):Entities {
    return filter((e)->{
      e.anchor != null && (anchor == null || e.anchor.e.id == anchor.id);
    });
  }

  public function animatables(?kind:Kind):Entities {
    return filter((e)->{
      e.animation != null;
    }, kind);
  }

  public function collidables(?kind:Kind):Entities {
    return filter((e)->{
      e.hasPosition() && e.image != null && e.anchor == null;
    }, kind);
  }

  public function drawables(?kind:Kind):Entities {
    return filter((e)->{
      e.hasPosition() && e.image != null && e.anchor == null;
    }, kind);
  }

  public function movables(?kind:Kind):Entities {
    return filter((e)->{
      e.hasPosition() && e.hasVelocity() && e.anchor == null;
    }, kind);
  }

  //
  // Entities
  //

  public function add(?kind:Kind):Entity {
    var id = ++idCounter;
    entities.add(id);

    if (kind != null) {
      kinds.set(id, kind);
    }

    return new Entity(this, id);
  }

  public function remove(id:EntityId):Void {
    reset(id);
    kinds.remove(id);
    entities.remove(id);
  }

  public function removeAll(?kind:Kind):Void {
    for (e in all(kind)) remove(e.id);
  }

  public function reset(id:EntityId):Void {
    // Position
    x.remove(id);
    y.remove(id);

    // Velocity
    speed.remove(id);
    angle.remove(id);

    anchor.remove(id);
    animation.remove(id);
    bounceStrategy.remove(id);
    health.remove(id);
    image.remove(id);
    powerupType.remove(id);
    value.remove(id);
  }

  function filter(f:Entity->Bool, ?kind:Kind):Entities {
    var v:Entities = [];
    for (id in entities) {
      if (kind == null || kinds.get(id) == kind) {
        var e = new Entity(this, id);
        if (f(e)) v.push(e);
      }
    }
    return v;
  }
}
