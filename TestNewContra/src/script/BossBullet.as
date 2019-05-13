package script {
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.ui.Box;
	
	public class BossBullet extends Script {
		/** @prop {name:intType, tips:"整数类型示例", type:Int, default:1000}*/
		public var intType: int = 1000;

		// 本对象盒子
		private var box:Sprite;
		
		// 子弹动画
		private var bulletAni:Animation;

		// 
		private var bulletSp:Sprite;
		
		override public function onEnable():void {
			trace(this.owner);
			// 获取本对象盒子
			box = this.owner as Sprite;
			
//			bulletSp = box.getChildByName("") as Sprite;
			
			// 获取子弹动画
			bulletAni = this.owner.parent["bullet_ani"] as Animation;
			bulletAni.play(0, false);
		}
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			
			if (other.label === "pass_n" || other.label === "pass_y") {
				console.log("打到地板");
			}
		}
		
		override public function onDisable():void {
		}
	}
}