package ;

import assets.Assets; 
import deep.macro.AssetsMacros;
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
		//AssetsMacros.setFontsRange("A-Z");
		Lib.current.addChild(new Bitmap(Assets.haxe));
		trace(Assets.flash);
		
		var f = Assets.arial;
		trace([f.fontName, f.fontStyle]);
		
		trace(Assets.text);
		
		var s = Assets.snd1;
		//s.play();
	}
	
}