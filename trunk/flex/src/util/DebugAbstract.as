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
	import mx.collections.ArrayCollection;
	/**
	 * Subclass this class to implement a new debug system 
	 * for exemple to dump the trace to a file
	 * You can subclass to send it to a socket or over HTTP
	 * 
	 * */
	public class DebugAbstract
	{
		
				//classé par ordre d'importance
		protected var m_bug			:Boolean 	= true;	//display bugs wich can cause crashes or instability
		protected var m_warning		:Boolean	= true; //display error wich don't cause crashes		
		protected var m_trace		:Boolean	= true; //standard trace, you may to display to see variable content		
		protected var m_verbose		:Boolean 	= false;//display trace you normaly won't to see poluate the trace
		

		
		protected 	var m_silent		:Boolean	= false;//n'affiche plus rien 
		protected 	var m_level			:Number		= 3; 	//niveau par défaut
		protected 	var regex			:RegExp;
		protected 	var m_prefix		:String		= "";//nom de l'application
		protected 	var m_br			:String 	= "\n"; //saut de ligne
		protected 	var m_ligne			:String 	= "__________________________________________________________";
		protected 	var m_bugPrefix		:String		= "/!\\" ;
		protected 	var m_warnPrefix	:String 	= "warn"
		protected	var m_classArrayCollection:ArrayCollection = new ArrayCollection(); //exclu une classe de la trace
		
		public function DebugAbstract()
		{
			
		}
		
		/**
		 *  You need to override a least this one
		 * */
		protected function whrite(str:String, bWhritePath:Boolean = true):void 
		{
			//if (Debug.isDebugBuild())
			{
				if(m_silent == false)
				{
				
					var className:String = AioDebugUtil.getCallerClass(4);
					var methodName:String = AioDebugUtil.getSimpleCallerMethod(4);
					var packageName:String = "";					
					packageName = className.split(".")[0];
					className =  className.split(".")[1];
					if(m_classArrayCollection.contains(className) == false)
					{
						if(m_prefix.length > 0)
						{
							m_prefix = m_prefix + " : ";
						}
						if(bWhritePath == true)
						{						
							trace(m_prefix+ packageName +className+"."+ methodName +"()" + m_br + m_prefix+ "\t" + str + m_br);
						}
						else
						{
							trace(str);	
						}
					}
				}
			}			
		}
		
		/**
		 * replace all \r\n by \n and all \n by \<br>
		 * need to be simplified by a cool regex
		 **/		
		protected function preformatString(str:String):String
		{	
			regex = /\r\n/g; 
			str = str.replace(regex,"\r");
			regex = /\n\r/g; 
			str = str.replace(regex,"\r");
			regex = /\n/g; 
			str = str.replace(regex,"\r");				
			regex = /\r/g; 
			str = str.replace(regex,"\r\t");
			regex = /<br>/g; 
			str = str.replace(regex,"\r\t");
			regex = /<p>/g; 
			str = str.replace(regex,"\r\n\t\t");
			regex = /<li>/g; 
			str = str.replace(regex,"\r\t*");
			regex = /<h>/g; 
			str = str.replace(regex,"\n"+m_ligne);
			return str
		}
		
		/**
		 * method at work don't use it unless you have read the code 
		 * or patched it
		 * you can use introspection to direct call objects.
		 * work in progress it can crash and the must to be improved
		 * */
		public  function command(command:String):void
		{
			//pattern = class.method(val1,val2,val3)
			// or this.method()
			// or method()
			var className	:String = "";
			var methodeName	:String = "";
			var values   	:String = ""; //don't work yet for multiple parameters
			var valuesArray :Array = new Array();
			
			className   = command.split(".")[0];
			methodeName = command.split(".")[0];
			
			
			if(command.split("(")!=null)
			{
				methodeName = command.split("(")[0];
			}
			//dmsTodo
			if(command.split("(")!=null)
			{
				values 		= command.split("(")[1];
			}
			if(values !=null && values.split(")")!=null)
			{
				values  	= values.split(")")[0];
			}
			if(values !=null && values.split(",") !=null)
			{
				valuesArray	   = values.split(",")[1];
			}
			
			if( methodeName == "hideClass")
			{
				disableClassTrace(values);
				d.bug()._trace(values + " is Disabled");
			}
			else if ( methodeName == "showClass")
			{
				enableClassTrace(values);
				d.bug()._trace(values + " is Enabled");
			}
			
			if(command == "man" || command == "?" || command == "help" || command =="h")
			{
				d.bug()._trace( 
				" * hideClass([className]) hide  the trace for the correspondant class \r" +
				" * showClass([className]) allow hided class trace  to be redisplayed \r" +	
				" * max() maximise the debugWindow\r" +	
				" * close() close the debug \r");				
			}
				
		}
		/**
		 * set a prefix  to display in front of each trace
		 **/
		public function setPrefix(prefix :String):void 
		{
			m_prefix = prefix;
		}
		
		/**
		* disable the trace  for  a particular className 
		*/
		public function disableClassTrace(className:String):void
		{
			if(m_classArrayCollection.contains(className))
			{
				m_classArrayCollection.addItem(className);	
			}			
		}
		/**
		 * enable the class name in the trace back, after it has been disable
		 **/
		public function enableClassTrace(className:String):void
		{
			var index:int = m_classArrayCollection.getItemIndex(className);
			if(index >= 0)
			{				
				m_classArrayCollection.removeItemAt(index);
			}
		}
		/**
		 * stop to log all traces
		 **/
		public function setLevelSilent (setItTo:Boolean):void
		{
			m_silent = setItTo;
		}
		
		/**
		 * enable or disable the "bugs" trace display
		 **/
		public function setBug (setItTo:Boolean):void
		{
			m_bug = setItTo;
		}
		
		/**
		 * enable or disable the "errors" trace display
		 **/
		public function setLevelError (setItTo:Boolean):void
		{
			m_warning = setItTo;
		}
		
		/**
		 * enable or disable the "traces" trace display
		 **/
		public function setLevelTrace (setItTo:Boolean):void
		{
			m_trace = setItTo;
		}
			
		/**
		 * enable or disable the "verboses" trace display
		 **/
		public function setLevelVerbose (setItTo:Boolean):void
		{
			m_verbose = setItTo;
		}	
		
		
		/**
		 * give a quick way to display traces
		 * level 0 shut down the traces
		 * level 1 just display the bugs
		 * level 2 just display the bugs, and the errors
		 * level 3 just display the bugs, errors and traces
		 * level 4 just display the bugs, errors, traces and verboses
		 **/
		public  function setLevel(level:Number ):void 
		{
			m_level = level;
			if ( m_level == 0)
			{
				m_bug		= false;
				m_warning 	= false;
				m_trace 	= false;
				m_verbose 	= false;
				m_silent	= true;
			}
			else if ( m_level == 1)
			{
				m_bug		= true;
				m_warning 	= false;
				m_trace 	= false;
				m_verbose 	= false;
				m_silent	= false;
			}
			else if ( m_level == 2 )
			{
				m_bug		= true;
				m_warning 	= true;
				m_trace 	= false;
				m_verbose 	= false;
				m_silent	= false;
			}
			else if ( m_level == 3 )
			{
				m_bug		= true;
				m_warning 	= true;
				m_trace 	= true;
				m_verbose 	= false;
				m_silent	= false;
			}
			else if ( m_level >= 4)
			{				
				m_bug		= true;
				m_warning 	= true;
				m_trace 	= true;
				m_verbose 	= true;
				m_silent	= false;
			}
		}
		
		/**
		 * mark a trace as a bug, the second parameter allow to display in wich object the trace occur
		 * */
		public function _bug (str:String):void
		{
			if(m_bug)
			{
				str = preformatString(str)
				regex = /\r/g; 		
				whrite( str.replace(regex,"\r\t/!\\"));
			}		
		}
		
		/**
		 * mark a trace as a warning, the second parameter allow to display in wich object the trace occur
		 * */
		public function _warning(str:String):void
		{
			if(m_warning)
			{
				str = preformatString(str)
				regex = /\r/g;
				whrite(str.replace(regex,"\r\t:( "));
			}			
		}
		
		/**
		 * mark a trace as a trace, the second parameter allow to display in wich object the trace occur
		 * */
		public function _trace (str:String):void 
		{
			if(m_trace)
			{
				whrite(preformatString(str));
			}
		}
		
		/**
		 * mark a trace as a verbose, the second parameter allow to display in wich object the trace occur
		 * */
		public function _verbose (str:String):void 
		{
			if(m_verbose)
			{
				whrite(preformatString(str)+m_br);				
			}				
		}
		
		/**
		 * add an return or new line
		 * */
		public function br(numberOflignes: Number = 1):void 
		{
			for(var i:Number;i< numberOflignes; i++)
			{
				whrite(m_br,false);
			}
		}
		
		/**
		* add a separation ligne
		* */	
		public function ligne():void
		{
			whrite(m_ligne,false);
		}
	}
}