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
	
	public class FlyProp extends Script {
		/** @prop {name:propM, tips:"M类道具", type:prefab}*/
		public var propM:Prefab;
		/** @prop {name:propB, tips:"B类道具", type:prefab}*/
		public var propB:Prefab;
		/** @prop {name:propF, tips:"F类道具", type:prefab}*/
		public var propF:Prefab;
		/** @prop {name:propS, tips:"S类道具", type:prefab}*/
		public var propS:Prefab;
		/** @prop {name:propL, tips:"L类道具", type:prefab}*/
		public var propL:Prefab;
		/** @prop {name:propR, tips:"R类道具", type:prefab}*/
		public var propR:Prefab;
		
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
				var aniBoom:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
				aniBoom.play(0, false);
				aniBoom.pos(thisSp.x, thisSp.y);
				// 将动画添加到父容器中
				thisSp.parent.addChild(aniBoom);
				
				// 创建道具
				var prop:Sprite = createProp();
				prop.pos(thisSp.x, thisSp.y);
				thisSp.parent.addChild(prop);
				
				// 最后删除自己并回收
				thisSp.removeSelf();
				Pool.recover("flyProp", thisSp);
			}
		}		
		
		/**
		 * 随机创建道具
		 */
		private function createProp():Sprite
		{
			// 随机生成数以随机生成道具类型
			var type:Number = Math.random();
			var prop:Sprite;
			if (type >= 0 && type < 0.15) {
				// 创建 M类型道具
				prop = Pool.getItemByCreateFun("prop_m", propM.create, propM);
			} else if (type >= 0.15 && type < 0.3) {
				// 创建 B类型道具
				prop = Pool.getItemByCreateFun("prop_b", propB.create, propB);
			} else if (type >= 0.3 && type < 0.45) {
				// 创建 F类型道具
				prop = Pool.getItemByCreateFun("prop_f", propF.create, propF);
			} else if (type >= 0.45 && type < 0.6) {
				// 创建 S类型道具
				prop = Pool.getItemByCreateFun("prop_s", propS.create, propS);
			} else if (type >= 0.6 && type < 0.75) {
				// 创建 L类型道具
				prop = Pool.getItemByCreateFun("prop_l", propL.create, propL);
			} else if (type >= 0.75 && type < 0.9) {
				// 创建 R类型道具
				prop = Pool.getItemByCreateFun("prop_r", propR.create, propR);
			}
			return prop;
		}		
		
		
		// 创建爆炸动画
		private function createEnemyObjBoomAni():Animation
		{
			var ani:Animation = new Animation();
			// 加载动画
			ani.loadAnimation("GameScene/EnemyObjBoom.ani",null, "res/atlas/boom.atlas");
			// 动画播放完后又回收到对象池中
			ani.on(Event.COMPLETE, null, function ():void{
				// 从容器中移除动画
				ani.removeSelf();
				// 回收到对象池
				Pool.recover("enemyObjBoom", ani);
			});
			return ani;
		}
		
		override public function onUpdate():void {	
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && thisSp.x > (scrollRect.x + scrollRect.width)) {
				thisSp.removeSelf();
				Pool.recover("flyProp", thisSp);
			}
			
		}
		
		override public function onDisable():void {
			Tween.clearAll(thisSp);
		}
	}
}