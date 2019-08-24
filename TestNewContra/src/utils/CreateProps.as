package utils
{
	import laya.display.Sprite;
	import laya.utils.Pool;

	public class CreateProps
	{
		private static var _instance:CreateProps;
		
		public function CreateProps(sn:Singlestonm){}
	
		public static function getInstance():CreateProps {
			if (CreateProps._instance == null) {
				CreateProps._instance = new CreateProps(new Singlestonm());
			}
			return CreateProps._instance;
		}
		
		
		/**
		 * 随机创建道具
		 */
		public function createProp(...args):Sprite
		{
			
			var singArray:Array = ["prop_m", "prop_b", "prop_f", "prop_s", "prop_l", "prop_r"];
			// 随机生成数以随机生成道具类型
			var type:uint = Math.round(Math.random()* 5);
			var prop:Sprite = Pool.getItemByCreateFun(singArray[type], args[type].create, args[type]);
			
			return prop;
		}	
		
	}
}
class Singlestonm{}