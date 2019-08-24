package enemyScript {
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.ui.Box;
	import laya.utils.Pool;
	
	import utils.CreateEffect;
	
	public class BossOneBullet extends Script {
		/** @prop {name:intType, tips:"整数类型示例", type:Int, default:1000}*/
		public var intType: int = 1000;
		
		// 本对象盒子
		private var thisSp:Sprite;
		
		// 子弹动画
		private var bulletAni:Animation;
		
		// 
		private var bulletSp:Sprite;
		
		override public function onEnable():void {
			// 获取本对象
			thisSp = this.owner as Sprite;
			// 获取子弹动画
			bulletAni = this.owner["bossOneBullet_ani"] as Animation;
			bulletAni.play(0, false);
		}
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "pass_n" || other.label === "pass_y") {
				// 通过对象池获取动画
				var aniBoom:Animation = Pool.getItemByCreateFun("enemyObjBoom", CreateEffect.getInstance().createEnemyObjBoomAni, this);
				aniBoom.pos(thisSp.x, thisSp.y);
				// 播放动画
				aniBoom.play(0,false);
				// 将动画添加到父容器中
				thisSp.parent.addChild(aniBoom);
				
				// 移除自己
				thisSp.removeSelf();
			}
		}
		
	
		
		override public function onDisable():void {
			Pool.recover("bossOneBullet", thisSp);
		}
	}
}