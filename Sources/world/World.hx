package world;

using world.EntityExtension;

typedef Entities = Array<Entity>;

class World {
  public var kinds:Map<EntityId,Kind> = new Map();

  var entities:Map<EntityId,Entity> = new Map();
  var entitiesIds:List<EntityId> = new List();
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

  public inline function all(?kind:Kind):Entities {
    return filter((_)->{ return true; }, kind);
  }

  inline function filter(f:Entity->Bool, ?kind:Kind):Entities {
    var v:Entities = [];
    for (id in entitiesIds) {
      if (kind == null || kinds.get(id) == kind) {
        var e = entities.get(id);
        if (f(e)) v.push(e);
      }
    }
    return v;
  }

  //
  // Entities
  //

  public function add(?kind:Kind):Entity {
    var id = ++idCounter;
    entitiesIds.add(id);

    if (kind != null) {
      kinds.set(id, kind);
    }

    var e:Entity = { id:id, kind:kind };
    entities.set(id, e);

    return e;
  }

  public function remove(e:Entity):Void {
    kinds.remove(e.id);
    entities.remove(e.id);
    entitiesIds.remove(e.id);
  }

  public function removeAll(?kind:Kind):Void {
    for (e in all(kind)) remove(e);
  }
}
