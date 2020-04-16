import kha.Assets;

class Animation {
  public static function fromSequence(id:String):AnimationData {
    var sequence:Array<String> = [];
    var count = 1;
    while (true) {
      var spriteId = '${id}_${count}';
      if (Assets.images.get(spriteId) == null) {
        break;
      }
      sequence.push(spriteId);
      count++;
    }
    return {
      sequence:sequence,
      current:1,
    }
  }

  public static function next(anim:AnimationData) {
    anim.current = (anim.current + 1) % anim.sequence.length;
  }
}
