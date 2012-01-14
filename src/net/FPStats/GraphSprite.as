package  net.FPStats
{
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
	
	/**
	 * A class for drawing graphs by simply providing the set of values to represent. Used to make fps and mem graphs in FPStats (doesn't depend from FlashPunk).
	 * 
	 * @author azrafe7
	 */
	public class GraphSprite extends Sprite
	{
		/** Constant to use with getTextField() function @see #getTextField() */
		public static const VALUE_TEXTFIELD:int = 0;
		/** Constant to use with getTextField() function @see #getTextField() */
		public static const MIN_TEXTFIELD:int = 1;
		/** Constant to use with getTextField() function @see #getTextField() */
		public static const MAX_TEXTFIELD:int = 2;
		
		/** TextField representing current value */
		public var valueText:TextField;
		/** TextField representing min value */
		public var minValueText:TextField;
		/** TextField representing max value */
		public var maxValueText:TextField;
		
		/** @see #lastValue
		 * @see #addValue() */
		protected var _lastValue:Number;
		/** Minimum value */
		public var minValue:Number = Infinity;
		/** Maximum value */
		public var maxValue:Number = -Infinity;
		
		/** Max number of displayed points on the graph */
		public var maxHistoryLength:int = 100;
		/** If set to true history will have no limits (i.e. you can continue to add values, all of them will be represented) */
		public var historyAutoExpand:Boolean = false;

		/** @internal Internal */
		protected var xStepWidth:Number;
		/** @internal Internal */
		protected var scaledValue:Number;
		/** @internal Internal */
		protected var ratio:Number;
		
		/** @see #WIDTH */
		protected var _WIDTH:Number = 0;
		/** @see #HEIGHT */
		protected var _HEIGHT:Number = 0;
		
		/** Default width of graph box */
		protected static const DEFAULT_WIDTH:Number = 200;
		/** Default height of graph box */
		protected static const DEFAULT_HEIGHT:Number = 60;
		
		/** @see #FONT_NAME */
		protected var _FONT_NAME:String = "default";
		/** @see #FONT_SIZE */
		protected var _FONT_SIZE:int = 8;
		/** @see #VALUE_COLOR */
		protected var _VALUE_COLOR:int = 0x3060bb;
		/** @see #MIN_COLOR */
		protected var _MIN_COLOR:int = 0xffffff;
		/** @see #MAX_COLOR */
		protected var _MAX_COLOR:int = 0xbb3030;
		
		/** @see #showMin */
		protected var _showMin:Boolean = true;
		/** @see #showMax */
		protected var _showMax:Boolean = true;
		/** @see #showValue */
		protected var _showValue:Boolean = true;
		
		/** If set to true a line will be shown on top of the graph when a new min or max is reached */
		public var showMinMaxLines:Boolean = true;
		
		/** Number of decimals to show for values */
		public var PRECISION:int = 2;
		/** Text to append to values (typically values units name) */
		public var UNIT:String = " units";
		/** Distance between two grid lines */
		public var GRID_SIZE:int = 10;
		
		/** Graph line color */
		public var LINE_COLOR:int = _VALUE_COLOR;
		/** Graph line alpha */
		public var LINE_ALPHA:Number = .8;
		/** Graph line thickness */
		public var LINE_THICKNESS:Number = 1.5;
		
		/** Graph box outline color */
		public var OUTLINE_COLOR:int = 0x151515;
		/** Graph box outline alpha */
		public var OUTLINE_ALPHA:Number = .6;
		/** Graph box outline thickness */
		public var OUTLINE_THICKNESS:Number = 1;

		/** Background color */
		public var BG_COLOR:int = 0x0;
		/** Background alpha */
		public var BG_ALPHA:Number = .5;
		/** Graph box corner radius */
		public var RECT_RADIUS:Number = 0;
		
		/** New min/max line alpha */
		public var MINMAX_LINE_ALPHA:Number = .3;
		
		/** Pixel distance from box to text */
		public var MARGIN:int = 3;
		
		/** Total number of values added (via addValue()) used for computing average */
		protected var valuesCount:Number = 0;
		/** Sum of all values @see #averageValue */
		protected var _sum:Number = 0;
		/** Contains a list of all values to be represented */
		protected var history:Vector.<Number> = new Vector.<Number>(); 
		
		/** Set to true once the graph has been initialized */
		protected var inited:Boolean = false;
		
		/** Indicates wether a new maximum has just been added */
		protected var newMaxReached:Boolean = false;
		/** Indicates wether a new minimum has just been added */
		protected var newMinReached:Boolean = false;
		
		/**
		 * Constructor
		 * 
		 * @param	x					x coord of the graph box
		 * @param	y					y coord of the graph box
		 * @param	w					width of the graph box (defaults to DEFAULT_WIDTH)
		 * @param	h					height of the graph box (defaults to DEFAULT_HEIGHT)
		 */
		public function GraphSprite(x:Number = 0, y:Number = 0, w:Number = 0, h:Number = 0)
		{
			super();
			this.x = x;
			this.y = y;
			_WIDTH = w || DEFAULT_WIDTH;
			_HEIGHT = h || DEFAULT_HEIGHT;
			
			init();	// initialize graph props
		}
		
		/** Initialize textFields with default properties */
		protected function init():void
		{
			if (inited) return;
									
			valueText = createDefaultTextField();
			VALUE_COLOR = LINE_COLOR;
			
			minValueText = createDefaultTextField();
			MIN_COLOR = _MIN_COLOR;
			
			maxValueText = createDefaultTextField();
			MAX_COLOR = _MAX_COLOR;

			addChild(valueText);
			addChild(minValueText);
			addChild(maxValueText);

			inited = true;
		}

		/** Average value (calculated from _all_ values added via addValue()) */
		public function get averageValue():Number
		{
			return _sum / valuesCount;
		}
		
		/** Last value added to history */
		public function get lastValue():Number
		{
			return _lastValue;
		}
		
		/** Add a new value to history values */
		public function addValue(val:Number):void 
		{
			_lastValue = val;
			if (_lastValue < minValue) {
				minValue = _lastValue;
				newMinReached = true;
			} else {
				newMinReached = false;
			}
			if (_lastValue > maxValue) {
				maxValue = _lastValue;
				newMaxReached = true;
			} else {
				newMaxReached = false;
			}
			
			if (history.length > maxHistoryLength && !historyAutoExpand) history.splice(0, 1);
			
			history[history.length] = _lastValue;
			valuesCount++;
			_sum += _lastValue;
		}		
		
		/** Wether or not min value is visible */
		public function get showMin():Boolean 
		{
			return _showMin;
		}
		
		/** Show/hide min value */
		public function set showMin(value:Boolean):void {
			_showMin = value;
			minValueText.visible = value;
		}
		
		/** Wether or not max value is visible */
		public function get showMax():Boolean 
		{
			return _showMax;
		}
		
		/** Show/hide max value */
		public function set showMax(value:Boolean):void {
			_showMax = value;
			maxValueText.visible = value;
		}
		
		/** Wether or not current value is visible */
		public function get showValue():Boolean 
		{
			return _showValue;
		}
		
		/** Show/hide current value */
		public function set showValue(value:Boolean):void {
			_showValue= value;
			valueText.visible = value;
		}
		
		/** Font family used for textFields */
		public function get FONT_NAME():String 
		{
			return _FONT_NAME;
		}
		
		/** Set font family to use for textFields */
		public function set FONT_NAME(value:String):void {
			_FONT_NAME = value;
			setTextProps({font:value, embedFonts:(value != "_sans" && value != "_serif" && value != "_typewriter")});
		}
		
		/** Font size used for textFields */
		public function get FONT_SIZE():Number
		{
			return _FONT_SIZE;
		}
		
		/** Set font size */
		public function set FONT_SIZE(value:Number):void {
			_FONT_SIZE = value;
			setTextProps({size:value});
		}
		
		/** Color of valueText */
		public function get VALUE_COLOR():int
		{
			return _VALUE_COLOR;
		}
		
		/** Set color of valueText */
		public function set VALUE_COLOR(value:int):void {
			_VALUE_COLOR = value;
			valueText.textColor = value;
		}
		
		/** Color of minValueText */
		public function get MIN_COLOR():int
		{
			return _MIN_COLOR;
		}
		
		/** Set color of minValueText */
		public function set MIN_COLOR(value:int):void {
			_MIN_COLOR = value;
			minValueText.textColor = value;
		}
		
		/** Color of maxValueText */
		public function get MAX_COLOR():int
		{
			return _MAX_COLOR;
		}
		
		/** Set color of maxValueText */
		public function set MAX_COLOR(value:int):void {
			_MAX_COLOR = value;
			maxValueText.textColor = value;
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
			updateTextPos();
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
			updateTextPos();
		}
		
		/** Update/render the graph */
		public function update():void 
		{	
			
			// set and reposition curr, min and max values
			valueText.text = _lastValue.toFixed(PRECISION) + UNIT;
			minValueText.text = minValue.toFixed(PRECISION) + UNIT;
			maxValueText.text = maxValue.toFixed(PRECISION) + UNIT;

			// draw graph background
			this.graphics.clear();
			this.graphics.beginFill(BG_COLOR, BG_ALPHA);
			this.graphics.lineStyle(OUTLINE_THICKNESS, OUTLINE_COLOR);
			this.graphics.drawRoundRectComplex(-OUTLINE_THICKNESS, -OUTLINE_THICKNESS, WIDTH-1+OUTLINE_THICKNESS*2, HEIGHT-1+OUTLINE_THICKNESS*2, RECT_RADIUS, RECT_RADIUS, RECT_RADIUS, RECT_RADIUS);
			this.graphics.endFill();
			
			var i:int;
			
			// draw graph
			var currHistoryLen:int = history.length;
			if (currHistoryLen > 0) {
				xStepWidth = WIDTH / (Math.max(maxHistoryLength, currHistoryLen-1));	// calc x distance (in pixels) of two consequent values
				ratio = (HEIGHT / (maxValue - minValue));								// calc ratio (used to scale values)
				
				this.graphics.lineStyle(LINE_THICKNESS, LINE_COLOR, LINE_ALPHA);				
				this.graphics.moveTo(0, - HEIGHT + history[0] * ratio);
				for (i = 0; i < currHistoryLen; i++) {
					 scaledValue = (history[i] - minValue) * ratio; 					// calc scaled value
					 if (i == 0) {
						this.graphics.moveTo(xStepWidth * i, HEIGHT - scaledValue);
					} else {
						this.graphics.lineTo(xStepWidth * i - 1, HEIGHT - scaledValue);
						
						// reposition value text
						if (i == currHistoryLen - 1) {	
							valueText.y = HEIGHT - scaledValue - FONT_SIZE * .5;
							var collideWithMax:Boolean = valueText.y < (maxValueText.y + maxValueText.getLineMetrics(0).ascent + 2); //valueText.hitTestObject(maxValueText);
							var collideWithMin:Boolean = valueText.y > (minValueText.y - maxValueText.getLineMetrics(0).ascent - 2); //valueText.hitTestObject(minValueText);
							if (collideWithMin) {
								valueText.y = minValueText.y;
								if (showMin && lastValue != minValue) {
									valueText.y -= FONT_SIZE;
								}
							}
							if (collideWithMax) {
								valueText.y = maxValueText.y;
								if (showMax && lastValue != maxValue) {
									valueText.y += valueText.getLineMetrics(0).ascent + 2;
								}
							}
						}
					}
				}
				
				// draw new min/max line if needed
				if (showMinMaxLines && (newMinReached || newMaxReached)) {	
					var tmpY:Number = newMinReached ? HEIGHT+1 : -1;
					this.graphics.lineStyle(LINE_THICKNESS, newMinReached ? _MIN_COLOR : _MAX_COLOR, MINMAX_LINE_ALPHA);
					this.graphics.moveTo(0, tmpY);
					this.graphics.lineTo(WIDTH, tmpY);
				}
			}

			// draw inner grid (if VALUE_GRID_SIZE > 0)
			if (GRID_SIZE > 0) {
				this.graphics.lineStyle(OUTLINE_THICKNESS, OUTLINE_COLOR, OUTLINE_ALPHA);
				for (i = 1; i <= int((maxValue - minValue) / GRID_SIZE); i++) {
					scaledValue = GRID_SIZE * i * ratio;
					this.graphics.moveTo(0, HEIGHT - scaledValue);
					this.graphics.lineTo(WIDTH - 1, HEIGHT - scaledValue);
				}
			}
		}

		/** Recalc textFields positions */
		public function updateTextPos():void 
		{
			valueText.x = WIDTH + MARGIN;
			valueText.y = HEIGHT*.5 - FONT_SIZE*.5;
			minValueText.x = WIDTH + MARGIN;
			minValueText.y = HEIGHT - FONT_SIZE - 1;
			maxValueText.x = WIDTH + MARGIN;
			maxValueText.y = - FONT_SIZE*.3;
		}
		
		/** Clear all values (including _sum) */
		public function clearValues():void 
		{
			history = new Vector.<Number>();
			valuesCount = 0;
			_sum = 0;
		}
		
		/** History vector containing all added values */
		public function getHistory():Vector.<Number>
		{
			return history;
		}
		
		/** Get textField corresponding to whatField value (one of VALUE_TEXTFIELD, MIN_TEXTFIELD, MAX_TEXTFIELD) */
		public function getTextField(whatField:int):TextField {
			var tf:TextField;
			switch (whatField) 
			{
				case 0: 
					tf = valueText;
					break;
				case 1: 
					tf = minValueText;
					break;
				case 2: 
					tf = maxValueText;
					break;
				default:
					tf = valueText;
					break;
			}
			return tf;
		}

		/** 
		 * Set textField and textFormat properties of all three textFields (minValueText, maxValueText and valueText)
		 * 
		 * <p>
		 * Example: 
		 * <listing>
		 * setTextProps({x:120, bold:true, font:"_typewriter"});		
		 * </listing>
		 * </p>
		 */
		public function setTextProps(properties:Object):void {
			for (var i:int=0; i <= MAX_TEXTFIELD; i++) {
				Utils.setTextProps(getTextField(i), properties);
			}
			updateTextPos();
		}
		
		/** Return a new TextField with default properties */
		internal function createDefaultTextField():TextField
		{
			var tf:TextField = new TextField();
			var fmt:TextFormat = new TextFormat(FONT_NAME, FONT_SIZE);
			tf.defaultTextFormat = fmt;
			tf.setTextFormat(fmt);
			tf.text = " ";
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.embedFonts = true;
			tf.selectable = false;
			tf.autoSize = TextFieldAutoSize.LEFT;
			
			return tf;
		}
		
	}
}