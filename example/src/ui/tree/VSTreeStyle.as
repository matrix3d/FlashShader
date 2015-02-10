package ui.tree 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author lizhi
	 */
	public class VSTreeStyle extends TreeStyle
	{
		 private var pen:GradientLinesPen = new GradientLinesPen(null, [0x999999, 0], [1, 0], [1.5, 1.5], 0);
		
		public function VSTreeStyle() 
		{
		}
		
		override public function renderCell(tree:TreeNode, x:Number, y:Number):Number {
			pen.g = ui.treeUI.graphics;
			
			 var sy:Number = y;
			var tui:TreeNodeUI=createTreeNodeUI(tree, x, y,ui)
            ui.treeUI.addChild(tui);
            y += 20;
            if (!tree.closed) {
                var vx:Number = x + 28;
                var vy:Number = y;
                for each(var child:TreeNode in tree.children) {
                    pen.moveTo(vx, y+8);
                    pen.lineTo(vx+12, y + 8);
                    vy = y;
                    y = renderCell(child, x + 20, y);
                }
				
				if(tree.children.length){
					pen.moveTo(vx, sy+20);
					pen.lineTo(vx, vy + 8);
				}
            }
			tui.update();
            return y;
		}
		
	}

}


import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.display.CapsStyle;
    import flash.display.GradientType;
    import flash.display.Graphics;
    import flash.display.SpreadMethod;
    import flash.geom.Matrix;
	import flash.text.TextFormat;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;



class GradientLinesPen
    {
        public var g:Graphics;
        private var colors:Array;
        private var alphas:Array;
        private var ratios:Array;
        private var m:Matrix = new Matrix();
        private var thickness:Number;
        private var sx:Number;
        private var sy:Number;
        private var w:Number;
        public function GradientLinesPen(g:Graphics,colors:Array,alphas:Array,widths:Array,thickness:Number) 
        {
            this.g = g;
            setGradientLines(colors, alphas, widths, thickness);
        }
        public function setGradientLines(colors:Array,alphas:Array,widths:Array,thickness:Number):void {
            for (var i:int = colors.length-2; i > 0;i-- ) {
                colors.splice(i, 0, colors[i]);
            }
            this.colors = colors;
            for (i = alphas.length-2; i > 0;i-- ) {
                alphas.splice(i, 0, alphas[i]);
            }
            this.alphas = alphas;
            w = 0;
            for each(var value:Number in widths) {
                w += value;
            }
            ratios = [];
            var cw:Number = 0;
            for (i = 0; i < widths.length - 1; i++ ) {
                cw += 0xff * widths[i] / w;
                ratios.push(cw);
                ratios.push(cw);
            }
            this.thickness = thickness;
        }
        public function moveTo(x:Number, y:Number):void {
            g.moveTo(x, y);
            sx = x;
            sy = y;
        }
        public function lineTo(x:Number, y:Number):void {
            var dx:Number = x - sx;
            var dy:Number = y - sy;
            var a:Number = Math.atan2(dy, dx);
            var m:Matrix = new Matrix();
            m.createGradientBox(w, w, a);
            g.lineStyle(thickness, 0, 0, false, null, CapsStyle.SQUARE);
            g.lineGradientStyle(GradientType.LINEAR, colors, alphas, ratios, m, SpreadMethod.REPEAT);
            g.lineTo(x, y);
            sx = x;
            sy = y;
        }
    }