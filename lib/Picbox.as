package lib
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.containers.VBox;
	import mx.controls.Alert;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.effects.Fade;
	import mx.effects.Rotate;
	import mx.events.CloseEvent;
	import mx.events.EffectEvent;
	import mx.formatters.NumberFormatter;
	
	public class Picbox extends VBox
	{
		// define UI controls
		public var img_pic:Image;
		public var canvas_for_pic:Canvas;
		public var lb_filename:Label;
		public var lb_filesize:Label;
		public var lb_uploading:Label;
		public var hbox_button_container:HBox;
		public var btn_left_rotate:Button;
		public var btn_right_rotate:Button;
		public var btn_del:Button;
		public var effect_rotate:Rotate;
		public var effect_fade:Fade;
		
		// define varibles
		private var _filename:String;
		private var _filesize:String;
		private var _rotation:int;
		private var _filedata:FileReference;
		private var _byteArray:ByteArray;
		private var _loader:Loader;
		private var _isLoadTooMuchFiles:Boolean;
		
		// icons
		[Embed(source='images/rotating_image_left.jpg')]
		public static var rotate_left:Class;
		
		[Embed(source='images/rotating_image_right.jpg')]
		public static var rotate_right:Class;
		
		[Embed(source='images/image_delete.jpg')]
		public static var image_delete:Class;
		
		public function Picbox(fileReference:FileReference, isLoadTooMuchFiles:Boolean)
		{
			// init all controls
			img_pic = new Image();
			canvas_for_pic = new Canvas();
			lb_filename = new Label();
			lb_filesize = new Label();
			lb_uploading = new Label();
			hbox_button_container = new HBox();
		 	btn_left_rotate = new Button();
			btn_right_rotate = new Button();
			btn_del = new Button(); 
			effect_rotate = new Rotate();
			effect_fade = new Fade();
			
			this.setStyle("showEffect", effect_fade);
			this.setStyle("hideEffect", effect_fade);
			
			// init data
			_filedata = fileReference;
			_filename = _filedata.name;
		  	_filesize = getFileSizeString(_filedata.size);
			
			// load photo and show it when there is not load too much files into flex
			_isLoadTooMuchFiles = isLoadTooMuchFiles;
			if(isLoadTooMuchFiles) {
				// if loaded too much files, stop set thumbnail for picture
        		// img_pic.source = "images/default_photo.gif";
        	} else {
        		_filedata.addEventListener(Event.COMPLETE, fileLoadComplete);
    			_filedata.load();
        	}
		  	_rotation = 0;
		  	
			// set propertis for them
			this.width = 80;
			this.height = 130;
			this.setStyle("borderStyle", "solid");
			this.setStyle("borderThickness", 1);
			this.setStyle("borderColor", "#eeeeee");
			this.setStyle("verticalGap", 0);
			this.setStyle("horizontalAlign", "center");
			
			canvas_for_pic.width = 78;
			canvas_for_pic.height = 59;
			canvas_for_pic.horizontalScrollPolicy = "off";
			canvas_for_pic.verticalScrollPolicy = "off";
			
			img_pic.width = 80;
			img_pic.height = 60;
			
			lb_filename.width = 70;
			lb_filename.setStyle("textAlign", "center");
			lb_filename.text = _filename;
			
			lb_filesize.width = 70;
			lb_filesize.setStyle("textAlign", "center");
			lb_filesize.text = _filesize;
			
			lb_uploading.width = 78;
			lb_uploading.setStyle("fontWeight", "bold");
			lb_uploading.setStyle("textAlign", "center");
			lb_uploading.text = "Uploading...";
			
			hbox_button_container.width = 78;
			hbox_button_container.setStyle("horizontalAlign", "center");
			hbox_button_container.setStyle("horizontalGap", 3);
			
			btn_left_rotate.width = 20;
			btn_left_rotate.addEventListener(MouseEvent.CLICK, leftRotate);
			
			btn_right_rotate.width = 20;
			btn_right_rotate.addEventListener(MouseEvent.CLICK, rightRotate);
			
			btn_del.width = 20;
			btn_del.addEventListener(MouseEvent.CLICK, removePicbox);
			
			// do not load the button picture if load too much files.
			if(!isLoadTooMuchFiles) {
				btn_left_rotate.setStyle('icon',rotate_left);
				btn_right_rotate.setStyle('icon',rotate_right);
				btn_del.setStyle('icon',image_delete);
			}
			
			// add controls to self container
			this.canvas_for_pic.addChild(this.img_pic);
			this.addChild(this.canvas_for_pic);
			
			this.addChild(this.lb_filename);
			this.addChild(this.lb_filesize);
			
			this.hbox_button_container.addChild(this.btn_left_rotate);
			this.hbox_button_container.addChild(this.btn_right_rotate);
			this.hbox_button_container.addChild(this.btn_del);
			this.addChild(this.hbox_button_container);
		}
		
		public function removePicbox(event:Event):void {
			mx.controls.Alert.show("Are you sure?","Delete File",3, this, function(event:CloseEvent):void {
				if (event.detail == Alert.YES) {
					fadePicbox();
	            }
			});
		}
		
		public function fadePicbox():void {
			effect_fade.addEventListener(EffectEvent.EFFECT_END, function(event:Event):void {
        		parent.removeChildAt(parent.getChildIndex(event.target.target));
			});
			
			this.visible = false;
		}
		
		public function rightRotate(event:Event):void {
			effect_rotate.stop();
			
			var rotation_from:int = _rotation;
			var rotation_to:int = _rotation += 90;
			
			effect_rotate.angleFrom = rotation_from;
			effect_rotate.angleTo = rotation_to;
			effect_rotate.target = this.img_pic;
			
			effect_rotate.play();
		}
		
		public function leftRotate(event:Event):void {
			effect_rotate.stop();
			
			var rotation_from:int = _rotation;
			var rotation_to:int = _rotation -= 90;
			
			effect_rotate.angleFrom = rotation_from;
			effect_rotate.angleTo = rotation_to;
			effect_rotate.target = this.img_pic;
			
			effect_rotate.play();
		}
		
		public function fileLoadComplete(event:Event):void {
        	_byteArray = event.currentTarget.data;
        	_loader = new Loader();
        	_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function():void {
        		img_pic.source =  Bitmap(_loader.content);
        	});
        	
        	if(_byteArray) {
        		_loader.loadBytes(_byteArray);
        	}
        }
        
        // unload the loaded fileReference, free the memory.
        public function unloadLoadedFile():void {
        	this.img_pic.source = null;
        	this.canvas_for_pic.removeAllChildren();
        	
        	btn_left_rotate.setStyle('icon', null);
			btn_right_rotate.setStyle('icon', null);
			btn_del.setStyle('icon', null);
        }
        
        /*
        * get a file size string and show it at lb_filesize lable
        */
        public function getFileSizeString(size:Number):String {
        	var sizeNumber:Number;
        	var sizeUnit:String;
        	
        	// to judge and select the unit, and get the right file size number
        	if(size < 1024){
        		sizeUnit = "Byte";
        		sizeNumber = size;
        	} else if(size > 1024 && size < 1024*1024) {
        		sizeUnit = "KB";
        		sizeNumber = size/1024;            		
        	} else if(size > 1024*1024) {
        		sizeUnit = "MB";
        		sizeNumber = size/(1024*1024);
        	}
        	
        	var nf:NumberFormatter=new NumberFormatter();
			nf.precision=2;
        	return (nf.format(sizeNumber)).toString() + " " + sizeUnit;
        }
        
        public function getFileReference():FileReference {
        	return this._filedata;
        }
        
        public function cancelUploading():void {
        	this._filedata.cancel();
        }
        
        public function upload(url:URLRequest):void {
        	this.width = 83;
        	this.height = 128;
        	this.setStyle("borderStyle", "solid");
			this.setStyle("borderThickness", 3);
			this.setStyle("borderColor", "#cccccc");
			
        	// maybe we can do something on uploading
        	showUploadingLabel();
        	this._filedata.upload(url);
        }
        
        public function setEnableAllButtons(x:Boolean):void {
        	this.btn_del.enabled = x;
        	this.btn_left_rotate.enabled = x;
        	this.btn_right_rotate.enabled = x;
        }
        
        public function showUploadingLabel():void {
        	//Alert.show(this.getChildIndex(hbox_button_container).toString());
        	//Alert.show(this.toString());
        	//this.removeChildAt(this.getChildIndex(hbox_button_container));
        	//this.addChild(lb_uploading);
        }
        
        /*
        * property setting zone
        */
        public function get size():Number {
			return _filedata.size;
		}
		
		public function get filename():String {
			return _filename;
		}
		
		public function get filesize():String {
			return getFileSizeString(_filedata.size);
		}
		
		public function get rotationDegrees():int {
        	return this._rotation;
        }
        
	}
}