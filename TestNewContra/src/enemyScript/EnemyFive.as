package enemyScript {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.media.SoundManager;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Pool;
	
	import script.Role;
	
	public class EnemyFive extends Script {
		/** @prop {name:enemyBullet, tips:"敌人子弹", type:prefab}*/
		public var enemyBullet:Prefab;
		
		// 本对象
		private var box:Box;
		
		// 人物对象
		private var role:Sprite;
		
		// 目前显现的图片
		private var curShowSp:Sprite
		
		// 目前显示的动画
		private var curShowAni:Animation;
		
		// 血值
		private var PH:Number;
		
		// 所有图片
		private var enemyFiveSp01:Sprite;
		private var enemyFiveSp02:Sprite;
		private var enemyFiveSp03:Sprite;
		private var enemyFiveSp04:Sprite;
		
		
		// 所有动画
		private var enemyFiveAni01:Animation;
		private var enemyFiveAni02:Animation;
		private var enemyFiveAni03:Animation;
		private var enemyFiveAni04:Animation;
		
		// 子弹的参数
		private var bulletX:Number = 0;
		private var bulletY:Number = 0;
		private var bulletvelocityX:Number = -1;
		private var bulletvelocityY:Number = 0;
		
		override public function onEnable():void {
			// 获取本对象并设置中心点
			box = this.owner as Box;
			box.visible = true;
			
			
			// 初始化血量
			PH = 10;
			
			// 获取人物对象
			role = Role.ROLE.owner as Sprite;
			
			// 获取所有图片
			enemyFiveSp01 = box.getChildByName("enemy_five01") as Sprite;
			enemyFiveSp02 = box.getChildByName("enemy_five02") as Sprite;
			enemyFiveSp03 = box.getChildByName("enemy_five03") as Sprite;
			enemyFiveSp04 = box.getChildByName("enemy_five04") as Sprite;
			
			
			// 获取所有动画
			enemyFiveAni01 = this.owner["enemy_five01_ani"] as Animation;
			enemyFiveAni02 = this.owner["enemy_five02_ani"] as Animation;
			enemyFiveAni03 = this.owner["enemy_five03_ani"] as Animation;
			enemyFiveAni04 = this.owner["enemy_five04_ani"] as Animation;
			
			// 初始化目前显示图片及播放动画的变量
			curShowSp = enemyFiveSp01;
			curShowAni = enemyFiveAni01;			
			
			// 先播放第五类敌人上升的动画
			enemyFiveAni01.play(0, false);
			enemyFiveAni01.on(Event.COMPLETE, this, function start():void {
				// 开始第五类敌人主循环
				calculateAngle(); // 先运行一次 calculateAngle 是为了避免下面开启循环时需等待 1 秒后再执行带来的不流畅感
				Laya.timer.loop(1000, this, calculateAngle);
				// 反射子弹
				Laya.timer.once(0, this, shootTimeOne);
			});

		}

		
		/**
		 * 以第四类敌人中心点为中心，
		 * 向下为 y 轴正方，
		 * 向右为 x 轴正方。
		 * 以x轴正方为起始线，
		 * 计算人物与第四类敌人（中心点）所形成的的角度。
		 */
		private function calculateAngle():void {
			
			// 计算角度
			var xx:Number = Math.pow(Math.abs(role.x - box.x), 2);
			var yy:Number = Math.pow(Math.abs(role.y - box.y), 2);
			var radius:Number = Math.sqrt(xx + yy);
			var rad:Number = getRad(role.x - box.x, role.y - box.y, radius);
			var angle:Number = 180 / Math.PI * rad;
			
			// 不同角度改变不同的图片、动画以及发射子弹
			if (angle >= 145 && angle < 360) {
				changeShow(enemyFiveSp02, enemyFiveAni02);
				// 设置子弹方向及速度
				bulletX = box.x - 25;
				bulletY = box.y - 1;
				bulletvelocityX = -1;
				bulletvelocityY = 0;
			} else if (angle >= 112.5 && angle < 145) {
				changeShow(enemyFiveSp03, enemyFiveAni03);
				
				bulletX = box.x - 25;
				bulletY = box.y - 15;
				bulletvelocityX = -1;
				bulletvelocityY = -0.5;
			}else if (angle >= 0 && angle < 112.5) {
				changeShow(enemyFiveSp04, enemyFiveAni04);
				
				bulletX = box.x - 15;
				bulletY = box.y - 25;
				bulletvelocityX = -0.5;
				bulletvelocityY = -1;
			}
			
		}
		
		/**
		 * 改变显示的图片及动画
		 * @param Sp 将要显示的图片
		 * @param ani 将要播放的动画
		 */
		private function changeShow(Sp:Sprite, ani:Animation):void
		{
			// 停止先前的动画及隐藏先前的图片
			curShowAni.stop();
			curShowSp.visible = false;
			// 更改目前的动画及目前的图片的引用地址
			curShowSp = Sp;
			curShowAni = ani;
			// 显示图片及播放动画
			curShowSp.visible = true;
			curShowAni.play();
			
		}		
		
		
		/**
		 * 发射子弹
		 * @param x 子弹要发射的 x 坐标
		 * @param y 子弹摇发射的 y 坐标
		 * @param velocityX 子弹 x 线性速度
		 * @param velocityY 子弹 y 线性速度
		 */
		private function shoot(x:Number, y:Number, velocityX:Number, velocityY:Number):void {
			// 从对象池中加载子弹
			var bulletSp:Sprite = Pool.getItemByCreateFun("enemyBullet", enemyBullet.create, enemyBullet);
			bulletSp.pos(x, y);
			// 子弹刚体，设置速度
			var bulletRigid:RigidBody = bulletSp.getComponent(RigidBody);
			bulletRigid.setVelocity({x:velocityX, y:velocityY});
			box.parent.addChild(bulletSp);
		}
		
		
		/**
		 * 第一颗子弹
		 * 停顿600毫秒后发射第二颗
		 */
		private function shootTimeOne():void{
			shoot(bulletX,bulletY,bulletvelocityX,bulletvelocityY);
			Laya.timer.once(600, this, shootTimeTow);
		}
		
		/**
		 * 第二颗子弹
		 * 停顿600毫秒后发射第三颗
		 */
		private function shootTimeTow():void{
			shoot(bulletX,bulletY,bulletvelocityX,bulletvelocityY);
			Laya.timer.once(600, this, shootTimeThree);
		}
		
		/**
		 * 第三颗子弹
		 * 停顿2.5秒后重复发射一二三颗子弹
		 */
		private function shootTimeThree():void{
			shoot(bulletX,bulletY,bulletvelocityX,bulletvelocityY);
			Laya.timer.once(2500, this, shootTimeOne);
		}
		
		
		/**
		 * 获取以第四类敌人为为中心，人物位置与第四类敌人，
		 * 以x轴正方为起始线的弧度值
		 * 
		 */
		private function getRad(xx:Number, yy:Number, moveRadius:Number):Number{
			var rad:Number = yy >= 0 ? (Math.PI * 2 - Math.acos(xx / moveRadius)) : (Math.acos(xx / moveRadius));			
			return rad;
		}
		
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "bullet") {
				PH --;
				if (PH <= 0) {
					// 通过对象池获取动画
					var aniBoom:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
					aniBoom.width = 50;
					aniBoom.height = 50;
					aniBoom.pos(box.x - 25, box.y - 25);
					// 将动画添加到父容器中
					box.parent.addChild(aniBoom);
					// 播放动画
					aniBoom.play(0,false);
					
					// 播放音效
					SoundManager.playSound("sound/enemy_four_five_boom.wav");
					
					// 最后删除自己并回收
					box.removeSelf();
					Pool.recover("enemyFive", box);
					
				}
			}
		}
		
		// 创建爆炸动画
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
		
		
		
		override public function onUpdate():void {	
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && box.x < scrollRect.x) {
				box.removeSelf();
				Pool.recover("enemyFive", box);
			}
			
		}
		
		override public function onDisable():void {
			Laya.timer.clearAll(this);
		}
	}
}