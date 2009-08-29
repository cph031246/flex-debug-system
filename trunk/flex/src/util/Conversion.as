package util
{
	import util.ConversionError;

	public class Conversion
	{
		public static function safeParseInt(src : String) : Number
		{
			var result : Number = parseInt(src);

			if (isNaN(result))
			{
				throw new ConversionError("from " + src + " to Number");
			}

			return result;
		}
	}
}
