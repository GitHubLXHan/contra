package enemyScript {
	import laya.components.Script;
	import laya.display.Animation;
	import laya.display.Sprite;
	import laya.events.Event;
	import laya.maths.Rectangle;
	import laya.physics.RigidBody;
	import laya.utils.Pool;
	
	import utils.CreateEffect;
	
	public class EnemyTow extends Script {
		
		private var thisSp:Sprite;
		private var enemyTowAni:Animation;
		private var rigid:RigidBody;
		private var type:Number; // 类型：2表示走到陆地边缘就往回走；0表示走到陆地边缘就跳出来
		
		override public function onEnable():void {
			thisSp = this.owner as Sprite;
			thisSp.visible = false;
			
			//  通过对象池加载第二类敌人行走的动画
			enemyTowAni = Pool.getItemByCreateFun("enemyTowAni", createEnemyTowAni, enemyTowAni);
			
			// 添加到舞台
			thisSp.parent.addChild(enemyTowAni);
			
			// 判断目前行走的方向，以改变播放的动画
			rigid = thisSp.getComponent(RigidBody);
			var aniName:String;
			if (rigid.linearVelocity.x < 0) {
				aniName = "enemy_tow_left";
			} else if (rigid.linearVelocity.x > 0) {
				aniName = "enemy_tow_right";
			}
			
			// 播放动画
			enemyTowAni.play(0, true, aniName);
			
			// 随机生成类型
			type = Math.random() > 0.5 ? 2 : 0;
			
		}
		
		/**
		 * 当对象池中没有第二类敌人的动画时 ，
		 * 调用此函数创建动画
		 */
		private function createEnemyTowAni():Animation
		{
			var ani:Animation = new Animation();
			ani.loadAnimation("GameScene/EnemyTow.ani", null, "res/atlas/enemy_tow.atlas");			
			return ani;
		}
		

		
		override public function onTriggerExit(other:*, self:*, contact:*):void {
			if ((other.label === "pass_y" || other.label === "pass_n") && self.label === "enemy_tow_foot") {
				if (type == 0) {
					rigid.type = "dynamic";
					rigid.setVelocity({x:rigid.linearVelocity.x, y:-5});
				} else {
					rigid.setVelocity({x:-rigid.linearVelocity.x, y:0});
					enemyTowAni.stop();
					var aniName:String;
					if (rigid.linearVelocity.x < 0) {
						aniName = "enemy_tow_left";
					} else if (rigid.linearVelocity.x > 0) {
						aniName = "enemy_tow_right";
					}
					enemyTowAni.play(0, true, aniName);
					type --;
				}
				
			}

		}
		
		
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "bullet" && self.label === "enemy_tow") {
				// 先停止播放敌人动画，对象池会自动回收该动画
				enemyTowAni.stop();
				enemyTowAni.removeSelf();
				Pool.recover("enemyTowAni", enemyTowAni);
				// 从对象池中加载爆炸动画后播放
				var boomAni:Animation = Pool.getItemByCreateFun("enemyRoleBoom", CreateEffect.getInstance().createEnemyRoleBoomAni, this);
				console.log('敌人二死亡');
				console.log(boomAni);
				boomAni.play(0, false, "enemyRoleBoom");
				boomAni.pos(thisSp.x, thisSp.y);
				thisSp.parent.addChild(boomAni);
				
				// 删除本对象
				thisSp.removeSelf();
//				console.log('enemyTow回收');
			}
			
			if (rigid.linearVelocity.y > 0 && (other.label === "pass_y" || other.label === "pass_n") && self.label === "enemy_tow_foot") {
				rigid.type = "kinematic";
				rigid.setVelocity({x:rigid.linearVelocity.x, y:0});
			}
		}
			
		
		override public function onUpdate():void{
			// 人物动画跟随刚体行走
			enemyTowAni.pos(thisSp.x, thisSp.y);
			
			// 超出显示区域则删除及回收自己
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			if ((scrollRect.width != 0) && (thisSp.x < scrollRect.x || thisSp.y > (scrollRect.y + scrollRect.height))) {
				console.log(thisSp.x,scrollRect.x, scrollRect.width);
				enemyTowAni.removeSelf();
				
				// 删除自己待系统回收
				thisSp.removeSelf();		
			}
		}
		
		/**
		 * 回收本对象
		 */
		override public function onDisable():void {
			// 回收自己
			console.log('tow 中 onDisable');
			Pool.recover("enemyTow", thisSp);
		}
	}
}