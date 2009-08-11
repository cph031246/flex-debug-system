package _view
{
	import flash.events.MouseEvent;
	
	import mx.containers.ApplicationControlBar;
	import mx.controls.Label;
	
	public class AioViewControlPanel extends ApplicationControlBar
	{
		
		public function AioViewControlPanel()
		{
			
			addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			alpha = 0.7;
		}
		
		private function onMouseDown(event:MouseEvent):void
		{
			startDrag();
		}
		private function onMouseUp(event:MouseEvent):void
		{
			stopDrag();
		}
		private function onMouseOut(event:MouseEvent):void
		{
			alpha = 0.7;
		}
		private function onMouseOver(event:MouseEvent):void
		{
			alpha = 1.0;
		}
	}
}