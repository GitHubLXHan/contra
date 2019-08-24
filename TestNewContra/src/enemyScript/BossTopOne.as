package enemyScript {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.physics.RigidBody;
	import laya.ui.Image;
	import laya.utils.Pool;
	
	import utils.CreateEffect;
	
	public class BossTopOne extends Script {
		/** @prop {name:bullet, tips:"子弹", type:prefab}*/
		public var bullet: Prefab;
		
		// 枪炮01血量
		private var top01HP:Number = 30;
		
		// 本对象
		private var thisSp:Sprite;
		private var thisParentSp:Sprite;
		private var thisRigid:RigidBody;
		private var top01Ani:Animation;

		override public function onEnable():void {
			// 获取所需对象
			thisSp = this.owner as Sprite;
			thisParentSp = thisSp.parent as Sprite;
			thisRigid = thisSp.getComponent(RigidBody);

			// 获取并播放动画
			top01Ani = this.owner.parent["top01_ani"] as Animation;
			top01Ani.play();
			
			// 发射子弹
			Laya.timer.loop(500, this, shoot);			
		}
		
		
		private function shoot():void
		{
			
			var posX:Number;
			var posY:Number;
			// 初始化子弹刚体速度
			var velocityX:Number = (Math.random() + 0.1) * 3;
			var velocityY:Number = (Math.random() + 0.1);
			posX = thisParentSp.x;
			posY = thisParentSp.y + 140;
			
			// 从回收池中获取子弹并且设置子弹速度
			var bulletSp:Sprite = Pool.getItemByCreateFun("bossOneBullet", bullet.create, bullet);
			var bulletRigid:RigidBody = bulletSp.getComponent(RigidBody);
			bulletSp.pos(posX, posY);
			bulletRigid.setVelocity({x:-velocityX, y:velocityY});
			thisParentSp.parent.addChild(bulletSp);
			
			
		}
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "bullet" && self.label === "boss_top01") {
				top01HP--;
				if (top01HP <= 0) {
					Laya.timer.clear(this, shoot);
					
					console.log("top01销毁");
					// 通过对象池获取动画
					var aniBoom:Animation = Pool.getItemByCreateFun('enemyObjBoom',CreateEffect.getInstance().createEnemyObjBoomAni, this);
					if (aniBoom) {
						aniBoom.pos(thisSp.x, thisSp.y);
						// 播放动画
						aniBoom.play(0,false);
						// 将动画添加到父容器中
						thisSp.parent.addChild(aniBoom);	
						
						var shade:Image = new Image();
						shade.skin = "boss/boss_one_top01_boomed.png";
						shade.x = 14;
						shade.y = 135;
						
						// 直接销毁自己，destroy时会移除自身的监听事件，自身的 timer事件，移除子节点以及自己
						// destroy对象默认会把自己从父节点移除，并且清理自身引用关系，等待js自动垃圾回收机制回收
						thisSp.destroy(true);						
					}
					

				}
			}
		}
	
		
		override public function onDisable():void {
			
		}
	}
}