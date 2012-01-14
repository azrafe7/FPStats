package 
{
	import Box2D.Common.b2Settings;
	import net.flashpunk.utils.Input;
	import net.FPStats.FPStats;
	import net.flashpunk.Engine;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.World;
	import net.flashpunk.utils.Key;
	import net.flashpunk.graphics.Text;
	import net.box2fp.Box2DWorld;
	import net.FPStats.Utils;
	
	/**
	 * ...
	 * @author azrafe7
	 */
	[SWF(width = "640", height = "480")]
	public class Main extends Engine 
	{

		private var stats:FPStats;
		
		public function Main():void 
		{
			trace("FP started!");
			super(640, 480, Box2DWorld.DEFAULT_FRAMERATE, true);
			
			FP.screen.scale = 1;
			FP.console.toggleKey = Key.TAB;
			FP.console.enable();
			FP.world = new MyWorld;
		}
		
		override public function init():void 
		{
			trace("FP init!");
			super.init();

			var text:Text = new Text("using Box2DFlash v. " + b2Settings.VERSION, 0, 0, { size:10, color:0xff3060 } );
			var textEntity:Entity = new Entity(FP.screen.width / 2 + 2, 3, text);
			textEntity.layer = -1;
			FP.world.add(textEntity);
			
			stats = new FPStats(10, 30, 150, 70, true, false, true, false);
			stats.VALUES_TEXT_SPACE = 0;
			//stats.fpsGraph.historyAutoExpand = stats.memGraph.historyAutoExpand = true;
			stats.showFpsAverage = true;
			stats.showElapsed = stats.showMemAverage = false;
			stats.showFpsValues = true;
			stats.fpsGraph.showMax = false;
			stats.showMemValues = true;
			FP.stage.addChild(stats);
			//stats.start();
			trace(stats.HEIGHT);
		}
		
		override public function update():void 
		{
			super.update();
			
			
			if (Input.pressed(Key.S)) {
				stats.timer.running ? stats.stop() : stats.start();
			}
			if (Input.pressed(Key.R)) {
				stats.reset();
			}
			if (Input.pressed(Key.C)) {
				stats.updateFrequency = 100 + int(Math.random() * 1500);
			}
			if (Input.pressed(Key.DELETE)) {
				stats.reset();
			}
			if (Input.pressed(Key.W)) {
				stats.WIDTH += 5;
				stats.update();
			}
		}
	}
	
}