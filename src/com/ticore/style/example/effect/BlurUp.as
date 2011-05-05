package com.ticore.style.example.effect {
	import mx.effects.Blur;

	public class BlurUp extends Blur {
		public function BlurUp(target:Object = null) {
			super(target);
			blurXFrom = blurYFrom = 0;
			blurXTo = blurYTo = 5;
		}
	}
}