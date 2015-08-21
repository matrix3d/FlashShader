package gl3d.parser.mmd 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author lizhi
	 */
	dynamic public class VMDReader extends ReaderBase
	{
		
		public function VMDReader(buffer:ByteArray) 
		{
			super(buffer);
			var b:String = this.readCString( 30 );
	
			this.name = this.readCString( 20 );
		}
		
	}

}