package
{
	import Box2D.Dynamics.b2Body;
	import Box2D.Dynamics.Joints.b2RevoluteJoint;
	import Box2D.Dynamics.Joints.b2RevoluteJointDef;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import net.box2fp.Box2DEntity;
	import net.box2fp.Box2DShapeBuilder;
	import net.flashpunk.graphics.Backdrop;
	import net.flashpunk.graphics.Canvas;
	import net.flashpunk.graphics.Image;
	import net.box2fp.graphics.SuperGraphiclist;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.TiledImage;
	
	public class MyWall extends Box2DEntity
	{
		public var image:TiledImage;		// useful 'cause already supports rotating via angle property
		
		public function MyWall(x:Number, y:Number, w:uint, h:uint)
		{
			super(x, y, w, h, b2Body.b2_kinematicBody);
			type = "wall";
			
			image = new TiledImage(FP.getBitmap(SPRITE), w, h);
			image.smooth = true;
			
			(graphic as SuperGraphiclist).add(image);
			image.x = image.y = 0;
			layer = -1;
			
			// center origin so that rotation is performed around the center
			image.centerOrigin();
			centerOrigin();
		}
		
		override public function buildShapes(friction:Number, density:Number, restitution:Number, group:int, category:int, collmask:int):void
		{
			Box2DShapeBuilder.buildRectangle(body, width / (2.0 * box2dworld.scale), height / (2.0 * box2dworld.scale), 0.3, 1, 0.6);
		}

		[Embed(source="wall.png")]
		private var SPRITE:Class;
		
	}
}