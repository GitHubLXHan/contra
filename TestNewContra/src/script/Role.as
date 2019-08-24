package script {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.media.SoundManager;
	import laya.physics.BoxCollider;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Handler;
	import laya.utils.Pool;
	
	public class Role extends Script {
		
		/** @prop {name:bullet, tips:"子弹", type:prefab}*/
		public var bullet:Prefab;

		
		// 静态访问接口
		public static var ROLE:Role;
		
		//人物动画
		private var ani:Animation;
		// 本对象精灵
		private var roleSp:Sprite;
		// 本对象父节点 - 即背景节点
		private var roleParentSp:Sprite;

		
		// 人物精灵刚体
		private var rigid:RigidBody;
		// 人物精灵身体碰撞区
		private var bodyBox:BoxCollider;
		// 人物精灵脚步碰撞区
		private var footBox:BoxCollider;
		
		
		// 人物目前方向,并且初始化
		private var curDirection:String = "r";
		// 人物目前倾斜发向
		private var curOblique:String = "nobl";
		// 人物目前动作
		private var curBehavior:String = "jump";
		//人物目前所处位置
		private var curWhere:String = "inland";
		// 人物子弹类型
		private var bulletType:Number = 1;
		// 摇杆最后一次移动的角度
		private var lastAngle:Number = -1; // -1表示没有移动
		
		
		// 人物是否可以跳跃、否正在跳跃，并且初始化
		private var canJump:Boolean = true;
		private var isJumping:Boolean = true;
		// 人物是否存活
		public var isAlive:Boolean = true;
		
		
		public function Role():void {
			Role.ROLE = this;
		}
		
	
		override public function onEnable():void {
			
			// 获取本对象精灵
			roleSp = this.owner as Sprite;
			roleSp.pos(66, 0);
			
			
			// 获取父节点
			roleParentSp = roleSp.parent as Sprite;
			
			
			// 获取人物精灵刚体
			rigid = roleSp.getComponent(RigidBody);
			
			// 获取人物精灵碰撞区
			var boxs:Array = roleSp.getComponents(BoxCollider);
			bodyBox = boxs[1];
			footBox = boxs[0];
			
			// 实例化动画并加载动画资源
			ani = new Animation();
			ani.loadAnimation("GameScene/Role.ani", Handler.create(this, onAniLoaded), "res/atlas/role_blue.atlas" );
		}
		
		/**
		 * 碰撞回调函数
		 */
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			
			if ((other.label === "pass_n" || other.label === "pass_y") && rigid.linearVelocity.y > 0 && self.label === "foot") {
				rigid.type = "kinematic";
				
				if (isAlive) {
					rigid.setVelocity({x:rigid.linearVelocity.x, y:0});
					// 设置此时可以跳跃
					canJump = true;
					// 设置不是跳跃
					isJumping = false;
					// 改变动画
					changeAni(curDirection, curOblique, "fire", "inland", "run");	
				} else {
					rigid.setVelocity({x:0, y:0});
					ani.gotoAndStop(4);
					rigid.enabled = false;
				}
					
				// 触碰到地面时是否显示站立动画
				if (lastAngle == -1) {
					move(lastAngle);
				}
			}
		
			
			// 掉落水中时
			if (other.label === "water" && rigid.linearVelocity.y > 0 && self.label === "foot"){
				rigid.type = "kinematic";
				if (isAlive) {
					// 设置不是跳跃并且不可跳跃
					isJumping = false;
					canJump = false;
					changeAni(curDirection, "nobl", "run", "inwater", "run");
					rigid.setVelocity({x:rigid.linearVelocity.x, y:0});
				} else {
					rigid.setVelocity({x:0, y:0});
					ani.gotoAndStop(4);
					rigid.enabled = false;
				}
				
				// 触碰到水面时是否显示站立动画
				if (lastAngle == -1) {
					move(lastAngle);
				}
				
			}
			
			
			// 当触碰到墙时
			if (other.label === "wall" && !isJumping) {
				changeAni(curDirection, curOblique, "fire", "inland", "run");	
				canJump = true;
				rigid.setVelocity({x:rigid.linearVelocity.x, y:-1});
			}
			
			
			// 当触碰到自动销毁地图时
			if (other.label === "touchDestroy" && self.label === "body") {
				// 可以跳跃
				canJump = true;
			}
			
			// 触碰到敌人或者掉下去时死亡
			if ((other.label === "enemy_bullet" || 
				other.label === "bossOneBullet" || 
				other.label === "enemy_one" ||
				other.label === "enemy_tow" ||
				other.label === "enemy_three" ||
				other.label === "die_line") && 
				self.label === "body" &&
				isAlive) {
				isAlive = false;
				ani.play(0, false, "blue_" + curDirection + "_nobl_die_any");
				rigid.type = "dynamic";
				rigid.setVelocity({x:-rigid.linearVelocity.x, y: -5});
				Laya.stage.timer.clearAll(Controller);
			}
			
			
			
		}
		
		
		/**
		 * 重新设置人物状态，相当于复活
		 */
		public function reStart():void {
			// 人物目前方向,并且初始化
			curDirection = "r";
			// 人物目前倾斜发向
			curOblique = "nobl";
			// 人物目前动作
			curBehavior = "jump";
			//人物目前所处位置
			curWhere = "inland";
			// 人物子弹类型
			bulletType = 1;
			// 摇杆最后一次移动的角度
			lastAngle = -1; // -1表示没有移动
			
			
			// 人物是否可以跳跃、否正在跳跃，并且初始化
			canJump = false;
			isJumping = true;
			// 人物是否存活
			isAlive = true;
			
			// 播放跳跃动画
			ani.play(0, true, "blue_r_nobl_jump_inland");
			
			
			// 重新启动刚体
			rigid.enabled = true;
			rigid.type = "dynamic";
			
			
		}
		
		
		public function pause():void {
			SoundManager.stopAll();
			
		}
		
		/**
		 * 碰撞结束
		 */
		override public function onTriggerExit(other:*, self:*, contact:*):void {
			if((other.label === "pass_y" || other.label === "pass_n") && !isJumping && self.label === "foot") {
				rigid.type = "dynamic";
				// 设置此时不可跳跃
				canJump = false;
				
			}
		}

		
		/**
		 * 向上跳跃
		 */
		public function jumpUp():void {
			if (!isAlive) return;  // 死亡状态下无法操作 
			if (!canJump) return;
			rigid.type = "dynamic";
			rigid.gravityScale = 1;
			rigid.linearVelocity = {x:rigid.linearVelocity.x, y:-6};
			canJump = false;
			// 播放跳跃动画
			changeAni(curDirection, "nobl", "jump", "inland", "jump");
			// 设置此时是在跳跃
			isJumping = true;
		}
		
		
		/**
		 * 向下跳跃
		 */
		public function jimpDown():void {
			if (curBehavior === "lie") {
				console.log("下去");
				rigid.type = "dynamic";
				rigid.applyForceToCenter({x:0, y:-50});
				changeAni(curDirection, "nobl", "jump", "inland", "jump");
			}
		}
		
		

		/**
		 * 开火
		 */
		public function onFire():void {
			
			if (!isAlive) return;  // 死亡状态下无法操作 
			
			// 播放音效
			SoundManager.playSound("sound/hitsnd1.wav");
			
			switch(bulletType)
			{
				case 1:
				{
					// 子弹
					var bulletSp:Sprite = Pool.getItemByCreateFun("myBullet", bullet.create, bullet);
					
					bulletSp.pos(roleSp.x + bulletOffsetForRoleX, roleSp.y + bulletOffsetForRoleY);
					
					var bulletRigid:RigidBody = bulletSp.getComponent(RigidBody);
					bulletRigid.setVelocity({x:bulletVelocityX,y:bulletVelocityY});
					roleParentSp.addChild(bulletSp);
		
					break;
				}
					
				default:
				{
					break;
				}
			}
			
						
			
			
			
		}
		
//		blue_方向_是否倾斜_行为_在哪里
//		blue_l_nobl_fire_inland
//		blue_r_nobl_fire_inland
//		blue_l_uobl_fire_inland
//		blue_r_uobl_fire_inland
//		blue_l_dobl_fire_inland
//		blue_r_dobl_fire_inland
//		blue_l_nobl_lie_inland
//		blue_r_nobl_lie_inland
//		blue_l_nobl_jump_inland
//		blue_r_nobl_jump_inland
//		blue_l_nobl_run_inland
//		blue_r_nobl_run_inland
//		blue_l_nobl_upfire_inland
//		blue_r_nobl_upfire_inland
		
//		blue_l_nobl_die_any
//		blue_r_nobl_die_any
		
//		blue_l_nobl_ufire_inwater
//		blue_r_nobl_ufire_inwater
//		blue_l_uobl_fire_inwater
//		blue_r_ubl_fire_inwater
//		blue_l_nobl_run_inwater
//		blue_r_nobl_run_inwater
		
		
		
		private var bulletOffsetForRoleX:Number;
		private var bulletOffsetForRoleY:Number;
		private var bulletVelocityX:Number;
		private var bulletVelocityY:Number;

		
		
		/**
		 * 移动人物，这是一个对外接口
		 * 通过摇杆的方向，改变人物当前的各种状态（curDirection/curOblique等等）
		 * 再调用动画转换函数（changeAni()）转换动画播放
		 * @param angle:摇杆角度
		 */
		public function move(angle:Number):void {
			if (!isAlive) return;  // 死亡状态下无法操作 
			
			lastAngle = angle; // 记录最后一次角度
			
			if (angle >= 67.5 && angle < 112.5) { // 上
				rigid.linearVelocity = {x:0, y:rigid.linearVelocity.y};		
				// 更改播放动画
				changeAni(curDirection, "nobl", "upfire", curWhere, "run");
				// 设置子弹的位置及方向
				if (curWhere === "inland") {
					setBulletInLand(3, 24, -20, 0, -3);
				} else if (curWhere === "inwater") {
					setBulletInWater(3, 24, 20, 0, -3);
				}
			}else if (angle >= 247.5 && angle < 292.5){ // 下
				if (rigid.linearVelocity.y == 0) { // 无跳跃时
					// 更改播放动画
					changeAni(curDirection, "nobl", "lie", curWhere, "lie");
					// 停止移动
					rigid.setVelocity({x:0, y:0});
					// 设置子弹的位置及方向
					if (curWhere === "inland") {
						setBulletInLand(-10, 40, 45, 3, 0);
					} else if (curWhere === "inwater") {
						setBulletInWater(-15, 45, 51, 3, 0);
					}	
				} else {
					// 跳跃时	
					setBulletInLand(10, 10, 30, 0, 3);
				}
				
			} else if (angle >= 157.5 && angle < 202.5) { // 左
				// 播放向左走动画
				rigid.linearVelocity = {x:-1.5, y:rigid.linearVelocity.y};
				// 更改播放动画
				changeAni("l", "nobl", "fire", curWhere, "run");
				// 设置子弹相对于人物偏移的位置及方向
				if (curWhere === "inland") {
					setBulletInLand(-15, 45, 19, 3, 0);				
				} else if (curWhere === "inwater") {
					setBulletInWater(-15, 45, 51, 3, 0);
				}
			} else if ((angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360)) { // 右
				// 向右走
				rigid.setVelocity({x:1.5, y:rigid.linearVelocity.y});
				// 更改播放动画
				changeAni("r", "nobl", "fire", curWhere, "run");
				// 设置子弹的位置及方向
				if (curWhere === "inland") {
					setBulletInLand(-15, 45, 19, 3, 0);
				} else if (curWhere === "inwater") {
					setBulletInWater(-15, 45, 51, 3, 0);
				}
			} else if (angle >= 112.5 && angle < 157.5) { // 左上
				// 向左走
				rigid.setVelocity({x:-1.5, y:rigid.linearVelocity.y});
				// 更改播放动画
				changeAni("l", "uobl", "fire", curWhere, "run");
				// 设置子弹的位置及方向
				if (curWhere === "inland") {
					setBulletInLand(-10, 35, 0, 3, -2);
				} else if (curWhere === "inwater") {
					setBulletInWater(-10, 35, 32, 3, -2);
				}
			} else if (angle >= 202.5 && angle < 247.5) { // 左下
				// 向左走
				rigid.setVelocity({x:-1.5, y:rigid.linearVelocity.y});
				// 更改播放动画
				changeAni("l", "dobl", "fire", curWhere, "run");
				// 设置子弹的位置及方向
				if (curWhere === "inland") {
					setBulletInLand(-10, 35, 35, 3, 2);
				} else if (curWhere === "inwater") {
					setBulletInWater(-15, 45, 51, 3, 0);
				}
			} else if (angle >= 22.5 && angle < 67.5) { // 右上
				// 向右上走
				rigid.setVelocity({x:1.5, y:rigid.linearVelocity.y});
				// 更改播放动画
				changeAni("r","uobl", "fire", curWhere, "run");
				// 设置子弹的位置及方向
				if (curWhere === "inland") {
					setBulletInLand(10, 35, 0, 3, -2);
				} else if (curWhere === "inwater") {
					setBulletInWater(-10, 35, 32, 3, -2);
				}
			} else if (angle >= 292.5 && angle < 337.5) { // 右下
				// 向右走
				rigid.setVelocity({x:1.5, y:rigid.linearVelocity.y});
				// 更改播放动画
				changeAni("r","dobl", "fire", curWhere, "run");
				// 设置子弹的位置及方向
				if (curWhere === "inland") {
					setBulletInLand(-10, 35, 35, 3, 2);
				} else if (curWhere === "inwater") {
					setBulletInWater(-15, 45, 51, 3, 0);
				}
			} else { // 其他情况
				rigid.linearVelocity = {x:0, y:rigid.linearVelocity.y};
				if (!isJumping) {
					changeAni(curDirection,"nobl", "stand", curWhere, "run");	
					// 设置子弹的位置及方向
					if (curWhere === "inland") {
						setBulletInLand(-15, 45, 19, 3, 0);
					} else if (curWhere === "inwater") {
						setBulletInWater(-15, 45, 51, 3, 0);
					}
				}
			}
		}
		
		
		/**
		 * 转换人物动画
		 */
		private function changeAni(dir:String, obl:String, behavior:String, where:String, collider:String):void {
			if ((curDirection != dir ||curOblique!=obl || curBehavior!=behavior || curWhere!=where) && !isJumping) {
				ani.stop();
				var aniName:String = "blue_"+dir+"_"+obl+"_"+behavior+"_"+where;
				ani.play(0, true, aniName);
				curOblique = obl;
				curBehavior  = behavior;
				curWhere = where;
				// 更改站立或行走时碰撞区
				changeCollider(collider);
			}
			curDirection = dir;
			
		}
		
		
		/**
		 * 在陆地上的情况
		 * 设置子弹相对于人物的偏移位置及方向
		 */
		private function setBulletInLand(...args):void{
			if (curDirection === "l") {
				bulletOffsetForRoleX = args[0];
				bulletOffsetForRoleY = args[2];
				bulletVelocityX = -args[3];
				bulletVelocityY = args[4];
				
			} else if (curDirection === "r") {
				bulletOffsetForRoleX = args[1];
				bulletOffsetForRoleY = args[2];
				bulletVelocityX = args[3];
				bulletVelocityY = args[4];	
			}
		}
		
		
		
		private function setBulletInWater(...args):void {
			if (curDirection === "l") {
				bulletOffsetForRoleX = args[0];
				bulletOffsetForRoleY = args[2];
				bulletVelocityX = -args[3];
				bulletVelocityY = args[4];
				
			} else if (curDirection === "r") {
				bulletOffsetForRoleX = args[1];
				bulletOffsetForRoleY = args[2];
				bulletVelocityX = args[3];
				bulletVelocityY = args[4];	
			}
		}
		
		
	
		/**
		 * 更改碰撞区域
		 */
		private function changeCollider(state:String):void {
			switch(state)
			{
				// 跳跃时碰撞区域
				case "jump":
				{
					if (curWhere === "inwater") return;
					setCollider(0, 0, 26, 30);
					break;
				}
				// 行走时碰撞区域
				case "run":
				{
					if (curBehavior === "jump") return;
					if (curWhere === "inland") {
						setCollider(0, 0, 25, 55);	
					} else {
						setCollider(0, 34, 25, 25);		
					}
					
					break;
				}
				case "lie":
				{
					if (curBehavior === "jump" || curWhere === "inwater") return;
					setCollider(-12, 34, 55, 28);
					break;					
				}
				default:
				{
					break;
				}
			}
		}
		
		private function setCollider(x:Number, y:Number, width:Number, height:Number):void {
			bodyBox.x = x;
			bodyBox.y = y;
			bodyBox.width = width;
			bodyBox.height = height;
		}
		
		
		
		/**
		 * 加载完动画资源后的回调函数
		 * 用于隐藏本对象精灵以及将动画添加到背景中
		 */
		private function onAniLoaded():void
		{
			roleSp.visible = false;
			ani.play(0, true, "blue_r_nobl_jump_inland");
			roleParentSp.addChild(ani);
		}
		
		
		/**
		 * 本对象精灵的位置随刚体位置变化而变化，
		 * 则动画位置随精灵位置变化而变化
		 */
		override public function onUpdate():void {
			ani.x = roleSp.x;
			ani.y = roleSp.y;
			
		}
		
		override public function onDisable():void {
			
		}
	}
}