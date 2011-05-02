package com.ticore.style.example.effect {
	import spark.effects.Scale;

	public class ScaleDown extends Scale {
		public function ScaleDown(target:Object = null) {
			super(target);
			scaleXTo = scaleYTo = 1;
		}
	}
}