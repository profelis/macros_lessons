package ;

import assets.Assets; 
import flash.display.Bitmap;
import flash.Lib;

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

class Main 
{
	
	static function main() 
	{
		
		
		var s = new assets.Sound_1();
		s.play();
		
		var i = new assets.Bitmap_flash(0, 0);
		Lib.current.addChild(new Bitmap(i));
		
		trace(Assets.bitmap_haxe);
	}
	
}