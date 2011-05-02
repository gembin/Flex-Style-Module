package com.ticore.style.module {
	import flash.system.Security;
	
	import mx.core.mx_internal;
	import mx.modules.ModuleBase;
	import mx.styles.CSSCondition;
	import mx.styles.CSSSelector;
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

		protected var selectors:Array = [];
		protected var overrideMap:Object = {};
		protected var effectMap:Object = {};
		protected var unloadGlobal:Boolean;

		protected var styleManager:IStyleManager2;

		//============================================================

		public static var StyleManagerCls:Class = mx.styles.StyleManager;

		// StyleManager class reference hook
		protected var StyleManager:Object = {styleModule: this,
				getStyleManager: function(... args):* {
					return new StyleManagerProxy(this.styleModule);
				}};

		protected var _styles_:Array = [];

		public function pushStyle(style:CSSStyleDeclaration):void {
			_styles_.push(style);
		}

		//============================================================

		public function setStyleDeclarations(styleManager:IStyleManager2):void {
			// (trace)("StyleModule.setStyleDeclarations();", styleManager);

			if (!styleManager) {
				styleManager = StyleManagerCls["getStyleManager"](null);
			}

			this.styleManager = styleManager;

			// clone styles with new styleManager
			for (var i:int = 0; i < _styles_.length; ++i) {
				var oldStyle:CSSStyleDeclaration = _styles_[i] as CSSStyleDeclaration;
				
				var selector:CSSSelector = oldStyle.selector;
				var selectorString:String = selector.toString();

				var newStyle:CSSStyleDeclaration = styleManager.getStyleDeclaration(selectorString);

				if (!newStyle) {
					newStyle = new CSSStyleDeclaration(selector, styleManager);
					selectors.push(selectorString);
				}

				// register override map and keys
				var factory:Function = oldStyle.factory;
				var dumpObj:Object = {};
				factory.apply(dumpObj);

				var keys:Array = overrideMap[selectorString];
				overrideMap[selectorString] ||= keys ||= [];

				for (var key:* in dumpObj) {
					newStyle.mx_internal::setLocalStyle(key, dumpObj[key]);
					keys.push(key);
				}
				
				// register effects map
				var addedEffects:Array;
				
				// (trace)("effects:", oldStyle.mx_internal::effects);
				newStyle.mx_internal::effects ||= oldStyle.mx_internal::effects ||= [];
				addedEffects = newStyle.mx_internal::effects.concat();
				effectMap[selectorString] = addedEffects;
			}
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
				var style:CSSStyleDeclaration = styleManager.getStyleDeclaration(selector);
				if (style != null) {
					var keys:Array = overrideMap[selector];
					var numKeys:int;
					var i:uint;
					if (keys != null) {
						numKeys = keys.length;
						for (i = 0; i < numKeys; i++) {
							// (trace)("clearOverride:", keys[i]);
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