package propScript {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Pool;
	
	import utils.CreateEffect;
	import utils.CreateProps;
	
	
	public class PropFrame extends Script {
		/** @prop {name:propsBox, tips:"道具", type:prefab}*/
		public var propsBox:Prefab;
		
		
		private var canShootSp:Sprite;
		private var noShootSp:Sprite;
		private var canShootAni:Animation;
		private var rigid:RigidBody;
		private var box:Box;
		
		override public function onEnable():void {
			
			// 获取本对象
			box = this.owner as Box;
			canShootSp = box.getChildByName("can_shoot") as Sprite;
			canShootSp.visible = false;
			noShootSp = box.getChildByName("no_shoot") as Sprite;
			noShootSp.visible = false;
			
			rigid = box.getComponent(RigidBody);
			canShootAni = this.owner["can_shoot_ani"] as Animation;
		
			playNoShoot();
		}
		
		
		/**
		 * 不启动刚体，显示关闭状态的图片，
		 * 时间维持一秒，期间子弹不可击打该道具
		 */
		private function playNoShoot():void
		{
			if (!this.box.activeInHierarchy) {
				console.log('No中打印未激活'); 
				return;
			}
			rigid.enabled = false;
			noShootSp.visible = true;
			canShootSp.visible = false;			
			Laya.timer.once(1000, this, playCanShoot);
		}
		
		/**
		 * 启动刚体，播放打开状态的动画，
		 * 时间维持一秒，期间子弹可以击打该道具
		 */
		private function playCanShoot():void
		{
			if (!this.box.activeInHierarchy){ 
				console.log('Can中打印未激活');
				return;
			}
			rigid.enabled = true;	
			noShootSp.visible = false;
			canShootSp.visible = true;
			canShootAni.play(0, false, "can_shoot_ani");
			Laya.timer.once(1000, this, playNoShoot);
		}
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "bullet") {
				// 通过对象池获取动画
				var aniBoom:Animation;
				aniBoom = Pool.getItemByCreateFun("enemyObjBoom", CreateEffect.getInstance().createEnemyObjBoomAni, this);
				aniBoom.play(0, false);
				aniBoom.pos(box.x, box.y);
	
				// 将动画添加到父容器中
				box.parent.addChild(aniBoom);
				
				// 创建道具
				var prop:Box = Pool.getItemByCreateFun("propsBox", propsBox.create, propsBox);
				prop.pos(box.x, box.y);
				box.parent.addChild(prop);					
				

				// 最后删除自己待系统回收
				box.removeSelf();
				Laya.timer.clear(this, playNoShoot);
				Laya.timer.clear(this, playCanShoot);
			}
		}
		
	
		
		
		override public function onUpdate():void {	
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && box.x < scrollRect.x) {
				// 删除自己带系统回收
				box.removeSelf();
			}
			
		}
		
		override public function onDisable():void {
			// 清除所有定时器
			
			// 回收自己
			Pool.recover("enemyProp", box);
		}
	}
}