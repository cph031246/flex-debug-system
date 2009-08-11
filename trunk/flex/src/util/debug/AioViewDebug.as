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
package util.debug
{
	//Damien MIRAS
	import _view.AioViewControlPanel;
	
	import flash.events.Event;
	import flash.utils.getQualifiedClassName;
	
	import mx.containers.ApplicationControlBar;
	import mx.controls.TextArea;
	import mx.events.FlexEvent;

	public  class AioViewDebug extends DebugAbstract
	{
		private var m_canvas			:AioViewControlPanel 	= null;
		private var m_textArea			:TextArea 				= null;
		private var m_margin			:Number					= 20;
		private var m_strBuffer			:String 				= "";
		private var m_panelCompleted	:Boolean 				= false;
		private var m_comment			:String					= "";
		private var m_bugColor			:String					= "DC4182";
		private var m_warningColor		:String					= "82A309";
			
		public function AioViewDebug()
		{
			//the char \r\n are replaced by the html equivalent
			m_br = "<br>";			
				
		}
		
		//fixme this is never called because the FlexEvent.CREATION_COMPLETE is never dispatched
		//or dispatched in a early stage 
		//to hack this I have set m_panelCompleted to true
		//but be carrefull because the panel can be not complete at all
		//it's a potential bug , but no time left to fix it
		private function onPanelComplete(e:Event):void
		{
			m_canvas.width = 400;
			m_canvas.height = 400;
			m_textArea.width = m_canvas.width - m_margin;
			m_textArea.height = m_canvas.height - m_margin;
			m_panelCompleted  = true;

		}
		
		//the margin betwin the pannel and the canvas (I have replaced canvas by appliclationControlBar 
		//for test purpose but feel free to replace that by a canvas it's more clean)
		//normaly you can set this margin with a CSS, wich is more conventional
		public function setMargin(margin:Number):void
		{
			m_margin = margin;
		}
		
		public function setBugColor(strColor:String):void 
		{
			m_bugColor = strColor;	
		}
		
		public function setWarningColor(strColor:String):void 
		{
			m_warningColor = strColor;	
		}
		
		
		/**
		 * change parent of the canvas
		 **/
		public function setParent(parent:Object):void
		{
			
			if(m_canvas == null)
			{
				m_canvas = new AioViewControlPanel ();			
				m_canvas.addEventListener(FlexEvent.CREATION_COMPLETE, onPanelComplete);			
				parent.addChild(m_canvas);
				m_textArea = new TextArea();			
				m_textArea.editable = false;			
				m_canvas.addChild(m_textArea);
				
			}
			else
			{
				m_canvas.parent.removeChild(m_canvas);
				parent.addChild(m_canvas);
			}
			
			
			//FIxme it can bug because I'm not sure the canvas will be always
			//completed just in time
			m_panelCompleted  = true; 
			
		}
		
		protected override  function whrite(str:String, object:*=null):void
		{
			if(m_silent == false)
			{
				if(m_panelCompleted && m_canvas != null && m_canvas.parent !=null && m_textArea !=null)
				{
					
					if(object != null)
					{
						//to get the name of the class where the trace occure
						var className:String = flash.utils.getQualifiedClassName(object);
					}
					str = "<b>" + m_prefix + " : " +className+"()</b> " +m_comment + m_br  + str;
					
					//in certain cases the uicomponent is not yet completed
					//so whe provide a string buffer to store the traces before it has been completed
					if(m_strBuffer.length > 0)
					{
						m_textArea.htmlText =  m_textArea.htmlText + m_strBuffer + str;
						m_textArea.validateNow();
						m_textArea.verticalScrollPosition =  m_textArea.textHeight;
						m_strBuffer = "";
					}
					else
					{
						m_textArea.htmlText = m_textArea.htmlText + str;
						m_textArea.validateNow();
						m_textArea.verticalScrollPosition =  m_textArea.textHeight;	
					}
					//to avoid the memory leak or string inflation
					//a big string is such thinks wich can make lag the application
					if(m_strBuffer.length > 1024)
					{
						m_strBuffer = "previous traces have been removed !";
					}
					
				}
				else
				{
					m_strBuffer = m_strBuffer + str;
				}
			}
		}
		
		/**
		 * Overrided this function to change the way wich tab return and new lines are displayed
		 * youc can use <p> and * for list
		 * */
		protected override function preformatString(str:String):String
		{
			
				//remplaces all \n by \r 
				regex = /\n/g; 
				str = str.replace(regex,"\r");
				
				//replaces all <p> by tab because they dont work fine
				regex = /<p>/g; 
				str = str.replace(regex,"\r\t\t\t\t"); 
				
				//replaces all stars by list
				regex = /\*(.*?)\r/g;				
				str = str.replace(regex,"<li>$1</li>");				
				
				regex = /<li>*(.*)<\/li>/g;
				str = str.replace(regex,"<ul><li>$1</li></ul>");
				
				//removes spaces between li beacause it cause bad display
				regex = /<\/li> /g;
				str = str.replace(regex,"</li>");				
				return str
		}
		
		
		public override function _bug (str:String,object:*=null):void
		{
			if(m_bug)
			{
				str = preformatString(str)
				regex = /\r/g; 			
				str = str.replace(regex,"<br>\t\t");
				//TODO replace thtat by a regex
				//and replace color by a member
				m_comment = "<font color=\"#"+m_bugColor+"\">BUG /!\\ </font>"
				whrite( "<font color=\"#"+m_bugColor+"\">" + str + "</font>",object);
				m_comment = "";
			}		
		} 
		
		public override function _warning(str:String,object:*=null):void
		{
			if(m_warning)
			{
				str = preformatString(str);
				regex = /\r/g;
				m_comment = "<font color=\"#"+m_warningColor+"\">WARNING !</font>"
				whrite( "<font color=\"#"+m_warningColor+"\">" + str + "</font>",object);
				m_comment = "";
			}			
		}
		
		public override function _trace (str:String,object:*=null):void 
		{
			if(m_trace)
			{
				whrite(preformatString(str),object);
			}
		}
		
		public override function br(numberOflignes: Number = 1):void 
		{
			for(var i:Number;i< numberOflignes; i++)
			{
				m_textArea.htmlText =  m_textArea.htmlText + m_br;
			}
		}		
	}
	
}