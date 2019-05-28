package propScript {
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.maths.Rectangle;
	import laya.media.SoundManager;
	import laya.physics.RigidBody;
	import laya.utils.Pool;
	
	public class PropR extends Script {

		// 本对象精灵
		private var thisSp:Sprite;
		// 本对象刚体
		private var rigid:RigidBody;
		
		override public function onEnable():void {
			// 获取本对象精灵
			thisSp = this.owner as Sprite;
			
			// 获取刚体并设置速度
			rigid = thisSp.getComponent(RigidBody);
			rigid.setVelocity({x:2 ,y:-6});
		}
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (rigid.linearVelocity.y > 0 && (other.label === "pass_y" || other.label === "pass_n" || other.label === "water")) {
				rigid.type = "kinematic";
				rigid.setVelocity({x:0 ,y:0});
			}
			
			if (other.label === "body") {
				//播放音效
				SoundManager.playSound("sound/get_prop.wav");
				// 删除自己并回收到对象池
				thisSp.removeSelf();
				Pool.recover("prop_r", thisSp);
			}
		}
		
		override public function onUpdate():void {	
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && (thisSp.x < scrollRect.x || thisSp.y > (scrollRect.y + scrollRect.height))) {
				thisSp.removeSelf();
				Pool.recover("prop_r", thisSp);
			}
			
		}
		
		override public function onDisable():void {
		}
	}
}