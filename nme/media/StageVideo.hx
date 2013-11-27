package nme.media;

#if (cpp||neko)

import nme.events.EventDispatcher;
import nme.Vector;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.net.NetStream;
import nme.display.Stage;
import nme.Loader;

class StageVideo extends EventDispatcher
{
   public var colorSpaces(get_colorSpaces,null) : Vector<String>;
   public var depth : Int;
   public var videoHeight(default,null) : Int;
   public var videoWidth(default,null) : Int;

   public var viewPort(get_viewPort, set_viewPort) : Rectangle;
   public var pan(get_pan,set_pan) : Point;
   public var zoom(get_zoom,set_zoom) : Point;

   inline static var PAUSE = 0;
   inline static var RESUME = 1;
   inline static var TOGGLE = 2;

   var nmeHandle:Dynamic;
   var nmePan:Point;
   var nmeZoom:Point;
   var nmeViewport:Rectangle;
   var nmeNetStream:NetStream;
   var nmeStage:Stage;

   public function new(inStage:Stage)
   {
      super();
      nmeStage = inStage;
      depth = 0;
      nmePan = new Point(0,0);
      nmeZoom = new Point(1,1);
      videoWidth = 0;
      videoHeight = 0;
      nmeViewport = new Rectangle(0,0,0,0);
   }

   function get_colorSpaces()
   {
      var colorSpaces = new Vector<String>();
      colorSpaces.push("BT.709");
      return colorSpaces;
   }

   // public function attachAVStream(avStream : AVStream) : Void { }

   public function attachNetStream(inNetStream : nme.net.NetStream) : Void
   {
      if (nmeNetStream!=null)
         nmeNetStream.nmeAttachedVideo = null;
      nmeNetStream = inNetStream;
      if (nmeNetStream!=null)
      {
         nmeNetStream.nmeAttachedVideo = this;
         nmeCreate();
      }
      else
      {
         nmeDestroy();
      }
   }
   // public function attachCamera(theCamera : Camera) : Void { }

   function get_pan() { return nmePan.clone(); }
   function set_pan(inPan:Point) : Point
   {
      nmePan = inPan.clone();
      if (nmeHandle!=null)
         nme_sv_pan(nmeHandle, inPan.x, inPan.y);
         
      return inPan;
   }

   function get_zoom() { return nmeZoom.clone(); }
   function set_zoom(inZoom:Point) : Point
   {
      nmeZoom = inZoom.clone();

      if (nmeHandle!=null)
         nme_sv_zoom(nmeHandle, nmeZoom.x, nmeZoom.y);

      return inZoom;
   }

   function get_viewPort() { return nmeViewport.clone(); }
   function set_viewPort(inVp:Rectangle) : Rectangle
   {
      nmeViewport= inVp.clone();
      if (nmeHandle!=null)
         nme_sv_viewport(nmeHandle, inVp.x, inVp.y, inVp.width, inVp.height );
      return inVp;
   }


   // You can use the NetStream API to call this like in flash, or you can just call them directly.

   public function nmeCreate()
   {
      if (nmeHandle==null)
        nmeHandle = nme_sv_create(nmeStage.nmeHandle,this);
      return nmeHandle!=null;
   }

   public function nmeDestroy()
   {
      if (nmeNetStream!=null && nmeNetStream.nmeAttachedVideo!=null)
         nmeNetStream.nmeAttachedVideo = null;
      nmeNetStream = null;
      
      if (nmeHandle!=null)
        nme_sv_destroy(nmeHandle);

      nmeHandle = null;
   }

   public function nmeGetTime():Float
   {
      if (nmeHandle==null)
         return 0;
      return nme_sv_get_time(nmeHandle);
   }

   public function nmeSeek(inTime:Float) : Void
   {
      if (nmeHandle==null)
         return;
      nme_sv_seek(nmeHandle,inTime);
   }

   public function nmePlay(inUrl:String, inStart:Float=0, inLength:Float=0) : Void
   {
      if (nmeHandle==null)
         nmeCreate();
      if (nmeHandle==null)
        return;

      nme_sv_play(nmeHandle,inUrl, inStart, inLength);
   }

   public function nmePause()
   {
      if (nmeHandle!=null)
        nme_sv_action(nmeHandle,PAUSE);
   }

   public function nmeTogglePause()
   {
      if (nmeHandle!=null)
        nme_sv_action(nmeHandle,TOGGLE);
   }

   public function nmeResume()
   {
      if (nmeHandle!=null)
        nme_sv_action(nmeHandle,RESUME);
   }



   private static var nme_sv_create = Loader.load("nme_sv_create", 2);
   private static var nme_sv_destroy = Loader.load("nme_sv_destroy", 1);
   private static var nme_sv_action = Loader.load("nme_sv_action", 2);
   private static var nme_sv_play = Loader.load("nme_sv_play", 4);
   private static var nme_sv_seek = Loader.load("nme_sv_seek", 2);
   private static var nme_sv_get_time = Loader.load("nme_sv_get_time", 1);
   private static var nme_sv_viewport = Loader.load("nme_sv_viewport", 5);
   private static var nme_sv_pan = Loader.load("nme_sv_pan", 3);
   private static var nme_sv_zoom = Loader.load("nme_sv_zoom", 3);
}

#else
typedef StageVideo = flash.net.StageVideo;
#end
