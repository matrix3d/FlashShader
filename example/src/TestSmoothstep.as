package  
{
    import flash.display.Sprite;
    /**
     * ...
     * @author lizhi
     */
    public class TestSmoothstep extends Sprite
    {
        
        public function TestSmoothstep() 
        {
            var step:Number = .01;
            
            graphics.lineStyle(0,0xff);
            for (var x:Number = 0; x < 1;x+=step ) {
                var y:Number = 1-smoothstep(0,1,x);
                if (x==0) {
                    graphics.moveTo(x * 400, y * 400);
                }else {
                    graphics.lineTo(x * 400, y * 400);
                }
            }
            
            graphics.lineStyle(0, 0xff00);
            for (x = 0; x < 1;x+=step ) {
                y =1- smoothstep2(0,1,x);
                if (x==0) {
                    graphics.moveTo(x * 400, y * 400);
                }else {
                    graphics.lineTo(x * 400, y * 400);
                }
            }
            
            graphics.lineStyle(0, 0xff0000);
            for (x = 0; x < 1;x+=step ) {
                y = Math.cos(Math.PI*x)*.5+.5;
                if (x==0) {
                    graphics.moveTo(x * 400, y * 400);
                }else {
                    graphics.lineTo(x * 400, y * 400);
                }
            }
        }
        
        //http://en.wikipedia.org/wiki/Smoothstep
        private function smoothstep(edge0:Number, edge1:Number, x:Number):Number
        {
            // Scale, bias and saturate x to 0..1 range
            x = Math.min(Math.max((x - edge0)/(edge1 - edge0), 0.0), 1.0); 
            // Evaluate polynomial
            return x*x*(3 - 2*x);
        }
        
        private function smoothstep2(edge0:Number, edge1:Number, x:Number):Number
        {
            // Scale, bias and saturate x to 0..1 range
            x = Math.min(Math.max((x - edge0)/(edge1 - edge0), 0.0), 1.0); 
            // Evaluate polynomial
            return x*x*x*(x*(x*6 - 15) + 10);
        }
        
    }

}