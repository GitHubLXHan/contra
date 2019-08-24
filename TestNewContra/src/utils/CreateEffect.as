package utils
{
	import laya.display.Animation;
	import laya.events.Event;
	import laya.utils.Pool;
	import laya.utils.Handler;

	public class CreateEffect
	{
		private static var _instance:CreateEffect;
		
		/**
		 * 1.函数的参数没有默认值，在没有传递参数的情况下去调用这个函数，编译器就会报错
		 * 2.内部类 Singletonm 只能对包内可见。在一个 .as 文件里可以写多个类。与文件名
		 *   相同的那个类叫主类，主类只能有一个，其它类可以是任意多个，而且其它类只对包
		 *   内可见，不能被外部引用。
		 */
		public function CreateEffect(sn:Singletonm){}
		
		
		public static function getInstance():CreateEffect {
			// 只有静态的私有变量 _instance CreateEffect，
			// 当第二次调用这个静态的 getInstance() 方法时，因为 _instance 不为null，
			// 所以不再new出第二个 CreateEffect，而是直接返回已存在的 _instance。
			// 这样就保证了全世界只有一个 CreateEffect 类型的实例
			if (CreateEffect._instance == null) {
				CreateEffect._instance = new CreateEffect(new Singletonm());
			}
			return CreateEffect._instance;
		}
		
		// 创建爆炸动画
		public function createEnemyObjBoomAni():Animation
		{
			console.log('工具中创建daoju爆炸');
			var ani:Animation = new Animation();
			// 加载动画
			ani.loadAnimation("GameScene/EnemyObjBoom.ani", Handler.create(this, function():void{
				console.log('Enemy 爆炸资源动画完毕');
			}));
			// 动画播放完后又回收到对象池中
			ani.on(Event.COMPLETE, null, function ():void{
				// 从容器中移除动画
				ani.removeSelf();
				// 回收到对象池
				//	console.log('propFrame动画回收');
				Pool.recover("enemyObjBoom", ani);
			});
			return ani;
		}
		
		/**
		 * 当对象池中没有爆炸动画时，
		 * 则调用此函数创建动画
		 */
		public function createEnemyRoleBoomAni():Animation
		{
			var ani:Animation = new Animation();
			ani.loadAnimation("GameScene/EnemyObjBoom.ani", Handler.create(this, function():void{
				console.log('Role 爆炸资源动画完毕');
			}), 'res/atlas/boom.atlas');
			console.log('在One中创建juese爆炸');
			console.log(ani);
			ani.on(Event.COMPLETE, null, function():void {
				ani.removeSelf();
				//				console.log('enemyOne中的爆炸回收');
				Pool.recover("enemyRoleBoom",ani);
			});
			return ani;
		}
		
	}
	
	
	
}

class Singletonm{};