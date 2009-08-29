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

// http://blog.another-d-mention.ro/programming/how-to-identify-at-runtime-if-swf-is-in-debug-or-release-mode-build/
// http://www.jonnyreeves.co.uk/2008/10/the-state-of-logging-in-actionscript-3/
	
package util
{
	import _view.AioViewPanelPlus;
	
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.containers.HBox;
	import mx.controls.Button;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.core.Application;
	import mx.core.ScrollPolicy;
	import mx.events.FlexEvent;

	public  class AioViewDebug extends DebugAbstract
	{
		private var m_viewPanel			:AioViewPanelPlus	 	= null;
		private var m_textArea			:TextArea 				= null;
		private var m_margin			:Number					= 10;
		private var m_strBuffer			:String 				= "<br>";
		private var m_comment			:String					= "";
		private var m_bugColor			:String					= "FF0000";
		private var m_warningColor		:String					= "00FF00";
		private var m_classColor		:String					= "C10076";
		private var m_methodColor		:String					= "A2FB04";
		private var m_bTextAreaCreated	:Boolean				= false;
		private var m_bPanelCreated 	:Boolean				= false;
		private var m_bMusBeDeleted 	:Boolean				= true;
		
		private var m_buttonErase		:Button					= null;
	
		private var m_textInputCommand 	:TextInput			= null;
		private var m_buttonSend		:Button				= null;
		
		
		public function AioViewDebug()
		{
			//the char \r\n are replaced by the html equivalent
			m_br = "<br>";			
				
		}
		
		/**
		 * change parent of the canvas
		 **/
		public function setParent(parent:Object):void
		{			
			if(m_viewPanel == null)
			{
				m_textArea = new TextArea();			
				m_textArea.editable = false;
				
				m_textInputCommand = new TextInput();
				m_textInputCommand.addEventListener(MouseEvent.CLICK,OnTextInputMouseClick);
				m_textInputCommand.text = "className";
				m_textInputCommand.percentWidth = 100;
						
				
				m_buttonSend = new Button();
				m_buttonSend.addEventListener(FlexEvent.BUTTON_DOWN, onButtonSendClicked);
				m_buttonSend.label = "send";
				
				
				m_buttonErase = new Button();
				m_buttonErase.addEventListener(FlexEvent.BUTTON_DOWN, onButtonEraseClicked);
				m_buttonErase.label = "effacer";
				
					
				m_viewPanel = new AioViewPanelPlus ();
				m_viewPanel.addEventListener(FlexEvent.CREATION_COMPLETE, onPanelCompleted);
				m_viewPanel.addEventListener(Event.RESIZE,onPanelResized);
				m_viewPanel.addEventListener("closeClickEvent", onPanelClosed);
				m_viewPanel.addEventListener(KeyboardEvent.KEY_DOWN,onKeyDown);
				
				m_viewPanel.horizontalScrollPolicy = ScrollPolicy.OFF
				m_viewPanel.verticalScrollPolicy = ScrollPolicy.OFF
				
				parent.addChild(m_viewPanel);	
				
				var hbox:HBox = new HBox();				
				
				hbox.addChild(m_textInputCommand);
				hbox.addChild(m_buttonSend);
				hbox.addChild(m_buttonErase);
				hbox.percentWidth = 100;
				hbox.setStyle("horizontalAlign","right");
				
				m_viewPanel.addChild(m_textArea);
				m_viewPanel.addChild(hbox)		
				m_viewPanel.setStyle("horizontalAlign","right");
				
				m_textArea.addEventListener(FlexEvent.CREATION_COMPLETE, onTextAreaCompleted);
			
				resizePanel();
			}
			else
			{
				m_viewPanel.parent.removeChild(m_viewPanel);
				parent.addChild(m_viewPanel);
			}			
			
			//FIxme it can bug because I'm not sure the canvas will be always
			//completed just in time
			//m_bPanelCreated  = true; 
			
		}
		private function onKeyDown(key:KeyboardEvent): void 
		{
			if(key.charCode == Keyboard.ENTER)
			{
				processCommand();
			}
		}
		private  function OnTextInputMouseClick(e:MouseEvent):void
		{
			if(m_bMusBeDeleted == true)
			{
				m_textInputCommand.text = "";
				m_bMusBeDeleted = false;
			}	
		}
		public function isVisible():Boolean
		{
			return m_viewPanel.visible;
		}
		private function onPanelClosed(e:Event):void
		{
			m_viewPanel.visible = false;
		}
		private function onButtonEraseClicked(e:FlexEvent):void
		{
			m_textArea.htmlText = "";
		}
		
		private function onButtonSendClicked(e:FlexEvent):void
		{
			processCommand();
		}
		private function processCommand():void 
		{
			command(m_textInputCommand.text);
			m_textInputCommand.text = "";	
		}
		

		//fixme this is never called because the FlexEvent.CREATION_COMPLETE is never dispatched
		//or dispatched in a early stage 
		//to hack this I have set m_panelCompleted to true
		//but be carrefull because the panel can be not complete at all
		//it's a potential bug , but no time left to fix it
		private function onPanelCompleted(e:Event):void
		{
			m_bPanelCreated = true;
			
			m_viewPanel.width = 400;
			m_viewPanel.height = Application.application.height - 20;
			m_viewPanel.x = Application.application.width -m_viewPanel.width;
			m_viewPanel.y = 0;
			
			flushBuffer();
			//in certain cases the uicomponent is not yet completed
			//so whe provide a string buffer to store the traces before it has been completed

			resizePanel();

		}

		private function onTextAreaCompleted(e:Event):void
		{
			m_bTextAreaCreated = true;
			flushBuffer();
			resizePanel();
		}
		private function onPanelResized(e:Event):void
		{
			resizePanel();
		}
		private function resizePanel():void
		{
			if(m_bTextAreaCreated == true && m_bPanelCreated == true)
			{
				m_textArea.x = 0;
				m_textArea.y = 0;
				m_textArea.width = m_viewPanel.width - m_margin;
				m_textArea.height = m_viewPanel.height - 60 - m_buttonErase.height;
			}
		}
		public function showDebugConsole(show:Boolean):void
		{
			m_viewPanel.visible = show;
		}
		
		protected override  function whrite(str:String, bWhritePath:Boolean = true):void
		{
			//DMStodo make an accesor for isdebugBuild if we want debug in relaease
			if( 	//Debug.isDebugBuild() 	== 	true &&	
				 	m_silent 				== 	false)
			{
				var className:String = ""; 
				className 	=	AioDebugUtil.getCallerClass(4);
				className 	=  	className.split(".")[1];
				//do the test here before poluate classe name with html
				//if some class have been excluded from trace				
				if(	m_classArrayCollection.contains(className) == false)
				{	
					if(bWhritePath == true)
					{
						var packageName:String = "";
						packageName = className.split(".")[0];
						
						var methodeName:String = "";
						//fixme number of level
						methodeName = AioDebugUtil.getSimpleCallerMethod(4);
					
						var htmlClassName:String = "";
						var htmlMethodeName:String = "";
						htmlClassName = "<font color=\"#"+m_classColor+"\">"+ className +"</font>";
						htmlMethodeName = "<font color=\"#"+m_methodColor+"\">"+methodeName+"</font>";
						if(m_prefix.length > 0)
						{
							m_prefix = m_prefix + " : ";
						}
						str = 	"<b>" + m_prefix + packageName +"::"+ htmlClassName+ "." + methodeName + "</b>"+ m_br
								+ m_comment + str;
					}
					if( isWindowInCorrectState() == true)		//if silent shut down debug traces
					{
						m_textArea.htmlText = m_textArea.htmlText + str;
						m_textArea.validateNow();
						m_textArea.verticalScrollPosition =  m_textArea.textHeight;				
					}
					else
					{
						if(m_strBuffer.length > 1024)
						{
							//to avoid the memory leak or string inflation
							//a big string is such thinks wich can make lag the application						
							m_strBuffer = "previous traces have been removed !";
						}
						m_strBuffer = m_strBuffer + str;						
					}				
				}
			}
		}
		
		private function isWindowInCorrectState():Boolean
		{
			return 		m_bPanelCreated  && 	//the panel must exist (avoid crashes)
						m_viewPanel  &&  		//the panel must exist (avoid crashes)
						m_viewPanel.parent  && 	//the panel must have a parent
						m_textArea &&			//same for textArea
						m_bTextAreaCreated ;
		}
		
		private function flushBuffer():void
		{
			if(	m_strBuffer.length 	>  0 		&& 
				m_bTextAreaCreated 	== true		&&
				m_bPanelCreated 	== true)
			{
				m_textArea.htmlText =  m_strBuffer;
				m_textArea.validateNow();
				m_textArea.verticalScrollPosition =  m_textArea.textHeight;
				m_strBuffer = "";
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
		
		
		public override function _bug (str:String):void
		{
			if(m_bug)
			{
				str = preformatString(str)
				regex = /\r/g; 			
				str = str.replace(regex,"<br>\t\t");
				//TODO replace thtat by a regex
				//and replace color by a member
//				m_comment = "<b><font color=\"#"+m_bugColor+"\">BUG /!\\ </font></b>"
				whrite( "<font color=\"#"+m_bugColor+"\"><b>" + str + "</b></font>"+m_br+m_br);
				m_comment = "";
			}		
		} 
		
		public override function _warning(str:String):void
		{
			if(m_warning)
			{
				str = preformatString(str);
				regex = /\r/g;
	//			m_comment = "<font color=\"#"+m_warningColor+"\">WARNING !</font>"
				whrite( "<font color=\"#"+m_warningColor+"\">" + str + "</font><br>"+m_br+m_br);
				m_comment = "";
			}			
		}
		public override function _verbose(str:String):void
		{
			if(m_verbose)
			{
				whrite(preformatString(str)+m_br+m_br);
			}
		} 
		
		public override function _trace (str:String):void 
		{
			if(m_trace)
			{
				whrite(preformatString(str)+m_br+m_br);
			}
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
		
		public  function setClassColor(strColor:String):void
		{
			m_classColor = strColor;
		}
		
		public  function setMethodColor(strColor:String):void
		{
			m_methodColor = strColor;
		}
		
		/**
		* add a separation ligne
		* */	
		public override function ligne():void
		{
			whrite(m_ligne,false);
		}
		
		public override function br(numberOflignes: Number = 1):void 
		{
			for(var i:Number;i< numberOflignes; i++)
			{
				whrite(m_br,false);
			}
		}
		
	}
	
}