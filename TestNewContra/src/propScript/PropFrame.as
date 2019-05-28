package propScript {
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Pool;
	import laya.maths.Rectangle;
	
	
	public class PropFrame extends Script {
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
			rigid.enabled = true;
			noShootSp.visible = false;
			canShootSp.visible = true;
			canShootAni.play(0, false, "can_shoot_ani");
			Laya.timer.once(1000, this, playNoShoot);
		}
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "bullet") {
				// 通过对象池获取动画
				var aniBoom:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
				aniBoom.play(0, false);
				aniBoom.pos(box.x, box.y);
				// 将动画添加到父容器中
				box.parent.addChild(aniBoom);
				
				// 创建道具
				var prop:Sprite = createProp();
				prop.pos(box.x, box.y);
				box.parent.addChild(prop);
				
				// 最后删除自己并回收
				box.removeSelf();
				Pool.recover("enemyProp", box);
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
			if ((scrollRect.width != 0) && box.x < scrollRect.x) {
				box.removeSelf();
				Pool.recover("enemyProp", box);
			}
			
		}
		
		override public function onDisable():void {
			Laya.timer.clearAll(this);
		}
	}
}