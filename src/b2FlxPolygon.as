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
	import flash.geom.Point;
	import org.flixel.*;
	
	import Box2D.Dynamics.*
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	
	/**
	 * b2FlxPolygon
	 * @author Yadu Rajiv
	 */
	public class b2FlxPolygon extends FlxPolygon
	{
		private var ratio:Number = 30; //1m : 30px
		
		public var _fixDef:b2FixtureDef;
		public var _bodyDef:b2BodyDef;
		public var _obj:b2Body;
		
		private var _world:b2World;
		
		public var _friction:Number = 0.8;
		public var _restitution:Number = 0.2;
		public var _density:Number = 0.7;
		
		public var _type:uint = b2Body.b2_dynamicBody;
		
		public var scaledPoints:Array;
		public var scaledPointsGeom:Array;
		
		private var triangulate:Triangulate = new Triangulate();
		
		public function b2FlxPolygon(X:int, Y:int, Width:uint, Height:uint, Points:Array, w:b2World) {
			
			super(X, Y, Width, Height, Points);
			scaledPoints = new Array();
			scaledPointsGeom = new Array();
			for (var i:int = 0; i < pointsRelativeCn.length; i++) {
				scaledPoints.push(new b2Vec2(pointsRelativeCn[i].x / ratio, pointsRelativeCn[i].y / ratio));
				scaledPointsGeom.push(new Point(pointsRelativeCn[i].x / ratio, pointsRelativeCn[i].y / ratio));
			}
			
			_world = w;
		}
		
		override public function update():void 
		{
			try {
				cx = _obj.GetPosition().x * ratio;
				cy = _obj.GetPosition().y * ratio;
				
				x = (_obj.GetPosition().x * ratio) - width / 2;
				y = (_obj.GetPosition().y * ratio) - height / 2;
				angle = _obj.GetAngle() * (180 / Math.PI);
				super.update();
			} catch (err:Error) {
				trace(err.message);
				kill();
			}
		}
		
		public function createBody():Boolean {
			try {
				
				var complex:Boolean = false;
				var boxShape:b2PolygonShape = new b2PolygonShape();
				
				if (Bourke.ClockWise(this.scaledPoints) == Bourke.CLOCKWISE) {
					this.scaledPoints.reverse();
					this.scaledPointsGeom.reverse();
					this.pointsRelative.reverse();
					this.pointsRelativeCn.reverse();
				}
				
				if (Bourke.Convex(this.scaledPoints) == Bourke.CONCAVE) {
					complex = true;
				}
				
				
				_bodyDef = new b2BodyDef();
				_bodyDef.position.Set((x + (width / 2)) / ratio, (y + (height / 2)) / ratio);
				_bodyDef.angle = angle * (Math.PI / 180);
				_bodyDef.type = _type;
				
				_obj = _world.CreateBody(_bodyDef);
				
				
				if (complex) {
					
					var tmp:Array = null;
					//if (hull != null) {
						tmp = triangulate.process(this.scaledPoints);	
					//}
						
					
					if(tmp !=null) {
					
						for (var i:uint = 0; i < tmp.length; i = i + 3) {
							boxShape = new b2PolygonShape();
							 boxShape.SetAsArray(new Array(tmp[i], tmp[i+1],tmp[i+2]));
							//boxShape.SetAsArray(new Array(new b2Vec2(tmp[i].x, tmp[i].y), new b2Vec2(tmp[i+1].x, tmp[i+1].y), new b2Vec2(tmp[i+2].x, tmp[i+2].y)));
							
							_fixDef = new b2FixtureDef();
							_fixDef.density = _density;
							_fixDef.restitution = _restitution;
							_fixDef.friction = _friction;
							_fixDef.shape = boxShape;
							
							_obj.CreateFixture(_fixDef);
						} 
					} else {
						throw(new Error("null from Triangulate.process()"));
					}
					
				} else {
					
					boxShape.SetAsArray(this.scaledPoints,this.scaledPoints.length)
					
					_fixDef = new b2FixtureDef();
					_fixDef.density = _density;
					_fixDef.restitution = _restitution;
					_fixDef.friction = _friction;
					_fixDef.shape = boxShape;
					
					_obj.CreateFixture(_fixDef);
				}
				
				
				return true;
			} catch (err:Error) {
				trace(err.message);
				_world.DestroyBody(_obj);
				kill();
				return false
			}
			
			return false;
		}
		
	}
	
}