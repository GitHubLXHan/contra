package script {
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.physics.BoxCollider;
	import laya.utils.Pool;
	
	public class TouchDestroy extends Script {


		private var thisSp:Sprite;
		
		override public function onEnable():void {
			// 获取本对象精灵
			thisSp = this.owner as Sprite;
		}
		
		private function createEnemyObjBoomAni():Animation
		{
			var ani:Animation = new Animation();
			// 加载动画
			ani.loadAnimation("GameScene/EnemyObjBoom.ani",null, "res/atlas/boom.atlas");
			// 动画播放完后又回收到对象池中
			ani.on(Event.COMPLETE, null, function ():void{
				// 从容器中移除动画
				ani.removeSelf();
				// 回收到对象池
				Pool.recover("enemyObjBoom", ani);
			});
			return ani;
			
		}
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "body") {
				// 通过对象池获取动画
				var aniBoom:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
				aniBoom.pos(thisSp.x, thisSp.y);
				// 将动画添加到父容器中
				thisSp.parent.addChild(aniBoom);
				// 播放动画
				aniBoom.play(0,false);
				
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