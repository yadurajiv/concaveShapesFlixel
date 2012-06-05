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

 /**
  * Code is heavily influenced by Box2D, Implementation in Flixel Tutorial
  * here - http://flashgamedojo.com/wiki/index.php?title=Box2D,_Implementation_%28Flixel%29
  * also - https://github.com/phmongeau/Box2D-Tutorial
  */
 
package 
{
	import org.flixel.*;
	
	import Box2D.Dynamics.*
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	
	/**
	 * ...
	 * @author Yadu Rajiv
	 */
	public class b2FlxTileBlock extends FlxTileblock 
	{
		private var ratio:Number = 30; //1m : 30px
		
		public var _fixDef:b2FixtureDef; // used to store density, the friction, the body defention and the body
		public var _bodyDef:b2BodyDef; // body def stores position, angle and type of body
		public var _obj:b2Body; // teh body :D lol
		
		private var _world:b2World;
		
		public var _friction:Number = 0.8;
		public var _restitution:Number = 0.3;
		public var _density:Number = 0.7;
		
		public var _type:uint = b2Body.b2_staticBody;
		
		public function b2FlxTileBlock(X:int, Y:int, Width:uint, Height:uint, w:b2World) {
			
			super(X, Y, Width, Height);
			
			_world = w;
		}
		
		public function createBody():void {
			var boxShape:b2PolygonShape = new b2PolygonShape();
			boxShape.SetAsBox((width / 2) / ratio, (height) / 2 / ratio);
			
			_fixDef = new b2FixtureDef();
			_fixDef.density = _density;
			_fixDef.restitution = _restitution;
			_fixDef.friction = _friction;
			_fixDef.shape = boxShape;
			
			_bodyDef = new b2BodyDef();
			_bodyDef.position.Set((x + (width / 2)) / ratio, (y + (height / 2)) / ratio);
			_bodyDef.angle = angle * (Math.PI / 180);
			_bodyDef.type = _type;
			
			_obj = _world.CreateBody(_bodyDef);
			_obj.CreateFixture(_fixDef);
		}
		
	}
	
}