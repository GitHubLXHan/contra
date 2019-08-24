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
	
	import utils.CreateEffect;
	
	public class EnemyFour extends Script {
		/** @prop {name:enemyBullet, tips:"敌人子弹", type:prefab}*/
		public var enemyBullet:Prefab;
		
		// 主角
		private var role:Sprite;
		
		// 本对象盒子
		private var box:Box;
		
		// 目前显现的图片
		private var curShowSp:Sprite
		
		// 目前显示的动画
		private var curShowAni:Animation;
		
		// 人物接近第五类敌人的标志
		private var isAccepted:Boolean;
		
		// 血值
		private var PH:Number;
		
		// 所有的动画
		private var enemyFour01:Animation;
		private var enemyFour03:Animation;
		private var enemyFour04:Animation;
		private var enemyFour05:Animation;
		private var enemyFour06:Animation;
		private var enemyFour07:Animation;
		private var enemyFour08:Animation;
		private var enemyFour09:Animation;
		private var enemyFour10:Animation;
		private var enemyFour11:Animation;
		private var enemyFour12:Animation;
		private var enemyFour13:Animation;
		private var enemyFour14:Animation;
		
		// 所有动画的精灵
		private var enemyFour01Sp:Sprite;
		private var enemyFour03Sp:Sprite;
		private var enemyFour04Sp:Sprite;
		private var enemyFour05Sp:Sprite;
		private var enemyFour06Sp:Sprite;
		private var enemyFour07Sp:Sprite;
		private var enemyFour08Sp:Sprite;
		private var enemyFour09Sp:Sprite;
		private var enemyFour10Sp:Sprite;
		private var enemyFour11Sp:Sprite;
		private var enemyFour12Sp:Sprite;
		private var enemyFour13Sp:Sprite;
		private var enemyFour14Sp:Sprite;
		
		
		// 子弹的参数
		private var bulletX:Number = 0;
		private var bulletY:Number = 0;
		private var bulletvelocityX:Number = -1;
		private var bulletvelocityY:Number = 0;
		
		
		
		override public function onEnable():void {
		
			// 获取主角
			role = Role.ROLE.owner as Sprite;
			
			box = this.owner as Box;

			// 初始化血量
			PH = 10;
			// 初始化标志
			isAccepted = false;
			
			// 获取所有动画的精灵
			
			enemyFour01Sp = box.getChildByName("enemy_four01") as Sprite;
			enemyFour03Sp = box.getChildByName("enemy_four03") as Sprite;
			enemyFour04Sp = box.getChildByName("enemy_four04") as Sprite;
			enemyFour05Sp = box.getChildByName("enemy_four05") as Sprite;
			enemyFour06Sp = box.getChildByName("enemy_four06") as Sprite;
			enemyFour07Sp = box.getChildByName("enemy_four07") as Sprite;
			enemyFour08Sp = box.getChildByName("enemy_four08") as Sprite;
			enemyFour09Sp = box.getChildByName("enemy_four09") as Sprite;
			enemyFour10Sp = box.getChildByName("enemy_four10") as Sprite;
			enemyFour11Sp = box.getChildByName("enemy_four11") as Sprite;
			enemyFour12Sp = box.getChildByName("enemy_four12") as Sprite;
			enemyFour13Sp = box.getChildByName("enemy_four13") as Sprite;
			enemyFour14Sp = box.getChildByName("enemy_four14") as Sprite;

			
			// 获取全部动画
			enemyFour01 = this.owner["enemy_four01_ani"] as Animation;
			enemyFour03 = this.owner["enemy_four03_ani"] as Animation;
			enemyFour04 = this.owner["enemy_four04_ani"] as Animation;
			enemyFour05 = this.owner["enemy_four05_ani"] as Animation;
			enemyFour06 = this.owner["enemy_four06_ani"] as Animation;
			enemyFour07 = this.owner["enemy_four07_ani"] as Animation;
			enemyFour08 = this.owner["enemy_four08_ani"] as Animation;
			enemyFour09 = this.owner["enemy_four09_ani"] as Animation;
			enemyFour10 = this.owner["enemy_four10_ani"] as Animation;
			enemyFour11 = this.owner["enemy_four11_ani"] as Animation;
			enemyFour12 = this.owner["enemy_four12_ani"] as Animation;
			enemyFour13 = this.owner["enemy_four13_ani"] as Animation;
			enemyFour14 = this.owner["enemy_four14_ani"] as Animation;
			
			
			// 初始化全局变量 - curShowSp(目前显示的图片) && curShowAni(目前播放的动画)
			curShowSp  = enemyFour01Sp;
			curShowAni = enemyFour01;
			curShowSp.visible = true;
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
			if (angle >= 75 && angle < 105) {
				changeShow(enemyFour03Sp, enemyFour03);
				// 设置子弹方向及速度
				bulletX = box.x - 1;
				bulletY = box.y - 25;
				bulletvelocityX = 0;
				bulletvelocityY = -1;
			} else if (angle >= 45 && angle < 75) {
				changeShow(enemyFour04Sp, enemyFour04);
				
				bulletX = box.x + 10;
				bulletY = box.y - 25;
				bulletvelocityX = 0.5;
				bulletvelocityY = -1;
			}else if (angle >= 15 && angle < 45) {
				changeShow(enemyFour05Sp, enemyFour05);
				
				bulletX = box.x + 25;
				bulletY = box.y - 15;
				bulletvelocityX = 1;
				bulletvelocityY = -0.5;
			}else if (angle >= 345 && angle < 15) {
				changeShow(enemyFour06Sp, enemyFour06);
				
				bulletX = box.x + 25;
				bulletY = box.y - 1;
				bulletvelocityX = 1;
				bulletvelocityY = 0;
			}else if (angle >= 315 && angle < 345) {
				changeShow(enemyFour07Sp, enemyFour07);
				
				bulletX = box.x + 25;
				bulletY = box.y + 7;
				bulletvelocityX = 1;
				bulletvelocityY = 0.5;
			}else if (angle >= 285 && angle < 315) {
				changeShow(enemyFour08Sp, enemyFour08);
				
				bulletX = box.x + 13;
				bulletY = box.y + 25;
				bulletvelocityX = 0.5;
				bulletvelocityY = 1;
			}else if (angle >= 255 && angle < 285) {
				changeShow(enemyFour09Sp, enemyFour09);
				
				bulletX = box.x;
				bulletY = box.y + 25;
				bulletvelocityX = 0;
				bulletvelocityY = 1;
			}else if (angle >= 225 && angle < 255) {
				changeShow(enemyFour10Sp, enemyFour10);
				
				bulletX = box.x - 13;
				bulletY = box.y + 25;
				bulletvelocityX = -0.5;
				bulletvelocityY = 1;
			}else if (angle >= 195 && angle < 225) {
				changeShow(enemyFour11Sp, enemyFour11);
				
				bulletX = box.x - 25;
				bulletY = box.y + 10;
				bulletvelocityX = -1;
				bulletvelocityY = 0.5;
			}else if (angle >= 165 && angle < 195) {
				changeShow(enemyFour12Sp, enemyFour12);
				
				bulletX = box.x - 25;
				bulletY = box.y - 1;
				bulletvelocityX = -1;
				bulletvelocityY = 0;
			}else if (angle >= 135 && angle < 165) {
				changeShow(enemyFour13Sp, enemyFour13);
				
				bulletX = box.x - 25;
				bulletY = box.y - 13;
				bulletvelocityX = -1;
				bulletvelocityY = -0.5;
			}else if (angle >= 105 && angle < 135) {
				changeShow(enemyFour14Sp, enemyFour14);
				
				bulletX = box.x - 13;
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
					var aniBoom:Animation = Pool.getItemByCreateFun("enemyObjBoom", CreateEffect.getInstance().createEnemyRoleBoomAni, this);
					aniBoom.width = 50;
					aniBoom.height = 50;
					aniBoom.pos(box.x - 15, box.y - 15);
					// 将动画添加到父容器中
					box.parent.addChild(aniBoom);
					// 播放动画
					aniBoom.play(0,false);
					
					// 播放音效
					SoundManager.playSound("sound/enemy_four_five_boom.wav");
					
					// 删除自己
					box.removeSelf();
				}
			}
		}

		
		override public function onUpdate():void {
			
			if (!isAccepted && box.x - role.x < 230) {
				curShowAni.play();
				isAccepted = true;
				// 第四类敌人主循环，每一秒执行一次
				Laya.timer.once(0, this, shootTimeOne);
				Laya.timer.loop(1000, this, calculateAngle);
				
				return ;
			}
			
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && box.x < scrollRect.x) {
				// 删除自己
				box.removeSelf();
			}
		}
		
		
		override public function onDisable():void {
			// 清除所有定时器
			Laya.timer.clearAll(this);
			// 回收到对象池
			console.log('在 Four 中 onDisable');
			Pool.recover("enemyFour", box);
		}
	}
}