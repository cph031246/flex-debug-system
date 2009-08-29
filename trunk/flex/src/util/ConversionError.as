package util
{
	public class ConversionError extends Error
	{
		private var m_message : String;
		private var m_property : String;

		public function ConversionError(message:String="", id:int=0)
		{
			super("", id);
			m_message = message;
			regenerateMessage();
		}

		public function set property(text : String) : void
		{
			m_property = property;
			regenerateMessage();
		}

		public function get property() : String
		{
			return m_property;
		}

		private function regenerateMessage() : void
		{
			if (m_property == "")
			{
				message = 'Conversion failed: ' + m_message;
			}
			else
			{
				message = 'Conversion failed for property ' + m_property + ': ' + m_message;
			}
		}
	}
}
