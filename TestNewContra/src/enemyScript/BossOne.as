package enemyScript {
	
	import laya.components.Prefab;
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.media.SoundChannel;
	import laya.media.SoundManager;
	import laya.ui.Box;
	import laya.utils.Handler;
	import laya.utils.Pool;
	
	public class BossOne extends Script {
		/** @prop {name:bullet, tips:"子弹", type:prefab}*/
		public var bullet: Prefab;

		
		// 本对象盒子
		private var box:Box;
		
		
		// 所有精灵
		private var top01:Sprite;
		private var top02:Sprite;
		private var foot:Sprite;

		
		
		
		override public function onEnable():void {
			// 获取本对象盒子
			box = this.owner as Box;
			
			// 获取所有精灵
			top01 = box.getChildByName("top01") as Sprite;
			top02 = box.getChildByName("top02") as Sprite;
			foot = box.getChildByName("foot") as Sprite;
		}
		

		private var isAllDestoryed:Boolean = false;
		override public function onUpdate():void {
			if (!isAllDestoryed && top01.destroyed && top02.destroyed && foot.destroyed) {
				// 爆炸
				bossOneBoom();
				isAllDestoryed = true;
			}
		}

		/**
		 * boss机爆炸
		 */
		private function bossOneBoom():void
		{
			box.visible= false;
			// 分成两波爆炸效果
			Laya.timer.once(0, this, boom);
			Laya.timer.once(500, this, boom);
			
			// 最后销毁boss
			Laya.timer.once(1000, this, function():void {
				box.destroy(true);
			});
		}		
		
		private function boom():void{
			// 通过对象池获取动画
			var aniBoom01:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
			var aniBoom02:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
			var aniBoom03:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
			var aniBoom04:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
			var aniBoom05:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
			var aniBoom06:Animation = Pool.getItemByCreateFun("enemyObjBoom", createEnemyObjBoomAni, this);
			
			// 随机设置位置
			aniBoom01.pos(box.x + Math.random() * 190, box.y + 160 + Math.random() * 90);
			aniBoom02.pos(box.x + Math.random() * 190, box.y + 160 + Math.random() * 90);
			aniBoom03.pos(box.x + Math.random() * 190, box.y + 160 + Math.random() * 90);
			aniBoom04.pos(box.x + Math.random() * 190, box.y + 160 + Math.random() * 90);
			aniBoom05.pos(box.x + Math.random() * 190, box.y + 160 + Math.random() * 90);
			aniBoom06.pos(box.x + Math.random() * 190, box.y + 160 + Math.random() * 90);
			
			// 将动画添加到父容器中
			box.parent.addChildren(aniBoom01, aniBoom02, aniBoom03, aniBoom04, aniBoom05, aniBoom06);

			// 先停止背景音乐
			SoundManager.stopMusic();
			// 播放音效
			SoundManager.playSound("sound/boss01_boom.wav",1, Handler.create(this, onComplete));
			
			// 播放动画
			aniBoom01.play(0,false);
			aniBoom02.play(0,false);
			aniBoom03.play(0,false);
			aniBoom04.play(0,false);
			aniBoom05.play(0,false);
			aniBoom06.play(0,false);
		}
		
		
		private function onComplete():void
		{
			// 播放游戏结束音效
			SoundManager.playSound("sound/gameover.wav");
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
		
		
		override public function onDisable():void {
		}
	}
}