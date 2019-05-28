package enemyScript {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.physics.RigidBody;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	public class EnemyThree extends Script {
		/** @prop {name:enemyBullet, tips:"敌人子弹", type:prefab}*/
		public var enemyBullet:Prefab;

		// 本对象
		private var thisSp:Sprite;
		// 背景遮罩
		private var shadeSp:Sprite;
		// 本对象刚体
		private var rigid:RigidBody;
		
		
		override public function onEnable():void {
			// 获取本对象
			thisSp = this.owner as Sprite;
			// 获取本对象刚体
			rigid = thisSp.getComponent(RigidBody);
			rigid.enabled = false; // 先让刚体失效。在下蹲的时候无效效，即不能被击打，其余是有才有效。
			
			// 加载背景遮罩资源
			Laya.loader.load("res/atlas/enemy_three.atlas", Handler.create(this, loaded));
			
		}
		
		/**
		 * 设置遮罩
		 */
		private function loaded():void
		{
			shadeSp = new Sprite();
			shadeSp.loadImage("enemy_three/shade.png");
			shadeSp.width = 30;
			shadeSp.height = 25;
			shadeSp.pos(thisSp.x, thisSp.y + 4);
			thisSp.parent.addChild(shadeSp);
			
			// 开始
			turnUp();
		}
		
		/**
		 * 人物上升
		 */
		private function turnUp():void
		{
			// 启动刚体，此时可以被射击
			rigid.enabled = true;
			
			Tween.to(thisSp, {y: thisSp.y - 14}, 1000, Ease.backInOut, Handler.create(this, shoot));
		}		
		
		/**
		 * 射击
		 */
		private function shoot():void
		{
			// 从对象池中获取子弹
			var bulletSp:Sprite = Pool.getItemByCreateFun("enemyBullet", enemyBullet.create, enemyBullet);
			bulletSp.pos(thisSp.x, thisSp.y + 7);
			// 子弹刚体，设置速度
			var rigid:RigidBody = bulletSp.getComponent(RigidBody);
			rigid.setVelocity({x:-2, y:0});
			if (thisSp.parent) {
				thisSp.parent.addChild(bulletSp);				
			}
			
			// 射击后停顿
			Laya.stage.timer.once(1000, this, turnDown);
		}		

		/**
		 * 人物下降
		 */
		private function turnDown():void
		{
			// 人物射击后下降
			Tween.to(thisSp, {y:thisSp.y + 14}, 1000, Ease.backIn, Handler.create(this, squat));
		}	
		
		
		/**
		 * 人物蹲下停顿
		 */
		private function squat():void
		{
			// 让刚体失效，此时不能被射击
			rigid.enabled = false;
			
			Laya.stage.timer.once(1500, this, turnUp);			
		}		
		
		
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "bullet" && self.label === "enemy_three") {
				// 先隐蔽自己
				thisSp.visible = false;
				
				// 从对象池中加载爆炸动画后播放
				var boomAni:Animation = Pool.getItemByCreateFun("enemyRoleBoom", createEnemyRoleBoomAni, this);
				boomAni.play(0, false, "enemyRoleBoom");
				boomAni.pos(thisSp.x, thisSp.y);
				thisSp.parent.addChild(boomAni);
				
				// 最后清楚所有 timer事件、删除本对象并回收
				Laya.stage.timer.clearAll(this);
				thisSp.removeSelf();
				Pool.recover("enemyThree", thisSp);
			}

		}
		
		/**
		 * 当对象池中没有爆炸动画时，
		 * 则调用此函数创建动画
		 */
		private function createEnemyRoleBoomAni():Animation
		{
			var ani:Animation = new Animation();
			ani.loadAnimation("GameScene/EnemyRoleBoom.ani", null, "res/atlas/boom.atlas");
			
			ani.on(Event.COMPLETE, null, function():void {
				ani.removeSelf();
				Pool.recover("enemyRoleBoom",ani);
			});
			return ani;
		}
		
		override public function onUpdate():void {
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && thisSp.x < scrollRect.x) {
				Tween.clearTween(thisSp); // 清楚该节点上所有的Tween缓东对象
				thisSp.removeSelf();
				Pool.recover("enemyThree", thisSp);	
				shadeSp.removeSelf();
			}
		}
		
		
		override public function onDisable():void {
		
		}
	}
}