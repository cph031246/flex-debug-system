package util
{
	import flash.system.Capabilities;
	
	import mx.messaging.channels.StreamingAMFChannel;

	// http://blog.another-d-mention.ro/programming/how-to-identify-at-runtime-if-swf-is-in-debug-or-release-mode-build/
	// http://www.jonnyreeves.co.uk/2008/10/the-state-of-logging-in-actionscript-3/
	public class AioDebugUtil
	{
		//verify if you have build a debug version or not
		public static function isDebugBuild() : Boolean
		{
			// Crée un objet Error, et vérifie si la stacktrace correspond
			// à une stacktrace du mode debug (c-à-d pas en "release build")
			//une chaine qui fini par deux point et le nombre (il s'agit du numéro de ligne)
			return new Error().getStackTrace().search(/:[0-9]+]$/m) > -1;
		}

		public function isDebugPlayer() : Boolean
		{
			return Capabilities.isDebugger;
		}

//		public static function msg(msg : *) : void
//		{
//			if (Debug.isDebugBuild())
//			{
//				var callerMethod : String = "";
//
//				try
//				{
//					callerMethod = Debug.getCallerMethod(2);
//					trace(callerMethod + ": " + msg);
//				}
//				catch (e : Error)
//				{
//					// trace("Warning: cannot retrieve caller method name");
//					trace(msg);
//				}
//			}
//		}

		public static function getSimpleCallerMethod(depth : int = 1) :String
		{
			return getCallerFromStackTrace(depth).split("/")[1];
		}
		public static function getCallerMethod(depth : int = 1) : String
		{
			return getCallerFromStackTrace(depth);
		}

		public static function getCallerClass(depth : int = 1) : String
		{
			return getCategoryNameFor(getCallerFromStackTrace(depth).split("/")[0]);
		}
		
		//http://www.jonnyreeves.co.uk/2008/10/the-state-of-logging-in-actionscript-3/
		private static function getCallerFromStackTrace(depth : int = 1) : String
        {
			Assert.isTrue(depth > 0);

		    var callerMethod : String = "";
		    //déclenche une fausse erreur pour obtenir la trace de la pile
			var stackTrace : String = new Error().getStackTrace();

			// Extract the last method from the StackTrack
			if (stackTrace != null)
			{
				var parts : Array = new Array();
				stackTrace.split("\n").join("");
				parts = stackTrace.split("\tat ");

				if (parts[depth + 2] != null)
				{
					// Handle Both Class Init and internal method cases
					if (parts[3].indexOf("$cinit") != -1)
					{
						callerMethod = parts[depth + 2].split("$cinit")[0] + "$cinit";
					}
					else
					{
						callerMethod = parts[depth + 2].split("[")[0];
					}
				}
			}
			return callerMethod;
		}

		/**
		 * return the namespace  and the class'name 
		 **/
		private static function getCategoryNameFor(qualifiedClassName : String) : String
        {
		        return qualifiedClassName.indexOf("::") > -1 ? qualifiedClassName.split("::").join(".") : qualifiedClassName;
		}
	}
}
