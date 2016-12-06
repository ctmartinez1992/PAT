import mx.utils.Delegate;
class Scroller
{
	private var conteudo:MovieClip;
	private var arrasta:MovieClip;
	private var limite:MovieClip;
	private var ctr:String;
	private var mascara:Number;
	private var suavidade:Number;
	private var velocidade:Number;
	private var cima:MovieClip;
	private var baixo:MovieClip;
	private var maxcima:Number;
	private var maxbaixo:Number;
	private var miny:Number;
	private var maxy:Number;
	private var sbMask_mc:MovieClip;
	public var scroll_ok:Boolean;
	private var array_lim_ctr:Array;
	private var inactivo:String;
	private var inactivo_valor:Number;
	
	function Scroller (tcontent:MovieClip, twh:Number, tes, tt:String, tup:MovieClip, tdown:MovieClip, tdragger:MovieClip, ttrack:MovieClip)
	{
		conteudo = tcontent;
		arrasta = tdragger;
		limite = ttrack;
		ctr = tt;
		mascara = twh;
		var temp:Array = tes.split(" ").join("").split(",");
		suavidade = Number(temp[0]);
		if (suavidade <= 0)
		{
			suavidade = 0.5;
		}
		velocidade = Number(temp[1]);
		if (velocidade <= 0)
		{
			velocidade = 10;
		}
		cima = tup;
		baixo = tdown;
		scroll_ok = false;
	}
	
	public function init():String
	{
		arrasta._y = limite._y;
		arrasta._x = limite._x;
		
		if (!inactivo)
		{
			inactivo = "Hidden";
		}

		array_lim_ctr = new Array();
		if (conteudo._height < mascara)
		{
			var da:Number = inactivo_valor;
			if (inactivo == "Hidden")
			{
				arrasta._visible = false;
				limite._visible = false;
				cima._visible = false;
				baixo._visible = false;
			}
			else
			{
				limite._alpha = da;
				baixo._alpha = da;
				arrasta._alpha = da;
				cima._alpha = da;
			}
			array_lim_ctr.push("Conteúdo demasiado pequeno para fazer scroll.");
		}
		if ((cima == undefined) || (limite == undefined) || (arrasta == undefined) || (baixo == undefined))
		{
			array_lim_ctr.push("Falta um elemento no stage (Dragger/Track/Up/Down).");
		}
		if (array_lim_ctr.length > 0)
		{
			return "S_ERR";
		}
		
		var obj;
		limite.obj = this;
		cima.obj = this;
		conteudo.obj = this;
		arrasta.obj = this;
		baixo.obj = this;
	  
		switch (ctr) 
		{
			case "over" :
				baixo.onRollOver = Delegate.create(this, scrollDownHandler);
				baixo.onRollOut = Delegate.create(this, stopScrollHandler);
				cima.onRollOver = Delegate.create(this, scrollUpHandler);
				cima.onRollOut = Delegate.create(this, stopScrollHandler);
				break;
			case "click" :
				baixo.onPress = Delegate.create(this, scrollDownHandler);
				cima.onPress = Delegate.create(this, scrollUpHandler);
				cima.onRelease = Delegate.create(this, stopScrollHandler);
				baixo.onRelease = Delegate.create(this, stopScrollHandler);
				break;
			case "both" :
				baixo.onPress = Delegate.create(this, scrollDownHandler);
				baixo.onRelease = Delegate.create(this, stopScrollHandler);
				cima.onPress = Delegate.create(this, scrollUpHandler);
				cima.onRelease = Delegate.create(this, stopScrollHandler);
				baixo.onRollOver = Delegate.create(this, scrollDownHandler);
				baixo.onRollOut = Delegate.create(this, stopScrollHandler);
				cima.onRollOver = Delegate.create(this, scrollUpHandler);
				cima.onRollOut = Delegate.create(this, stopScrollHandler);
				break;
		}

		var mouseListener:Object = new Object();
		var keyListener:Object = new Object();
		Mouse.addListener(mouseListener);
		Key.addListener(keyListener);
		
		keyListener.onKeyUp = Delegate.create(this, keyUpHandler);
		keyListener.onKeyDown = Delegate.create(this, keyDownHandler);
		mouseListener.onMouseWheel = Delegate.create(this, mouseHandler);

		arrasta.onPress = Delegate.create(this, draggerDownHandler);
		arrasta.onMouseUp = Delegate.create(this, draggerUpHandler);
		
		var new_depth:Number = conteudo._parent.getNextHighestDepth();
		var sbMask_mc:MovieClip = conteudo._parent.createEmptyMovieClip("sb_" + new_depth + "_mc",new_depth);
		sbMask_mc.beginFill (0xff0000, 100);
		sbMask_mc.moveTo (0, 0);
		sbMask_mc.lineTo (conteudo._width, 0);
		sbMask_mc.lineTo (conteudo._width, mascara);
		sbMask_mc.lineTo (0, mascara);
		sbMask_mc.endFill ();
		sbMask_mc._y = conteudo._y;
		sbMask_mc._x = conteudo._x;
		sbMask_mc._width = conteudo._width + 4;
		sbMask_mc._height = mascara;

		conteudo.setMask(sbMask_mc);
		

		maxcima = Math.floor(conteudo._y - ((conteudo._height - mascara) + conteudo._y));
		maxbaixo = conteudo._y;
		miny = limite._y;
		maxy = limite._y + (limite._height - arrasta._height);

		array_lim_ctr.push("Área Visível: " + mascara);
		array_lim_ctr.push("Área com Scroll: " + (maxcima * -1));
		array_lim_ctr.push("Velocidade: " + velocidade);
		array_lim_ctr.push("Suavidade: " + suavidade);
		array_lim_ctr.push("Conteúdo: " + conteudo);
		array_lim_ctr.push("Inactivo: " + inactivo);
		array_lim_ctr.push("Minimo y: " + miny);
		array_lim_ctr.push("Maximo y: " + maxy);
		if (inactivo == "Trans")
		{
			array_lim_ctr.push("Alpha: " + inactivo_valor);
		}
		return "S_OK";
	}
	

	private function draggerUpHandler():Void
	{
		arrasta.stopDrag();
		stopScrollHandler();
	}
	private function draggerDownHandler():Void
	{
		scroll_ok = true;
		arrasta.startDrag(false, arrasta._x, miny, arrasta._x, maxy);
		arrasta.onEnterFrame = function()
		{
			var o:Object = this.obj;
			o.updateContentPosition();
		}
	}
	private function keyUpHandler():Void
	{
		if (checkKey(Key.getCode()))
		{
			stopScrollHandler();
		}
	}
	private function keyDownHandler():Void
	{
		if (checkKey(Key.getCode()))
		{
			if (checkKey(Key.getCode()) == 40)
			{
				scrollDownHandler();
			}
			else
			{
				scrollUpHandler();
			}
		}
	}
	private function mouseHandler(delta:Number):Void
	{
		if (delta > 0)
		{
			scroll_ok = true;
			arrasta.onEnterFrame = function()
			{
				var o:Object = this.obj;
				if (o.scroll_ok)
				{
					o.arrasta._y = Math.max(o.miny, o.arrasta._y - o.velocidade);
				}
				o.updateContentPosition();
				o.scroll_ok = false;
			}
		}
		else
		{
			scroll_ok = true;
			arrasta.onEnterFrame = function()
			{
				var o:Object = this.obj;
				if (o.scroll_ok)
				{
					o.arrasta._y = Math.min(o.maxy, o.arrasta._y + o.velocidade);
				}
				o.updateContentPosition();
				o.scroll_ok = false;
			}
		}
	}
	
	private function scrollDownHandler():Void
	{
		scroll_ok = true;
		arrasta.onEnterFrame = function()
		{
			var o:Object = this.obj;
			if (o.scroll_ok)
			{
				o.arrasta._y = Math.min(o.maxy, o.arrasta._y + o.velocidade);
			}
			o.updateContentPosition();
		}
	}
	private function scrollUpHandler():Void
	{
		scroll_ok = true;
		arrasta.onEnterFrame = function()
		{
			var o:Object = this.obj;
			if (o.scroll_ok)
			{
				o.arrasta._y = Math.max(o.miny, o.arrasta._y - o.velocidade);
			}
			o.updateContentPosition();
		}
	}
	private function stopScrollHandler():Void
	{
		scroll_ok = false;
	}
	private function updateContentPosition():Void
	{
		maxcima = Math.floor(conteudo._y - ((conteudo._height - mascara) + conteudo._y));
		var percent:Number = (arrasta._y - limite._y) / (limite._height - arrasta._height);
		var newY:Number = Math.round(maxbaixo + (percent*maxcima));
		if ((Math.round(conteudo._y))  == newY && (!scroll_ok))
		{
			delete arrasta.onEnterFrame;
		} else {
			conteudo._y += (newY-conteudo._y)/suavidade;
		}
	}
		

	private function checkKey(key:Number):Number
	{
		if ((key == 40) || (key == 38))
		{
			return key;
		}
		return 0;
	}
	public function output():Void
	{
		var i:Number;
		for (i=0; i<array_lim_ctr.length;i++)
		{
			trace(array_lim_ctr[i]);
		}
	}
	public function disable(type:String, num:Number):Void
	{
		inactivo = "Hidden";
		if ((type == "Hidden") || (type == "Trans"))
		{
			inactivo = type;
		}
		inactivo_valor = 50;
		if (arguments.length > 1)
		{
			inactivo_valor = num;
		}
	}
}