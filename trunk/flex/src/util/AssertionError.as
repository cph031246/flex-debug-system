package util
{
	public class AssertionError extends Error
	{
		public function AssertionError(message:String="", id:int=0)
		{
			super('Assertion failed: ' + message, id);
		}
		
	}
}