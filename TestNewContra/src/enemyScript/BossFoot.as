package enemyScript {
	
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	
	public class BossFoot extends Script {
		
		private var footHP:Number = 50;
		private var thisSp:Sprite;
		private var footAni:Animation;
		
		// 发射器精灵
		private var top01:Sprite;
		private var top02:Sprite;
		
		
		override public function onEnable():void {
			
			// 获取本身精灵
			thisSp = this.owner as Sprite;
			
			// 获取并播放动画
			footAni = this.owner.parent["foot_ani"] as Animation;
			footAni.play();
		
			// 获取发射器精灵
			top01 = thisSp.parent.getChildByName("top01") as Sprite;
			top02 = thisSp.parent.getChildByName("top02") as Sprite;
				
		}
		
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "bullet" && self.label === "boss_foot" && top01.destroyed && top02.destroyed) {
				footHP--;
				if (footHP <= 0) {
					console.log("foot销毁");
					// 直接销毁自己，destroy时会移除自身的监听事件，自身的 timer事件，移除子节点以及自己
					// destroy对象默认会把自己从父节点移除，并且清理自身引用关系，等待js自动垃圾回收机制回收
					thisSp.destroy(true);						
				}
			}
		}
		

		
		override public function onDisable():void {
		}
	}
}