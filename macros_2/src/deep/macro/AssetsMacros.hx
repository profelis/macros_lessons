package deep.macro;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;

#if macro

enum AssetType {
	AImage;
	ASound;
}

#end

class AssetsMacros {
	
	#if macro
	static var IMAGES = ["jpg", "jpeg", "gif", "png"];
	static var SOUNDS = ["mp3", "wav"];
	
	// Название мета тега
	static function getMetaName(type:AssetType) {
		return switch (type) {
			case AImage: ":bitmap";
			case ASound: ":sound";
		}
	}
	
	// Базовый тип
	static function getKind(type:AssetType) {
		return switch (type) {
			case AImage: TDClass( { pack : ["flash", "display"], name : "BitmapData", params :[] } );
			case ASound: TDClass( { pack : ["flash", "media"], name : "Sound", params :[] } );
		}
	}
	
	// префикс класса
	static function getPrefix(type:AssetType) {
		return switch (type) {
			case AImage: "Bitmap_";
			case ASound: "Sound_";
		}
	}
	
	static function getArgs(type:AssetType):Array<Expr> {
		return switch (type) {
			case AImage: [macro 0, macro 0];
			case ASound: [];
		}
	}
	#end
	
	macro static public function embed(path:String):Array<Field> {
		
		path = Context.resolvePath(path);
		
		var pos = Context.currentPos();
		var res = Context.getBuildFields();
		
		for (f in FileSystem.readDirectory(path)) {
			var file = path + "/" + f;
			if (FileSystem.isDirectory(file)) continue;
			
			var ext = f.substring(f.lastIndexOf(".") + 1).toLowerCase();
			var type = if (Lambda.has(IMAGES, ext)) AImage;
				else if (Lambda.has(SOUNDS, ext)) ASound; else null;
			
			if (type == null) continue; // фаил неизвестного типа
			
			var name = f.substring(0, f.lastIndexOf("."));
			
			var data = File.getContent(file);
			var filePos = Context.makePosition( { min:0, max:0, file:file } );
			var clazz:TypeDefinition  = {
				pos : filePos,
				fields : [],
				params : [],
				pack : ["assets"],
				name : getPrefix(type) + name,
				meta : [ { name : getMetaName(type), params : [ { expr :EConst(CString("data:" + data)), pos :filePos } ], pos : filePos } ],
				isExtern : false,
				kind : getKind(type),
			};
			
			Context.defineType(clazz);
			
			res.push( {
				name : getPrefix(type).toLowerCase() + name,
				access : [APublic, AStatic],
				doc : null,
				kind : FVar(null, { expr : ENew( { pack : ["assets"], name : getPrefix(type) + name, params : [] }, getArgs(type)), pos : pos } ),
				meta : [],
				pos : pos,
			});
		}
		return res;
	}
}