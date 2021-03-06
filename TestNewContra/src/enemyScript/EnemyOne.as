package enemyScript {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.physics.RigidBody;
	import laya.utils.Pool;
	
	import script.Role;
	
	import utils.CreateEffect;
	
	public class EnemyOne extends Script {

		/** @prop {name:enemyBullet, tips:"敌人子弹", type:prefab}*/
		public var enemyBullet:Prefab;

		// 第一类敌人
		private var thisSp:Sprite;

		// 主角色
		private var role:Sprite;	
		
		// 是否需要改变图片
		private var isNeedChange:Boolean = false;
		
		// 射击的方向
		private var dir:Object = {x:-1, y:-1}; 
		
		override public function onEnable():void {
			// 获取自己
			thisSp = this.owner as Sprite;
			// 获取主角色
			role = Role.ROLE.owner as Sprite;
			// 加载第一类敌人的图集
			Laya.loader.load("res/atlas/enemy_one.atlas");
			// 设置定时器，定时发射子弹
			Laya.timer.once(0, this, shootTimeOne);
		}
		
		/**
		 * 发射子弹
		 */
		private function onFire():void
		{
			// 从对象池中加载子弹
			var bulletSp:Sprite = Pool.getItemByCreateFun("enemyBullet", enemyBullet.create, enemyBullet);
			bulletSp.pos(thisSp.x + 15, thisSp.y + 8);
			// 子弹刚体，设置速度
			var bulletRigid:RigidBody = bulletSp.getComponent(RigidBody);
			bulletRigid.setVelocity(dir);
			thisSp.parent.addChild(bulletSp);
		}		
		
		
		/**
		 * 第一颗子弹
		 * 停顿600毫秒后发射第二颗
		 */
		private function shootTimeOne():void{
			onFire();
			Laya.timer.once(600, this, shootTimeTow);
		}
		
		/**
		 * 第二颗子弹
		 * 停顿600毫秒后发射第三颗
		 */
		private function shootTimeTow():void{
			onFire();
			Laya.timer.once(600, this, shootTimeThree);
		}
		
		/**
		 * 第三颗子弹
		 * 停顿2.5秒后重复发射一二三颗子弹
		 */
		private function shootTimeThree():void{
			onFire();
			Laya.timer.once(2500, this, shootTimeOne);
		}
		
		
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "bullet" && self.label === "enemy_one") {
				// 从对象池中加载爆炸动画后播放
				var boomAni:Animation = Pool.getItemByCreateFun("enemyRoleBoom", CreateEffect.getInstance().createEnemyRoleBoomAni, this);
				boomAni.play(0, false, "enemyRoleBoom");
				boomAni.pos(thisSp.x, thisSp.y);
				thisSp.parent.addChild(boomAni);
				
				// 删除自己待系统回收
				thisSp.removeSelf();
				
			}
		}

		override public function onUpdate():void {
			var imgPath:String;
			
			if (role.x < thisSp.x) 
			{
				if (role.y < thisSp.y - 50) {
					imgPath = "enemy_one/enemy_one_left03.png";
					dir = {x:-1, y:-1};
					isNeedChange = true;
				} else if (role.y > thisSp.y + 50) {
					imgPath = "enemy_one/enemy_one_left01.png";
					isNeedChange = true;
					dir = {x:-1, y:1};
				} else {
					imgPath = "enemy_one/enemy_one_left02.png";
					isNeedChange = true;
					dir = {x:-1, y:0};
				}
			} else {
				if (role.y < thisSp.y - 50) {
					imgPath = "enemy_one/enemy_one_right03.png";
					isNeedChange = true;
					dir = {x:1, y:-1};
				} else if (role.y > thisSp.y + 50) {
					imgPath = "enemy_one/enemy_one_right01.png";
					isNeedChange = true;
					dir = {x:1, y:1};
				} else {
					imgPath = "enemy_one/enemy_one_right02.png";
					isNeedChange = true;
					dir = {x:1, y:0};
				}
			}
			
			if (isNeedChange) {
				thisSp.loadImage(imgPath);
			}
			
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && thisSp.x < scrollRect.x) {
				thisSp.removeSelf();
				Pool.recover("enemyOne", thisSp);			
			}
			
		}
		
		
		override public function onDisable():void {
			// 清除所有定时器
			Laya.timer.clearAll(this);
			// 回收自己
			console.log('enmeyOne在OnDisable中回收');
			Pool.recover("enemyOne", thisSp);
			
		}
		
	}
}