package script {
	
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Pool;
	
	public class Boss extends Script {
		/** @prop {name:bullet, tips:"子弹", type:prefab}*/
		public var bullet: Prefab;

		// 本对象盒子
		private var box:Box;
		
		// 所有图片
		private var boss:Sprite;
		private var top01:Sprite;
		private var top02:Sprite;
		private var foot:Sprite;
		
		// 所有动画
		private var top01Ani:Animation;
		private var top02Ani:Animation;
		private var footAni:Animation;
		
		
		override public function onEnable():void {
			// 获取本对象盒子
			box = this.owner as Box;
			
			// 获取所有图片
			boss = box.getChildByName("boss01") as Sprite;
			top01 = box.getChildByName("top01") as Sprite;
			top02 = box.getChildByName("top02") as Sprite;
			foot = box.getChildByName("foot") as Sprite;
		
			// 获取所有动画
			top01Ani = this.owner["top01_ani"] as Animation;
			top02Ani = this.owner["top02_ani"] as Animation;
			footAni = this.owner["foot_ani"] as Animation;
		
			// 播放所有动画
			footAni.play();
			
			top01Shoot();
			
		}
		
		
		/*** top01 与 top02 交替发射子弹 ***/
		
		private function top01Shoot():void {
			top01Ani.play(0, false);
			top01Ani.on(Event.COMPLETE, this, shoot, [1]);
			Laya.timer.once(500, this, top02Shoot);
		}
		
		private function shoot(...args):void
		{
			var posX:Number;
			var posY:Number;
			var velocityX:Number = (Math.random() + 0.1) * 3;
			var velocityY:Number = (Math.random() + 0.1);
			if (args[0] == 1) {
				posX = 5376;
				posY = 208;
				
			} else {
				posX = 5427;
				posY = 208;
			}
			
			// 子弹
			var bulletBox:Box = Pool.getItemByCreateFun("boss01Bullet", bullet.create, bullet);
			bulletBox.pos(posX, posY);
			var bulletSp:Sprite = bulletBox.getChildByName("bullet") as Sprite;
			var bulletRigid:RigidBody = bulletSp.getComponent(RigidBody);
			bulletRigid.setVelocity({x:-velocityX,y:-velocityY});
			box.parent.addChild(bulletBox);
			
			
			console.log(posX,posY,velocityX,velocityY);
		}
		
		private function top02Shoot():void {
			top02Ani.play(0, false);
			top02Ani.on(Event.COMPLETE, this, shoot, [2]);
			Laya.timer.once(500, this, top01Shoot);
		}
		
		/*************************************/
		
		
		override public function onDisable():void {
		}
	}
}