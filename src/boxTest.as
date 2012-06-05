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
	import flash.display.Sprite;
	import flash.geom.Point;
	import org.flixel.*;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	
	/**
	 * ...
	 * @author Yadu Rajiv
	 */
	public class boxTest extends FlxState 
	{
		[Embed(source = "../data/tile.png")] private var atile:Class;
		
		public var _world:b2World;
		private var box:b2FlxSprite;
		
		private var _tmpPoints:Array;
		
		private var _mouseLastX:Number;
		private var _mouseLastY:Number;
		
		private var _mouseStartX:Number;
		private var _mouseStartY:Number;
		
		private var _endX:Number;
		private var _endY:Number;
		
		private var _mouseLastXTmp:Number;
		private var _mouseLastYTmp:Number;
		
		private var _mouseStartXTmp:Number;
		private var _mouseStartYTmp:Number;
		
		private var _mouseDown:Boolean;
		
		private var _gfxTmp:Sprite;
		
		private var _polyWidth:Number = 0;
		private var _polyHeight:Number = 0;
		
		private var _currentInk:uint;
		private var _drawAlpha:Number;
        private var _borderColor:uint;
        private var _borderSize:uint;
		
		private var _phyObjects:FlxGroup;
		private var _objPoints:Array;
		
		private var _pixel_dist:Number = 20;
		
		private var _dbgSprite:Sprite = new Sprite();
		
		
		override public function create():void 
		{
			//FlxG.showBounds = true;
			setupWorld();
			
			
						/**
			 * Show mouse cursor
			 */
			FlxG.mouse.show();
			
			/**
			 * Drawing settings
			 */
			_currentInk = 0x000000;
			_drawAlpha = 1;
			_borderColor = 0x333333;
			_borderSize = 4;
			
			/**
			 * A group that holds all our FlxPolyPhysics objects.
			 */
			_phyObjects = new FlxGroup();
			add(_phyObjects);
			
			
			
			_dbgSprite = new Sprite();
			addChild(_dbgSprite);
			
			var debugDraw:b2DebugDraw = new b2DebugDraw();
			debugDraw.SetSprite(_dbgSprite);
			debugDraw.SetDrawScale(30.0);
			debugDraw.SetFillAlpha(0.3);
			debugDraw.SetLineThickness(1.0);
			debugDraw.SetFlags(b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit | b2DebugDraw.e_centerOfMassBit);
			_world.SetDebugDraw(debugDraw);
			
		}
		
		override public function update():void 
		{
			_world.Step(FlxG.elapsed, 10, 10);
			_world.ClearForces();
			if(FlxG.showBounds) {
				_world.DrawDebugData();
			}
			
			if (FlxG.mouse.justReleased()) {
				/*
				var tmp:b2FlxSprite = new b2FlxSprite(mouseX, mouseY, 32 ,32, _world);
				tmp.angle = Math.floor(FlxU.random() * 355);
				tmp.createBody();
				tmp.loadGraphic(atile, false, false, 32, 32);
				*/
				
				/* 
				_tmpPoints = new Array();
				_tmpPoints.push(new Point(FlxG.mouse.x , FlxG.mouse.y ));
				_tmpPoints.push(new Point(FlxG.mouse.x + 50, FlxG.mouse.y));
				_tmpPoints.push(new Point(FlxG.mouse.x + 30, FlxG.mouse.y + 120));
				_tmpPoints.push(new Point(FlxG.mouse.x , FlxG.mouse.y + 30));
				
				
				var tmp:b2FlxPolygon = new b2FlxPolygon(FlxG.mouse.x, FlxG.mouse.y,50,120,_tmpPoints, _world);
				//tmp.angle = Math.floor(FlxU.random() * 355);
				tmp.createBody();
				//tmp.loadGraphic(atile, false, false, 32, 32);
				tmp.alpha = 0.5;
				add(tmp);
				 */
			}
			
			

/**
			 * The mouse was just pressed, handle it
			 */
			if (FlxG.mouse.justPressed()) {
				
				/**
				 * we stop the screen from slowing to a stop like it
				 * usually does with lerp defaulting at 1.5
				 */
				//FlxG.followLerp = 0;
				
				/**
				 * _endX/Y keeps changing
				 * _mouseStartX/Y is not needed anymore?
				 * _mouseLastX/Y is used to store the last mouse position where we plotted a position.
				 * All of them are world coords and not screen coords
				 */
				_polyWidth = _endX = _mouseStartX = _mouseLastX = FlxG.mouse.x;
				_polyHeight = _endY = _mouseStartY = _mouseLastY = FlxG.mouse.y;
				
				/**
				 * used by _gfxTmp to plot a drawing on screen
				 * using a sprite. They are local screen coords and not
				 * world coords, they are used to just draw on the fly
				 * and be discarded.
				 */
				_mouseStartXTmp = _mouseLastXTmp = FlxG.mouse.screenX;
				_mouseStartYTmp = _mouseLastYTmp = FlxG.mouse.screenY;
				
				/**
				 * flag mouse down
				 */
				_mouseDown = true
				
				/**
				 * createa a new sprite to do a temp on screen drawing
				 */
				_gfxTmp = new Sprite();
				
				/**
				 * line style start to draw and set position of cursor to 
				 * current screen x and y.
				 */
				_gfxTmp.graphics.beginFill(_currentInk, _drawAlpha);
				_gfxTmp.graphics.lineStyle(_borderSize, _borderColor, _drawAlpha);
				_gfxTmp.graphics.moveTo(_mouseStartXTmp, _mouseStartYTmp);
				
				/**
				 * re-create the array to store actual screen cords for FlxPolygon and
				 * the first x and y are pushed in as a flash.geom.Point
				 */
				_objPoints = new Array();
				_objPoints.push(new Point(_mouseLastX, _mouseLastY));
				
				/**
				 * add temp sprite to screen for everyone to see
				 */
				addChild(_gfxTmp);
				
				/**
				 * or not..
				 */
				//_gfxTmp.visible = false;

			}
			
			
			/**
			 * The mouse is down, handle it.
			 */
			if (_mouseDown) {
				
				/**
				 * Code taken from example given by Emanuele Feronato
				 * http://www.emanueleferonato.com/2009/12/29/way-of-an-idea-box2d-prototype/#more-2131
				 */
				var dist_x:int=FlxG.mouse.screenX -_mouseLastXTmp;
				var dist_y:int = FlxG.mouse.screenY -_mouseLastYTmp;
				
				/**
				 * we calculate the distance from our last point to our current
				 * position, and if it is bigger than the limit we imposed at
				 * 'pixel_dist = 20'(20pixels) then plot to the current x and y
				 */
				if (dist_x*dist_x+dist_y*dist_y>_pixel_dist*_pixel_dist) {
					
					/**
					 * plot line using current x and y
					 */
					_gfxTmp.graphics.lineTo(FlxG.mouse.screenX, FlxG.mouse.screenY);
					
					/**
					 * push position, actual position in the world and not screen position,
					 * to an array to be used to create an FlxPolygon
					 */
					_objPoints.push(new Point(FlxG.mouse.x, FlxG.mouse.y));
					
					/**
					 * saving last mouse position
					 */
					_mouseLastXTmp = FlxG.mouse.screenX
					_mouseLastYTmp = FlxG.mouse.screenY;
					
					if (FlxG.mouse.x < 0 && _polyWidth <=0) {
						if(_polyWidth < FlxG.mouse.x) {
							_polyWidth = FlxG.mouse.x;
						}
					} else {
						if(_polyWidth < FlxG.mouse.x) {
							_polyWidth = FlxG.mouse.x;
						}
					}
					
					if (FlxG.mouse.y < 0 && _polyHeight <=0) {
						if(_polyHeight < FlxG.mouse.y) {
							_polyHeight = FlxG.mouse.y;
						}
					} else { 
						if(_polyHeight < FlxG.mouse.y) {
							_polyHeight = FlxG.mouse.y;
						}
					}
					
					/**
					 * your actual endx and y are going to be somewhere else other
					 * than where you actually started, if you move your mouse up
					 * or to the back from your actual starting point. so you need
					 * to change them and store them to find out the actual x and y 
					 * of your object
					 */
					if (_endX > FlxG.mouse.x) {
						_endX =  FlxG.mouse.x;
					}
					if (_endY > FlxG.mouse.y) {
						_endY = FlxG.mouse.y;
					}
				}
				
			}
			
			/**
			 * Mouse key press was just released, handle it
			 */
			if (FlxG.mouse.justReleased()) {
				
				/**
				 * we had set mouse down as true..
				 */
				if (_mouseDown) {
					_mouseDown = false
					
					/**
					 * finish drawing the graphics
					 */
					_gfxTmp.graphics.endFill();
					
					_polyWidth = FlxU.abs(_polyWidth - _endX) + _borderSize;
					_polyHeight = FlxU.abs(_polyHeight - _endY)  + _borderSize;
					
					trace("w: " + _polyWidth);
					trace("h: " + _polyHeight);
					
					
					/**
					 * create a new FlxPolygon and pass the poly data to it
					 */
					var tmp:b2FlxPolygon = new b2FlxPolygon(_endX -_borderSize/2, _endY -_borderSize/2, _polyWidth, _polyHeight, _objPoints, _world);
					//tmp.angle = Math.floor(FlxU.random() * 355);
					tmp.createBody();
					add(tmp);
					
					/**
					 * Remove temporary sprite drawn on screen
					 */
					removeChild(_gfxTmp);
					
					/**
					 * Since we are done drawing we put the lerp back
					 */
					//FlxG.followLerp = 1.5;
				}
			}

			/**
			 * Extra mouse down work
			 */
			if (!FlxG.mouse.pressed()) {
				
				/**
				 * If the space key was not held down, then
				 * our follow FlxSprite follows the mouse(x only),
				 * and our camera follows the sprite.
				 */
				if (!FlxG.keys.pressed("SPACE")) {
					//_follow.x = FlxG.mouse.x;
				}
				
				/**
				 * D key toggles debug draw
				 */
				if (FlxG.keys.justPressed("D")) {
					if (FlxG.showBounds) {
						FlxG.showBounds = false;
						_dbgSprite.visible = false;
						//_follow.visible = false;
					} else {
						FlxG.showBounds = true;
						_dbgSprite.visible = true;
						//_follow.visible = true;
					}

				}
			}
			
			
			super.update();
		}
		
		private function setupWorld():void {
			
			FlxG.showBounds = true;
			
			FlxG.mouse.show();
			
			bgColor = 0xffffffff;

			var gravity:b2Vec2 = new b2Vec2(0, 9.8);
			_world = new b2World(gravity, true)
			
			var floor:b2FlxTileBlock = new b2FlxTileBlock(0, 400, 640, 32, _world);
			floor.createBody();
			floor.loadGraphic(atile);			
			//floor.visible = false;
			add(floor);
			
		}
		
	}
	
}