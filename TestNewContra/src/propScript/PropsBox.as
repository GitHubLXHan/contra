package propScript {
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.maths.Rectangle;
	import laya.media.SoundManager;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Pool;
	
	public class PropsBox extends Script {
		
		// 本对象盒子
		private var thisBox:Box;
		// 本对象刚体
		private var rigid:RigidBody;
		// 愈显示的精灵
		private var sp:Sprite;
		
		
		override public function onEnable():void {
			// 获取本对象精灵
			thisBox = this.owner as Box;
			// 道具名字数组
			var propsArr:Array = ["propM", "propB", "propF", "propS", "propL", "propR",];
			// 随机指定道具
			var type:uint = Math.round(Math.random() * 5);
			sp = thisBox.getChildByName(propsArr[type]) as Sprite;
			// 设置可见
			sp.visible = true;
			
			console.log("随机道具名字" + propsArr[type]);
			
			
			// 获取刚体并设置速度
			rigid = thisBox.getComponent(RigidBody);
			rigid.setVelocity({x:2 ,y:-6});
			rigid.type = "dynamic";
		}
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (rigid.linearVelocity.y > 0 && (other.label === "pass_y" || other.label === "pass_n" || other.label === "water")) {
				rigid.type = "kinematic";
				rigid.setVelocity({x:0 ,y:0});
			}
			
			if (other.label === "body") {
				//播放音效
				SoundManager.playSound("sound/get_prop.wav");
				// 先设置精灵不可见
				sp.visible = false;
				// 删除自己并回收到对象池
				thisBox.removeSelf();
			}
		}
		
		override public function onUpdate():void {	
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && (thisBox.x < scrollRect.x || thisBox.y > (scrollRect.y + scrollRect.height))) {
				thisBox.removeSelf();
				
			}
			
		}
		
		override public function onDisable():void {
			Pool.recover("propsBox", thisBox);
		}
	}
}