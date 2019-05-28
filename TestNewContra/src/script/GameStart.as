package script {
	import laya.display.Stage;
	import laya.maths.Point;
	import laya.media.SoundManager;
	import laya.physics.ChainCollider;
	import laya.utils.Stat;
	import laya.webgl.WebGL;
	
	import ui.GameScene.GameMainSceneUI;
	
	public class GameStart extends GameMainSceneUI {
		/** @prop {name:intType, tips:"整数类型示例", type:Int, default:1000}*/
		public var intType: int = 1000;
		/** @prop {name:numType, tips:"数字类型示例", type:Number, default:1000}*/
		public var numType: Number = 1000;
		/** @prop {name:strType, tips:"字符串类型示例", type:String, default:"hello laya"}*/
		public var strType: String = "hello laya";
		/** @prop {name:boolType, tips:"布尔类型示例", type:Bool, default:true}*/
		public var boolType: Boolean = true;
		// 更多参数说明请访问: https://ldc2.layabox.com/doc/?nav=zh-as-2-4-0

		public function GameStart():void {
			super();
		}

		override public function onEnable():void {
			Laya.init(667, 375, WebGL);
			Laya.stage.screenMode = Stage.SCREEN_HORIZONTAL;			
			Laya.stage.scaleMode = Stage.SCALE_FIXED_WIDTH;	
			// Laya.enableDebugPanel();
			// Stat.show();						
		}
		
		override public function onDisable():void {
		}
	}
}