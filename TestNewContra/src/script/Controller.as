package script {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Graphics;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.events.Keyboard;
	import laya.maths.Rectangle;
	import laya.physics.BoxCollider;
	import laya.physics.RigidBody;
	import laya.utils.Browser;
	import laya.utils.Ease;
	import laya.utils.Handler;
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
		
		// 三段地图
		private var map1:Sprite;
		private var map2:Sprite;
		private var map3:Sprite;
		// 三张个合一
		private var map:Sprite;
		private var viewPort:Rectangle;
		private var rec:Rectangle;

		// 人物脚本
		private var roleClass:Role;
		// 人物精灵
		private var roleSp:Sprite;

		
		override public function onEnable():void {
			map = this.owner.getChildByName("background") as Sprite;


			// 创建人物预制件
			roleClass = role.create() as Role;
			roleSp = roleClass as Sprite;
			map.addChild(roleSp);
		}
	
		
		
		
		override public function onDisable():void {
		}
	}
}