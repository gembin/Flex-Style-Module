package com.ticore.style.module {
	import flash.system.Security;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import mx.core.mx_internal;
	import mx.modules.ModuleBase;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.IStyleManager2;
	import mx.styles.IStyleModule;

	public class StyleModule extends ModuleBase implements IStyleModule {

		private static var domainsAllowed:Boolean = allowDomains();

		private static function allowDomains():Boolean {
			if (Security.sandboxType != "application") {
				Security.allowDomain("*");
			}
			return true;
		}

		//============================================================
		
		public function StyleModule() {
			// reset static flag _MyStyleMod_StylesInit_done
			var fullName:String = getQualifiedClassName(this);
			var className:String = fullName.split("::")[1];
			var Cls:Class = getDefinitionByName(fullName) as Class;
			var varName:String = "_" + className + "_StylesInit_done";
			
			var qName:QName = new QName(mx_internal, varName);
			Cls[qName] = false;
		}

		protected var selectors:Array = [];
		protected var overrideMap:Object = {};
		protected var effectMap:Object = {};
		protected var unloadGlobal:Boolean;

		protected var styleManager:IStyleManager2;

		//============================================================

		public static var StyleManagerCls:Class = mx.styles.StyleManager;

		// StyleManager class reference hook
		protected var StyleManager:Object = new StyleManagerProxy(this);
		
		public function getStyleDeclaration(selector:String):CSSStyleDeclaration {
			return StyleManagerCls.getStyleDeclaration(selector);
		}

		public function setStyleDeclaration(selector:String, style:CSSStyleDeclaration, update:Boolean):void {
			
			var newStyle:CSSStyleDeclaration = StyleManagerCls.getStyleDeclaration(selector);
			
			if (!newStyle) {
				newStyle = new CSSStyleDeclaration();
			}
			
			// register override map and keys
			var factory:Function = style.factory;
			
			if (!(factory)) return;
			
			var dumpObj:Object = {};
			factory.apply(dumpObj);

			var keys:Array = overrideMap[selector];
			keys ||= [];
			overrideMap[selector] ||= keys;

			for (var key:* in dumpObj) {
				newStyle.mx_internal::setStyle(key, dumpObj[key]);
				keys.push(key);
			}
			
			// register effects map
			var addedEffects:Array;
			
			style.mx_internal::effects = style.mx_internal::effects || [];
			newStyle.mx_internal::effects = newStyle.mx_internal::effects || style.mx_internal::effects;
			
			addedEffects = style.mx_internal::effects.concat();
			effectMap[selector] = addedEffects;
			
			// update style
			StyleManagerCls.setStyleDeclaration(selector, newStyle, true);
		}
		
		//============================================================
		// original external style module functions

		public function unload():void {
			// (trace)("StyleModule.unload();");
			unloadOverrides();
			unloadStyleDeclarations();
			if (unloadGlobal) {
				styleManager.stylesRoot = null;
				styleManager.initProtoChainRoots();
			}
		}

		private function unloadOverrides():void {
			// (trace)("StyleModule.unloadOverrides();");
			for (var selector:String in overrideMap) {
				// (trace)("selector:", selector);
				var style:CSSStyleDeclaration = StyleManagerCls.getStyleDeclaration(selector);
				if (style != null) {
					var keys:Array = overrideMap[selector];
					var numKeys:int;
					var i:uint;
					if (keys != null) {
						numKeys = keys.length;
						for (i = 0; i < numKeys; i++) {
							// (trace)("clearOverride:", keys[i], style.getStyle(keys[i]));
							style.mx_internal::clearOverride(keys[i]);
						}
					}
					keys = effectMap[selector];
					if (keys != null) {
						numKeys = keys.length;
						var index:uint;
						var effects:Array = style.mx_internal::effects;
						for (i = 0; i < numKeys; i++) {
							// ReferenceError: Error #1069: Number 上找不到屬性 0，而且沒有預設值。
							// index = effects.indexOf(numKeys[i]);
							index = effects.indexOf(keys[i]);
							if (index >= 0) {
								effects.splice(index, 1);
							}
						}
					}
				}
			}
			overrideMap = null;
			effectMap = null;
		}

		private function unloadStyleDeclarations():void {
			// (trace)("StyleModule.unloadStyleDeclarations();");
			var numSelectors:int = selectors.length;
			for (var i:int = 0; i < numSelectors; i++) {
				var selector:String = selectors[i];
				styleManager.clearStyleDeclaration(selector, false);
			}
			selectors = null;
		}

		//============================================================
	}
}