package  
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2Body;
	import flash.system.System;
	import net.box2fp.Box2DEntity;
	import net.box2fp.Box2DWorld;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Key;
	import net.flashpunk.utils.Input;
	
	/**
	 * ...
	 * @author azrafe7
	 */
	public class MyWorld extends Box2DWorld 
	{
		public var wall:MyWall;
		public var entity:MyEntity;
		
		public function MyWorld()
		{
			super();
			setGravity(new b2Vec2(0, 10));
			FP.console.log("TAB - toggle console | D - toggle debug | DEL - clear stage | G - call GC");
		}
		
		override public function begin():void
		{
			debug = false;
			//doDebug();
			wall = new MyWall(FP.screen.width*.5, 420, 640, 79);
			add(wall);	// add floor entity
		}

		override public function update():void
		{
			super.update();
			
			// add a new entity every now and then (or on mouse click)
			if (!paused && (Math.random() > 0.3 || Input.mousePressed))
			{
				if (Input.mousePressed) {
					add(new MyEntity(Input.mouseX, Input.mouseY));
				} else {
					add(new MyEntity(Math.random() * 600 + 20, Math.random() * 200));
				}
			}
			
			// press ESC to exit debug player
			if (Input.check(Key.ESCAPE)) {
				System.exit(1);
			}
			// press D to toggle debug mode
			if (Input.pressed(Key.D)) {
				debug = !debug;
			}
			// press DELETE to clear all objects
			if (Input.pressed(Key.DELETE)) {
				var arr:Array = new Array();
				getType("object", arr);
				for each (var obj:Box2DEntity in arr)
				{
					obj.remove();
				}
			}
			// press G to force a call to Garbage Collector
			if (Input.pressed(Key.G)) {
				trace("GC called");
				System.gc();
			}
			// press P to pause
			if (Input.pressed(Key.P)) {
				if (paused) {
					unpause();
				} else {
					pause();
				}
			}

			if (Input.check(Key.LEFT)) {
				wall.body.SetAwake(true);
				wall.body.SetAngularVelocity(wall.body.GetAngularVelocity() - .31);
			} else if (Input.check(Key.RIGHT)) {
				wall.body.SetAwake(true);
				wall.body.SetAngularVelocity(wall.body.GetAngularVelocity() + .31);
			}
			wall.body.SetAngularVelocity(wall.body.GetAngularVelocity() * .96);
		} 	
	}

}