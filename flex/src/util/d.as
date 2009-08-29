/*Copyright (c) 2009 Damien MIRAS

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.*/
package util
{
	
	//par défaut la classe Debug envoie ses traces dans la console d'éclipse
	//cette classe peut envoyer ses traces à plusieures consoles 
	//pour l'instant on a une console graphique 
	//il serait possible d'ajouter une console http
	//et un dump vers un fichier
	public class d
	{
		private static 	var s_instance 		:d 				= new d();
		private 		var m_sendToView	:Boolean 		= true;
		private 		var m_viewDebug		:AioViewDebug 	= null;
		private 		var m_debugAbstract	:DebugAbstract 	= null;
	
		
		public function d()
		{
			if(s_instance != null)
			{
				var error:String = 	 "\r\n On ne peut pas créer un Debug de cette manière il faut " + 
									 "\r\n rappeller Debug.getInstance() \r\n";
				trace(error);
				throw new Error(error);
			}
			m_debugAbstract = new DebugAbstract();
			m_viewDebug 	= new AioViewDebug();
		}
		
		public function getViewDebug():AioViewDebug
		{
			return m_viewDebug;
		}
		public static function bug():d
		{
			return s_instance;
		}
		public function showDebugConsole(show:Boolean):void
		{
			m_viewDebug.showDebugConsole(show);
		}
		public  function sendToView(parent:Object):void
		{
			m_sendToView = true;
			m_viewDebug.setParent(parent);			
		}
		public function setPrefix(prefix :String):void 
		{			
			m_debugAbstract.setPrefix(prefix);			
			m_viewDebug.setPrefix(prefix);
		}
		
		/**
		 * shut down all traces
		 * */
		public function setLevelSilent (setItTo:Boolean):void
		{
		
			m_viewDebug.setLevelSilent(setItTo);			
			m_debugAbstract.(setItTo);
		}
		
		public function setBug (setItTo:Boolean):void
		{
			m_viewDebug.setBug(setItTo);			
			m_debugAbstract.setBug(setItTo);
		}
		
		/**
		* disable the trace  for  a particular className 
		*/		
		public function disableClassTrace(className:String):void
		{
			disableClassTrace(className);
		}
		
		/**
		 * enable the class name in the trace back, after it has been disable
		 **/
		public function enableClassTrace(className:String):void
		{
			enableClassTrace(className);
		}
		
		public function setLevelError (setItTo:Boolean):void
		{
			
			m_viewDebug.setLevelError(setItTo);			
			m_debugAbstract.setLevelError(setItTo);
		}
		
		public function setLevelTrace (setItTo:Boolean):void
		{
			
			m_viewDebug.setLevelTrace(setItTo);
			m_debugAbstract.setLevelTrace(setItTo);
		}		

		public function setLevelVerbose (setItTo:Boolean):void
		{
		
			m_viewDebug.setLevelVerbose(setItTo);		
			m_debugAbstract.setLevelVerbose(setItTo);
		}	
			
		public  function setLevel(level:Number ):void 
		{		
			m_viewDebug.setLevel(level);
			m_debugAbstract.setLevel(level);
		}
		
		private function isEnable():Boolean
		{
			//fixme : verifier doit retourner true si les deux sont true
			return  m_sendToView && m_viewDebug.isVisible();
		}
		public function _bug (str:String):void
		{
			if(isEnable() == true)
			{
				m_viewDebug._bug(str);
			}
			m_debugAbstract._bug(str);
		} 
		public function _warning(str:String):void
		{
			if(isEnable() == true)
			{
				m_viewDebug._warning(str);
			}
			m_debugAbstract._warning(str);	
		}
		public function _trace (str:String):void 
		{
			if(isEnable() == true)
			{
				m_viewDebug._trace(str);
			}
			m_debugAbstract._trace(str);
		}
		public function _verbose (str:String = ""):void 
		{
			if(isEnable() == true)
			{
				m_viewDebug._verbose(str);
			}
			m_debugAbstract._verbose(str);	
		}
		public function br(numberOflignes: Number = 1):void 
		{
			if(isEnable() == true)
			{
				m_viewDebug.br(numberOflignes);
			}
			m_debugAbstract.br(numberOflignes);
		}
		public function ligne():void
		{
			if(isEnable() == true)
			{
				m_viewDebug.ligne();
			}
			m_debugAbstract.ligne();
		}
	}
}
