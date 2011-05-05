package com.ticore.style.module {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.setTimeout;
	
	import mx.styles.CSSStyleDeclaration;
	import mx.styles.StyleManagerImpl;

	public class StyleManagerProxy extends StyleManagerImpl {
		
		protected var styleModule:Object;
		protected var timer:Timer = new Timer(0, 1);
		protected var quene:Array = [];
		
		override public function StyleManagerProxy(styleModule:Object) {
			this.styleModule = styleModule;
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerCompleteHandler);
		}

		// always return null, force style module call StyleManager.setStyleDeclaration();
		override public function getStyleDeclaration(selector:String):CSSStyleDeclaration {
			return null;
		}

		override public function setStyleDeclaration(selector:String,
					styleDeclaration:CSSStyleDeclaration, update:Boolean):void {
			
			// delay execute until style factory setup
			quene.push([selector, styleDeclaration, update]);
			if (!timer.running) timer.start();
		}

		protected function onTimerCompleteHandler(e:TimerEvent):void{
			var args:Array;
			while (args = quene.shift()) {
				styleModule.setStyleDeclaration.apply(null, args);
			}
		}
	}
}