package script {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.physics.BoxCollider;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Handler;
	import laya.utils.Pool;
	
	public class Role extends Script {
		/** @prop {name:enemyOne, tips:"第一类敌人", type:prefab}*/
		public var enemyOne: Prefab;
		/** @prop {name:enemyTow, tips:"第二类敌人", type:prefab}*/
		public var enemyTow: Prefab;
		/** @prop {name:enemyThree, tips:"第三类敌人", type:prefab}*/
		public var enemyThree: Prefab;
		/** @prop {name:enemyFour, tips:"第四类敌人", type:prefab}*/
		public var enemyFour: Prefab;
		/** @prop {name:enemyFive, tips:"第五类敌人", type:prefab}*/
		public var enemyFive: Prefab;
		/** @prop {name:enemyBoss01, tips:"第一关Boss", type:prefab}*/
		public var enemyBoss01: Prefab;
		/** @prop {name:propFrame, tips:"道具框架", type:prefab}*/
		public var propFrame:Prefab;
		
		
		
		/** @prop {name:bullet, tips:"触碰即销毁的地图块", type:prefab}*/
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
		
		
		public function Role():void {
			Role.ROLE = this;
		}
		
	
		override public function onEnable():void {
			
			// 获取本对象精灵
			roleSp = this.owner as Sprite;
			
			
			
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

			roleSp.pos(4720, 0);
				
		}
		

		
		/**
		 * 碰撞回调函数
		 */
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			
			if ((other.label === "pass_n" || other.label === "pass_y") && rigid.linearVelocity.y > 0 && self.label === "foot") {
				rigid.type = "kinematic";
				
				rigid.setVelocity({x:rigid.linearVelocity.x, y:0});
				// 设置此时可以跳跃
				canJump = true;
				// 设置不是跳跃
				isJumping = false;
				// 改变动画
				changeAni(curDirection, curOblique, "fire", "inland", "run");	
				// 触碰到地面时是否显示站立动画
				if (lastAngle == -1) {
					move(lastAngle);
				}
			}
			
			
			if (other.label === "enemy_five" && self.label === "foot") {
				console.log("撞到敌人五");
			}
			
			
			
			
			// 掉落水中时
			if (other.label === "water" && rigid.linearVelocity.y > 0 && self.label === "foot"){
				
				// 设置不是跳跃并且不可跳跃
				isJumping = false;
				canJump = false;
				
				changeAni(curDirection, "nobl", "run", "inwater", "water");
				rigid.type = "kinematic";
				rigid.setVelocity({x:rigid.linearVelocity.x, y:0});
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
			
			
			if (other.label === "produceOne" && self.label === "produce") {
				Laya.stage.timer.loop(1500, this, produceEnemyTow, [900, 128, {x:-1, y:0}]);
				
			}
			if (other.label === "cancelProduceOne" && self.label === "produce") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.once(0, this, produceEnemyOne, ([1000, 290]));
			}
			
			
			if (other.label === "produceTow" && self.label === "produce") {
				Laya.stage.timer.loop(1500, this, produceEnemyTow, [483, 290, {x:2, y:0}]);
			}
			
			if (other.label === "cancelProduceTow" && self.label === "produce") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.loop(1500, this, produceEnemyTow, [1670, 130, {x:-1, y:0}]);
			}
			
			if (other.label === "cancelProduceThree" && self.label === "produce") {
				Laya.stage.clearTimer(this, produceEnemyTow);
			}
			
			
			if (other.label === "produceFour" && self.label === "produce") {
				Laya.stage.timer.loop(2000, this, produceEnemyTow, [1940, 130, {x: -1, y:0}]);
				Laya.stage.timer.once(0, this, produceEnemyOne, ([2000, 128]));
				Laya.stage.timer.once(0, this, produceEnemyThree, ([2200, 154]));
				Laya.stage.timer.once(0, this, produceEnemyFour, ([2040, 240]));
				
			}
			
			if (other.label === "cancelProduceFour" && self.label === "produce") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.loop(2000, this, produceEnemyTow, [2960, 182, {x: -1, y:0}]);
			}

			
			if (other.label === "cancelProduceFive" && self.label === "produce") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.loop(2000, this, produceEnemyTow, [3060, 76, {x: -1, y:0}]);
				Laya.stage.timer.once(0, this, produceEnemyThree, ([2500, 100]));
				Laya.stage.timer.once(0, this, producePropFrame, ([2574, 230]));
			}
			
			
			if (other.label === "cancelProduceSix" && self.label === "produce") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.once(0, this, produceEnemyFour, ([2680, 186]));
			}
			
			if (other.label === "cancelProduceSix" && self.label === "produce") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.once(0, this, produceEnemyFour, ([2680, 186]));
			}
			
			if (other.label === "produceSeven" && self.label === "produce") {
				Laya.stage.timer.once(0, this, produceEnemyFour, ([2950, 201]));
				Laya.stage.timer.loop(2000, this, produceEnemyTow, [3130, 290, {x: -1, y:0}]);
			}
			
			if (other.label === "cancelProduceSeven" && self.label === "produce") {
				Laya.stage.timer.clear(this, produceEnemyTow);
				Laya.stage.timer.once(0, this, produceEnemyTow, [3400, 130, {x: -1, y:0}]);
			}
			
			if (other.label === "produceEight" && self.label === "produce") {
				Laya.stage.timer.once(0, this, produceEnemyFive, ([3380, 240]));
			}
			
			if (other.label === "cancelProduceEight" && self.label === "produce") {
				Laya.stage.timer.once(0, this, produceEnemyFive, ([3593, 78]));
				Laya.stage.timer.once(0, this, producePropFrame, ([3755, 283]));
			}
			
			if (other.label === "produceNine" && self.label === "produce") {
				Laya.stage.timer.once(0, this, produceEnemyOne, ([3893, 182]));
				Laya.stage.timer.once(0, this, produceEnemyTow, [4046, 238, {x: -1, y:0}]);
			}
			
			if (other.label === "cancelProduceNine" && self.label === "produce") {
				// 在这里产生飞行道具
				
				
				Laya.stage.timer.once(0, this, produceEnemyTow, [4582, 183, {x: -1, y:0}]);
				
			}
			
			
			if (other.label === "produceTen" && self.label === "produce") {
				Laya.stage.timer.once(0, this, produceEnemyFive, ([4585, 188]));
				Laya.stage.timer.once(0, this, produceEnemyTow, [4632, 290, {x: -1, y:0}]);
			}
			
			
			if (other.label === "cancelProduceTen" && self.label === "produce") {
				Laya.stage.timer.once(0, this, produceEnemyFour, ([4931, 282]));
				Laya.stage.timer.once(0, this, produceEnemyFour, ([5198, 282]));
			}
			
			if (other.label === "produceEleven" && self.label === "produce") {
				Laya.stage.timer.once(0, this, produceBoss01, ([5382, 67]));
			}
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
		

		
		private function producePropFrame(...args):void
		{
			// 测试--道具框架
			var propFrameSp:Box;
			propFrameSp = propFrame.create() as Box;
			propFrameSp.pos(args[0], args[1]);
			roleSp.parent.addChild(propFrameSp);			
		}
		
		
		/**
		 * 产生第一类敌人
		 */
		private function produceEnemyOne(...args):void {
			// 第一类敌人临时变量
			var enemyOneSp:Sprite;
			enemyOneSp = Pool.getItemByCreateFun("enemyOne", enemyOne.create, enemyOne);
			enemyOneSp.pos(args[0], args[1]);
			roleSp.parent.addChild(enemyOneSp);
		}
		
		
		/**
		 * 产生第二类敌人
		 */
		private function produceEnemyTow(...args):void
		{
			// 第二类敌人临时变量
			var enemyTowSp:Sprite;
			// 初始化第二类敌人
			enemyTowSp = Pool.getItemByCreateFun("enemyTow", enemyTow.create, enemyTow);
			enemyTowSp.pos(args[0], args[1]);
			//设置速度
			var r:RigidBody = enemyTowSp.getComponent(RigidBody);
			r.setVelocity(args[2]);
			roleSp.parent.addChild(enemyTowSp);
		}	
		
		
		/**
		 * 产生第一类敌人
		 */
		private function produceEnemyThree(...args):void {
			// 第三类敌人临时变量
			var enemyThreeSp:Sprite;
			enemyThreeSp = Pool.getItemByCreateFun("enemyThree", enemyThree.create, enemyThree);
			enemyThreeSp.pos(args[0], args[1]);
			roleSp.parent.addChild(enemyThreeSp);
		}
		
		
		/**
		 * 产生第四类敌人
		 */
		private function produceEnemyFour(...args):void {
			// 测试--第四类敌人
			var enemyFourSp:Box;
			enemyFourSp = Pool.getItemByCreateFun("enemyFour", enemyFour.create, enemyFour);
			enemyFourSp.pos(args[0], args[1]);
			roleSp.parent.addChild(enemyFourSp);
		}
		
		/**
		 * 生产第五类敌人
		 */
		private function produceEnemyFive(...args):void
		{
			var enemyFiveSp:Sprite;
			enemyFiveSp = Pool.getItemByCreateFun("enemyFive", enemyFive.create, enemyFive);
			enemyFiveSp.pos(args[0],args[1]);
			roleSp.parent.addChild(enemyFiveSp);	
		}
		
		
		/**
		 * 生产第一关BOSS
		 */
		private function produceBoss01(...args):void {
			var enemyBoss01Sp:Sprite;
			enemyBoss01Sp = Pool.getItemByCreateFun("enemyBoss01", enemyBoss01.create, enemyBoss01);
			enemyBoss01Sp.pos(args[0], args[1]);
			roleSp.parent.addChild(enemyBoss01Sp);
			trace(enemyBoss01Sp);
		}
		
		/**
		 * 跳跃
		 */
		public function jump():void {
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
		 * 开火
		 */
		public function onFire():void {
			
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
			lastAngle = angle;
			
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
				if (rigid.linearVelocity.y != 0) return; 
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
					setBulletInLand(-10, 35, 0, 3, -2);
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
						setBulletInLand(-10, 35, 35, 3, 2);
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
					setCollider(0, 0, 23, 28);
					break;
				}
				// 行走时碰撞区域
				case "run":
				{
					setCollider(0, 0, 25, 55);
					break;
				}
				case "lie":
				{
					setCollider(-12, 34, 55, 28);
					break;					
				}
				case "water":
				{
					setCollider(0, 32, 25, 25);
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