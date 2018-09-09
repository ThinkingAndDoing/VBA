//+------------------------------------------------------------------+
//| SampleEA.mq4                                                     |
//| Copyright ?2008, MetaQuotes Software Corp.                       |
//| QQ:XXX                                                           |
//+------------------------------------------------------------------+
#property link  "www.xw.com"

//---- input parameters
//可以选择4H时间线，做黄金
extern   double TakeProfit = 100000; //止盈
extern   double StopLoss = 100000; //止损
extern   double Lots = 0.01; //手数
extern   double TrailingStop = 50;
extern   int ShortEma = 5;//
extern   int LongEma = 10;//

enum Direction {UP=1, DOWN=-1};

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init() 
{
    //----

    //----
    return (0);
}
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit() 
{
    //----

    //----
    return (0);
}

//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start() 
{
	if (Bars < 100) 
	{
		Print("bars less than 100");
		return (0);
	}

	if (TakeProfit < 10) 
	{
		Print("TakeProfit less than 10");
		return (0); // check TakeProfit
	}
	

	CheckForOpen();
	CheckForClose();
	return (0);
}
//+------------------------------------------------------------------+
// 获取当前的趋势
//+------------------------------------------------------------------+
int CheckCurrentTrend()
{
	double SEma, LEma;
	SEma = iMA(NULL, 0, ShortEma, 0, MODE_LWMA, PRICE_CLOSE, 0);//MODE_SMA
	LEma = iMA(NULL, 0, LongEma, 0, MODE_LWMA, PRICE_CLOSE, 0);

	static int isCrossed = 0;
	isCrossed = Crossed(LEma, SEma);
	return (isCrossed);
}


//+------------------------------------------------------------------+
// 检查当前开仓条件，如果满足就开仓
//+------------------------------------------------------------------+
int CheckForOpen()
{
	int ticket;
	int isCrossed;
	int total;
	
	RefreshRates();
	isCrossed = CheckCurrentTrend();
	
	//趋势改变，关闭原来反向的单子
	if(isCrossed==DOWN)
	{
		ForceCloseAll(OP_BUY);
	}
	if(isCrossed==UP)
	{
		ForceCloseAll(OP_SELL);
	}
	
	//开启新方向的单子
	total = OrdersTotal();
	if (total < 1)
	{
		if (isCrossed == DOWN) // 满足空仓条件，开空仓
		{
			ticket = OrderSend(Symbol(), OP_SELL, Lots, Bid, 3, Bid + StopLoss * Point,Bid - TakeProfit * Point, "EMA_CROSS", 12345, 0, Green);
			if (ticket > 0) 
			{
				if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
					Print("SELL order opened : ", OrderOpenPrice());
			} else Print("Error opening SELL order : ", GetLastError());
			return (0);
		}
		if (isCrossed == UP) // 满足多仓条件，开多仓
		{
			ticket = OrderSend(Symbol(), OP_BUY, Lots, Ask, 3, Ask - StopLoss * Point,Ask + TakeProfit * Point, "EMA_CROSS", 12345, 0, Red);
			if (ticket > 0) 
			{
				if (OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES))
					Print("BUY order opened : ", OrderOpenPrice());
			} else Print("Error opening BUY order : ", GetLastError());
			return (0);
		}
		return (0);
	}
	return(0);
}

//+------------------------------------------------------------------+
// 订单修改，实现动态止盈止损跟踪
//+------------------------------------------------------------------+
int CheckForClose()
{

	RefreshRates();
	int cnt = 0;
	int total = OrdersTotal();
	for (cnt = 0; cnt < total; cnt++) 
	{
		if(OrderSelect(cnt, SELECT_BY_POS, MODE_TRADES)==False)
		{
		   Print("OrderSelect failed.");
		   continue;
		}
		if (OrderType() <= OP_SELL && OrderSymbol() == Symbol()) 
		{
			if (OrderType() == OP_SELL) // long position is opened
			{//OP_SELL
				// check for trailing stop
				if (TrailingStop > 0) 
				{
					if (Bid - OrderOpenPrice() > Point * TrailingStop) 
					{
						if (OrderStopLoss() < Bid - Point * TrailingStop) 
						{
							if(OrderModify(OrderTicket(), OrderOpenPrice(),Bid - Point * TrailingStop,OrderTakeProfit(), 0, Green)==False)
							   Print("OrderModify failed.");
							return (0);
						}
					}
				}
			} else // go to short position
			{//OP_BUY
				// check for trailing stop
				if (TrailingStop > 0) 
				{
					if ((OrderOpenPrice() - Ask) > (Point * TrailingStop)) 
					{
						if ((OrderStopLoss() > (Ask + Point * TrailingStop))) 
						{
							if(OrderModify(OrderTicket(), OrderOpenPrice(),Ask + Point * TrailingStop,OrderTakeProfit(), 0, Red)==False)
							   Print("OrderModify failed.");;
							return (0);
						}
					}
				}
			}
		}
	}
	return(0);
}

//+------------------------------------------------------------------+
// 关闭所有订单，买单或者卖单
//+------------------------------------------------------------------+
void ForceCloseAll(int orderType)
{
	for (int i = OrdersTotal() - 1; i >= 0; i--)
	{
		OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
		if (OrderSymbol() == Symbol())// && OrderMagicNumber() == a_magic_0)
		{
			if (OrderType() == orderType)
			{
				OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(OrderClosePrice(), Digits), 3, Red);
				Sleep(1000);
			}
		}
	}
}

//+------------------------------------------------------------------+
// 获取当前时间信息，
//+------------------------------------------------------------------+
string GetTimeInfo(datetime curDate)
{
   string var1=TimeToStr(curDate, TIME_DATE|TIME_SECONDS);
   return var1;
}

//+------------------------------------------------------------------+
// 移动平均线多空条件判断，
//+------------------------------------------------------------------+
int Crossed(double lineLong, double lineShort) 
{
	static Direction curDirection = UP;
	static Direction preDirection = UP;
	static bool first_time = true;
	
	//Don't work in the first load, wait for the first cross!
	if (first_time == true) 
	{
		first_time = false;
		return (0);
	}
	
	//up 多头市场 上穿做多
	if ( 0.02< lineShort - lineLong)
	{
	   curDirection = UP; 
	}
	//down 空头市场 下穿做空
	if ( -0.02> lineShort - lineLong)
	{
	   curDirection = DOWN; 
	}
	//changed 多空改变
	if (curDirection != preDirection) 
	{
	   if(curDirection==DOWN)
	   {
	      Print("Hello Wei! The trend is down!");
	      Print(lineLong);
	      Print(lineShort);
	   }
	   if(curDirection==UP)
	   {
	      Print("Hello Wei! The trend is up!");
	      Print(lineLong);
	      Print(lineShort);
	   }
		preDirection = curDirection;
		return (preDirection);
	}
	else return (0); 
}

