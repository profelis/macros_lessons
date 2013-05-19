package deep.macro;

import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

#if macro

enum AssetType {
	AImage;
	ASound;
	AFont;
}

#end

class AssetsMacros {
	
	#if macro
	static var IMAGES = ["jpg", "jpeg", "gif", "png"];
	static var SOUNDS = ["mp3", "wav"];
	static var FONTS = ["ttf"];
	
	// Название мета тега
	inline static function getMetaName(type:AssetType) {
		return switch (type) {
			case AImage: ":bitmap";
			case ASound: ":sound";
			case AFont: ":font";
		}
	}
	
	// комплексный тип
	inline static function getComplexType(type:AssetType):ComplexType {
		return switch (type) {
			case AImage: macro : flash.display.BitmapData;
			case ASound: macro : flash.media.Sound;
			case AFont: macro : flash.text.Font;
		}
	}
	
	// Базовый тип
	inline static function getKind(type:ComplexType):TypeDefKind {
		return switch (type) {
			case TPath(p): TDClass(p);
			default:
				Context.error("can't find asset type", Context.currentPos());
				null;
		}
	}
	
	inline static function getClassPrefix(type:AssetType) {
		return switch (type) {
			case AImage: "Bitmap_";
			case ASound: "Sound_";
			case AFont: "Font_";
		}
	}
	
	inline static function getVarPrefix(type:AssetType) {
		return switch (type) {
			case AImage: "bmp";
			case ASound: "snd";
			case AFont: "fnt";
		}
	}
	
	inline static function getArgs(type:AssetType):Array<Expr> {
		return switch (type) {
			case AImage: [macro 0, macro 0];
			case ASound, AFont: [];
		}
	}
	
	static var idEreg = ~/[A-Z_][A-Z0-9_]*/i;
	static var idCharEreg = ~/[A-Z0-9_]/i;
	
	inline static function varName(type:AssetType, name:String) {
		if (idEreg.match(name)) return name;
		else {
			var res = "";
			for (i in 0...name.length) {
				var ch = name.charAt(i);
				if (idCharEreg.match(ch)) res += ch;
			}
			return getVarPrefix(type) + res;
		}
	}
	#end
	
	macro static public function embed(path:String):Array<Field> {
		
		path = Context.resolvePath(path);
		
		var display = Context.defined("display");
		
		var pos = Context.currentPos();
		var res = Context.getBuildFields();
		
		for (f in FileSystem.readDirectory(path)) {
			var file = path + "/" + f;
			if (FileSystem.isDirectory(file)) continue;
			
			var p = new Path(file);
			var ext = p.ext.toLowerCase();
			var type = if (Lambda.has(IMAGES, ext)) AImage;
				else if (Lambda.has(SOUNDS, ext)) ASound;
				else if (Lambda.has(FONTS, ext)) AFont;
			
			if (type == null) continue; // фаил неизвестного типа
			
			var ct = getComplexType(type);
			
			var data = display ? null : File.getContent(file);
			var filePos = Context.makePosition( { min:0, max:0, file:file } );
			var className = getClassPrefix(type) + p.file;
			var metaParams = [ { expr :EConst(CString("data:" + data)), pos :filePos } ];
			if (type == AFont) metaParams.push( { expr :EConst(CString("32-128")), pos :filePos } );
			
			var clazz:TypeDefinition  = {
				pos : filePos,
				fields : [],
				params : [],
				pack : ["assets"],
				name : className,
				meta : [ { name : getMetaName(type), params : metaParams, pos : filePos } ],
				isExtern : false,
				kind : getKind(ct),
			};
			
			Context.defineType(clazz);
			
			res.push( {
				name : varName(type, p.file),
				access : [APublic, AStatic],
				//doc : null,
				kind : FVar(ct, { expr : ENew( { pack : ["assets"], name : className, params : [] }, getArgs(type)), pos : pos } ),
				//meta : [],
				pos : pos,
			});
		}
		return res;
	}
}