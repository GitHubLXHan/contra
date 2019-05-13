package script {
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.physics.BoxCollider;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	
	public class PropFrame extends Script {

		
		
		private var canShootSp:Sprite;
		private var noShootSp:Sprite;
		private var canShootAni:Animation;
		private var rigid:RigidBody;
		
		override public function onEnable():void {
			
			var box:Box = this.owner as Box;
			canShootSp = box.getChildByName("can_shoot") as Sprite;
			canShootSp.visible = false;
			noShootSp = box.getChildByName("no_shoot") as Sprite;
			noShootSp.visible = false;
			
			rigid = canShootSp.getComponent(RigidBody);
		
			canShootAni = this.owner["can_shoot_ani"] as Animation;
		
			playNoShoot();
				
		}
		
		/**
		 * 不启动刚体，显示关闭状态的图片，
		 * 时间维持一秒，期间子弹不可击打该道具
		 */
		private function playNoShoot():void
		{
			rigid.enabled = false;
			noShootSp.visible = true;
			canShootSp.visible = false;			
			Laya.timer.once(1000, this, playCanShoot);
		}
		
		/**
		 * 启动刚体，播放打开状态的动画，
		 * 时间维持一秒，期间子弹可以击打该道具
		 */
		private function playCanShoot():void
		{
			rigid.enabled = true;
			noShootSp.visible = false;
			canShootSp.visible = true;
			canShootAni.play(0, false, "can_shoot_ani");
			Laya.timer.once(1000, this, playNoShoot);
		}
		
		
		
		
		

		
		
		
		override public function onDisable():void {
		}
	}
}