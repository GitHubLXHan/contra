package enemyScript {
	import laya.components.Script;
	import laya.display.Sprite;
	import laya.maths.Rectangle;
	import laya.utils.Pool;
	
	public class EnemyBullet extends Script {

		private var thisSp:Sprite;
		

		override public function onEnable():void {
			thisSp = this.owner as Sprite;	
			
		}
	
		override public function onTriggerEnter(other:*, self:*, contact:*):void {
			if (other.label === "body") {
				thisSp.removeSelf();
				Pool.recover("enemyBullet", thisSp);

			}
		}
		
		
		
		override public function onUpdate():void {
			var scrollRect:Rectangle = Laya.stage.scrollRect ? Laya.stage.scrollRect : new Rectangle();
			
				if (thisSp.x > (scrollRect.x + scrollRect.width) || 
					thisSp.y > (scrollRect.y + scrollRect.height) || 
					thisSp.x < scrollRect.x ||
					thisSp.y < scrollRect.y) {
					thisSp.removeSelf();
					Pool.recover("enemyBullet", thisSp);			
				}	
		}
		
		
		
		override public function onDisable():void {
		}
	}
}