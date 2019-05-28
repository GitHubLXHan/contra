package script {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.display.Text;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.maths.Rectangle;
	import laya.media.Sound;
	import laya.media.SoundChannel;
	import laya.media.SoundManager;
	import laya.net.Loader;
	import laya.physics.CircleCollider;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	import propScript.PropFrame;
	
	public class Controller extends Script {
		/** @prop {name:role, tips:"Role脚本", type:prefab}*/
		public var role:Prefab;
		/** @prop {name:touchDestroy, tips:"触碰即销毁的地图块", type:prefab}*/
		public var touchDestroy:Prefab;
		/** @prop {name:enemyOne, tips:"第一类敌人", type:prefab}*/
		public var enemyOne:Prefab;
		/** @prop {name:enemyTow, tips:"第二类敌人", type:prefab}*/
		public var enemyTow:Prefab;
		/** @prop {name:enemyThree, tips:"第三类敌人", type:prefab}*/
		public var enemyThree: Prefab;
		/** @prop {name:enemyFour, tips:"第四类敌人", type:prefab}*/
		public var enemyFour:Prefab;
		/** @prop {name:enemyFive, tips:"第五类敌人", type:prefab}*/
		public var enemyFive:Prefab;
		/** @prop {name:enemyBossOne, tips:"第一关Boss", type:prefab}*/
		public var enemyBossOne: Prefab;
		/** @prop {name:propFrame, tips:"道具框架", type:prefab}*/
		public var propFrame:Prefab;
		/** @prop {name:flyProp, tips:"飞行物", type:prefab}*/
		public var flyProp:Prefab;
		
		// 触碰即销毁的地图
		private var touchDestroySp:Sprite;
		
		
		// 三张个合一
		private var map:Sprite;
		// 人物脚本
		private var roleClass:Role;
		// 人物精灵
		private var roleSp:Sprite;
		// 人物当前方向
		private var curDir:String;
		
		
		/*
		  关于摇杆的参数
		*/
		// 摇杆
		private var rocker:Sprite;
		// 大圆
		private var rockerBig:Sprite;
		// 小圆
		private var rockerSmall:Sprite;
		// 摇杆位置
		private var rockerX:Number;
		private var rockerY:Number;
		// 大小圆的中心位置
		private var rockerSBX:Number = 60;
		private var rockerSBY:Number = 60;
		// 摇杆半径
		private var rocekerRadius:Number = 70;
		/* 结束 */
		
		
		/* 
		  开枪、跳跃、下跃等按钮
		*/
		// 开枪按钮
		private var fireBtn:Sprite;
		private var fireBtnX:Number;
		private var fireBtnY:Number;
		// 上跳按钮
		private var jumpUpBtn:Sprite;
		private var jumpUpBtnX:Number;
		private var jumpUpBtnY:Number;
		// 下跃按钮
		private var jumpDownBtn:Sprite;
		private var jumpDownBtnX:Number;
		private var jumpDownBtnY:Number;
		/* 结束 */
		
		
		/*
		  地图移动所需参数
		*/
		private var viewCenterX:Number;
		private var viewCenterY:Number;
		private var scrollRectYMin:Number;
		private var scrollRectYMax:Number;
		private var scrollRectXMin:Number;
		private var scrollRectXMax:Number;
		/* 结束 */
		
		// 产生敌人的碰撞体数组
		private var circleColliderArr:Array;
		
		
		private var soundChannel:SoundChannel;
		
		
		override public function onEnable():void {
			// 获取背景节点
			map = this.owner.getChildByName("background") as Sprite;
				
			
			// 延迟300毫秒后，
			Laya.timer.once(500, this, laterExec);

			
			// 实例化摇杆大小圆
			rocker = new Sprite();
			rockerBig = new Sprite();
			rockerSmall = new Sprite();

			// 实例化按钮
			fireBtn = new Sprite();
			jumpUpBtn = new Sprite();
			jumpDownBtn = new Sprite();
			
			// 创建人物预制件
			roleSp = role.create() as Sprite;
			map.addChild(roleSp);
			
			// 临时变量
			var tempTouchDestroySp:Sprite;
			// 为第一处需使用到此地形的地方添加该地形
			for (var i:int = 0; i < 4; i++) 
			{
				// 从对象池中创建对象
				tempTouchDestroySp = Pool.getItemByCreateFun("touchDestroy",touchDestroy.create, touchDestroy);
				tempTouchDestroySp.pos(1236 + (54 * i), 175);
				map.addChild(tempTouchDestroySp);
			}
			// 第二处
			for (var i:int = 0; i < 4; i++) 
			{
				// 从对象池中创建对象
				tempTouchDestroySp = Pool.getItemByCreateFun("touchDestroy",touchDestroy.create, touchDestroy);
				tempTouchDestroySp.pos(1717 + (54 * i), 175);
				map.addChild(tempTouchDestroySp);
			}
			
			// 获取所有能产生敌人的碰撞体
			circleColliderArr = this.owner.getComponents(CircleCollider);
			
			// 第二类敌人临时变量
			var enemyTowSp:Sprite;
			// 初始化第二类敌人
			enemyTowSp = Pool.getItemByCreateFun("enemyTow", enemyTow.create, enemyTow);
			enemyTowSp.pos(520, 130);
			var r:RigidBody = enemyTowSp.getComponent(RigidBody);
			r.setVelocity({x:-1, y:0});
			map.addChild(enemyTowSp);
			
			
			// 第一类敌人临时变量
			var enemyOneSp:Sprite;
			enemyOneSp = Pool.getItemByCreateFun("enemyOne", enemyOne.create, enemyOne);
			enemyOneSp.pos(512, 290);
			map.addChild(enemyOneSp);
			
			
			// 获取 Role 类静态访问变量
			roleClass = Role.ROLE;
			
			
			// 道具框架
			var propFrameSp:Box;
			propFrameSp = Pool.getItemByCreateFun("enemyProp", propFrame.create, propFrame);
			propFrameSp.pos(512, 232);
			map.addChild(propFrameSp);
			
			Laya.loader.load("sound/background.mp3", Handler.create(this, play),null, Loader.SOUND);
			// 音效音量
			SoundManager.soundVolume = 0.7; 
		}
		
		/**
		 * 加载完音效后自动播放，
		 * 需要用户点击舞台（使焦点处于舞台）才会播放
		 */
		private function play():void {
			soundChannel = SoundManager.playMusic("sound/background.mp3");
			SoundManager.soundVolume = 0.7;
			soundChannel.play();
		}
		
		/**
		 * 延迟300毫秒后执行此函数
		 * 用于计算一些需要在浏览器完全打开之后
		 * 再计算的数据
		 */ 
		private function laterExec():void {
			
			// 舞台显示的大小 - 可当做手机的屏幕大小
			var displayHeight:Number = Laya.stage.height;
			var displayWidth:Number = Laya.stage.width;
			
			// 计算摇杆的中心点位置
			rockerX = 130;
			rockerY = displayHeight - 90;
			
			// 计算各个按钮的位置
			fireBtnX = displayWidth - 110;
			fireBtnY = displayHeight - 110;
			jumpUpBtnX = displayWidth - 90;
			jumpUpBtnY = displayHeight - 180;
			jumpDownBtnX = displayWidth - 180;
			jumpDownBtnY = displayHeight - 90;
			
			// 加载图片资源
			Laya.loader.load("res/atlas/icon.atlas", Handler.create(this, onIconAtlasLoaded));
			
			// 计算屏幕显示中心
			viewCenterY = Laya.stage.displayHeight / 2;
			viewCenterX = Laya.stage.displayWidth / 2;
			
			// 计算 滚动区域 范围
			scrollRectYMin = 0;
			scrollRectYMax = 375 - Laya.stage.stage.displayHeight;
			scrollRectXMax = 5571 - Laya.stage.displayWidth;
			scrollRectXMin = 0;
			
			// 给舞台添加一个 滚动区域
			// 在接下来的屏幕移动效果
			// 其实就是移动 滚动区域
			var rec:Rectangle = new Rectangle(0, 0, Laya.stage.displayWidth, Laya.stage.displayHeight);
			Laya.stage.scrollRect = rec;
			
			// 给本角色添加游戏循环
			Laya.stage.timer.loop(10, this, onLoop);
		}
		
		
		
		/**
		 * 游戏循环
		 */
		private function onLoop():void
		{		
			
			// 调动移动 滚动区域 函数
			moveMap();
			if (!roleClass.isAlive) {
				Laya.stage.clearTimer(this, onLoop);
				Laya.stage.clearTimer(this, produceEnemyTow);
				var text:Text = new Text();
				text.visible = true;
				text.pivot(30, 30);
				text.text = "点击屏幕复活";
				text.color = "#ffffff";
				text.fontSize = 30;
				text.pos(Laya.stage.scrollRect.x + ( Laya.stage.scrollRect.width / 2), Laya.stage.scrollRect.y + (Laya.stage.height / 2));
				map.addChild(text);
				
				var resume:Function = function():void {
					roleSp.pos(Laya.stage.scrollRect.x  + 50, 0);
					roleClass.reStart();					
					// 给本角色添加游戏循环
					Laya.stage.timer.loop(10, this, onLoop);	
					Laya.stage.on(Event.MOUSE_UP, this, function up():void {
						text.visible = false;
						Laya.stage.off(Event.MOUSE_DOWN, this, resume);
						Laya.stage.off(Event.MOUSE_UP, this, up);
					});
				}
				Laya.stage.on(Event.MOUSE_DOWN, this, resume);
				

				
			}
			
			
		}		

		/**
		 * 碰撞检查函数
		 * 当人物触碰到碰撞体(在场景中放置特定位置的碰撞体)时，
		 * 将产生各类敌人
		 */
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "produce" && self.label === "produceOne") {
				Laya.stage.timer.loop(1500, this, produceEnemyTow, [900, 128, {x:-1, y:0}]);
				// 销毁碰撞点，避免再次碰撞产生敌人
				circleColliderArr[0].destroy();
			}
			if (other.label === "produce" && self.label === "cancelProduceOne") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.once(0, this, produceEnemyOne, ([1000, 290]));
				
				// 产生飞行物
				Laya.stage.timer.once(0, this, produceFlyProp, [50]);
				
				// 销毁碰撞点，避免再次碰撞产生敌人
				circleColliderArr[1].destroy();
			}
			
			
			if (other.label === "produce" && self.label === "produceTow") {
				Laya.stage.timer.loop(1500, this, produceEnemyTow, [483, 290, {x:2, y:0}]);
				circleColliderArr[2].destroy();
			}
			
			if (other.label === "produce" && self.label === "cancelProduceTow") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.loop(1500, this, produceEnemyTow, [1670, 130, {x:-1, y:0}]);
				circleColliderArr[3].destroy();
			}
			
			if (other.label === "produce" && self.label === "cancelProduceThree") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				circleColliderArr[4].destroy();
			}
			
			
			if (other.label === "produce" && self.label === "produceFour") {
				Laya.stage.timer.loop(2000, this, produceEnemyTow, [1940, 130, {x: -1, y:0}]);
				Laya.stage.timer.once(0, this, produceEnemyOne, ([2000, 128]));
				Laya.stage.timer.once(0, this, produceEnemyThree, ([2200, 154]));
				Laya.stage.timer.once(0, this, produceEnemyFour, ([2040, 265]));
				circleColliderArr[5].destroy();
				
			}
			
			if (other.label === "produce" && self.label === "cancelProduceFour") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.loop(2000, this, produceEnemyTow, [2960, 182, {x: -1, y:0}]);
				circleColliderArr[6].destroy();
			}
			
			
			if (other.label === "produce" && self.label === "cancelProduceFive") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.loop(2000, this, produceEnemyTow, [3060, 76, {x: -1, y:0}]);
				Laya.stage.timer.once(0, this, produceEnemyThree, ([2500, 100]));
				Laya.stage.timer.once(0, this, producePropFrame, ([2574, 230]));
				circleColliderArr[7].destroy();
			}
			
			
			if (other.label === "produce" && self.label === "cancelProduceSix") {
				Laya.stage.clearTimer(this, produceEnemyTow);
				Laya.stage.timer.once(0, this, produceEnemyFour, ([2680, 211]));
				circleColliderArr[8].destroy();
			}
			
			
			if (other.label === "produce" && self.label === "produceSeven") {
				Laya.stage.timer.once(0, this, produceEnemyFour, ([3026, 207]));
				Laya.stage.timer.loop(2000, this, produceEnemyTow, [3130, 290, {x: -1, y:0}]);
				circleColliderArr[9].destroy();
			}
			
			if (other.label === "produce" && self.label === "cancelProduceSeven") {
				Laya.stage.timer.clear(this, produceEnemyTow);
				Laya.stage.timer.once(0, this, produceEnemyTow, [3400, 130, {x: -1, y:0}]);
				circleColliderArr[10].destroy();
			}
			
			if (other.label === "produce" && self.label === "produceEight") {
				Laya.stage.timer.once(0, this, produceEnemyFive, ([3380, 256]));
				circleColliderArr[11].destroy();
			}
			
			if (other.label === "produce" && self.label === "cancelProduceEight") {
				Laya.stage.timer.once(0, this, produceEnemyFive, ([3593, 100]));
				Laya.stage.timer.once(0, this, producePropFrame, ([3755, 283]));
				circleColliderArr[12].destroy();
			}
			
			if (other.label === "produce" && self.label === "produceNine") {
				Laya.stage.timer.once(0, this, produceEnemyOne, ([3893, 182]));
				Laya.stage.timer.once(0, this, produceEnemyTow, [4046, 238, {x: -1, y:0}]);
				circleColliderArr[13].destroy();
			}
			
			if (other.label === "produce" && self.label === "cancelProduceNine") {
				// 在这里产生飞行道具
				Laya.stage.timer.once(0, this, produceFlyProp, [50]);
				Laya.stage.timer.once(0, this, produceFlyProp, [150]);
				Laya.stage.timer.once(0, this, produceFlyProp, [250]);
				
				Laya.stage.timer.once(0, this, produceEnemyTow, [4582, 183, {x: -1, y:0}]);
				circleColliderArr[14].destroy();
				
			}
			
			
			if (other.label === "produce" && self.label === "produceTen") {
				Laya.stage.timer.once(0, this, produceEnemyFive, ([4585, 207]));
				Laya.stage.timer.once(0, this, produceEnemyTow, [4632, 290, {x: -1, y:0}]);
				circleColliderArr[15].destroy();
			}
			
			
			if (other.label === "produce" && self.label === "cancelProduceTen") {
				Laya.stage.timer.once(0, this, produceEnemyFour, ([4956, 315]));
				Laya.stage.timer.once(0, this, produceEnemyFour, ([5198, 313]));
				circleColliderArr[16].destroy();
			}
			
			if (other.label === "produce" && self.label === "produceEleven") {
				Laya.stage.timer.once(0, this, produceBoss01, ([5382, 67]));
				circleColliderArr[17].destroy();
			}
			
		}
		
		/**
		 * 产生第一类敌人
		 */
		private function produceEnemyOne(...args):void {
			// 第一类敌人临时变量
			var enemyOneSp:Sprite;
			enemyOneSp = Pool.getItemByCreateFun("enemyOne", enemyOne.create, enemyOne);
			enemyOneSp.pos(args[0], args[1]);
			map.addChild(enemyOneSp);
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
			map.addChild(enemyTowSp);
		}	
		
		
		/**
		 * 产生第三类敌人
		 */
		private function produceEnemyThree(...args):void {
			// 第三类敌人临时变量
			var enemyThreeSp:Sprite;
			enemyThreeSp = Pool.getItemByCreateFun("enemyThree", enemyThree.create, enemyThree);
			enemyThreeSp.pos(args[0], args[1]);
			map.addChild(enemyThreeSp);
		}
		
		
		/**
		 * 产生第四类敌人
		 */
		private function produceEnemyFour(...args):void {
			// 测试--第四类敌人
			var enemyFourSp:Box;
			enemyFourSp = Pool.getItemByCreateFun("enemyFour", enemyFour.create, enemyFour);
			enemyFourSp.pos(args[0], args[1]);
			map.addChild(enemyFourSp);
		}
		
		/**
		 * 生产第五类敌人
		 */
		private function produceEnemyFive(...args):void
		{
			var enemyFiveSp:Sprite;
			enemyFiveSp = Pool.getItemByCreateFun("enemyFive", enemyFive.create, enemyFive);
			enemyFiveSp.pos(args[0],args[1]);
			map.addChild(enemyFiveSp);	
		}
		
		
		/**
		 * 生产第一关BOSS
		 */
		private function produceBoss01(...args):void {
			var enemyBoss01Sp:Sprite;
			enemyBoss01Sp = Pool.getItemByCreateFun("enemyBoss01", enemyBossOne.create, enemyBossOne);
			enemyBoss01Sp.pos(args[0], args[1]);
			map.addChild(enemyBoss01Sp);
		}
		
		/**
		 * 生产道具框架
		 */
		private function producePropFrame(...args):void
		{
			var propFrameSp:Box;
			propFrameSp = Pool.getItemByCreateFun("enemyProp", propFrame.create, propFrame);
			propFrameSp.pos(args[0], args[1]);
			map.addChild(propFrameSp);			
		}		
		
		/**
		 * 生产飞行物
		 */		
		private function produceFlyProp(...args):void {
			var flyPropSp:Sprite;
			flyPropSp = Pool.getItemByCreateFun("flyProp", flyProp.create, flyProp);
			flyPropSp.pos(Laya.stage.scrollRect.x, args[0]);
			map.addChild(flyPropSp);
		}
		
		/**
		 * 加载完icon的atlas资源后调用此函数
		 * 此函数用于对两个摇杆圆Sprite加载图片
		 */
		private function onIconAtlasLoaded():void
		{
			/*
			 * 处理摇杆 
			*/
			// 为摇杆两个 Sprite 加载图片资源
			rockerBig.loadImage("icon/rocker.png",Handler.create(this, onBigLoaded));
			rockerSmall.loadImage("icon/rocker_center.png", Handler.create(this, onSmallLoaded));
			
			/* 
			因为摇杆要时时刻刻保持在最顶层，
			但是人物移动时舞台视口会移动，影响了摇杆的位置，
			所以将其添加到父节点后再添加到舞台上，
			让父节点随视口移动即可
			*/
			
			// 摇杆父节点
			rocker.pos(rockerX, rockerY);
			rocker.pivot(75, 75);
			rocker.size(150, 150);
			// 摇杆两个圆添加到父节点中
			rocker.addChild(rockerSmall);
			rocker.addChild(rockerBig);
			Laya.stage.addChild(rocker);
			/*
			 * 结束
			*/		
			
			
			/*
			 * 处理按钮 
			*/
			// 为按钮 Sprite 加载图片资源
			fireBtn.loadImage("icon/fire.png",Handler.create(this, onFireBtnLoaded));
			jumpUpBtn.loadImage("icon/jump.png",Handler.create(this, onJumpUpBtnLoaded));
			jumpDownBtn.loadImage("icon/jump_down.png", Handler.create(this, onJumpDownBtnLoaded));
			// 将按钮添加到舞台
			Laya.stage.addChildren(fireBtn, jumpUpBtn,jumpDownBtn); 
			/*
			 * 结束
			*/
			
			
		}	
		
		/*************************** 按钮 - 开始 ***************************/
		/*** 关于下跃按钮开始 ***/
		/**
		 * 加载完 下跃 按钮的回调函数
		 * 用于设置按钮大小、位置等参数
		 */
		private function onJumpDownBtnLoaded():void
		{
			jumpDownBtn.size(60, 60);		
			jumpDownBtn.pos(jumpDownBtnX, jumpDownBtnY);	
			jumpDownBtn.alpha = 0.6;
			jumpDownBtn.on(Event.MOUSE_DOWN, this, onMouseClickJumpDownDown);
			jumpDownBtn.on(Event.MOUSE_UP, this, onMouseClickJumpDownUp);
		}
		
		private function onMouseClickJumpDownUp(e:Event):void
		{
			e.stopPropagation();
		}		

		/**
		 * 下跃按钮
		 */
		private function onMouseClickJumpDownDown():void
		{
			roleClass.jimpDown();
		}
		/*** 关于下跃按钮结束 ***/
		
		/******************************************************/		
		
		/*** 关于上跃按钮开始 ***/
		/**
		 * 加载完 上跃 按钮的回调函数
		 * 用于设置按钮大小、位置等参数
		 */		
		private function onJumpUpBtnLoaded():void
		{
			jumpUpBtn.size(60, 60);		
			jumpUpBtn.pos(jumpUpBtnX, jumpUpBtnY);
			jumpUpBtn.alpha = 0.6;
			jumpUpBtn.on(Event.MOUSE_DOWN, this, onMousClickJumpUpDown);
			jumpUpBtn.on(Event.MOUSE_UP, this, onMousClickJumpUpUp);
			
		}
		
		private function onMousClickJumpUpUp(e:Event):void
		{
			// 阻止抬起时触动舞台的抬起事件
			e.stopPropagation();
		}
		
		/**
		 * 上跳按钮侦听事件
		 */
		private function onMousClickJumpUpDown(e:Event):void
		{
			roleClass.jumpUp();	
		}
		/*** 关于上跃按钮开结束 ***/
		
		/************************* 按钮 - 结束 ****************************/
		
		/*** 关于开枪按钮开始 ***/
		/**
		 * 加载完 开枪 按钮的回调函数
		 * 用于设置按钮大小、位置等参数
		 */
		private function onFireBtnLoaded():void
		{
			fireBtn.size(90, 90);
			fireBtn.pos(fireBtnX, fireBtnY);
			fireBtn.alpha = 0.6;
			fireBtn.on(Event.MOUSE_DOWN, this, onMouseClickFireDown);
			fireBtn.on(Event.MOUSE_UP, this, onMouseClickFireUp);
		}
		
		
		/**
		 * 开枪按钮抬起侦听事件
		 * 
		 */
		private function onMouseClickFireUp(e:Event):void
		{
			// 阻止抬起时触动舞台的抬起事件
			e.stopPropagation();			
		}		
	
		
		/**
		 * 开枪按钮按下侦听事件
		 */
		private function onMouseClickFireDown():void
		{
			roleClass.onFire();
		}		
		/*** 关于开枪按钮结束 ***/
		/******************************************************/
		
		
		/**
		 * 加载完大圆后的回调函数
		 * 用于设置大圆的样式即添加侦听事件
		 */
		private function onBigLoaded():void
		{
			//设置大圆的位置、大小、透明度、中心轴		
			rockerBig.pos(rockerSBX, rockerSBY);
			rockerBig.size(150, 150);
			rockerBig.alpha = 0.6;
			rockerBig.pivot(75, 75);		
			rockerBig.on(Event.MOUSE_DOWN, this, this.onMouseClickRockerSmallDown);
			
		}
		
		
		/**
		 * 加载完小圆后的回调函数
		 * 用于设置小圆的样式即添加侦听事件
		 */
		private function onSmallLoaded():void
		{	
			//设置小圆的位置、大小、透明度、中心轴
			rockerSmall.pos(rockerSBX, rockerSBY);
			rockerSmall.size(50, 50);
			rockerSmall.alpha = 0.6;
			rockerSmall.pivot(25,25);
			
			// 添加侦听事件
//			rockerSmall.on(Event.MOUSE_DOWN, this, this.onMouseClickRockerSmallDown);
				
		}
		
		
		/**
		 * 鼠标按下事件
		 */
		private function onMouseClickRockerSmallDown(e:Event):void
		{
			e.stopPropagation();
			// 在舞台上添加鼠标抬起及鼠标移动侦听事件，用于控制人物
			Laya.stage.on(Event.MOUSE_UP, this, onMouseClickRockerSmallUp)
			Laya.stage.on(Event.MOUSE_MOVE, this, onRockerSmallMove);	
			// 修改小圆透明度，当点下去的时候透明度为 1
			rockerSmall.alpha = 1;		
			
		}
		
		/**
		 * 鼠标抬起事件
		 */
		private function onMouseClickRockerSmallUp(e:Event):void
		{
			// 当鼠标抬起时销毁舞台的鼠标抬起及鼠标移动侦听事件
			Laya.stage.off(Event.MOUSE_UP, this, onMouseClickRockerSmallUp);
			Laya.stage.off(Event.MOUSE_MOVE, this, onRockerSmallMove);
			// 利用缓动动画将小圆移动回原处
			Tween.to(rockerSmall, {x:rockerSBY, y:rockerSBY}, 300, Ease.backIn);
			// 重设透明度
			rockerSmall.alpha = 0.6;
			
			roleClass.move(-1);
			
		}
		
		/**
		 * 移动摇杆
		 */
		private function onRockerSmallMove():void { 
			//定义临时变量
			var absX:Number;
			var absY:Number;
			var powX:Number;
			var powY:Number;
			var moveRadius:Number;
			var posX:Number;
			var posY:Number;
			// 获取鼠标位置
			posX = rocker.mouseX + Laya.stage.scrollRect.x;
			posY = rocker.mouseY + Laya.stage.scrollRect.y;
	
			
			//计算小圆是否被拉得太远
			absX = Math.abs(posX - rockerBig.x);
			absY = Math.abs(posY - rockerBig.y);
			powX = Math.pow(absX, 2);
			powY = Math.pow(absY, 2);
			moveRadius = Math.sqrt(powX + powY);
			
			
			// 以 rockerRaidus 为准，超出则销毁移动侦听事件及将小圆复位
			// 改变小圆的位置
			if (moveRadius > rocekerRadius) {
				var smallx:Number = ((rocekerRadius * (posX - rockerBig.x)) / moveRadius) + rockerBig.x;
				var smally:Number = ((rocekerRadius * (posY - rockerBig.y)) / moveRadius) + rockerBig.y;
				rockerSmall.pos(smallx, smally, true);
			} else {
				rockerSmall.pos(posX, posY, true);
			}
			
			
			// 弧度值
			var rad:Number = getRad(posX - rockerSBX, posY - rockerSBY, moveRadius);
			// 弧度转角度
			var angle:Number = 180 / Math.PI * rad;
			
			// 移动人物
			roleClass.move(angle);
			
		}	

		
		override public function onKeyDown(e:Event):void {
			switch(e.keyCode)
			{
				
				
				// 跳
				case Keyboard.SPACE:
				{
					roleClass.jumpUp();	
					break;
				}
					
				// 开枪
				case Keyboard.V:
				{
					roleClass.onFire();
					break;					
				}
				case Keyboard.R:
				{
					roleSp.pos(Laya.stage.scrollRect.x  + 50, 0);
					roleClass.reStart();					
					// 给本角色添加游戏循环
					Laya.stage.timer.loop(10, this, onLoop);
					break;
				}
				default:
				{
					break;
				}
			}

		}
	
		
		/**
		 * 获取以摇杆为中心，鼠标位置与中心点的弧度值
		 * 
		 */
		private function getRad(xx:Number, yy:Number, moveRadius:Number):Number{
			var rad:Number = yy >= 0 ? (Math.PI * 2 - Math.acos(xx / moveRadius)) : (Math.acos(xx / moveRadius));			
			return rad;
		}
		
		
		/**
		 * 移动 Laya.stage.scrollRect（滚动区域）实现移动屏幕效果
		 */
		private function moveMap():void {
			
			/*
			移动 x 方向
			*/
			// 当人物移动到 1/2 屏幕的时候才进行移动背景图，因为人物只能前进
			if (roleSp.x - Laya.stage.scrollRect.x >= viewCenterX) {
				// 试移动 滚动区域 的 X轴
				var moveX:Number = roleSp.x - viewCenterX;
				// 再判断是否超过了移动界限
				if (moveX > scrollRectXMax || moveX < scrollRectXMin) {
					// 若超过则将 moveX 设置为 滚动区域 原来未移动时的 X轴
					moveX = Laya.stage.scrollRect.x;
				}
				// 更新滚动区域的位置
				Laya.stage.scrollRect.x = moveX;
				
				// 更新摇杆的位置，因为摇杆必须实时固定在屏幕上
				rockerX = moveX + 130;
				rocker.pos(rockerX, rockerY);
				
				// 也需要移动按钮 X轴的位置，使按钮跟随屏幕随时移动
				fireBtnX = moveX  + Laya.stage.displayWidth - 110;
				jumpUpBtnX = moveX  + Laya.stage.displayWidth - 90;
				jumpDownBtnX = moveX  + Laya.stage.displayWidth - 180;
				fireBtn.pos(fireBtnX, fireBtnY);
				jumpUpBtn.pos(jumpUpBtnX, jumpUpBtnY);
				jumpDownBtn.pos(jumpDownBtnX, jumpDownBtnY);
			}
			/* 结束 */
			
			
			/*
			移动 y 方向
			*/
			// 试移动 滚动区域 的 Y 轴
			var moveY:Number = roleSp.y - viewCenterY; 
			// 再判断是否超过移动界限
			if (moveY > scrollRectYMax || moveY <scrollRectYMin) {
				// 若超过则将 moveY 值设置为 滚动区域 原来未移动时的 Y 轴
				moveY = Laya.stage.scrollRect.y;
			}
			// 更新滚动区域 Y轴 位置
			Laya.stage.scrollRect.y = moveY;
			
			// 更新摇杆的位置，因为摇杆必须实时固定在屏幕上
			rockerY = moveY + Laya.stage.displayHeight - 90;
			rocker.pos(rockerX, rockerY);
			
			// 也需要移动 按钮 Y轴的位置，使按钮跟随屏幕随时移动
			fireBtnY = moveY + Laya.stage.displayHeight - 110;
			jumpUpBtnY = moveY + Laya.stage.displayHeight - 180;
			jumpDownBtnY = moveY + Laya.stage.displayHeight - 90;
			fireBtn.pos(fireBtnX, fireBtnY);
			jumpUpBtn.pos(jumpUpBtnX, jumpUpBtnY);
			jumpDownBtn.pos(jumpDownBtnX, jumpDownBtnY);
			/* 结束 */
		}
		
		override public function onDisable():void {
		}
	}
}