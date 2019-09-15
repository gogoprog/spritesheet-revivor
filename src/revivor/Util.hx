package revivor;

class Util {
    static public function getColorString(r:Int, g:Int, b:Int, a:Int):String {
        return "rgba(" + r + "," + g + "," + b + "," + a/255 + ")";
    }
}
