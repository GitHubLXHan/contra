package script {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.d3.core.light.DirectionLight;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.maths.Rectangle;
	import laya.physics.BoxCollider;
	import laya.physics.ChainCollider;
	import laya.physics.RigidBody;
	import laya.utils.Browser;
	import laya.utils.ClassUtils;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	public class Controller extends Script {
		/** @prop {name:intType, tips:"整数类型示例", type:Int, default:1000}*/
		public var intType: int = 1000;
		/** @prop {name:numType, tips:"数字类型示例", type:Number, default:1000}*/
		public var numType: Number = 1000;
		/** @prop {name:strType, tips:"字符串类型示例", type:String, default:"hello laya"}*/
		public var strType: String = "hello laya";
		/** @prop {name:boolType, tips:"布尔类型示例", type:Bool, default:true}*/
		public var boolType: Boolean = true;
		/** @prop {name:role, tips:"Role脚本", type:prefab}*/
		public var role:Prefab;
		/** @prop {name:touchDestroy, tips:"触碰即销毁的地图块", type:prefab}*/
		public var touchDestroy:Prefab;

		
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
				tempTouchDestroySp = Pool.getItemByCreateFun("touchDestroy",createTouchDestroy, this);
				tempTouchDestroySp.pos(1025 + (45 * i), 175);
				map.addChild(tempTouchDestroySp);
			}
			// 第二处
			for (var i:int = 0; i < 4; i++) 
			{
				// 从对象池中创建对象
				tempTouchDestroySp = Pool.getItemByCreateFun("touchDestroy",createTouchDestroy, this);
				tempTouchDestroySp.pos(1428 + (45 * i), 175);
				map.addChild(tempTouchDestroySp);
			}
			
			
			
			// 获取 Role 类静态访问变量
			roleClass = Role.ROLE;
			
			// 获取人物精灵刚体
			var boxChollider:BoxCollider = roleSp.getComponent(BoxCollider);
		}
	
		
		
		
		private function createTouchDestroy():Sprite {
			// 创建触碰即销毁的地图
			return touchDestroy.create() as Sprite;
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
			rockerX = 80;
			rockerY = displayHeight - 80;
			
			// 计算各个按钮的位置
			fireBtnX = displayWidth - 100;
			fireBtnY = displayHeight - 100;
			jumpUpBtnX = displayWidth - 90;
			jumpUpBtnY = displayHeight - 160;
			jumpDownBtnX = displayWidth - 160;
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
			Laya.timer.loop(10, this, onLoop);

		}
		
		
		
		/**
		 * 游戏循环
		 */
		private function onLoop():void
		{		
			
			// 调动移动 滚动区域 函数
			moveMap();
			
			// 人物 - 移动及播放动画
			roleClass.moveAndChangeAni();
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
			rocker.pivot(60, 60);
			rocker.size(120, 120);
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
		
		/**
		 * 加载完 下跃 按钮的回调函数
		 * 用于设置按钮大小、位置等参数
		 */
		private function onJumpDownBtnLoaded():void
		{
			jumpDownBtn.size(50, 50);		
			jumpDownBtn.pos(jumpDownBtnX, jumpDownBtnY);	
			jumpDownBtn.alpha = 0.6;
			jumpDownBtn.on(Event.MOUSE_DOWN, this, onMouseClickJumpDownDown);
		}
		

		private function onMouseClickJumpDownDown():void
		{
			console.log(roleClass.getDir());	
			console.log(roleClass.getState());	

		}
		
		/**
		 * 加载完 上跃 按钮的回调函数
		 * 用于设置按钮大小、位置等参数
		 */		
		private function onJumpUpBtnLoaded():void
		{
			jumpUpBtn.size(50, 50);		
			jumpUpBtn.pos(jumpUpBtnX, jumpUpBtnY);
			jumpUpBtn.alpha = 0.6;
			jumpUpBtn.on(Event.CLICK, this, onMousClickJumpUpDown);
		}
		
		private function onMousClickJumpUpDown():void
		{
			roleClass.jump();	
//			roleClass.setRoleState("jump");
		}
		
		/**
		 * 加载完 开枪 按钮的回调函数
		 * 用于设置按钮大小、位置等参数
		 */
		private function onFireBtnLoaded():void
		{
			fireBtn.size(80, 80);
			fireBtn.pos(fireBtnX, fireBtnY);
			fireBtn.alpha = 0.6;
		}
		
		
		/**
		 * 加载完大圆后的回调函数
		 * 用于设置大圆的样式即添加侦听事件
		 */
		private function onBigLoaded():void
		{
			//设置大圆的位置、大小、透明度、中心轴		
			rockerBig.pos(rockerSBX, rockerSBY);
			rockerBig.size(120, 120);
			rockerBig.alpha = 0.6;
			rockerBig.pivot(60, 60);		
			
		}
		
		
		/**
		 * 加载完小圆后的回调函数
		 * 用于设置小圆的样式即添加侦听事件
		 */
		private function onSmallLoaded():void
		{	
			//设置小圆的位置、大小、透明度、中心轴
			rockerSmall.pos(rockerSBX, rockerSBY);
			rockerSmall.size(40, 40);
			rockerSmall.alpha = 0.6;
			rockerSmall.pivot(20,20);
			
			// 添加侦听事件
			rockerSmall.on(Event.MOUSE_DOWN, this, this.onMouseClickRockerSmallDown);
				
		}
		
		
		/**
		 * 鼠标按下事件
		 */
		private var isPressing:Boolean;
		private function onMouseClickRockerSmallDown():void
		{
			// 在舞台上添加鼠标抬起及鼠标移动侦听事件，用于控制人物
			Laya.stage.on(Event.MOUSE_UP, this, onMouseClickRockerSmallUp)
			Laya.stage.on(Event.MOUSE_MOVE, this, onRockerSmallMove);	
			// 修改小圆透明度，当点下去的时候透明度为 1
			rockerSmall.alpha = 1;		
			// 值为true表示按下
			isPressing = true;
			
		}
		
		/**
		 * 鼠标抬起事件
		 */
		private function onMouseClickRockerSmallUp():void
		{
			// 当鼠标抬起时销毁舞台的鼠标抬起及鼠标移动侦听事件
			Laya.stage.off(Event.MOUSE_UP, this, onMouseClickRockerSmallUp);
			Laya.stage.off(Event.MOUSE_MOVE, this, onRockerSmallMove);
			// 利用缓动动画将小圆移动回原处
			Tween.to(rockerSmall, {x:rockerSBY, y:rockerSBY}, 300, Ease.backIn);
			// 重设透明度
			rockerSmall.alpha = 0.6;
			
			// 值为false表示抬起
			isPressing = false;
			// 人物状态及方向
			roleClass.setRoleState("stop");
			roleClass.setDirection(curDir, isPressing);
			
			
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
				//				console.log("超出了  " + moveRadius);
//				Laya.stage.off(Event.MOUSE_MOVE, this, onRockerSmallMove);
//				Tween.to(rockerSmall, {x:rockerSBY, y:rockerSBY}, 300, Ease.backIn);
//				rockerSmall.alpha = 0.6;
			} else {
				rockerSmall.pos(posX, posY, true);
			}
			
			
			// 弧度值
			var rad:Number = getRad(posX - rockerSBX, posY - rockerSBY, moveRadius);
			// 弧度转角度
			var angle:Number = 180 / Math.PI * rad;
			
			/*
			判断方向
			*/
			if ((angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360)){
				roleClass.setDirection("right",isPressing);
				roleClass.setRoleState("run");
				curDir = "right";
//				console.log("右");
			} else if (angle >= 22.5 && angle < 67.5) {
				roleClass.setDirection("right", isPressing);
				roleClass.setRoleState("obl_up");
				curDir = "right";
//				console.log("右上");
				
			} else if (angle >= 67.5 && angle < 112.5) {
				roleClass.setDirection("up",isPressing);
//				console.log("上");
				
			} else if (angle >= 112.5 && angle < 157.5) {
				roleClass.setDirection("left", isPressing);
				roleClass.setRoleState("obl_up");
				curDir = "left";
//				console.log("左上");
				
			} else if (angle >= 157.5 && angle < 202.5) {
				roleClass.setDirection("left",isPressing);
				roleClass.setRoleState("run");				
				curDir = "left";
				//				console.log("左");
			} else if (angle >= 202.5 && angle < 247.5) {
				roleClass.setDirection("left", isPressing);
				roleClass.setRoleState("obl_down");
				curDir = "left";
//				console.log("左下");
				
			} else if (angle >= 247.5 && angle < 292.5) {

				roleClass.setDirection(curDir,isPressing);
				roleClass.setRoleState("lie");
//				console.log("下");
				
			} else if (angle >= 292.5 && angle < 337.5){
				roleClass.setDirection("right", isPressing);
				roleClass.setRoleState("obl_down");
				curDir = "right";
//				console.log("右下");
			}
			/* 结束 */
			
			// 设置状态
//			roleClass.setRoleState("run");
			
			

			
		}	

		
		override public function onKeyDown(e:Event):void {
			isPressing = true;
			switch(e.keyCode)
			{
				// 左
				case Keyboard.NUMPAD_4:
				{
					roleClass.setDirection("left",isPressing);
					roleClass.setRoleState("run");				
					curDir = "left";
		
					break;
				}
				
				// 右
				case Keyboard.NUMPAD_6:
				{
					roleClass.setDirection("right",isPressing);
					roleClass.setRoleState("run");
					curDir = "right";
					
					break;
				}
					
				// 下
				case Keyboard.NUMPAD_2:
				{
					roleClass.setDirection(curDir,isPressing);
					roleClass.setRoleState("lie");
					break;
				}
					
				// 上
				case Keyboard.NUMPAD_8:
				{
					
					
					break;
				}
					
				// 左上
				case Keyboard.NUMPAD_7:
				{
					roleClass.setDirection("left", isPressing);
					roleClass.setRoleState("obl_up");
					curDir = "left";
					break;
				}
				
				// 左下
				case Keyboard.NUMPAD_1:
				{
					roleClass.setDirection("left", isPressing);
					roleClass.setRoleState("obl_down");
					curDir = "left";
					break;
				}
					
				// 右上
				case Keyboard.NUMPAD_9:
				{
					roleClass.setDirection("right", isPressing);
					roleClass.setRoleState("obl_up");
					curDir = "right";
					break;
					
					break;
				}
					
				// 右下
				case Keyboard.NUMPAD_3:
				{
					roleClass.setDirection("right", isPressing);
					roleClass.setRoleState("obl_down");
					curDir = "right";
					break;
				}
				
				// 跳
				case Keyboard.SPACE:
				{
					roleClass.jump();	
					break;
				}
					
				// 打印信息
				case Keyboard.V:
				{
					console.log("状态：" + roleClass.getState());
					console.log("方向" + roleClass.getDir());
					console.log("播放" + roleClass.getIsPlay());
					console.log("碰撞区" + roleClass.getRigidBound());
					break;					
				}
				default:
				{
					break;
				}
			}

		}
		
		override public function onKeyUp(e:Event):void {
			switch(e.keyCode)
			{
				// 左
				case Keyboard.NUMPAD_4:
				{
					// 值为false表示抬起
					isPressing = false;
					// 人物状态及方向
					roleClass.setRoleState("stop");
					roleClass.setDirection(curDir, isPressing);
					
					break;
				}
					
					// 右
				case Keyboard.NUMPAD_6:
				{
					// 值为false表示抬起
					isPressing = false;
					// 人物状态及方向
					roleClass.setRoleState("stop");
					roleClass.setDirection(curDir, isPressing);
					break;
				}
					
					// 下
				case Keyboard.NUMPAD_2:
				{
					// 值为false表示抬起
					isPressing = false;
					// 人物状态及方向
					roleClass.setRoleState("stop");
					roleClass.setDirection(curDir, isPressing);
					break;
				}
					
					// 上
				case Keyboard.NUMPAD_8:
				{
					// 值为false表示抬起
					isPressing = false;
					// 人物状态及方向
					roleClass.setRoleState("stop");
					roleClass.setDirection(curDir, isPressing);
					break;
				}
					
					// 左上
				case Keyboard.NUMPAD_7:
				{
					// 值为false表示抬起
					isPressing = false;
					// 人物状态及方向
					roleClass.setRoleState("stop");
					roleClass.setDirection(curDir, isPressing);
					break;
				}
					
					// 左下
				case Keyboard.NUMPAD_1:
				{
					// 值为false表示抬起
					isPressing = false;
					// 人物状态及方向
					roleClass.setRoleState("stop");
					roleClass.setDirection(curDir, isPressing);
					break;
				}
					
					// 右上
				case Keyboard.NUMPAD_9:
				{
					// 值为false表示抬起
					isPressing = false;
					// 人物状态及方向
					roleClass.setRoleState("stop");
					roleClass.setDirection(curDir, isPressing);
					break;
				}
					
					// 右下
				case Keyboard.NUMPAD_3:
				{
					// 值为false表示抬起
					isPressing = false;
					// 人物状态及方向
					roleClass.setRoleState("stop");
					roleClass.setDirection(curDir, isPressing);
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
//			if (roleSp.x - Laya.stage.scrollRect.x >= viewCenterX) {
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
				rockerX = moveX + 80;
				rocker.pos(rockerX, rockerY);
				
				// 也需要移动按钮 X轴的位置，使按钮跟随屏幕随时移动
				fireBtnX = moveX  + Laya.stage.displayWidth - 100;
				jumpUpBtnX = moveX  + Laya.stage.displayWidth - 90;
				jumpDownBtnX = moveX  + Laya.stage.displayWidth - 160;
				fireBtn.pos(fireBtnX, fireBtnY);
				jumpUpBtn.pos(jumpUpBtnX, jumpUpBtnY);
				jumpDownBtn.pos(jumpDownBtnX, jumpDownBtnY);
			
//			}
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
			rockerY = moveY + Laya.stage.displayHeight - 80;
			rocker.pos(rockerX, rockerY);
			
			// 也需要移动 按钮 Y轴的位置，使按钮跟随屏幕随时移动
			fireBtnY = moveY + Laya.stage.displayHeight - 100;
			jumpUpBtnY = moveY + Laya.stage.displayHeight - 160;
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