package script {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.filters.IFilter;
	import laya.maths.Rectangle;
	import laya.physics.BoxCollider;
	import laya.physics.RigidBody;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Tween;
	
	public class Role extends Script {
		/** @prop {name:intType, tips:"整数类型示例", type:Int, default:1000}*/
		public var intType: int = 1000;
		/** @prop {name:numType, tips:"数字类型示例", type:Number, default:1000}*/
		public var numType: Number = 1000;
		/** @prop {name:strType, tips:"字符串类型示例", type:String, default:"hello laya"}*/
		public var strType: String = "hello laya";
		/** @prop {name:boolType, tips:"布尔类型示例", type:Bool, default:true}*/
		public var boolType: Boolean = true;

		// 更多参数说明请访问: https://ldc2.layabox.com/doc/?nav=zh-as-2-4-0


		
		
		//人物动画
		private var ani:Animation;
		
		// 本对象精灵
		private var roleSp:Sprite;
		// 本对象父节点 - 即背景节点
		private var roleParentSp:Sprite;
		// 人物精灵刚体
		private var rigid:RigidBody;
		
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
		
		
		// 地图移动所需参数
		private var viewCenterX:Number;
		private var viewCenterY:Number;
		private var scrollRectYMin:Number;
		private var scrollRectYMax:Number;
		private var scrollRectXMin:Number;
		private var scrollRectXMax:Number;
		
		// 人物方向
		private var direction:String;
		
	
		override public function onEnable():void {
			
			var boxChollider:BoxCollider = this.owner.getComponent(BoxCollider);
			
			// 延迟300毫秒后，
			Laya.timer.once(500, this, laterExec);
			
			// 实例化摇杆大小圆
			rocker = new Sprite();
			rockerBig = new Sprite();
			rockerSmall = new Sprite();
			
			// 获取本对象精灵
			roleSp = this.owner as Sprite;
			
			// 获取父节点
			roleParentSp = roleSp.parent as Sprite;
			// 获取人物精灵刚体
			rigid = roleSp.getComponent(RigidBody);
			
			// 实例化动画并加载动画资源
			ani = new Animation();
			ani.loadAnimation("GameScene/Role.ani", Handler.create(this, onAniLoaded));
			

			

			
				
		}
		

		/**
		 * 延迟300毫秒后执行此函数
		 * 用于计算一些需要在浏览器完全打开之后
		 * 再计算的数据
		 */ 
		private function laterExec():void {
			// 计算摇杆的中心点位置
			rockerX = 80;
			rockerY = Laya.stage.displayHeight - 80;
			// 加载图片资源
			Laya.loader.load("res/atlas/icon.atlas", Handler.create(this, onIconAtlasLoaded));
	
			// 计算屏幕显示中心
			viewCenterY = Laya.stage.displayHeight / 2;
			viewCenterX = Laya.stage.displayWidth / 2;
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
			// 临时测试
			ani.on(Event.COMPLETE, this, onAniPlayed);
			roleSp.pos(viewCenterX, viewCenterY);
		}
		
		/**
		 * 游戏循环
		 */
		private function onLoop():void
		{		
			// 调动移动 滚动区域 函数
			moveMap();
			// 播放人物动画
			switch(direction)
			{
				case "right":
				{
					if (!ani.isPlaying) {
						ani.play(0, false, "blue_r_run");				
					}		
					break;
				}
				case "left":
				{
					if (!ani.isPlaying) {
						ani.play(0, false, "blue_l_run");					
					}		
					break;
				}
				case "up":
				{
					break;
				}	
				case "down":
				{
					break;
				}	
				case "stop":
				{
					ani.stop();
					break;
				}	
				default:
				{
					break;
				}
			}			

		}		
		
		/**
		 * 临时函数
		 */
		private function onAniPlayed():void
		{
			console.log("结束");
			switch(direction)
			{
				case "right":
				{
					ani.play(0, false, "blue_r_run");		
					break;
				}
				case "left":
				{
					ani.play(0, false, "blue_l_run");		
					break;
				}
				case "up":
				{
					break;
				}	
				case "down":
				{
					break;
				}	
				default:
				{
					break;
				}
			}			
		}		
		
		/**
		 * 碰撞回调函数
		 */
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "pass_n") {
				rigid.setVelocity({x:0, y:0})		
			}
		}
		
		/**
		 * 移动 Laya.stage.scrollRect（简称 滚动区域）实现移动屏幕效果
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
				rockerX = moveX + 80;
				rocker.pos(rockerX, rockerY);
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
			rockerY = moveY + Laya.stage.displayHeight - 80;
			rocker.pos(rockerX, rockerY);
			/* 结束 */
		}
		
		
		
		/**
		 * 加载完icon的atlas资源后调用此函数
		 * 此函数用于对两个摇杆圆Sprite加载图片
		 */
		private function onIconAtlasLoaded():void
		{
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
			rockerSmall.on(Event.MOUSE_DOWN, this, this.onMouseClickDown);
			rockerSmall.on(Event.MOUSE_UP, this, onMouseClickUp)	
		}
		
		/**
		 * 鼠标按下事件
		 */
		private function onMouseClickDown():void
		{
			// 给摇杆小圆添加鼠点击按下事件
			rockerSmall.on(Event.MOUSE_MOVE, this, onRockerSmallMove);	
			// 修改小圆透明度，当点下去的时候透明度为 1
			rockerSmall.alpha = 1;		
			
		}
		
		/**
		 * 鼠标抬起事件
		 */
		private function onMouseClickUp():void
		{
			// 当鼠标抬起时销毁 摇杆小圆 的鼠标移动事件
			rockerSmall.off(Event.MOUSE_MOVE, this, onRockerSmallMove);
			// 利用缓动动画将小圆移动回原处
			Tween.to(rockerSmall, {x:rockerSBY, y:rockerSBY}, 300, Ease.backIn);
			// 重设透明度
			rockerSmall.alpha = 0.6;
			// 人物速度为零
			rigid.setVelocity({x:0, y:0});
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
			console.log("posX = " + posX);
			console.log("posY = " + posY);
			
			// 改变小圆的位置
			rockerSmall.pos(posX, posY, true);
			//计算小圆是否被拉得太远
			absX = Math.abs(rockerSmall.x - rockerBig.x);
			absY = Math.abs(rockerSmall.y - rockerBig.y);
			powX = Math.pow(absX, 2);
			powY = Math.pow(absY, 2);
			moveRadius = Math.sqrt(powX + powY);
			// 弧度值
			var rad:Number = getRad(posX - rockerSBX, posY - rockerSBY, moveRadius);
			// 弧度转角度
			var angle:Number = 180 / Math.PI * rad;
			
			/*
			  判断方向
			*/
			if ((angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360)){
				rigid.linearVelocity = {x:1, y:0};
				direction = "right";

				console.log("右");
			} else if (angle >= 22.5 && angle < 67.5) {
				
				console.log("右上");
				
			} else if (angle >= 67.5 && angle < 112.5) {
				direction = "up";
				console.log("上");
				rigid.setVelocity({x:0, y:-1});
			} else if (angle >= 112.5 && angle < 157.5) {
				
				console.log("左上");
				
			} else if (angle >= 157.5 && angle < 202.5) {
				direction = "left";

				console.log("左");
				rigid.setVelocity({x:-1, y:0});

//				moveMap(1,0);
				
			} else if (angle >= 202.5 && angle < 247.5) {
				
				console.log("左下");
			
			} else if (angle >= 247.5 && angle < 292.5) {
				rigid.setVelocity({x:0, y:1});
				direction = "down";
				console.log("下");
				
			} else if (angle >= 292.5 && angle < 337.5){
				
				console.log("右下");
			}
			/* 结束 */
			
			// 以 rockerRaidus 为准，超出则销毁移动侦听事件及将小圆复位
			if (moveRadius > rocekerRadius) {
				console.log("超出了  " + moveRadius);
				Laya.stage.off(Event.MOUSE_MOVE, this, onRockerSmallMove);
				Tween.to(rockerSmall, {x:rockerSBY, y:rockerSBY}, 300, Ease.backIn);
				rockerSmall.alpha = 0.6;
			}
			
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
		 * 加载完动画资源后的回调函数
		 * 用于隐藏本对象精灵以及将动画添加到背景中
		 */
		private function onAniLoaded():void
		{
			roleSp.visible = false;
			roleParentSp.addChild(ani);
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