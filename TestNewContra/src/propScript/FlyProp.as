package propScript {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.physics.BoxCollider;
	import laya.physics.RigidBody;
	import laya.utils.Ease;
	import laya.utils.Handler;
	import laya.utils.Pool;
	import laya.utils.Tween;
	
	import utils.CreateEffect;
	import utils.CreateProps;
	
	public class FlyProp extends Script {
		/** @prop {name:propsBox, tips:"道具", type:prefab}*/
		public var propsBox:Prefab;
		
		private var thisSp:Sprite;
		private var thisCollider:BoxCollider;
		private var thisRigid:RigidBody;
		
		override public function onEnable():void {
			// 获取本对象精灵
			thisSp = this.owner as Sprite;
			thisRigid = thisSp.getComponent(RigidBody);
			thisRigid.setVelocity({x: 2, y:thisRigid.linearVelocity.y});
			// 飞行
			flyDown();
		}
		
		
		/**
		 * 向上飞行
		 */
		private function flyUp():void {
			Tween.to(thisSp, {y:thisSp.y - 60}, 900, Ease.backOut, Handler.create(this, flyDown));
		}
		
		/**
		 * 向下飞行
		 */
		private function flyDown():void {
			Tween.to(thisSp, {y:thisSp.y + 60}, 900, Ease.backOut, Handler.create(this, flyUp));
		}
		
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "bullet" && self.label === "fly_prop") {
				// 通过对象池获取动画
				var aniBoom:Animation;	
				aniBoom = Pool.getItemByCreateFun("enemyObjBoom", CreateEffect.getInstance().createEnemyObjBoomAni, this);
				aniBoom.play(0, false);
				aniBoom.pos(thisSp.x, thisSp.y);
				
				// 将动画添加到父容器中
				thisSp.parent.addChild(aniBoom);
				
				// 创建道具
				var prop:Sprite =Pool.getItemByCreateFun("propsBox", propsBox.create, propsBox);
				prop.pos(thisSp.x, thisSp.y);
				thisSp.parent.addChild(prop);

				// 最后删除自己待系统回收
				thisSp.removeSelf();
				
			}
		}		
				
		
		override public function onUpdate():void {	
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && thisSp.x > (scrollRect.x + scrollRect.width)) {
				// 删除自己待系统回收
				thisSp.removeSelf();
			}
			
		}
		
		override public function onDisable():void {
			// 清除缓东效果
			Tween.clearAll(thisSp);
			// 回收自己
			Pool.recover("flyProp", thisSp);
		}
	}
}