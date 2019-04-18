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
		
		// 人物方向
		private var direction:String = "right";
		// 人物状态
		private var roleState:String = "jump"; 
		// 人物是否可以跳跃
		private var canJump:Boolean = true;
		
		
		// 人物速度
		private var speedX:Number = 0;
		private var speedY:Number = 0;
		
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
			console.log("boxs");
			trace(boxs);
			// 实例化动画并加载动画资源
			ani = new Animation();
			ani.loadAnimation("GameScene/Role.ani", Handler.create(this, onAniLoaded));
			
			roleSp.pos(900, 0);
				
		}
		

		
		public function getDir():String {
			return direction;
		}
		public function getState():String {
			return roleState;
		}
		public function getRigidBound():String {
			return bodyBox.x + "," + bodyBox.y + "," + bodyBox.width + "," + bodyBox.height;
		}
		public function getIsPlay():Boolean {
			return ani.isPlaying;
		}
		
		/**
		 * 碰撞回调函数
		 */
		// 是否可以行走
		private var isCanRight:Boolean = true;
		private var isCanLeft:Boolean = true;
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			
			if ((other.label === "pass_n" || other.label === "pass_y") && rigid.linearVelocity.y > 0 && self.label === "foot") {
				rigid.type = "kinematic";
				roleState = "touch";
				// 设置此时可以跳跃
				canJump = true;
			}
			
			
			// 触碰当不可行走障碍物
			if (other.label === "l_wall" && roleState != "jump") {
//				roleState = "no_right";
				isCanRight = false;
			}else if (other.label === "r_wall"  && roleState != "jump") {
//				roleState = "no_left";
				isCanLeft = false;
			}
			
			
			// 当触碰到自动销毁地图时
			if (other.label === "touchDestroy") {
				// 可以跳跃
				canJump = true;
			}
			
			// 在水中的时候
			if (other.label === "water") {
				rigid.type = "kinematic";
				// 设置此时不可以跳跃
				canJump = false;
				// 改变状态
				roleState = "water";
			}
			
		}

		/**
		 * 碰撞结束
		 */
		override public function onTriggerExit(other:*, self:*, contact:*):void {
			if((other.label === "pass_y" || other.label === "pass_n") && roleState != "jump" && self.label === "foot") {
				rigid.type = "dynamic";
				roleState = "jump";
				// 设置此时不可跳跃
				canJump = false;
			}
			
			if (other.label === "l_wall") {
//				roleState = "run";
				isCanRight = true;
			}
			if (other.label === "r_wall") {
//				roleState = "run";
				isCanLeft = true;
			}
			

			
		}
		
		/**
		 * 持续碰撞
		 */
		override public function onTriggerStay(other:*, self:*, contact:*):void {
			self = footBox;
		}
		
		/**
		 * 跳跃
		 */
		public function jump():void {
			if (!canJump) return;
			rigid.type = "dynamic";
			rigid.gravityScale = 1;
			rigid.linearVelocity = {x:0, y:-6};
			roleState = "jump";
			canJump = false;
			ani.stop();
		}
		
		private var angle:Number;
		public function setAngle(angle:Number):void {
			this.angle = angle;
		}
		
		1
		public function moveAndChangeAni():void {
			if ((angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360)){
				//				console.log("右");
				rigid.setVelocity({x:1, y:rigid.linearVelocity.y});
				
				
			} else if (angle >= 22.5 && angle < 67.5) {
				//				console.log("右上");
			} else if (angle >= 67.5 && angle < 112.5) {
				//				console.log("上");
			} else if (angle >= 112.5 && angle < 157.5) {
				//				console.log("左上");
			} else if (angle >= 157.5 && angle < 202.5) {
				//				console.log("左");
			} else if (angle >= 202.5 && angle < 247.5) {
				//				console.log("左下");
			} else if (angle >= 247.5 && angle < 292.5) {
				//				console.log("下");
			} else if (angle >= 292.5 && angle < 337.5){
				//				console.log("右下");
			} 
			switch(angle)
			{
				// 上
				case angle >= 67.5 && angle < 112.5:
				{
					
					break;
				}
				// 下
				case angle >= 247.5 && angle < 292.5:
				{
					
					break;
				}
				// 左
				case (angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360):
				{
					
					break;
				}
				// 右
				case (angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360):
				{
					
					break;
				}
				// 左上
				case (angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360):
				{
					
					break;
				}
				// 左下
				case (angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360):
				{
					
					break;
				}
				// 右上
				case (angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360):
				{
					
					break;
				}
				// 右下
				case (angle >= 0 && angle < 22.5) ||(angle >= 337.5 && angle < 360):
				{
					
					break;
				}
				default:
				{
					break;
				}
			}
			
			
			
			// 播放人物动画及移动人物
//			switch(direction)
//			{
//				case "right":
//				{
//					if (!ani.isPlaying) {
//						switch(roleState)
//						{
//							case "jump":
//							{
//								if (pressing) {
//									// 跳跃时且向右走
//									rigid.setVelocity({x:1, y:rigid.linearVelocity.y});	
//								}								
//								// 播放跳跃动画
//								ani.play(0, true, "blue_r_jump");
//								// 更改跳跃时碰撞区
//								changeCollider("jump");
//								break;
//							}
//							case "run":
//							{
//								if (isCanRight) {
//									//没有跳跃且可以像右走
//									rigid.linearVelocity = {x:1, y:0};
//								} else {
//									//没有跳跃，不可以像右走
//									rigid.linearVelocity = {x:0, y:0};
//								}
//								// 播放向右走动画
//								ani.play(0, true, "blue_r_str_right");
//								// 更改站立或行走时碰撞区
//								changeCollider("run");
//								break;
//							}
//							case "stop":
//							{
//								// 停止移动
//								rigid.setVelocity({x:0 , y:0});
//								ani.play(0, false, "blue_r_stand");
////								roleState = "run";
//								break;
//							}
//							case "water_run":
//							{
//								
//								break;
//							}
//								
//								
//							case "touch":
//							{
//								if (pressing) {
//									roleState = "run";
//								} else {
//									roleState = "stop";
//								}
//								break;
//							}
//							case "lie":
//							{
//								if (rigid.linearVelocity.y == 0) {
//									ani.play(0, false, "blue_r_lie");
//									rigid.setVelocity({x:0, y:0});
//								}
//								break;
//							}	
//							case "obl_down":
//							{
//								ani.play(0, true, "blue_r_obl_down");
//								// 处于 斜 的方向
////								isObl = true;
//								break;
//							}
//							case "obl_up":
//							{
//								ani.play(0, true, "blue_r_obl_up");
//								// 处于 斜 的方向
////								isObl = true;
//								break;
//							}
//							default:
//							{
//								break;
//							}
//						}						
//					} else {
//						// 正在播放动画的情况下
//						switch(roleState)
//						{
//							case "jump":
//							{
//								if (pressing) {
//									// 跳跃情况下，移动人物
//									rigid.linearVelocity = {x:1, y:rigid.linearVelocity.y};	
//								}
//								// 更改跳跃时碰撞区
//								changeCollider("jump");
//								break;
//							}
//							case "run":
//							{								
//								if (isCanRight) {
//									//没有跳跃且可以像右走的情况下
//									rigid.linearVelocity = {x:1, y:0};
//								} else {
//									// 不可向右走
//									rigid.linearVelocity = {x:0, y:0};	
//								}
//								// 更改站立或行走碰撞区
//								changeCollider("run");
//								break;
//							}
//							case "stop":
//							{
//								// 停止移动
//								rigid.setVelocity({x:0 , y:0});
////								roleState = "run";
//								break;
//							}
//							case "touch":
//							{
//								if (pressing) {
//									ani.stop();
//									roleState = "run";
//								} else {
//									ani.stop();
//									roleState = "stop";
//								}
//								break;
//							}
//							case "obl_down":
//							{
//								rigid.setVelocity({x:1, y:0});
//								break;
//							}
//							case "obl_up":
//							{
//								rigid.setVelocity({x:1, y:0});
//								break;
//							}
//							case "lie":
//							{
//								if (rigid.linearVelocity.y == 0) {
//									ani.play(0, false, "blue_r_lie");
//									rigid.setVelocity({x:0, y:0});
//								}
//								break;
//							}
//							default:
//							{
//								break;
//							}
//						}
//					}
//					break;
//				}
//				case "left":
//				{
//					if (!ani.isPlaying) {
//						switch(roleState)
//						{
//							case "jump":
//							{
//								if (pressing) {
//									// 跳跃时且向右走
//									rigid.setVelocity({x:-1, y:rigid.linearVelocity.y});
//								}								
//								// 播放跳跃动画
//								ani.play(0, false, "blue_l_jump");
//								// 更改跳跃时碰撞区
//								changeCollider("jump");
//								break;
//							}
//							case "run":
//							{
//								if (isCanLeft) {
//									//没有跳跃且可以像右走的情况下
//									rigid.linearVelocity = {x:-1, y:0};
//								} else {
//									// 不可向右走时
//									rigid.linearVelocity = {x:0, y:0};
//								}
//								// 播放向右走动画
//								ani.play(0, true, "blue_l_str_left");	
//								// 更改站立或行走时碰撞区
//								changeCollider("run");
//								break;
//							}
//							case "stop":
//							{
//								// 停止移动
//								rigid.setVelocity({x:0 , y:0});
//								ani.play(0, false, "blue_l_stand");
////								roleState = "run";
//								break;
//							}
//							case "touch":
//							{
//								if (pressing) {
//									roleState = "run";
//								} else {
//									roleState = "stop";
//								}
//								break;
//							}
//							case "obl_down":
//							{
//								ani.play(0, true, "blue_l_obl_down");
//								break;
//							}
//							case "obl_up":
//							{
//								ani.play(0, true, "blue_l_obl_up");
//								break;
//							}
//							case "lie":
//							{
//								if (rigid.linearVelocity.y == 0) {
//									ani.play(0, false, "blue_l_lie");
//									rigid.setVelocity({x:0, y:0});
//								}
//								break;
//							}
//							default:
//							{
//								break;
//							}
//						}						
//					} else {
//						// 正在播放动画的情况下
//						switch(roleState)
//						{
//							case "jump":
//							{
//								if (pressing) {
//									// 跳跃情况下，移动人物
//									rigid.linearVelocity = {x:-1, y:rigid.linearVelocity.y};
//								}
//								// 更改跳跃时碰撞区
//								changeCollider("jump");
//								break;
//							}
//							case "run":
//							{				
//								if (isCanLeft) {
//									//没有跳跃且可以像右走的情况下
//									rigid.linearVelocity = {x:-1, y:0};
//								} else {
//									rigid.linearVelocity = {x:0, y:0};									
//								}
//								// 更改站立或行走时碰撞区
//								changeCollider("run");
//								break;
//							}
//							case "stop":
//							{
//								// 停止移动
//								rigid.setVelocity({x:0 , y:0});
////								roleState = "run";
//								break;
//							}
//							case "touch":
//							{
//								if (pressing) {
//									ani.stop();
//									roleState = "run";
//								} else {
//									ani.stop();
//									roleState = "stop";
//								}
//								break;
//							}
//							case "obl_down":
//							{
//								rigid.setVelocity({x:-1, y:0});
//								break;
//							}
//							case "obl_up":
//							{
//								rigid.setVelocity({x:-1, y:0});
//								break;
//							}
//							case "lie":
//							{
//								if (rigid.linearVelocity.y == 0) {
//									ani.play(0, false, "blue_l_lie");
//									rigid.setVelocity({x:0, y:0});
//									
//								}
//								break;
//							}
//							default:
//							{
//								break;
//							}
//						}
//					}
//					break;
//				}
//				case "up":
//				{
//					
//					break;
//				}	
//				case "down":
//				{
//
//					break;
//				}	
//				default:
//				{
//					break;
//				}
//			}	
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
					bodyBox.x = 0;
					bodyBox.y = 0;
					bodyBox.width = 23;
					bodyBox.height = 28;
					break;
				}
				// 行走时碰撞区域
				case "run":
				{
					bodyBox.x = 4;
					bodyBox.y = 0;
					bodyBox.width = 23;
					bodyBox.height = 45;
					break;
				}
					
				default:
				{
					break;
				}
			}
		}
		
		
		// 是否按住移动摇杆
		private var pressing:Boolean;
		/**
		 * 改变移动方向
		 */
		public function setDirection(dir:String,clickDown:Boolean):void {
			if (direction != dir) {
				// 如果改变的方向与当前方向不同，则停止播放动画
				// 让 moveAndChangeAni() 函数另外播放其他动画
				
				// 设置方向
				this.direction = dir; 
				// 是否停止播放动画
				ani.stop();			
			} else {
				// 如果方向没有改变时，再判断是否需要停止播放动画
				if (roleState === "stop") {
					ani.stop();	
				}
				
			}
			// 正在按压移动摇杆（true:是，false:否）
			pressing = clickDown;
		}
		
		
		/**
		 * 改变人物目前的状态
		 */
		public function setRoleState(state:String):void {
			if (roleState === "jump") {
				return;
			} else {
				// 如果当前状态为 obl_down/up，但是更改后的状态state不是obl_down/up，
				// 则修改 isObl，设置当前不为 斜 的方向
				if ((roleState != "obl_down" && state === "obl_down") 
					|| 
					(roleState != "obl_up" && state === "obl_up")
					||
					(roleState != "run" && state === "run")) {
						ani.stop();
				}	
				// 设置状态
				roleState = state;
			}
			
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