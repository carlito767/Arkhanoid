package world;

import components.Anchored;
import components.Animation;
import components.Image;
import components.Position;
import components.PowerupType;
import components.Velocity;

typedef Entities = Array<Entity>;

class World {
  // Views
  public inline function all(?kind:Kind):Entities {
    return filter((_)->{ return true; }, kind);
  }

  // Components
  public var anchored:Map<EntityId,Anchored> = new Map();
  public var animations:Map<EntityId,Animation> = new Map();
  public var images:Map<EntityId,Image> = new Map();
  public var positions:Map<EntityId,Position> = new Map();
  public var powerupTypes:Map<EntityId,PowerupType> = new Map();
  public var velocities:Map<EntityId,Velocity> = new Map();

  public var kinds:Map<EntityId,Kind> = new Map();

  // Entities
  var entities:List<EntityId> = new List();
  var idCounter:EntityId = 0;

  public function new() {
  }

  //
  // Views
  //

  public function animatables(?kind:Kind):Entities {
    return filter((e:Entity)->{
      e.animation != null;
    }, kind);
  }

  public function drawables(?kind:Kind):Entities {
    return filter((e:Entity)->{
      e.position != null && e.image != null;
    }, kind);
  }

  public function movables(?kind:Kind):Entities {
    return filter((e:Entity)->{
      e.position != null && e.velocity != null;
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

  public function remove(e:Entity):Void {
    var id = e.id;

    anchored.remove(id);
    animations.remove(id);
    images.remove(id);
    positions.remove(id);
    powerupTypes.remove(id);
    velocities.remove(id);

    kinds.remove(id);

    entities.remove(id);
  }

  public function removeAll(?kind:Kind):Void {
    for (e in all(kind)) remove(e);
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
