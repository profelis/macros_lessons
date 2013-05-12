#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.File;
#end

class Main {
	
	#if !macro
	static function main() {
		trace(test(Date.fromString("2013-01-01")));
		var date = getBuildDate6();
		trace(date);
		trace(Type.typeof(date));
		
		trace(getFileContent("foo.txt"));
	}
	#end
	
	@:macro static function test(e:Expr) {
		trace(e);
		return e;
	}
	
	@:macro static public function getBuildDate():Expr {
		var d = Date.now();
		return Context.makeExpr(d.toString(), Context.currentPos());
	}
	
	@:macro static public function getBuildDate2():Expr {
		var d = Date.now();
		return Context.parse("Date.fromString('" + d.toString() + "')", Context.currentPos());
	}
	
	@:macro static public function getBuildDate3():Expr {
		var d = Date.now();
		var p = Context.currentPos();
		return { expr:ECall(
					{expr:EField(
						{expr:EConst(CIdent("Date")), pos:p },
						"fromString"),
					pos:p }, 
					[ { expr:EConst(CString(d.toString())), pos:p } ]),
				pos:p };
	}
	
	@:macro static public function getBuildDate4():Expr {
		var d = Date.now();
		var e = Context.makeExpr(d.toString(), Context.currentPos());
		return macro Date.fromString($e);
	}
	
	// в Haxe 2 $() аналогично Context.makeExpr
	@:macro static public function getBuildDate5():Expr {
		return macro Date.fromString($(Date.now().toString()));
	}
	
	// еще один простой пример
	@:macro static public function getBuildDate6():Expr {
		return macro Date.fromTime($(Date.now().getTime()));
	}
	
	@:macro static public function getFileContent(path:String) {
		return macro $(File.getContent(path));
	}
}