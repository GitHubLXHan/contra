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
		private var direction:String;
		// 人物状态
		private var roleState:String; 
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
			
//			roleSp.pos(100, 0);
				
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
				console.log("进入 myself");
				trace(self);
				rigid.gravityScale =  0;
				console.log("触碰到");
				roleState = "touch";
				
			}
			
			// 触碰当不可行走障碍物
			if (other.label === "l_wall" && roleState != "jump") {
//				roleState = "no_right";
				isCanRight = false;
			}else if (other.label === "r_wall"  && roleState != "jump") {
//				roleState = "no_left";
				isCanLeft = false;
			}
		}

		/**
		 * 碰撞结束
		 */
		override public function onTriggerExit(other:*, self:*, contact:*):void {
			if((other.label === "pass_y" || other.label === "pass_n") && roleState != "jump" && self.label === "foot") {
				console.log("出来");
				trace(self);
				rigid.type = "dynamic";
				rigid.gravityScale = 1;
				roleState = "jump";
				
			}
			if (other.label === "l_wall") {
//				roleState = "run";
				isCanRight = true;
			}
			if (other.label === "r_wall") {
//				roleState = "run";
				isCanLeft = true;
			}
			console.log("碰撞结束");
			trace(self);
			
		}
		
		/**
		 * 持续碰撞
		 */
		override public function onTriggerStay(other:*, self:*, contact:*):void {
			console.log("持续碰撞");
			trace(self);
			self = footBox;
		}
		
		/**
		 * 跳跃
		 */
		public function jump():void {
			rigid.type = "dynamic";
			rigid.gravityScale = 1;
			rigid.linearVelocity = {x:0, y:-6};
			roleState = "jump";
			ani.stop();
		}
		
		public function moveAndChangeAni():void {
			// 播放人物动画及移动人物
			switch(direction)
			{
				case "right":
				{
					if (!ani.isPlaying) {
						switch(roleState)
						{
							case "jump":
							{
								if (pressing) {
									// 跳跃时且向右走
									rigid.setVelocity({x:1, y:rigid.linearVelocity.y});	
								}								
								// 播放跳跃动画
								ani.play(0, true, "blue_r_jump");
								// 更改跳跃时碰撞区
								bodyBox.x = 0;
								bodyBox.y = 0;
								bodyBox.width = 23;
								bodyBox.height = 28;
								break;
							}
							case "run":
							{
								if (isCanRight) {
									//没有跳跃且可以像右走
									rigid.linearVelocity = {x:1, y:0};
								} else {
									//没有跳跃，不可以像右走
									rigid.linearVelocity = {x:0, y:0};
								}
								// 播放向右走动画
								ani.play(0, true, "blue_r_run");
								// 更改站立或行走时碰撞区
								bodyBox.x = 4;
								bodyBox.y = 0;
								bodyBox.width = 23;
								bodyBox.height = 45;
								break;
							}
							case "stop":
							{
								// 停止移动
								rigid.setVelocity({x:0 , y:0});
								ani.play(0, false, "blue_r_stand");
//								roleState = "run";
								break;
							}
							
							case "touch":
							{
								if (pressing) {
									roleState = "run";
								} else {
									roleState = "stop";
								}
								break;
							}
							case "lie":
							{
								if (rigid.linearVelocity.y == 0) {
									ani.play(0, false, "blue_r_lie");
									rigid.setVelocity({x:0, y:0});
								}
								break;
							}	
							default:
							{
								break;
							}
						}						
					} else {
						// 正在播放动画的情况下
						switch(roleState)
						{
							case "jump":
							{
								if (pressing) {
									// 跳跃情况下，移动人物
									rigid.linearVelocity = {x:1, y:rigid.linearVelocity.y};	
								}
								// 更改跳跃时碰撞区
								bodyBox.x = 0;
								bodyBox.y = 0;
								bodyBox.width = 23;
								bodyBox.height = 28;
								break;
							}
							case "run":
							{								
								if (isCanRight) {
									//没有跳跃且可以像右走的情况下
									rigid.linearVelocity = {x:1, y:0};
								} else {
									// 不可向右走
									rigid.linearVelocity = {x:0, y:0};	
								}
								// 更改站立或行走碰撞区
								bodyBox.x = 4;
								bodyBox.y = 0;
								bodyBox.width = 23;
								bodyBox.height = 45;
								break;
							}
							case "stop":
							{
								// 停止移动
								rigid.setVelocity({x:0 , y:0});
//								roleState = "run";
								break;
							}
							case "touch":
							{
								if (pressing) {
									ani.stop();
									roleState = "run";
								} else {
									ani.stop();
									roleState = "stop";
								}
								break;
							}
							case "lie":
							{
								if (rigid.linearVelocity.y == 0) {
									ani.play(0, false, "blue_r_lie");
									rigid.setVelocity({x:0, y:0});
								}
								break;
							}
							default:
							{
								break;
							}
						}
					}
					break;
				}
				case "left":
				{
					if (!ani.isPlaying) {
						switch(roleState)
						{
							case "jump":
							{
								if (pressing) {
									// 跳跃时且向右走
									rigid.setVelocity({x:-1, y:rigid.linearVelocity.y});
								}								
								// 播放跳跃动画
								ani.play(0, false, "blue_l_jump");
								// 更改跳跃时碰撞区
								bodyBox.x = 0;
								bodyBox.y = 0;
								bodyBox.width = 23;
								bodyBox.height = 28;
								break;
							}
							case "run":
							{
								if (isCanLeft) {
									//没有跳跃且可以像右走的情况下
									rigid.linearVelocity = {x:-1, y:0};
								} else {
									// 不可向右走时
									rigid.linearVelocity = {x:0, y:0};
								}
								// 播放向右走动画
								ani.play(0, true, "blue_l_run");	
								// 更改站立或行走时碰撞区
								bodyBox.x = 4;
								bodyBox.y = 0;
								bodyBox.width = 23;
								bodyBox.height = 45;
								break;
							}
							case "stop":
							{
								// 停止移动
								rigid.setVelocity({x:0 , y:0});
								ani.play(0, false, "blue_l_stand");
//								roleState = "run";
								break;
							}
							case "touch":
							{
								if (pressing) {
									roleState = "run";
								} else {
									roleState = "stop";
								}
								break;
							}
							case "lie":
							{
								if (rigid.linearVelocity.y == 0) {
									ani.play(0, false, "blue_l_lie");
									rigid.setVelocity({x:0, y:0});
								}
								break;
							}
							default:
							{
								break;
							}
						}						
					} else {
						// 正在播放动画的情况下
						switch(roleState)
						{
							case "jump":
							{
								if (pressing) {
									// 跳跃情况下，移动人物
									rigid.linearVelocity = {x:-1, y:rigid.linearVelocity.y};
								}
								// 更改跳跃时碰撞区
								bodyBox.x = 0;
								bodyBox.y = 0;
								bodyBox.width = 23;
								bodyBox.height = 28;
								break;
							}
							case "run":
							{				
								if (isCanLeft) {
									//没有跳跃且可以像右走的情况下
									rigid.linearVelocity = {x:-1, y:0};
									
								} else {
									rigid.linearVelocity = {x:0, y:0};									
								}
								// 更改站立或行走时碰撞区
								bodyBox.x = 4;
								bodyBox.y = 0;
								bodyBox.width = 23;
								bodyBox.height = 45;			
								break;
							}
							case "stop":
							{
								// 停止移动
								rigid.setVelocity({x:0 , y:0});
//								roleState = "run";
								break;
							}
							case "touch":
							{
								if (pressing) {
									ani.stop();
									roleState = "run";
								} else {
									ani.stop();
									roleState = "stop";
								}
								break;
							}
							case "lie":
							{
								if (rigid.linearVelocity.y == 0) {
									ani.play(0, false, "blue_l_lie");
									rigid.setVelocity({x:0, y:0});
									
								}
								break;
							}
							default:
							{
								break;
							}
						}
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
				default:
				{
					break;
				}
			}	
		}
		
	
		/**
		 * 改变移动方向
		 */
		private var pressing:Boolean;
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
			roleState = roleState === "jump" ? "jump" : state;
			
		
				
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