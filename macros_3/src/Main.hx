package ;

import assets.Assets; 

/**
 * ...
 * @author deep <system.grand@gmail.com>
 */

class Main 
{
	
	static function main() 
	{
		trace(Assets.flash);
		
		var f = new PT_Sans();
		trace([f.fontName, f.fontStyle]);
		
		trace(Assets.text);
	}
	
}