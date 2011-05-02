package com.ticore.style.example.effect {
	import spark.effects.Scale;

	public class ScaleUp extends Scale {
		public function ScaleUp(target:Object = null) {
			super(target);
			scaleXTo = scaleYTo = 1.5;
		}
	}
}