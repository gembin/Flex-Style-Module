package com.ticore.style.example.effect {
	import mx.effects.Blur;

	public class BlurDown extends Blur {
		public function BlurDown(target:Object = null) {
			super(target);
			blurXFrom = blurYFrom = 5;
			blurXTo = blurYTo = 0;
		}
	}
}