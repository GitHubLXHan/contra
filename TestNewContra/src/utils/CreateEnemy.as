package utils
{
	import laya.display.Sprite;
	import laya.physics.RigidBody;
	import laya.ui.Box;
	import laya.utils.Pool;

	/**
	 * 使用单例模式创建 CreateEnemy 对象
	 * 详细见 CreateEffect.as
	 */
	
	public class CreateEnemy
	{
		private static var _instance:CreateEnemy;
		
		public function CreateEnemy(sn:Singletonm){}
		
		public static function getInstance():CreateEnemy {
			if (CreateEnemy._instance == null) {
				_instance = new CreateEnemy(new Singletonm());
			}
			return CreateEnemy._instance;
		}
		
		/**
		 * 产生第一类敌人
		 */
		public function produceEnemyOne(...args):void {
			// 第一类敌人临时变量
			var enemyOneSp:Sprite;
			enemyOneSp = Pool.getItemByCreateFun("enemyOne", args[0].create, args[0]);
			enemyOneSp.pos(args[2], args[3]);
			args[1].addChild(enemyOneSp);
		}
		
		/**
		 * 产生第二类敌人
		 */
		public function produceEnemyTow(...args):void
		{
			// 第二类敌人临时变量
			var enemyTowSp:Sprite;
			// 初始化第二类敌人
			enemyTowSp = Pool.getItemByCreateFun("enemyTow", args[0].create, args[0]);
			enemyTowSp.pos(args[2], args[3]);
			//设置速度
			var r:RigidBody = enemyTowSp.getComponent(RigidBody);
			r.setVelocity(args[4]);
			args[1].addChild(enemyTowSp);
		}
		
		/**
		 * 产生第三类敌人
		 */
		public function produceEnemyThree(...args):void {
			// 第三类敌人临时变量
			var enemyThreeSp:Sprite;
			enemyThreeSp = Pool.getItemByCreateFun("enemyThree", args[0].create, args[0]);
			enemyThreeSp.pos(args[2], args[3]);
			args[1].addChild(enemyThreeSp);
		}
		
		/**
		 * 产生第四类敌人
		 */
		public function produceEnemyFour(...args):void {
			// 测试--第四类敌人
			var enemyFourSp:Box;
			enemyFourSp = Pool.getItemByCreateFun("enemyFour", args[0].create, args[0]);
			enemyFourSp.pos(args[2], args[3]);
			args[1].addChild(enemyFourSp);
		}
		
		
		/**
		 * 生产第五类敌人
		 */
		public function produceEnemyFive(...args):void
		{
			var enemyFiveSp:Sprite;
			enemyFiveSp = Pool.getItemByCreateFun("enemyFive", args[0].create, args[0]);
			enemyFiveSp.pos(args[2],args[3]);
			args[1].addChild(enemyFiveSp);	
		}
		
		/**
		 * 生产第一关BOSS
		 */
		public function produceBoss01(...args):void {
			var enemyBoss01Sp:Sprite;
			enemyBoss01Sp = Pool.getItemByCreateFun("enemyBoss01", args[0].create, args[0]);
			enemyBoss01Sp.pos(args[2], args[3]);
			args[1].addChild(enemyBoss01Sp);
		}
		
		/**
		 * 生产道具框架
		 */
		public function producePropFrame(...args):void
		{
			var propFrameSp:Box;
			propFrameSp = Pool.getItemByCreateFun("enemyProp", args[0].create, args[0]);
			propFrameSp.pos(args[2], args[3]);
			args[1].addChild(propFrameSp);			
		}
		
		/**
		 * 生产飞行物
		 */		
		public function produceFlyProp(...args):void {
			var flyPropSp:Sprite;
			flyPropSp = Pool.getItemByCreateFun("flyProp", args[0].create, args[0]);
			flyPropSp.pos(Laya.stage.scrollRect.x, args[2]);
			args[1].addChild(flyPropSp);
		}
		
		
	}
}
class Singletonm{}