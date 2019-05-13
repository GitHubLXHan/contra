package script {
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.maths.Rectangle;
	import laya.physics.RigidBody;
	import laya.utils.Pool;
	
	public class Bullet extends Script {

		private var thisSp:Sprite;
		private var rigid:RigidBody;
		private var ani:Animation;
		
		
		override public function onEnable():void {
			thisSp = this.owner as Sprite;
			thisSp.visible = false;
			ani = Pool.getItemByCreateFun("myBulletAni", createBulletAnimation, this);
			ani.play(0, false, "myBullet_type01");
			thisSp.parent.addChild(ani);
			rigid = thisSp.getComponent(RigidBody);
		}

		/**
		 * 对象池中没有动画的时候即调用此方法创建动画
		 */
		private function createBulletAnimation():Animation
		{
			var tempAni:Animation = new Animation();
			tempAni.loadAnimation("GameScene/Bullet.ani", null, "res/atlas/bullet.atlas");
			return tempAni;
		}
		
		private function onAniLoaded():void
		{
			ani.visible = true;
			thisSp.visible = false;
			thisSp.addChild(ani);
		}
		
		override public function onUpdate():void {
			
			ani.pos(thisSp.x, thisSp.y);
			
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && thisSp.x > (scrollRect.x + scrollRect.width) || 
				thisSp.y > (scrollRect.y + scrollRect.height) || 
				thisSp.x < scrollRect.x ||
				thisSp.y < scrollRect.y) {	
					thisSp.removeSelf();
				Pool.recover("myBullet", thisSp);
			}	
			
		}
		
		
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {

			if (other.label === "enemy_one" || 
				other.label === "enemy_tow" || 
				other.label === "enemy_three" || 
				other.label === "enemy_four" ||
				other.label === "enemy_five" ||
				other.label === "can_shoot") {
				thisSp.removeSelf();
				Pool.recover("myBullet", thisSp);
			}
		}
		
		override public function onDisable():void {
			ani.removeSelf();
			Pool.recover("myBulletAni", ani);
		}
	}
}