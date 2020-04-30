import kha.Storage;

class Settings {
  public static function read<T:{var v:Int;}>(filename:String, defaults:T):T {
    var file = Storage.namedFile(filename);
    var data:T = file.readObject();
    if (data != null && data.v == defaults.v) {
      return data;
    }
    return defaults;
  }

  public static function write<T:{var v:Int;}>(filename:String, settings:T):Void {
    var file = Storage.namedFile(filename);
    file.writeObject(settings);
  }
}
