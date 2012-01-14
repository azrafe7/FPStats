package net.FPStats
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.*;

	/**
	 * A static class with some utility functions. Used in FPStats and GraphSprite.
	 * 
	 * @author azrafe7
	 */
	public class Utils 
	{
		
		/** Clone an object (creating a new instance and making a shallow copy of all properties)
		 * @param obj		object to clone (its class _must_ have a parameterless constructor)
		 * @return a clone of obj */
		public static function clone(obj:Object):* 
		{
			var res:*;
			var objClass:Object;
			
			if (obj != null) {
				objClass = getDefinitionByName(getQualifiedClassName(obj));
				res = new objClass();
				copyProperties(obj, res);
			} else {
				res =  null;
			}
			return res;
		}
		
		
		/**
		 * Copy all src properties (public variables and readwrite-able properties) into dest
		 * @param	src		source object
		 * @param	dest	destination object
		 */
		public static function copyProperties(src:*, dest:*):void 
		{
			if (src == null || dest == null) return;
			
			var definition:XML = describeType(dest);
			if (!(dest is Array) && !(src is Array)) {
				for (var p:String in src) {
					dest[p] = src[p];
					//trace(p + ": ", src[p], dest[p], src[p] == dest[p] ? "NOT " : "", "EQUALS");
				}
			}
			var props:XMLList = definition..variable + definition..accessor;
			var propName:String;
			for (var i:int; i < props.length(); i++) {
				propName = props[i].@name;
				if (props[i].@access == "readwrite" && src.hasOwnProperty(propName)) {
					dest[propName] = src[propName];
					//trace(propName + ": ", src[propName], dest[propName], src[propName] != dest[propName] ? "NOT" : "", "EQUALS");
				}
			}
		}
		
		/**
		 * Set properties of obj assigning defaultProperties first
		 * @param	obj						object on which properties will be set
		 * @param	properties				properties to assign
		 * @param	defaultProperties		default properties to assign first
		 * 
		 * <p>
		 * Example: 
		 * <listing>
		 * setProperties(textField, {text: "lorem ipsum", alpha: .5}, {textColor = 0xFFFFFF, alpha: 1});		
		 * </listing>
		 * </p>
		 */
		public static function setProperties(obj:Object, properties:Object, defaultProperties:Object = null):void 
		{
			var prop:*;
			for (prop in defaultProperties) {
				if (obj.hasOwnProperty(prop)) {
					obj[prop] = defaultProperties[prop];
				}
			}
			for (prop in properties) {
				if (obj.hasOwnProperty(prop)) {
					obj[prop] = properties[prop];
				}
			}
		}
		
		/**
		 * Set textField and textFormat properties of textFieldObj
		 * @param	textFieldObj		textField on which properties will be set
		 * @param	properties			properties to assign
		 * 
		 * <p>
		 * Example: 
		 * <listing>
		 * setTextProps(textFieldObj, {x:120, bold:true, font:"_typewriter"});		
		 * </listing>
		 * </p>
		 */
		public static function setTextProps(textFieldObj:TextField, properties:Object):void {
			var tf:TextField = textFieldObj;
			var fmt:TextFormat;
			setProperties(tf, properties);
			fmt = tf.getTextFormat();
			setProperties(fmt, properties);
			tf.setTextFormat(fmt);
			tf.defaultTextFormat = fmt;
		}
		
		/**
		 * Left pad a string (using padChar as padding char)
		 * @param	length		desired characters length of the output string
		 * @param	text		string to pad
		 * @param	padChar		padding char (defaults to " ")
		 * 
		 * @return padded string
		 * 
		 * <p>
		 * Example: 
		 * <listing>
		 * padLeft(5, "12", "0") 		
		 * </listing>
		 * </p>
		 * returns "00012"
		 */
		public static function padLeft(length:int, text:String, padChar:String = " "):String 
		{
			var res:String = text;
			var diff:int = length - res.length;
			
			if (diff > 0) {
				for (var i:int = 0; i < diff; i++) {
					res = padChar + res;
				}
			}
			return res;
		}
		
		/**
		 * Return a string representing time in a more readable format (hh:mm:ss.ms)
		 * @param	seconds			time to format in seconds
		 * @param	showMS			true to show milliseconds
		 * @param	precisionMS		number of ms digits to show
		 * 
		 * @return formatted string
		 * 
		 * <p>
		 * Example: 
		 * <listing>
		 * timeFormat(3700.732, true, 2);		 	
		 * </listing>
		 * </p>
		 * returns "01:01:40.73"
		 */ 
		public static function timeFormat(seconds:Number, showMS:Boolean = false, precisionMS:int = 3):String 
		{
			var delimiter:String = ":";
			var text:String = "";
			var hh:int, mm:int, ss:int, ms:int;

			hh = Math.floor(seconds / 3600);
			mm = Math.floor(seconds / 60) % 60;
			ss = Math.floor(seconds % 60);
			text = "";
			text += padLeft(2, hh.toString(), "0") + delimiter;
			text += padLeft(2, mm.toString(), "0") + delimiter;
			text += padLeft(2, ss.toString(), "0");
			if (showMS) {
				ms = (seconds - Math.floor(seconds)) * Math.pow(10, precisionMS);
				text += "." + padLeft(precisionMS, ms.toString(), "0");
			}
			return text;
		}
		
	}

}