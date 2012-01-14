package  net.FPStats
{
	import flash.events.Event;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import net.FPStats.Utils;
	import flash.text.AntiAliasType;
	import flash.utils.*;
	import flash.display.BlendMode;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.system.System;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	/**
	 * A class for monitoring FPS and memory usage showing values on graphs in real time. 
	 * Integrates with - and uses - FlashPunk 1.6.
	 * <p>
	 * 
	 * • Simple usage example:
	 * </p><p>
	 * Override the <code>init()</code> method of your Engine subclass (typically your Main class) and add these lines in it:
	 * 
	 * <listing>
	 * var stats:FPStats = new FPStats();  // create a new instance
	 * FP.stage.add(stats);                // add it to the stage
	 * stats.start();                      // start sampling and showing values
	 * </listing>
	 * or, in one line:
	 * <listing>
	 * FP.stage.add(new FPStats(10, 30, 0, 0, true));        // add it to the stage at 10,30 with default dimensions and start monitoring
	 * </listing>
	 * </p>
	 * 
	 * • Notes:
	 * <p>FPS values are calculated using <code>FP.frameRate</code></p>
	 * <p>Mememory values represent the total amount of memory used by all running instances of Flash as reported from <code>System.totalMemory</code></p>
	 * 
	 * @author azrafe7
	 * 
	 */
	public class FPStats extends Sprite
	{
		/** Author */
		public static const AUTHOR:String = "azrafe7";
		/** Version number */
		public static const VERSION:String = "0.3b";
		/** Build date */
		public static const BUILD_DATE:String = "15 Jan 2012";	
		
		/** Timer used to sample values */
		protected var _timer:Timer;
		/** Timer start time */
		protected var _startTime:int;
		/** Timer pause time */
		protected var _stopTime:int = 0;
		/** @see #elapsed */
		protected var _elapsed:Number = 0;
		

		/** @see #updateFrequency */
		protected var _updateFreq:int = 500;
		
		/** Elapsed time textField @see #showElapsed */
		protected var _elapsedText:TextField;
		/** Fps average textField @see #showFpsAverage */
		protected var _fpsAvgText:TextField;
		/** Mem average textField @see #showMemAverage */ 
		protected var _memAvgText:TextField;

		/**
		 * @see #separatedGraphs
		 * @see #FPStats() Constructor parameter
		 */
		protected var _separatedGraphs:Boolean = true;
		
		/** Fps GraphSprite */
		public var fpsGraph:GraphSprite = new GraphSprite();
		/** Mem GraphSprite */
		public var memGraph:GraphSprite = new GraphSprite();
		
		/** @see #WIDTH */
		protected var _WIDTH:Number;
		/** @see #HEIGHT */
		protected var _HEIGHT:Number;
		
		/** Default width of the outer box */
		protected var DEFAULT_WIDTH:Number = 200;
		/** Default height of the outer box */
		protected var DEFAULT_HEIGHT:Number = 80;
		
		/** Extra space to the right of the graphs (used for current mem and fps textFields) */
		public var VALUES_TEXT_SPACE:Number = 65;
		
		/** @see #showElapsed */
		protected var _showElapsed:Boolean = true;
		/** @see #showFpsAverage */
		protected var _showFpsAverage:Boolean = true;
		/** @see #showMemAverage */
		protected var _showMemAverage:Boolean = true;
		/** @see #showFpsValues */
		protected var _showFpsValues:Boolean = true;
		/** @see #showMemValues */
		protected var _showMemValues:Boolean = true;
		
		/** @see #FPStats() Constructor parameter */
		protected var _showFpsGraph:Boolean = true;
		/** @see #FPStats() Constructor parameter */
		protected var _showMemGraph:Boolean = true;
	
		/** Outer box sprite containing the GraphSprites */
		protected var _graph:Sprite = new Sprite();
		
		/** Internal graphs margin from the outer box */
		public var MARGIN:Number = 4;
		
		/** Outer box corner radius */
		public var RECT_RADIUS:int = 0;
		/** Outer box line thickness */
		public var LINE_THICKNESS:int = 1;
		/** Outer box line color */ 
		public var LINE_COLOR:int = 0x151515;
		/** Outer box background color */
		public var BG_ALPHA:Number = .5;
		/** Outer box background alpha */
		public var BG_COLOR:int = 0x0;
		/** Elapsed time text color */
		public var ELAPSED_COLOR:int = 0xFFFFFF;
				
		/** Indicates if the instance has been initialized @see #init() */
		protected var inited:Boolean = false;					
		
		
		/**
		 * Constructor
		 * 
		 * @param	x					x coord of the outer box
		 * @param	y					y coord of the outer box
		 * @param	w					width of the outer box (defaults to DEFAULT_WIDTH)
		 * @param	h					height of the outer box (defaults to DEFAULT_HEIGHT)
		 * @param 	autoStart			set this to true to automatically start monitoring after being added to stage (otherwise you have to manually call start())
		 * @param	showFpsGraph		set this to true if fps graph should be visible
		 * @param	showMemGraph		set this to true if mem graph should be visible
		 * @param	separatedGraphs		set this to true to create separated (non overlapping) graphs for fps and mem
		 */
		public function FPStats(x:Number = 10, y:Number = 30, w:Number = 0, h:Number = 0, autoStart:Boolean = false, showFpsGraph:Boolean = true, showMemGraph:Boolean = true, separatedGraphs:Boolean = true) 
		{
			super();
			this.x = x;
			this.y = y;
			_WIDTH = w || DEFAULT_WIDTH;
			_HEIGHT = h || DEFAULT_HEIGHT;
			
			_showFpsGraph = showFpsGraph;
			_showMemGraph = showMemGraph;
			_separatedGraphs = separatedGraphs;
			
			if (autoStart) {
				addEventListener(Event.ADDED_TO_STAGE, function():void {
					start();
					removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
				});
			}
			
			init();	// initialize
		}
		
		/** Initialize */
		protected function init():void
		{
			if (inited) return;
			
			fpsGraph.LINE_THICKNESS = 1;
			fpsGraph.LINE_ALPHA = 1;
			fpsGraph.VALUE_COLOR = fpsGraph.LINE_COLOR = 0xd38b38;		// orange color for fps graph line and value
			//fpsGraph.maxHistoryLength = 120;
			fpsGraph.PRECISION = 1;
			fpsGraph.minValue = 0;
			fpsGraph.maxValue = FP.assignedFrameRate + 2;
			fpsGraph.UNIT = " / " + FP.assignedFrameRate.toString() + " FPS";	// append assigned frame rate to fps values
			addChild(fpsGraph);
			
			//memGraph.maxHistoryLength = 120;
			memGraph.UNIT = " Mb";
			memGraph.GRID_SIZE = 5;
			memGraph.LINE_THICKNESS = 1;
			memGraph.LINE_ALPHA = 1;
			addChild(memGraph);
			
			_fpsAvgText = fpsGraph.createDefaultTextField();
			_memAvgText = memGraph.createDefaultTextField();
			_elapsedText = memGraph.createDefaultTextField();
			
			_fpsAvgText.y = _memAvgText.y = _elapsedText.y = _HEIGHT;
			
			_fpsAvgText.text = _memAvgText.text = _elapsedText.text = "average";
			
			_fpsAvgText.autoSize = TextFieldAutoSize.CENTER;
			_memAvgText.autoSize = TextFieldAutoSize.RIGHT;
			
			_elapsedText.textColor = ELAPSED_COLOR;
			_fpsAvgText.textColor = fpsGraph.VALUE_COLOR;
			_memAvgText.textColor = memGraph.VALUE_COLOR;
			
			showFpsValues = _showFpsGraph;
			fpsGraph.showMax = false;
			showMemValues = _showMemGraph;
			
			addChild(_fpsAvgText);
			addChild(_memAvgText);
			addChild(_elapsedText);
			
			resize();
			updateTextPos();
			
			inited = true;
		}

		/** Update textFields positions */
		protected function updateTextPos():void 
		{
			_elapsedText.y = _fpsAvgText.y = _memAvgText.y = HEIGHT - memGraph.FONT_SIZE*1.5;
			
			_elapsedText.x = MARGIN;
			var maxWidth:Number = Math.max(fpsGraph.x + fpsGraph.WIDTH, memGraph.x + memGraph.WIDTH) - MARGIN;
			_fpsAvgText.x = MARGIN + (maxWidth - _fpsAvgText.textWidth) * .5;
			_memAvgText.x = MARGIN + maxWidth - _memAvgText.textWidth -3;
		}
		
		/** Graph width */
		public function get WIDTH():Number
		{
			return _WIDTH;
		}
		
		/** Set graph width */
		public function set WIDTH(w:Number):void
		{
			_WIDTH = w;
			resize();
		}
		
		/** Graph height */
		public function get HEIGHT():Number
		{
			return _HEIGHT;
		}
		
		/** Set graph height */
		public function set HEIGHT(h:Number):void
		{
			_HEIGHT = h;
			resize();
		}
				
		/** Wether or not elapsed time is visible */
		public function get showElapsed():Boolean 
		{
			return _showElapsed;
		}
		
		/** Show/hide elapsedTime */
		public function set showElapsed(value:Boolean):void {
			_showElapsed = value;
			_elapsedText.visible = value;
		}

		/** Wether or not fps average is visible */
		public function get showFpsAverage():Boolean 
		{
			return _showFpsAverage;
		}
		
		/** Show/hide fps average */
		public function set showFpsAverage(value:Boolean):void {
			_showFpsAverage = value;
			_fpsAvgText.visible = value;
		}
		
		/** Wether or not mem average is visible */
		public function get showMemAverage():Boolean 
		{
			return _showMemAverage;
		}
		
		/** Show/hide mem average */
		public function set showMemAverage(value:Boolean):void {
			_showMemAverage = value;
			_memAvgText.visible = value;
			resize();
		}

		/** Wether or not mem values are visible (or at least one of them is) */
		public function get showMemValues():Boolean 
		{
			return memGraph.showValue || memGraph.showMin || memGraph.showMax;
		}
		
		/** Show/hide mem values */
		public function set showMemValues(value:Boolean):void {
			_showMemValues = value;
			memGraph.showValue = memGraph.showMin = memGraph.showMax = value;
			resize();
		}

		/** Wether or not fps values are visible (at least one of them is) */
		public function get showFpsValues():Boolean 
		{
			return fpsGraph.showValue || fpsGraph.showMin || fpsGraph.showMax;
		}
		
		/** Show/hide fps values */
		public function set showFpsValues(value:Boolean):void {
			_showFpsValues = value;
			fpsGraph.showValue = fpsGraph.showMin = fpsGraph.showMax = value;
			resize();
		}

		/** Elapsed time (in milliseconds) */
		public function get elapsed():Number {
			return _elapsed;
		}
		
		/** Wether or not the instance was created with the separatedGraphs parameter set to true (meaning the two graphs are not overlapping) 
		 * @see #FPStats() Constructor parameter */
		public function get separatedGraphs():Boolean {
			return _separatedGraphs;
		}
				
		/** Timer object used to sample values */
		public function get timer():Timer 
		{
			return _timer;
		}
		
		/** Force a call to the Garbage Collector (works only in the debug player) */
		public function callGC():void {
			System.gc();
		}
		
		/** Recalc/adjust positions and dimensions */
		public function resize():void {
			var showBelowText:Boolean = showElapsed || showMemAverage || showFpsAverage;
			var graphHeight:Number = (HEIGHT - MARGIN * 2) / 2;
			
			fpsGraph.visible = _showFpsGraph;
			memGraph.visible = _showMemGraph;
			
			if (showBelowText) {
				graphHeight -= memGraph.FONT_SIZE / 2;
			}
			if (memGraph.visible && fpsGraph.visible && separatedGraphs) {
				graphHeight -= MARGIN / 2;
			}
			
			fpsGraph.x = MARGIN;
			fpsGraph.y = MARGIN;
			fpsGraph.WIDTH = WIDTH - (showFpsValues || showMemValues ? VALUES_TEXT_SPACE : 0) - MARGIN * 2;
			fpsGraph.HEIGHT = graphHeight * (_showMemGraph && separatedGraphs? .75 : 2);
			
			memGraph.x = fpsGraph.x;
			memGraph.y = fpsGraph.y + (_showFpsGraph ? fpsGraph.HEIGHT + MARGIN : 0);
			memGraph.WIDTH = fpsGraph.WIDTH;
			memGraph.HEIGHT = graphHeight + (_showFpsGraph ? graphHeight * .25 : graphHeight);
			
			if (!_separatedGraphs && _showFpsGraph) {
				memGraph.WIDTH  = memGraph.WIDTH * .96;
				memGraph.HEIGHT = fpsGraph.HEIGHT * .6;
				memGraph.x = fpsGraph.y + fpsGraph.WIDTH * .02;
				memGraph.y = fpsGraph.y + fpsGraph.HEIGHT * .27;
			}
			
			updateTextPos();
		}
		
		/** Start/unpause values sampling */
		public function start():void 
		{
			//trace("start");
			if (!_timer) _startTime = getTimer();
			if (_stopTime) {
				_startTime += getTimer() - _stopTime;
				_stopTime = 0;
			}
			_timer = new Timer(updateFrequency);
			_timer.addEventListener(TimerEvent.TIMER, update);
			update(null);
			_timer.start();
		}
			
		/** Pause values sampling */
		public function stop():void
		{
			if (!_timer.running) return;
			//trace("stop");
			_timer.stop();
			_timer.removeEventListener(TimerEvent.TIMER, update);
			_stopTime = getTimer();
		}
		
		/** Wether or not the timer is paused */
		public function get isPaused():Boolean 
		{
			return (_timer && !_timer.running);
		}
		
		/** Clear graphs, reset values and timer */
		public function reset():void 
		{
			//trace("reset");
			//_timer.reset();
			fpsGraph.clearValues();
			memGraph.clearValues();
			_startTime = getTimer();
			//_stopTime = 0;
			update(null);
		}
		
		/** Current update frequency (in milliseconds) @default 500 */
		public function get updateFrequency():Number {
			return _updateFreq;
		}
		
		/** Set new update frequency (in milliseconds) */
		public function set updateFrequency(value:Number):void 
		{
			stop();
			_updateFreq = value;
			start();
			//trace("new freq:", value);
		}
		
		/** Update graphs and values (called every updateFrequency milliseconds) @see #updateFrequency */
		public function update(evt:TimerEvent = null):void 
		{	
			_elapsed = (getTimer() - _startTime) / 1000;	// calc elapsed time since start() (or reset()) was called
			
			// draw background
			graphics.clear();
			graphics.beginFill(BG_COLOR, BG_ALPHA);
			graphics.lineStyle(LINE_THICKNESS, LINE_COLOR);
			graphics.drawRoundRectComplex(0, 0, WIDTH - 1, HEIGHT - 1, RECT_RADIUS, RECT_RADIUS, RECT_RADIUS, RECT_RADIUS);
			graphics.endFill();
			
			// sample values (but only if the timer is active and update has been called with evt != null)
			if (_timer.running && evt) {	
				memGraph.addValue(Number(System.totalMemory/1024/1024));
				fpsGraph.addValue(FP.frameRate != Infinity ? FP.frameRate : 0);
			}

			// update graphs
			memGraph.update();
			fpsGraph.update();
			
			// update textFields
			_elapsedText.text = Utils.timeFormat(_elapsed, true, 1);
			_fpsAvgText.text = fpsGraph.averageValue.toFixed(fpsGraph.PRECISION) + " FPS";
			_memAvgText.text = memGraph.averageValue.toFixed(memGraph.PRECISION) + memGraph.UNIT;
		}
			
	}

}