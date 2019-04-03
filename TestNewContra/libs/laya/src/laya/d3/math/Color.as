package laya.d3.math {
	import laya.d3.core.IClone;
	import laya.renders.Render;
	import laya.d3.math.Native.ConchColor;
	/**
	 * <code>Color</code> 类用于创建颜色实例。
	 */
	public class Color implements IClone {
		/**
		 * 红色
		 */
		public static const RED:Color = new Color(1, 0, 0, 1);
		/**
		 * 绿色
		 */
		public static const GREEN:Color = new Color(0, 1, 0, 1);
		/**
		 * 蓝色
		 */
		public static const BLUE:Color = new Color(0, 0, 1, 1);
		/**
		 * 蓝绿色
		 */
		public static const CYAN:Color = new Color(0, 1, 1, 1);
		/**
		 * 黄色
		 */
		public static const YELLOW:Color = new Color(1, 0.92, 0.016, 1);
		/**
		 * 品红色
		 */
		public static const MAGENTA:Color = new Color(1, 0, 1, 1);
		/**
		 * 灰色
		 */
		public static const GRAY:Color = new Color(0.5, 0.5, 0.5, 1);
		/**
		 * 白色
		 */
		public static const WHITE:Color = new Color(1, 1, 1, 1);
		/**
		 * 黑色
		 */
		public static const BLACK:Color = new Color(0, 0, 0, 1);
		
		/**red分量*/
		public var r:Number;
		/**green分量*/
		public var g:Number;
		/**blue分量*/
		public var b:Number;
		/**alpha分量*/
		public var a:Number;
		
		/**
		 * 创建一个 <code>Color</code> 实例。
		 * @param	r  颜色的red分量。
		 * @param	g  颜色的green分量。
		 * @param	b  颜色的blue分量。
		 * @param	a  颜色的alpha分量。
		 */
		public function Color(r:Number = 1, g:Number = 1, b:Number = 1, a:Number = 1) {
			//if (Render.supportWebGLPlusAnimation || Render.supportWebGLPlusRendering) {
			if (__JS__("(window.conch != null)")) {
				__JS__("return new ConchColor(r, g, b, a)");
			}
			this.r = r;
			this.g = g;
			this.b = b;
			this.a = a;
		}
		
		/**
		 * 克隆。
		 * @param	destObject 克隆源。
		 */
		public function cloneTo(destObject:*):void {
			var destColor:Color = destObject as Color;
			destColor.r = r;
			destColor.g = g;
			destColor.b = b;
			destColor.a = a;
		}
		
		/**
		 * 克隆。
		 * @return	 克隆副本。
		 */
		public function clone():* {
			var dest:Color = __JS__("new this.constructor()");
			cloneTo(dest);
			return dest;
		}
	
	}

}