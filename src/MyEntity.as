package
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import net.box2fp.Box2DWorld;
	import net.flashpunk.graphics.PreRotation;
	
	import net.box2fp.Box2DEntity;
	import net.box2fp.Box2DShapeBuilder;
	import net.box2fp.graphics.SuperGraphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.FP;
	
	public class MyEntity extends Box2DEntity
	{
		private var i:Image;
		private	var sprite:Class;
		private var cnt:int = 0;
		
		public function MyEntity(x:Number, y:Number, b2BodyType:uint = 2 /*b2Body.b2_dynamicBody*/)
		{
			super(x, y, 0, 0, b2BodyType);
			
			// select random sprite
			switch (FP.rand(3)) {
				case 0: 
					sprite = CRATE;
					break;
				case 1: 
					sprite = SPIKE;
					break;
				case 2: 
					sprite = BALL;
					break;
				default:
			}
			type = "object";
			i = new Image(sprite);
			(graphic as SuperGraphiclist).add(i);

			// adjust entity's size to reflect sprite's size (used in buildShapes function)
			width = i.width;
			height = i.height;
			
			// center origin coords of both entity and image
			i.centerOrigin();
			centerOrigin();
		}
		
		override public function buildShapes(friction:Number, density:Number, restitution:Number, group:int, category:int, collmask:int):void
		{
			// create body for entity
			if (sprite == CRATE) {
				Box2DShapeBuilder.buildRectangle(body, width / (2.0 * box2dworld.scale), height / (2.0 * box2dworld.scale), 0.3, 1, 0.1);
			} else {
				Box2DShapeBuilder.buildCircle(body, (width-1) / (2.0 * box2dworld.scale), 0.3, 1, 0.5);
			}
		}
		
		override public function added():void
		{
			super.added();
			// set random velocities
			body.SetAngularVelocity(Math.random() * 2 - 4);
			body.GetDefinition().linearVelocity.Set(Math.random() * 5 - 2.5, -Math.random() * 3);
		}
		
		override public function update():void {
			// remove entity when falls offscreen
			if (this.y > FP.screen.height || (cnt > 10 && body.GetType() == b2Body.b2_dynamicBody)) {
				remove();
				//box2dworld.remove(this);
			}
			cnt += 1;
			super.update();
		}
		
		[Embed(source = "woodcrate.png")]
		public static const CRATE:Class;

		[Embed(source = "spikeball.png")]
		public static const SPIKE:Class;
		
		[Embed(source = "ball.png")]
		public static const BALL:Class;
	}
}