import kha.Assets;
import kha.Image;

class AnimationManager {
  public static function load(id:String):Animation {
    var sequence = new List<Image>();
    while (true) {
      var image = Assets.images.get('${id}_${sequence.length + 1}');
      if (image == null) {
        break;
      }
      sequence.add(image);
    }
    if (sequence.length == 0) {
      throw 'No image for "$id"';
    }
    return {
      sequence:sequence,
    }
  }

  public static function cycle(id:String):Animation {
    var animation = load(id);
    animation.cycle = true;
    return animation;
  }

  public static function next(animation:Animation):Null<Image> {
    var image = animation.sequence.pop();
    if (image != null && animation.cycle == true) {
      animation.sequence.add(image);
    }
    return image;
  }

  public static function current(animation:Animation):Null<Image> {
    return animation.sequence.first();
  }

  public static function reverse(animation:Animation):Animation {
    var sequence = new List<Image>();
    for (image in animation.sequence) {
      sequence.push(image);
    }
    return {
      sequence:sequence,
    }
  }

  public static function chain(animation1:Animation, animation2:Animation):Animation {
    var sequence = new List<Image>();
    for (image in animation1.sequence) {
      sequence.add(image);
    }
    for (image in animation2.sequence) {
      sequence.add(image);
    }
    return {
      sequence:sequence,
    }
  }
}
