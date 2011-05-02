package com.ticore.style.module {
	import mx.managers.SystemManagerGlobals;
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManagerImpl;

	public class StyleManagerProxy extends StyleManagerImpl {
		
		protected var styleModule:Object;
		
		override public function StyleManagerProxy(styleModule:Object) {
			super(SystemManagerGlobals.topLevelSystemManagers[0]);
			this.styleModule = styleModule;
		}

		override public function getStyleDeclaration(selector:String):CSSStyleDeclaration {
			return null;
		}

		override public function setStyleDeclaration(selector:String,
					styleDeclaration:CSSStyleDeclaration, update:Boolean):void {
			styleModule.pushStyle(styleDeclaration);
		}

	}
}