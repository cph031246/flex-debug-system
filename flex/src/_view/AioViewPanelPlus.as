/********************************************
 
 title   : SuperPanelPlus
 version : 1.0
 author  : Joel Hooks
 website : http://joelhooks.com
 date    : 2008-05-26
 * EXTENDS
 title   : SuperPanel
 version : 1.9
 author  : Wietse Veenstra
 website : http://www.wietseveenstra.nl
 date    : 2007-05-08
 
 * some patch by Damien MIRAS
 * this portion of code IS NOT under MIT licence
********************************************/
package _view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import mx.containers.Canvas;
	import mx.containers.Panel;
	import mx.controls.Button;
	import mx.core.Application;
	import mx.core.UIComponent;
	import mx.events.DragEvent;
	import mx.events.EffectEvent;
	import mx.events.FlexEvent;
	import mx.managers.CursorManager;
	
	import util.d;
	
	[Event(name="closeClickEvent", type="flash.events.Event")]
	
	public class AioViewPanelPlus extends Panel 
	{

		[Bindable] public var m_showControls	:Boolean 	= true;
		[Bindable] public var m_resizeEnabled	:Boolean = true;
		[Bindable] public var m_dragEnabled		:Boolean	= true;	
		[Embed(source="/ressources/img/resizeCursor.png")]
		private static var resizeCursor:Class;
		
		private var	m_uiComponentTitleBar	:UIComponent;
		private var m_oldWidth				:Number 		= 0;
		private var m_oldHeight				:Number 		= 0;
		
	
		private var m_oldDecreasedWidth		:Number 		= 0;
		private var m_oldDecreasedHeight	:Number 		= 0;
		private var m_oldDecreasedX	:Number 		= 0;
		private var m_oldDecreasedY	:Number 		= 0;
		
		
		
		private var m_oldX					:Number 		= 0;
		private var m_oldY					:Number 		= 0;
		private var m_oAlpha				:Number			= 1;

		private var m_buttonIconify			:Button			= new Button();
		private var m_buttonNormalMax		:Button			= new Button();
		private var m_buttonClose			:Button			= new Button();
		private var m_buttonResizeHandler	:Button			= new Button();
		private var m_panelMenu				:Panel			= new Panel();
		private var m_canvasMenuBar			:Canvas			= new Canvas();
		private var m_oldPoint				:Point 			= new Point();	
		private var resizeCur				:Number			= 0;
		private var m_isManualResizing		:Boolean		= false;

		
		[Inspectable(defaultValue=0.95)]
		[Bindable]
		private var m_selectedBorderAlpha:Number = .95;
		
		[Inspectable(defaultValue=0.95)]
		[Bindable]
		private var m_unselectedBorderAlpha:Number = .65;	
		
		[Inspectable(defaultValue=0.95)]
		[Bindable]
		private var m_moveAlpha:Number = .65;
		
		[Inspectable(defaultValue=0.3)]
		[Bindable]
		private var m_highlightAlpha1:Number = .3;
		
		[Inspectable(defaultValue=0.1)]
		[Bindable]
		private var m_highlightAlpha2:Number = .1;
		
		[Inspectable(defaultValue=0x333333)]
		[Bindable]
		private var m_styleColor:uint = 0x333333;
						
		public function AioViewPanelPlus() 
		{
			addEventListener(FlexEvent.SHOW, onShow);
			addEventListener(FlexEvent.HIDE, onHide);
			addEventListener(FlexEvent.CREATION_COMPLETE,onCreationComplete);
			addEventListener(Event.RESIZE, onResize);

		}
		
		public function addListeners():void 
		{
			addEventListener(MouseEvent.CLICK, onClick);
			
			if (m_dragEnabled) 
			{
				m_uiComponentTitleBar.addEventListener(MouseEvent.MOUSE_DOWN, onTitleBarMouseDown);
			}
			
			if (m_showControls) 
			{
				m_buttonClose.addEventListener(MouseEvent.CLICK, onButtonCloseMouseClick);
				m_buttonNormalMax.addEventListener(MouseEvent.CLICK, onButtonMaxMouseClick);
				m_buttonIconify.addEventListener(MouseEvent.CLICK, onButtonIconifyMouseClick);
			}
			
			if (m_resizeEnabled) 
			{
				m_buttonResizeHandler.addEventListener(MouseEvent.MOUSE_OVER, onButtonResizeMouseOver);
				m_buttonResizeHandler.addEventListener(MouseEvent.MOUSE_OUT, onButtonResizeMouseOut);
				m_buttonResizeHandler.addEventListener(MouseEvent.MOUSE_DOWN, onButtonResizeMouseDown);
			}
		}
		
		private function onCreationComplete(e:FlexEvent):void
		{
			initPos();
			positionChildren();
		}
		
		private function onResize(e:Event):void
		{
			if(m_isManualResizing == false)
			{
				m_oldWidth = width;
				m_oldHeight = height;
				//DMSmod
				m_oldX = x;
				m_oldY = y;
			}
			positionChildren();
		} 
		
		private function onShow(event:FlexEvent):void
		{
			initPos();
			positionChildren();
		}
		
		private function onHide(event:FlexEvent):void
		{

		}
		
		override protected function createChildren():void 
		{
			super.createChildren();
			m_uiComponentTitleBar = super.titleBar;
			setStyle("headerColors", 	[m_styleColor, m_styleColor]);
			setStyle("highlightAlphas", [m_highlightAlpha1, m_highlightAlpha2]);
			setStyle("borderColor", 	m_styleColor);
			setStyle("borderAlpha", 	m_selectedBorderAlpha);
			
			if (m_resizeEnabled) 
			{				
				m_buttonResizeHandler.width     = 12;
				m_buttonResizeHandler.height    = 12;
				m_buttonResizeHandler.x			= unscaledWidth - m_buttonResizeHandler.width;
				m_buttonResizeHandler.y			= unscaledHeight - m_buttonResizeHandler.height;
				
				m_buttonResizeHandler.styleName = "resizeHandler";
				rawChildren.addChild(m_buttonResizeHandler);
				initPos();
			}
			
			if (m_showControls) 
			{
				m_buttonIconify.width		= 10
				m_buttonIconify.height    	= 10;
				m_buttonIconify.styleName 	= "iconifyButton";
				m_buttonIconify.toolTip		= "Renvoyer dans le mur";				
				m_buttonNormalMax.width     = 10;
				m_buttonNormalMax.height    = 10;
				m_buttonNormalMax.styleName = "increaseButton";
				m_buttonNormalMax.toolTip	= "Agrandir";
				m_buttonClose.width     	= 10;
				m_buttonClose.height    	= 10;
				m_buttonClose.styleName 	= "closeButton";
				m_buttonClose.toolTip		= "Supprimer le widget";
				m_uiComponentTitleBar.addChild(m_buttonIconify);
				m_uiComponentTitleBar.addChild(m_buttonNormalMax);
				m_uiComponentTitleBar.addChild(m_buttonClose);
			}
			
			positionChildren();	
			addListeners();
		}
		
		public function initPos():void 
		{
			validateSize(false);
			m_oldDecreasedWidth  = width;
			m_oldDecreasedHeight = height;
			m_oldWidth = width;
			m_oldHeight = height;
			m_oldDecreasedX  = x;
			m_oldDecreasedY  =  y;
			m_oldX = x;
			m_oldY = y;
		}
		
		public function positionChildren():void 
		{
			if (m_showControls) 
			{
				m_buttonIconify.buttonMode    = true;
				m_buttonIconify.useHandCursor = true;
				m_buttonIconify.x = unscaledWidth - m_buttonIconify.width - 40;
				m_buttonIconify.y = 8;
				
				m_buttonNormalMax.buttonMode    = true;
				m_buttonNormalMax.useHandCursor = true;
				m_buttonNormalMax.x = unscaledWidth - m_buttonNormalMax.width - 24;
				m_buttonNormalMax.y = 8;
				
				m_buttonClose.buttonMode	   = true;
				m_buttonClose.useHandCursor = true;
				m_buttonClose.x = unscaledWidth - m_buttonClose.width - 8;
				m_buttonClose.y = 8;
			}
			
			if (m_resizeEnabled) 
			{
				m_buttonResizeHandler.y = unscaledHeight - m_buttonResizeHandler.height - 1;
				m_buttonResizeHandler.x = unscaledWidth - m_buttonResizeHandler.width - 1;
				
				m_buttonResizeHandler.y = height - m_buttonResizeHandler.height - 1;
				m_buttonResizeHandler.x = width - m_buttonResizeHandler.width - 1;
			}
		}

		public function removeListeners():void
		{
			removeEventListener(MouseEvent.CLICK, onClick);
			
			if (m_dragEnabled) 
			{
				m_uiComponentTitleBar.removeEventListener(MouseEvent.MOUSE_DOWN, onTitleBarMouseDown);
			}
			
			if (m_showControls) 
			{
				m_buttonClose.removeEventListener(MouseEvent.CLICK, onButtonCloseMouseClick);
				m_buttonNormalMax.removeEventListener(MouseEvent.CLICK, onButtonMaxMouseClick);
				m_buttonIconify.removeEventListener(MouseEvent.CLICK, onButtonIconifyMouseClick);
			}
			
			if (m_resizeEnabled) 
			{
				m_buttonResizeHandler.removeEventListener(MouseEvent.MOUSE_OVER, onButtonResizeMouseOver);
				m_buttonResizeHandler.removeEventListener(MouseEvent.MOUSE_OUT, onButtonResizeMouseOut);
				m_buttonResizeHandler.removeEventListener(MouseEvent.MOUSE_DOWN, onButtonResizeMouseDown);
			}			
		}
		
		private function onClick(event:MouseEvent):void 
		{
			m_uiComponentTitleBar.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			//parent.setChildIndex(this, parent.numChildren - 1)
			panelFocusCheckHandler();
		}
		
		public function onTitleBarMouseDown(event:MouseEvent):void 
		{
			m_uiComponentTitleBar.addEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
		}
		
		public function titleBarMoveHandler(event:MouseEvent):void 
		{
			if (width < screen.width) 
			{
				Application.application.parent.addEventListener(MouseEvent.MOUSE_UP, titleBarDragDropHandler);
				m_uiComponentTitleBar.addEventListener(DragEvent.DRAG_DROP,titleBarDragDropHandler);
				//parent.setChildIndex(this, parent.numChildren - 1);
				panelFocusCheckHandler();
				// this.alpha = _moveAlpha;
				startDrag(false, new Rectangle(0, 0, screen.width - width, screen.height - height));
			}
		}
		
		public function titleBarDragDropHandler(event:MouseEvent):void 
		{
			m_uiComponentTitleBar.removeEventListener(MouseEvent.MOUSE_MOVE, titleBarMoveHandler);
			stopDrag();
			if (m_oAlpha < 1) 
			{
				alpha = m_oAlpha;
			} 
			else 
			{
				alpha = 1;
			}
		}
		
		public function panelFocusCheckHandler():void 
		{
			for (var i:int = 0; i < parent.numChildren; i++) 
			{
				var child:UIComponent = UIComponent(parent.getChildAt(i));
				if (parent.getChildIndex(child) < parent.numChildren - 1) 
				{
					child.setStyle("borderAlpha", m_unselectedBorderAlpha);
				} 
				else if (parent.getChildIndex(child) == parent.numChildren - 1) 
				{
					child.setStyle("borderAlpha", m_selectedBorderAlpha);
				}
			}
		}
		
		public function endEffectEventHandler(event:EffectEvent):void 
		{
			m_buttonResizeHandler.visible = true;
		}
		
		public function onButtonMaxMouseClick(event:MouseEvent):void 
		{
			if (m_buttonNormalMax.styleName == "increaseButton") 
			{
				if (height > 28) 
				{
					initPos();

					m_oldDecreasedWidth  = width;
				 	m_oldDecreasedHeight = height;
				
					//WARNING set x,y do this after the initpos() !
 					x = 0;
					y = 0;					
					width = screen.width;
					height = screen.height;
					m_buttonNormalMax.styleName = "decreaseButton";
					m_buttonNormalMax.toolTip = "Niveau inférieur";
					positionChildren();
				}
			} 
			else 
			{

 				x = m_oldDecreasedX;
 				y = m_oldDecreasedY;
				width 	=  m_oldDecreasedWidth;
				height 	=  m_oldDecreasedHeight;
				
				m_buttonNormalMax.styleName = "increaseButton";
				m_buttonNormalMax.toolTip = "Agrandir";
				positionChildren();
			}
		}
		
		public function onButtonIconifyMouseClick(event:MouseEvent):void
		{
			removeEventListener(MouseEvent.CLICK, onClick);
			dispatchEvent( new Event( "iconifyClickEvent", true ) );
		}
		
		public function onButtonCloseMouseClick(event:MouseEvent):void 
		{
			removeEventListener(MouseEvent.CLICK, onClick);
			dispatchEvent( new Event( "closeClickEvent", true ) );
		}
		
		public function onButtonResizeMouseOver(event:MouseEvent):void 
		{
			m_isManualResizing = true;
			resizeCur = CursorManager.setCursor(resizeCursor);
		}
		
		public function onButtonResizeMouseOut(event:MouseEvent):void 
		{
			
			CursorManager.removeCursor(CursorManager.currentCursorID);
		}
		
		public function onButtonResizeMouseDown(event:MouseEvent):void 
		{
			m_isManualResizing = true;
			enabled = false;
			
			Application.application.parent.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Application.application.parent.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			
			m_buttonResizeHandler.addEventListener(MouseEvent.MOUSE_OVER, onButtonResizeMouseOver);
			onClick(event);
			resizeCur = CursorManager.setCursor(resizeCursor);
			m_oldPoint.x = mouseX;
			m_oldPoint.y = mouseY;
			m_oldPoint = localToGlobal(m_oldPoint);		
		}
		
		public function onMouseMove(event:MouseEvent):void 
		{
			stopDragging();
			
			var xPlus:Number = Application.application.parent.mouseX - m_oldPoint.x;			
			var yPlus:Number = Application.application.parent.mouseY - m_oldPoint.y;
			

			
			if (m_panelMenu.height == 150) 
			{
				if (m_oldWidth + xPlus > 215) 
				{
					width = m_oldWidth + xPlus;
				}
				if (m_oldHeight + yPlus > 200) 
				{
					height = m_oldHeight + yPlus;
				}				
			}
			else 
			{
				if (m_oldWidth + xPlus > 140) 
				{
					width = m_oldWidth + xPlus;
				}
				if (m_oldHeight + yPlus > 80) 
				{
					height = m_oldHeight + yPlus;
				}
			}
			positionChildren();
		}
		
		public function onMouseUp(event:MouseEvent):void 
		{
			enabled = true;
			
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Application.application.parent.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);

			CursorManager.removeCursor(CursorManager.currentCursorID);
			m_buttonResizeHandler.addEventListener(MouseEvent.MOUSE_OVER, onButtonResizeMouseOver);
			initPos();
		}
		
		public function get selectedBorderAlpha( ):Number 
		{ 
			return m_selectedBorderAlpha 
		}
		
		public function set selectedBorderAlpha( value:Number ):void 
		{
			 m_selectedBorderAlpha = value 
		}
		
			
		public function get unselectedBorderAlpha( ):Number 
		{ 
			return m_unselectedBorderAlpha 
		}
		
		public function set unselectedBorderAlpha( value:Number ):void 
		{ 
			m_unselectedBorderAlpha = value 
		}
		
		
		public function get moveAlpha( ):Number 
		{ 
			return m_moveAlpha 
		}
				
		public function set moveAlpha( value:Number ):void 
		{ 
			m_moveAlpha = value 
		}				

		public function get highlightAlpha1( ):Number 
		{ 
			return m_highlightAlpha1 
		}
		
		public function set highlightAlpha1( value:Number ):void 
		{ 
			m_highlightAlpha1 = value
		}
		

		public function get highlightAlpha2( ):Number 
		{ 
			return m_highlightAlpha2 
		}
		
		public function set highlightAlpha2( value:Number ):void 
		{
			m_highlightAlpha2 = value 
		}
						

		public function get styleColor( ):Number 
		{ 
			return m_styleColor 
		}
		
		public function set styleColor( value:Number ):void 
		{ 
			m_styleColor = value
		}
	}
	
}
