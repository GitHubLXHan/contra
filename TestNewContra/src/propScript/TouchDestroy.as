package propScript {
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.media.SoundManager;
	import laya.physics.BoxCollider;
	import laya.utils.Pool;
	
	import utils.CreateEffect;
	
	public class TouchDestroy extends Script {


		private var thisSp:Sprite;
		
		override public function onEnable():void {
			// 获取本对象精灵
			thisSp = this.owner as Sprite;
		}
		

		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "body") {
				// 通过对象池获取动画
				var aniBoom:Animation = Pool.getItemByCreateFun("enemyObjBoom", CreateEffect.getInstance().createEnemyObjBoomAni, this);
				aniBoom.pos(thisSp.x, thisSp.y);
				// 将动画添加到父容器中
				thisSp.parent.addChild(aniBoom);
				// 播放动画
				aniBoom.play(0,false);
				
				// 播放音效
				SoundManager.playSound("sound/stone_boom.wav");
				
				// 销毁碰撞体
				var thisCollider:BoxCollider = this.owner.getComponent(BoxCollider);
				thisCollider.destroy();
				
				// 移除自己
				thisSp.removeSelf();
			}
		}
		
		override public function onDisable():void {
			// 回收本对象
			Pool.recover("touchDestroy", thisSp);
		}
		
	}
}