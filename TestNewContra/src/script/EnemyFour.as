package script {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Pool;
	
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
		private var PH:Number = 10;
		
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
		
		
		
		
		override public function onEnable():void {
		
			// 获取主角
			role = Role.ROLE.owner as Sprite;
			
			box = this.owner as Box;
			box.anchorX = 0.5;
			box.anchorY = 0.5;
				
			
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
				shoot(box.x - 1, box.y - 25, 0, -1);
			} else if (angle >= 45 && angle < 75) {
				changeShow(enemyFour04Sp, enemyFour04);
				shoot(box.x + 10, box.y - 25, 0.5, -1);
			}else if (angle >= 15 && angle < 45) {
				changeShow(enemyFour05Sp, enemyFour05);
				shoot(box.x + 25, box.y - 15, 1, -0.5);
			}else if (angle >= 345 && angle < 15) {
				changeShow(enemyFour06Sp, enemyFour06);
				shoot(box.x + 25, box.y - 1, 1, 0);
			}else if (angle >= 315 && angle < 345) {
				changeShow(enemyFour07Sp, enemyFour07);
				shoot(box.x + 25, box.y + 7, 1, 0.5);
			}else if (angle >= 285 && angle < 315) {
				changeShow(enemyFour08Sp, enemyFour08);
				shoot(box.x + 13, box.y + 25, 0.5, 1);
			}else if (angle >= 255 && angle < 285) {
				changeShow(enemyFour09Sp, enemyFour09);
				shoot(box.x, box.y + 25, 0, 1);
			}else if (angle >= 225 && angle < 255) {
				changeShow(enemyFour10Sp, enemyFour10);
				shoot(box.x - 13, box.y + 25, -0.5, 1);
			}else if (angle >= 195 && angle < 225) {
				changeShow(enemyFour11Sp, enemyFour11);
				shoot(box.x - 25, box.y + 10, -1, 0.5);
			}else if (angle >= 165 && angle < 195) {
				changeShow(enemyFour12Sp, enemyFour12);
				shoot(box.x - 25, box.y - 1, -1, 0);
			}else if (angle >= 135 && angle < 165) {
				changeShow(enemyFour13Sp, enemyFour13);
				shoot(box.x - 25, box.y - 13, -1, -0.5);
			}else if (angle >= 105 && angle < 135) {
				changeShow(enemyFour14Sp, enemyFour14);
				shoot(box.x -13, box.y - 25, -0.5, -1);
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
					// 先隐藏自己
					box.visible = false;
					
					// 通过对象池获取动画
					var aniBoom:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
					aniBoom.width = 50;
					aniBoom.height = 50;
					aniBoom.pos(box.x - 15, box.y - 15);
					// 将动画添加到父容器中
					box.parent.addChild(aniBoom);
					// 播放动画
					aniBoom.play(0,false);
					
					// 最后删除自己并回收
					box.removeSelf();
					Pool.recover("enemyFour", box);
					
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
			
			if (!isAccepted && box.x - role.x < 230) {
				curShowAni.play();
				isAccepted = true;
				// 第四类敌人主循环，每一秒执行一次
				Laya.timer.loop(1200, this, calculateAngle);
				return ;
			}
			
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && box.x < scrollRect.x) {
				box.removeSelf();
				Pool.recover("enemyFour", box);
			}
		}
		
		
		override public function onDisable():void {
			Laya.stage.timer.clear(this, calculateAngle);
		}
	}
}