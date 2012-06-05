/**
Copyright (c) 2011 Yadu Rajiv

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
 */
   
/**
 * Some parts of this project uses code written by others, where mentioned.
 */

package 
{
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.InterpolationMethod;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import org.flixel.FlxSprite;
	
	/**
	 * FlxPolygon
	 * @author Yadu Rajiv
	 */
	public class FlxPolygon extends FlxSprite 
	{
		public var points:Array;
		
		public var pointsRelative:Array;
		
		public var pointsRelativeCn:Array;
		
		private var _currentInk:uint;
		private var _drawAlpha:Number;
		private var _borderSize:Number;
		private var _borderColor:uint
		
		private var _redraw:Boolean;
		
		private var _fillGradType:String;
		private var _fillGradColors:Array;
		private var _fillGradAlphas:Array;
		private var _fillGradRatios:Array;
		
		public var cx:Number;
		public var cy:Number;
		
		/**
		 * 
		 * Constructor for FlxPolygon, creates a draws a polygon
		 * @param	X position of the Polygon
		 * @param	Y position of the Polygon
		 * @param	W width of the polygon
		 * @param	H height of the polygon
		 * @param	Points an array of objects of the type flash.geom.Point, where each point is an absolute position of each vertex in the world and *NOT* relative to the X and Y of the object itself
		 */
		public function FlxPolygon(X:Number,Y:Number,W:Number,H:Number,Points:Array) {
			
			super(X, Y);
			width = W;
			height = H;
			cx = x + (W / 2);
			cy = y +  (H / 2);
			
			
			/**
			 * stores points in an array as Points locally
			 */
			points = new Array();
			pointsRelative = new Array();
			pointsRelativeCn = new Array();
			
			for (var i:int = 0; i < Points.length; i++) {
				
				points.push(new Point(Points[i].x,Points[i].y));
				pointsRelative.push(new Point(Points[i].x,Points[i].y));
				pointsRelativeCn.push(new Point(Points[i].x,Points[i].y));

				
				pointsRelative[i].x = pointsRelative[i].x - X;
				pointsRelative[i].y = pointsRelative[i].y - Y;
				pointsRelativeCn[i].x = pointsRelativeCn[i].x - cx;
				pointsRelativeCn[i].y = pointsRelativeCn[i].y - cy;
				
				
				trace("--[" + i + "]----");
				trace("Points[i]: "+ Points[i] );
				trace("points[i]: " + points[i] );
				trace("pointsRelative[i]: " + X +"/"+Y+" - " + pointsRelative[i] );
				trace("pointsRelativeCn[i]: " + cx +"/"+cy+" - " + pointsRelativeCn[i] );
				
			}
			
			/**
			 * default line and fill settings
			 */
			setFormat();
			
		
			/**
			 * not used
			 */
			_fillGradType = GradientType.RADIAL;
			_fillGradColors = [0x222222, 0x000000];
			_fillGradAlphas = [1, 1];
			_fillGradRatios = [127, 255];
			
			/**
			 * redraw is a flag set when we want to redraw the polygon again to the sprites BitmapData object
			 */
			_redraw = true;
						
		}
		
		/**
		 * * sets redraw to true
		 * @param	b Boolean if you want to redraw or not. True by default
		 */
		public function setRedrawFlag(b:Boolean = true):void {
			this._redraw = b;
		}
		
		public function setFormat(Ink:uint = 0x000000, BorderSize:int = 4, BorderColor:uint = 0x333333):void {
			_currentInk = Ink;
			_borderSize = BorderSize;
			_borderColor = BorderColor;
		}
		
		override public function update():void 
		{
			super.update();
			
			if(this._redraw) {
				
				/**
				 * Create a new Sprite to draw on
				 */
				var _gfx:Sprite = new Sprite();

				/**
				 * Srart the fill
				 */
				_gfx.graphics.beginFill(_currentInk, alpha);
				//_gfx.graphics.beginGradientFill(_fillGradType, _fillGradColors, _fillGradAlphas, _fillGradRatios, null, SpreadMethod.PAD, InterpolationMethod.RGB, 0.5);
				_gfx.graphics.lineStyle(_borderSize, _borderColor, alpha);
				_gfx.graphics.moveTo( pointsRelative[0].x - _borderSize/2, pointsRelative[0].y - _borderSize/2);
				
				for (var i:int = 1; i < pointsRelative.length; i++) {
					_gfx.graphics.lineTo( pointsRelative[i].x - _borderSize/2, pointsRelative[i].y - _borderSize/2);
				}
				
				_gfx.graphics.endFill();
				
				var tmpBMP:BitmapData = new BitmapData(_gfx.width, _gfx.height,true,0x00ffffff);
				var transMat:Matrix = new Matrix();
				transMat.translate(Math.abs(_gfx.getRect(_gfx).x) + _borderSize/2, Math.abs(_gfx.getRect(_gfx).y) + _borderSize/2);
				tmpBMP.draw(_gfx, transMat);
				
				var tmpBMP2:BitmapData = new BitmapData(_gfx.width,_gfx.height,true,0x00ffffff);
				tmpBMP2.copyPixels(tmpBMP, new Rectangle(0,0, _gfx.width, _gfx.height), new Point());
				
				this.pixels = tmpBMP2;
				this.refreshHulls();
				
				this._redraw = false;
			}
		}
		
		public static function FindCenter(p:Array):Point {
			var sumx:Number = 0;
			var sumy:Number = 0;
			var n:Number = p.length;
			
			for (var i:int = 0; i < n; i++) {
				sumx = sumx + p[i].x;
				sumy = sumy + p[i].y;
			}
			
			return new Point(sumx / n, sumy / n);
		}
		
	}
	
}