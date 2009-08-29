package util
{
	import util.AssertionError;
	import util.AioDebugUtil;

	public class Assert
	{
		// Il est possible d'utiliser la valeur de retour dans un if () si vous
		// craignez encore que l'assertion puisse être fausse en mode release
		public static function isTrue(condition : Boolean, message : String = '') : Boolean
		{
			// Les assertions ne se produisent pas en "release build"
			if (AioDebugUtil.isDebugBuild() && !condition)
			{
				
				throw new AssertionError(message);
			}
			else
			{
				
				return condition;
			}
		}

		public static function notNull(value : Object, message : String = '') : Boolean
		{
			return Assert.isTrue(value != null, message);
		}

		public static function callerIs(qualifiedMethodName : String, message : String = "") : Boolean
		{
			if (AioDebugUtil.isDebugBuild())
			{
				var callerMethod : String = "";

				try
				{
					callerMethod = AioDebugUtil.getCallerMethod(3);
				}
				catch (e : Error)
				{
					//it crash in debug version only
					if (AioDebugUtil.isDebugBuild())
					{
						trace("serious bug cannot retrieve caller method name");
						return false;
					}
				}

				if (message == "")
				{
					message = "This method MUST be called from "
						+ qualifiedMethodName
						+ ", go fix your code!";
				}

				return Assert.isTrue(callerMethod == qualifiedMethodName, message);
			}

			return true;
		}

		public static function callerIsOneOf(qualifiedMethodNames : Array, message : String = "") : Boolean
		{
			if (AioDebugUtil.isDebugBuild())
			{
				var callerMethod : String = "";

				try
				{
					callerMethod = AioDebugUtil.getCallerMethod(3);
				}
				catch (e : Error)
				{
					if (AioDebugUtil.isDebugBuild())
					{
						trace("Warning: cannot retrieve caller method name");
						return false;
					}
				}

				if (message == "")
				{
					message = "This method MUST be called from one of the following methods: "
						+ qualifiedMethodNames.toString()
						+ ", go fix your code!";
				}

				return Assert.isTrue(qualifiedMethodNames.indexOf(callerMethod) > -1, message);
			}

			return true;
		}
	}
}
