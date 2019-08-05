/*******************************************************************
原理：最近数十年来，一些美国学者将“黄金分割率”应用在股市行情分析方面
，发现并当股指或股价的上涨速度达到前波段跌幅的0．382倍或是0．618倍附
近时，都会产生较大的反压，随时可能出现止涨下跌；当股指或股价出现下跌
时，其下跌的幅度达到前波段涨幅的0．382或是0．618倍附近时，都会产生较
大的支撑，随时可能出现止跌上涨。为什么会这么巧合呢？究其根源，既然自
然界都受到“黄金分割”这种神奇力量的规范，那么，人类无可避免地也会受到
自然界的制约。股市行情是集合众人力量的行为，它也属于一种自然的社会现
象，因此其必然有规律可循，在一般情况下也不可能不受到自然界无形力量的
制约。可以预言，在对股市行情的观察分析中，如果能够恰到好处地运用“黄
金分割率”，必然能够较为准确地预测股指或股价的走势，大大提高股票投资
的盈利率。
*******************************************************************/


#property  copyright "Copyright  2017 RO"
#property  link      "http://www.sohu.com/a/124015858_522927"
//改进方法：计算每一笔单子的最大浮亏，设计出最合理的止损；将交易时间设定在22.5点-次日4点；调整加仓间距；


enum ENUM_Trading_Mode      {PendingLimitOrderFollowTrend = 0,PendingLimitOrderReversalTrend = 1,PendingStopOrderFollowTrend = 2,PendingStopOrderReversalTrend = 3  };
enum ENUM_Candlestick_Mode      {ToAvoidNews = 0,ToTriggerOrder = 1 };
enum ENUM_Trend         {Downtrend = -1, Uptrend = 1, Ambiguoustend = 0};

//------------------
//本EA基于超买超卖策略，遇见单边行情会亏损
//buy limit——买入限价，在当前价格下方挂买单（低价买入）
//sell limit——卖出限价，在当前价格上方挂卖单（高价卖出）
//buy stop——买入止损，在当前价格上方挂买单（高价买入）
//sell stop——卖出止损，在当前价格下方挂卖单（低价卖出）
//Ask: seller's price, Bid: buyer's price, 
extern  ENUM_Trading_Mode  TradingMode=PendingStopOrderReversalTrend  ;
extern bool UseMM=false ;   
extern double Risk=0.1  ; //风险系数
extern double FixedLots=0.01  ;   
extern double LotsBase=1.1  ;   
extern bool UseTakeProfit=false ;   
extern int   TakeProfit=200  ;   
extern bool UseStopLoss=true ;   
extern int   StopLoss=500  ; //默认500点止损
extern bool AutoTargetMoney=true  ;   
extern double TargetMoneyFactor=20  ;   
extern double TargetMoney=0  ;   
extern bool AutoStopLossMoney=false ;   
extern double StoplossFactor=0  ;   
extern double StoplossMoney=0  ;   
extern bool UseTrailing=false ;  //是否使用动态止损 
extern int   TrailingStop=20  ;   
extern int   TrailingStart=0  ;   
extern  ENUM_Candlestick_Mode  CandlestickMode=ToAvoidNews  ;//蜡烛棒模式
extern int   CandlestickHighLow=500  ;   
extern int   MaxOrderBuy=39  ;   
extern int   MaxOrderSell=39  ;   
extern int   PendingDistance=25  ;   
extern int   Pipstep=15  ;   
extern double PipstepBase=1  ;   
extern double MaxSpreadPlusCommission=50  ;   
extern bool HighToLow=true  ;   
extern double HighFibo=76.4  ;   
extern double LowFibo=23.6  ;   
extern int   StartBar=1  ;   
extern int   BarsBack=20  ;
extern bool ShowFibo=true  ;   
extern int   Slippage=3  ;   
extern int   MagicNumber=1  ;   
extern string TradeComment="RO-EA"  ;  
extern bool TradeMonday=true  ;   
extern bool TradeTuesday=true  ;   
extern bool TradeWednesday=true  ;   
extern bool TradeThursday=true  ;   
extern bool TradeFriday=true  ;   
extern int   StartHour=0  ;   
extern int   StartMinute=0  ;   
extern int   EndHour=23  ;   
extern int   EndMinute=59  ;   
double    总_do_1 = 10000.0;
double    GoldenSectionBrk1 = 0.236; //GoldenSectionBrk1
double    GoldenSectionBrk2 = 0.382;
double    GoldenSectionBrk3 = 0.5;
double    GoldenSectionBrk4 = 0.618;
double    GoldenSectionBrk5 = 0.764;
double    GoldenSectionBrkSt = 0.0;
double    GoldenSectionBrkEd = 1.0;
uint      总_ui_9 = Blue;
uint      总_ui_10 = DarkGray;
double    总_do11ko[];
double    总_do12ko[];
double    总_do13ko[];
double    总_do14ko[];
double    总_do15ko[];
double    总_do16ko[];
double    总_do17ko[];
double    总_do18ko[];
double    dTotalProfitBuy = 0.0;
double    dTotalProfitSell = 0.0;
bool      boDoCloseBuyOrd = false;
bool      boDoCloseSellOrd = false;
int       总_in_23 = 0;
int       总_in_24 = 0;
int       iMaxSellOrder = 0;
int       iMaxBuyOrder = 0;
int       总_in_27 = 0;
int       总_in_28 = 0;
double    总_do29si30[30];
int       mI_digits = 0; //小数点后面位数
double    mI_point = 0.0; //当前报价的点值
int       iDigitsAfterDeciPoint = 0;
double    theTradeUnit = 0.0;//真正交易的单位
double    theMaxTradeNum = 0.0; //允许的最大交易量
double    交易比例 = 0.0; //每次交易的比例
double    总_do_36 = 0.0;
double    PendingDistancePrice = 0.0; //加仓间距
double    总_do_38 = 0.0;
double    总_do_39 = 0.0;
double    总_do_40 = 0.0;
double    总_do_41 = 0.0;
double    总_do_42 = 0.0;
double    总_do_43 = 0.0;
bool      boIsCommissionRateCalc = false;
double    dCommissionRate = 0.0;
int       总_in_46 = 0;
double    总_do_47 = 0.0;
bool      总_bo_48 = true;
double    总_do_49 = 240.0;
double    总_do_50 = 0.0;
int       总_in_51 = 0;
double    dDiffOfMaxAndMin = 0.0;
double    总_do_53 = 0.0;
double    总_do_54 = 0.0;
double    总_do_55 = 0.0;
double    总_do_56 = 0.0;
double    总_do_57 = 0.0;
double    总_do_58 = 0.0;
double    总_do_59 = 0.0;

#import   "stdlib.ex4"
string ErrorDescription( int iErrorID);
#import     

int init()
{
	int       iPeriod;
	double    dLotStep;
	//----- -----

	ArrayInitialize(总_do29si30,0.0); 
	mI_digits = MarketInfo(NULL, MODE_DIGITS) ;
	mI_point = MarketInfo(NULL, MODE_POINT) ; 
	Print("Digits: " + string(mI_digits) + " Point: " + DoubleToString(MarketInfo(NULL,MODE_POINT),mI_digits)); 
	dLotStep = MarketInfo(Symbol(),MODE_LOTSTEP) ; //最小递增下单量
	iDigitsAfterDeciPoint = MathLog(dLotStep) / (-2.302585092994) ;//MathLog(10)=2.302585092994
	theTradeUnit = MathMax(FixedLots,MarketInfo(Symbol(),23)) ;
	theMaxTradeNum = MathMin(总_do_1,MarketInfo(Symbol(),25)) ;
	交易比例 = Risk / 100.0 ;
	总_do_36 = NormalizeDouble(MaxSpreadPlusCommission * mI_point,mI_digits + 1) ;
	PendingDistancePrice = NormalizeDouble(PendingDistance * mI_point,mI_digits) ;
	总_do_43 = NormalizeDouble(mI_point * CandlestickHighLow,mI_digits) ;
	boIsCommissionRateCalc = false ;
	dCommissionRate = NormalizeDouble(总_do_47 * mI_point,mI_digits + 1) ;
	if ( !(IsTesting()) )
	{
		if ( 总_bo_48 )
		{
			iPeriod = Period() ;
			switch(Period())
			{
			case PERIOD_M1 :
			总_do_49 = 5.0 ;
				break;
			case PERIOD_M5 :
			总_do_49 = 15.0 ;
				break;
			case PERIOD_M15 :
			总_do_49 = 30.0 ;
				break;
			case PERIOD_M30 :
			总_do_49 = 60.0 ;
				break;
			case PERIOD_H1 :
			总_do_49 = 240.0 ;
				break;
			case PERIOD_H4 :
			总_do_49 = 1440.0 ;
				break;
			case PERIOD_D1:
			总_do_49 = 10080.0 ;
				break;
			case PERIOD_W1:
			总_do_49 = 43200.0 ;
				break;
			case PERIOD_MN1 :
			总_do_49 = 43200.0 ;
		}}
		总_do_50 = 0.0001 ;
	}
	DeleteAllObjects ( ); 
	SetIndexBuffer(0,总_do11ko); 
	SetIndexBuffer(1,总_do12ko); 
	SetIndexBuffer(2,总_do13ko); 
	SetIndexBuffer(3,总_do14ko); 
	SetIndexBuffer(4,总_do15ko); 
	SetIndexBuffer(5,总_do16ko); 
	SetIndexBuffer(6,总_do17ko); 
	SetIndexBuffer(7,总_do18ko); 
	SetIndexLabel(0,"Fibo_" + DoubleToString(GoldenSectionBrkSt,4)); 
	SetIndexLabel(1,"Fibo_" + DoubleToString(GoldenSectionBrk1,4)); 
	SetIndexLabel(2,"Fibo_" + DoubleToString(GoldenSectionBrk2,4)); 
	SetIndexLabel(3,"Fibo_" + DoubleToString(GoldenSectionBrk3,4)); 
	SetIndexLabel(4,"Fibo_" + DoubleToString(GoldenSectionBrk4,4)); 
	SetIndexLabel(5,"Fibo_" + DoubleToString(GoldenSectionBrk5,4)); 
	SetIndexLabel(7,"Fibo_" + DoubleToString(GoldenSectionBrkEd,4)); 
	return(0); 
}
//init <<==
//---------- ----------  ---------- ----------
int start()
{
	double    子_do_4;
	double    子_do_5;
	double    dLastSellPrice;
	double    dLastBuyPrice;
	int       iLastError;
	string    strErrorDescription;
	int       iTktOfNewOrder;
	double    tradePrice; //交易的价格
	double    dProfitRate;
	ENUM_Trend  eCurrentTrend;
	int       ordertype;
	bool      子_bo_15;
	double    dOrderOpenPrice;
	double    basicVolume; //每次的交易量
	double    buyVolume; //买入手数
	double    sellVolume; //卖出手数
	double    子_do_20;
	double    子_do_21;
	double    dTakeProfit;
	double    dStopLoss;
	double    theHighPriceOfCur; // 当前柱的最高价
	double    theLowPriceOfCur; // 当前柱的最低价
	double    theHighPriceOfPre; // 前一柱的最高价
	double    theLowPriceOfPre; // 前一柱的最低价
	int       子_in_28;
	int       子_in_29;
	double    dLowest;
	double    dHighest;
	int       iIndexOfLowest;
	int       iIndexOfHighest;
	double    子_do_34;
	double    子_do_35;
	double    dPriceOfLowFibo;
	//double    子_do_37;
	//double    子_do_38;
	//double    子_do_39;
	//double    子_do_40;
	//double    子_do_41;
	double    dPriceOfHighFibo;
	int       i;
	double    dSpread;//点差
	double    子_do_45;
	int       j;
	double    averageSpread;//最近三十个柱点差的均值
	double    子_do_48;
	double    子_do_49;
	double    子_do_50;
	double    theDiffOfCur; // 当前柱的最高价和最低价的差值
	double    theDiffOfPre; // 前一柱的最高价和最低价的差值
	int       挂单数量;
	string    子_st_54;
	//----- -----


	if ( ShowFibo == true )
	{
		CalcFibo(); 
	}
	子_do_4 = NormalizeDouble(Pipstep * MathPow(PipstepBase,CountTradesSell ( )),0) ;
	子_do_5 = NormalizeDouble(Pipstep * MathPow(PipstepBase,CountTradesBuy ( )),0) ;
	dLastSellPrice = FindLastSellPrice_Hilo ( ) ;
	dLastBuyPrice = FindLastBuyPrice_Hilo ( ) ;
	iLastError = 0 ;
	iTktOfNewOrder = 0 ;
	tradePrice = 0.0 ;
	dProfitRate = 0.0 ;
	eCurrentTrend = Ambiguoustend;
	ordertype = 0 ;
	子_bo_15 = false ;
	dOrderOpenPrice = 0.0 ;
	basicVolume = 0.0 ;
	buyVolume = 0.0 ;
	sellVolume = 0.0 ;
	子_do_20 = 0.0 ;
	子_do_21 = 0.0 ;
	dTakeProfit = 0.0 ;
	dStopLoss = 0.0 ;
	theHighPriceOfCur = iHigh(NULL,0,0) ;
	theLowPriceOfCur = iLow(NULL,0,0) ;
	theHighPriceOfPre = iHigh(NULL,0,1) ;
	theLowPriceOfPre = iLow(NULL,0,1) ;
	子_in_28 = 0 ;
	子_in_29 = 0 ;
	dLowest = 0.0 ;
	dHighest = 0.0 ;
	iIndexOfLowest = iLowest(NULL,0,MODE_LOW,BarsBack,StartBar) ;
	iIndexOfHighest = iHighest(NULL,0,MODE_HIGH,BarsBack,StartBar) ;
	子_do_34 = 0.0 ;
	子_do_35 = 0.0 ;
	dHighest = High[iIndexOfHighest] ;//在20个连续柱子范围内计算最大值，在当前图表上从第1个至第21个的索引
	dLowest = Low[iIndexOfLowest] ;//在20个连续柱子范围内计算最小值，在当前图表上从第1个至第21个的索引
	dDiffOfMaxAndMin = dHighest - dLowest ;//在当前图表上从第1个至第21个的柱子中最大值与最小值的差值
	dPriceOfLowFibo = LowFibo / 100.0 * dDiffOfMaxAndMin + dLowest ;
	//子_do_37 = dDiffOfMaxAndMin * 0.236 + dLowest ;
	//子_do_38 = dDiffOfMaxAndMin * 0.382 + dLowest ;
	//子_do_39 = dDiffOfMaxAndMin * 0.5 + dLowest ;
	//子_do_40 = dDiffOfMaxAndMin * 0.618 + dLowest ;
	//子_do_41 = dDiffOfMaxAndMin * 0.764 + dLowest ;
	dPriceOfHighFibo = HighFibo / 100.0 * dDiffOfMaxAndMin + dLowest ;
	
	//计算佣金率，比率越大，表示佣金所占比列越多
	if ( !(boIsCommissionRateCalc) )
	{
		for (i = OrdersHistoryTotal() - 1 ; i >= 0 ; i = i - 1)
		{
			if ( !(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) || !(OrderProfit()!=0.0) || !(OrderClosePrice()!=OrderOpenPrice()) || OrderSymbol() != Symbol() )   continue;
			boIsCommissionRateCalc = true ;
			dProfitRate= MathAbs(OrderProfit() / (OrderClosePrice() - OrderOpenPrice()));
			dCommissionRate = ( -(OrderCommission())) / dProfitRate ;
			break;
		
		}
	}
	
	//每次交易的数量
	basicVolume = NormalizeDouble(AccountBalance() * AccountLeverage() * 交易比例 / MarketInfo(Symbol(),MODE_LOTSIZE),iDigitsAfterDeciPoint) ;
	if ( !(UseMM) )
	{
		basicVolume = FixedLots ;
	}
	
	//?
	总_do_57 = basicVolume * TargetMoneyFactor * CountTradesSell ( ) * LotsBase ;
	if ( !(AutoTargetMoney) )
	{
		总_do_57 = TargetMoney ;
	}
	总_do_56 = basicVolume * TargetMoneyFactor * CountTradesBuy ( ) * LotsBase ;
	if ( !(AutoTargetMoney) )
	{
		总_do_56 = TargetMoney ;
	}
	总_do_59 = basicVolume * StoplossFactor * CountTradesSell ( ) * LotsBase ;
	if ( !(AutoStopLossMoney) )
	{
		总_do_59 = StoplossMoney ;
	}
	总_do_58 = basicVolume * StoplossFactor * CountTradesBuy ( ) * LotsBase ;
	if ( !(AutoStopLossMoney) )
	{
		总_do_58 = StoplossMoney ;
	}
	
	//计算最近三十根柱子的点差均值
	dSpread = Ask - Bid ; //卖出价减去买入价=点差
	ArrayCopy(总_do29si30,总_do29si30,0,1,29); 
	总_do29si30[29] = dSpread;
	if ( 总_in_46 <  30 )
	{
		总_in_46=总_in_46 + 1;
	}
	子_do_45 = 0.0 ;
	i = 29 ;
	for (j = 0 ; j < 总_in_46 ; j = j + 1)
	{
		子_do_45 = 子_do_45 + 总_do29si30[i] ;
		i = i - 1;
	}
	averageSpread = 子_do_45 / 总_in_46 ;
	
	//?
	子_do_48 = NormalizeDouble(Ask + dCommissionRate,mI_digits) ;
	子_do_49 = NormalizeDouble(Bid - dCommissionRate,mI_digits) ;
	子_do_50 = NormalizeDouble(averageSpread + dCommissionRate,mI_digits + 1) ;
	theDiffOfCur = theHighPriceOfCur - theLowPriceOfCur ;
	theDiffOfPre = theHighPriceOfPre - theLowPriceOfPre ;
	if ( Bid - dLastSellPrice>=子_do_4 * Point() )
	{
		iMaxSellOrder = MaxOrderSell ;
	}
	else
	{
		iMaxSellOrder = 1 ;
	}
	if ( dLastBuyPrice - Ask>=子_do_5 * Point() )
	{
		iMaxBuyOrder = MaxOrderBuy ;
	}
	else
	{
		iMaxBuyOrder = 1 ;
	}
	
	//计算当前趋势?
	if ( CandlestickMode != ToAvoidNews )
	{
		if ( CandlestickMode == 1 && theDiffOfCur>总_do_43 )
		{
			if ( Bid>dPriceOfHighFibo )
			{
				eCurrentTrend = Downtrend ;
			}
			else
			{
				if ( Bid<dPriceOfLowFibo )
				{
					eCurrentTrend = Uptrend ;
				}
			}
		}
	}
	else
	{
		if ( theDiffOfCur<=总_do_43 && theDiffOfPre<=总_do_43 )
		{//当前行情没有大起大落
			if ( Bid>dPriceOfHighFibo )
			{//当前买入价在黄金分割点76.4的上访
				eCurrentTrend = Downtrend ;
			}
			else
			{
				if ( Bid<dPriceOfLowFibo )
				{
					eCurrentTrend = Uptrend ;
				}
			}
		}
	}
	
	//动态修改挂单的买入价，止损价，止盈价
	挂单数量 = 0 ;
	for (i = 0 ; i < OrdersTotal() ; i = i + 1)
	{
		if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) || OrderMagicNumber() != MagicNumber )   continue;
		ordertype = OrderType() ;
		if ( ordertype == OP_BUY || ordertype == OP_SELL || OrderSymbol() != Symbol() )   continue;
		挂单数量 = 挂单数量 + 1;
		switch(ordertype)
		{
		case OP_BUYSTOP:
			dOrderOpenPrice = NormalizeDouble(OrderOpenPrice(),mI_digits) ;
			tradePrice = NormalizeDouble(Ask + PendingDistancePrice,mI_digits) ;//重新计算交易价
			if ( tradePrice>=dOrderOpenPrice )   break;
			子_do_20 = NormalizeDouble(tradePrice - StopLoss * Point(),mI_digits) ;//重新计算止损
			子_do_21 = NormalizeDouble(TakeProfit * Point() + tradePrice,mI_digits) ;//重新计算止盈
			dStopLoss = 子_do_20 ;
			if ( !(UseStopLoss) )
			{
				dStopLoss = 0.0 ;
			}
			dTakeProfit = 子_do_21 ;
			if ( !(UseTakeProfit) )
			{
				dTakeProfit = 0.0 ;
			}
			if ( OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() )
			{
				子_bo_15 = OrderModify(OrderTicket(),tradePrice,dStopLoss,dTakeProfit,0,Blue) ;//重新修改挂单
			}
			if ( 子_bo_15 )   break;
			iLastError = GetLastError() ;
			strErrorDescription = ErrorDescription(iLastError) ;
			Print("BUYSTOP Modify Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
			break;
		case OP_SELLSTOP:
			dOrderOpenPrice = NormalizeDouble(OrderOpenPrice(),mI_digits) ;
			tradePrice = NormalizeDouble(Bid - PendingDistancePrice,mI_digits) ;
			if (tradePrice<=dOrderOpenPrice)   break;
			子_do_20 = NormalizeDouble(StopLoss * Point() + tradePrice,mI_digits) ;
			子_do_21 = NormalizeDouble(tradePrice - TakeProfit * Point(),mI_digits) ;
			dStopLoss = 子_do_20 ;
			if ( !(UseStopLoss) )
			{
				dStopLoss = 0.0 ;
			}
			dTakeProfit = 子_do_21 ;
			if ( !(UseTakeProfit) )
			{
				dTakeProfit = 0.0 ;
			}
			if ( OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() )
			{
				子_bo_15 = OrderModify(OrderTicket(),tradePrice,dStopLoss,dTakeProfit,0,Red) ;
			}
			if ( 子_bo_15 )   break;
			iLastError = GetLastError() ;
			strErrorDescription = ErrorDescription(iLastError) ;
			Print("SELLSTOP Modify Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
			break;
		case OP_SELLLIMIT:
			dOrderOpenPrice = NormalizeDouble(OrderOpenPrice(),mI_digits) ;
			tradePrice = NormalizeDouble(Bid + PendingDistancePrice,mI_digits) ;
			if ( !(tradePrice<dOrderOpenPrice) )   break;
			子_do_20 = NormalizeDouble(StopLoss * Point() + tradePrice,mI_digits) ;
			子_do_21 = NormalizeDouble(tradePrice - TakeProfit * Point(),mI_digits) ;
			dStopLoss = 子_do_20 ;
			if ( !(UseStopLoss) )
				{
				dStopLoss = 0.0 ;
				}
			dTakeProfit = 子_do_21 ;
			if ( !(UseTakeProfit) )
				{
				dTakeProfit = 0.0 ;
				}
			if ( OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() )
				{
				子_bo_15 = OrderModify(OrderTicket(),tradePrice,dStopLoss,dTakeProfit,0,Red) ;
				}
			if ( 子_bo_15 )   break;
			iLastError = GetLastError() ;
			strErrorDescription = ErrorDescription(iLastError) ;
			Print("BUYLIMIT Modify Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
				break;
		case OP_BUYLIMIT:
			dOrderOpenPrice = NormalizeDouble(OrderOpenPrice(),mI_digits) ;
			tradePrice = NormalizeDouble(Ask - PendingDistancePrice,mI_digits) ;
			if ( !(tradePrice>dOrderOpenPrice) )   break;
			子_do_20 = NormalizeDouble(tradePrice - StopLoss * Point(),mI_digits) ;
			子_do_21 = NormalizeDouble(TakeProfit * Point() + tradePrice,mI_digits) ;
			dStopLoss = 子_do_20 ;
			if ( !(UseStopLoss) )
				{
				dStopLoss = 0.0 ;
				}
			dTakeProfit = 子_do_21 ;
			if ( !(UseTakeProfit) )
				{
				dTakeProfit = 0.0 ;
				}
			if ( OrderMagicNumber() == MagicNumber && OrderSymbol() == Symbol() )
				{
				子_bo_15 = OrderModify(OrderTicket(),tradePrice,dStopLoss,dTakeProfit,0,Blue) ;
				}
			if ( 子_bo_15 )   break;
			iLastError = GetLastError() ;
			strErrorDescription = ErrorDescription(iLastError) ;
			Print("SELLLIMIT Modify Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
		}
	}
	
	//关闭所有买单或者卖单
	if ( CountTradesBuy() == 0 )
	{
		boDoCloseBuyOrd = false ;
	}
	if ( CountTradesSell() == 0 )
	{
		boDoCloseSellOrd = false ;
	}
	TotalProfitbuy(); 
	TotalProfitsell(); 
	ChartComment(); 
	if ( ( ( 总_do_56>0.0 && dTotalProfitBuy>=总_do_56 ) || ( -(总_do_58)<0.0 && dTotalProfitBuy<= -(总_do_58)) ) )
	{
		boDoCloseBuyOrd = true ;
	}
	if ( boDoCloseBuyOrd )
	{
		OpenBuyOrdClose ( ); 
	}
	if ( ( ( 总_do_57>0.0 && dTotalProfitSell>=总_do_57 ) || ( -(总_do_59)<0.0 && dTotalProfitSell<= -(总_do_59)) ) )
	{
		boDoCloseSellOrd = true ;
	}
	if ( boDoCloseSellOrd )
	{
		OpenSellOrdClose ( ); 
	}
	
	//是否使用动态止损
	if ( UseTrailing )
	{
		MoveTrailingStop(); 
	}
	
	//设置每周的某个工作日不交易
	if ( !(TradeMonday) && DayOfWeek() == 1 )
	{
		return(0); 
	}
	if ( !(TradeTuesday) && DayOfWeek() == 2 )
	{
		return(0); 
	}
	if ( !(TradeWednesday) && DayOfWeek() == 3 )
	{
		return(0); 
	}
	if ( !(TradeThursday) && DayOfWeek() == 4 )
	{
		return(0); 
	}
	if ( !(TradeFriday) && DayOfWeek() == 5 )
	{
		return(0); 
	}
	
	//当前仓位已经达到上限，不再下单
	switch(TradingMode)
	{
	case PendingLimitOrderFollowTrend :
	case PendingStopOrderFollowTrend :
		if ( Bid<dPriceOfLowFibo && CountTradesSell () >= iMaxSellOrder )
		{
			return(0); 
		}
		if ( Bid>dPriceOfHighFibo && CountTradesBuy () >= iMaxBuyOrder )
		{
			return(0); 
		}
		break;
	case PendingLimitOrderReversalTrend :
	case PendingStopOrderReversalTrend :
		if ( Bid>dPriceOfHighFibo && CountTradesSell () >= iMaxSellOrder )
		{
			return(0); 
		}
		if ( Bid<dPriceOfLowFibo && CountTradesBuy () >= iMaxBuyOrder )
		{
			return(0); 
		}
		break;
	}
	
	switch(TradingMode)
	{
	case PendingLimitOrderFollowTrend :
		if ( 挂单数量 != 0 || eCurrentTrend == Ambiguoustend || !(子_do_50<=总_do_36) || !(isTradeTime ( )) )   break;
		basicVolume = AccountBalance() * AccountLeverage() * 交易比例 / MarketInfo(Symbol(),15) ;
		if ( !(UseMM) )
		{
		basicVolume = FixedLots ;
		}
		buyVolume = NormalizeDouble(basicVolume * MathPow(LotsBase,CountTradesBuy ( )),mI_digits) ;
		buyVolume = MathMax(theTradeUnit,buyVolume) ;
		buyVolume = MathMin(theMaxTradeNum,buyVolume) ;
		sellVolume = NormalizeDouble(basicVolume * MathPow(LotsBase,CountTradesSell ( )),mI_digits) ;
		sellVolume = MathMax(theTradeUnit,sellVolume) ;
		sellVolume = MathMin(theMaxTradeNum,sellVolume) ;
		if ( eCurrentTrend ==  Downtrend )
		{
		   tradePrice = NormalizeDouble(Ask - PendingDistancePrice,mI_digits) ;
		   子_do_20 = NormalizeDouble(tradePrice - StopLoss * Point(),mI_digits) ;
		   子_do_21 = NormalizeDouble(TakeProfit * Point() + tradePrice,mI_digits) ;
		   dStopLoss = 子_do_20 ;
		   if ( !(UseStopLoss) )
		   {
		      dStopLoss = 0.0 ;
		   }
		   dTakeProfit = 子_do_21 ;
		   if ( !(UseTakeProfit) )
		   {
		      dTakeProfit = 0.0 ;
		   }
		   iTktOfNewOrder = OrderSend(Symbol(),OP_BUYLIMIT,buyVolume,tradePrice,Slippage,dStopLoss,dTakeProfit,TradeComment,MagicNumber,0,Blue) ;
		   if ( iTktOfNewOrder > 0 )   break;
		   iLastError = GetLastError() ;
		   strErrorDescription = ErrorDescription(iLastError) ;
		   Print("BUYLIMIT Send Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " LT: " + DoubleToString(buyVolume,mI_digits) + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
		   break;
		}else{
				tradePrice = NormalizeDouble(Bid + PendingDistancePrice,mI_digits) ;
		   子_do_20 = NormalizeDouble(StopLoss * Point() + tradePrice,mI_digits) ;
		   子_do_21 = NormalizeDouble(tradePrice - TakeProfit * Point(),mI_digits) ;
		   dStopLoss = 子_do_20 ;
		   if ( !(UseStopLoss) )
		   {
		      dStopLoss = 0.0 ;
		   }
		   dTakeProfit = 子_do_21 ;
		   if ( !(UseTakeProfit) )
		   {
		      dTakeProfit = 0.0 ;
		   }
		   iTktOfNewOrder = OrderSend(Symbol(),OP_SELLLIMIT,sellVolume,tradePrice,Slippage,dStopLoss,dTakeProfit,TradeComment,MagicNumber,0,Red) ;
		   if ( iTktOfNewOrder > 0 )   break;
		   iLastError = GetLastError() ;
		   strErrorDescription = ErrorDescription(iLastError) ;
		   Print("SELLLIMIT Send Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " LT: " + DoubleToString(sellVolume,mI_digits) + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
		   break;
		}

	case PendingLimitOrderReversalTrend :
		if ( 挂单数量 != 0 || eCurrentTrend == Ambiguoustend || !(子_do_50<=总_do_36) || !(isTradeTime ( )) )   break;
		basicVolume = AccountBalance() * AccountLeverage() * 交易比例 / MarketInfo(Symbol(),15) ;
		if ( !(UseMM) )
		{
		   basicVolume = FixedLots ;
		}
		buyVolume = NormalizeDouble(basicVolume * MathPow(LotsBase,CountTradesBuy ( )),mI_digits) ;
		buyVolume = MathMax(theTradeUnit,buyVolume) ;
		buyVolume = MathMin(theMaxTradeNum,buyVolume) ;
		sellVolume = NormalizeDouble(basicVolume * MathPow(LotsBase,CountTradesSell ( )),mI_digits) ;
		sellVolume = MathMax(theTradeUnit,sellVolume) ;
		sellVolume = MathMin(theMaxTradeNum,sellVolume) ;
		if ( eCurrentTrend ==  Downtrend )
		{
		   tradePrice = NormalizeDouble(Bid + PendingDistancePrice,mI_digits) ;
		   子_do_20 = NormalizeDouble(StopLoss * Point() + tradePrice,mI_digits) ;
		   子_do_21 = NormalizeDouble(tradePrice - TakeProfit * Point(),mI_digits) ;
		   dStopLoss = 子_do_20 ;
		   if ( !(UseStopLoss) )
		   {
		      dStopLoss = 0.0 ;
		   }
		   dTakeProfit = 子_do_21 ;
		   if ( !(UseTakeProfit) )
		   {
		      dTakeProfit = 0.0 ;
		   }
		   iTktOfNewOrder = OrderSend(Symbol(),OP_SELLLIMIT,sellVolume,tradePrice,Slippage,dStopLoss,dTakeProfit,TradeComment,MagicNumber,0,Red) ;
		   if ( iTktOfNewOrder > 0 )   break;
		   iLastError = GetLastError() ;
		   strErrorDescription = ErrorDescription(iLastError) ;
		   Print("SELLLIMIT Send Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " LT: " + DoubleToString(sellVolume,mI_digits) + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
		   break;
		}else{
			tradePrice = NormalizeDouble(Ask - PendingDistancePrice,mI_digits) ;
		   子_do_20 = NormalizeDouble(tradePrice - StopLoss * Point(),mI_digits) ;
		   子_do_21 = NormalizeDouble(TakeProfit * Point() + tradePrice,mI_digits) ;
		   dStopLoss = 子_do_20 ;
		   if ( !(UseStopLoss) )
		   {
		      dStopLoss = 0.0 ;
		   }
		   dTakeProfit = 子_do_21 ;
		   if ( !(UseTakeProfit) )
		   {
		      dTakeProfit = 0.0 ;
		   }
		   iTktOfNewOrder = OrderSend(Symbol(),OP_BUYLIMIT,buyVolume,tradePrice,Slippage,dStopLoss,dTakeProfit,TradeComment,MagicNumber,0,Blue) ;
		   if ( iTktOfNewOrder > 0 )   break;
		   iLastError = GetLastError() ;
		   strErrorDescription = ErrorDescription(iLastError) ;
		   Print("BUYLIMIT Send Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " LT: " + DoubleToString(buyVolume,mI_digits) + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
		   break;
		}
	case PendingStopOrderFollowTrend :
		if ( 挂单数量 != 0 || eCurrentTrend == Ambiguoustend || !(子_do_50<=总_do_36) || !(isTradeTime ( )) )   break;
		basicVolume = AccountBalance() * AccountLeverage() * 交易比例 / MarketInfo(Symbol(),15) ;
		if ( !(UseMM) )
		{
		   basicVolume = FixedLots ;
		}
		buyVolume = NormalizeDouble(basicVolume * MathPow(LotsBase,CountTradesBuy ( )),mI_digits) ;
		buyVolume = MathMax(theTradeUnit,buyVolume) ;
		buyVolume = MathMin(theMaxTradeNum,buyVolume) ;
		sellVolume = NormalizeDouble(basicVolume * MathPow(LotsBase,CountTradesSell ( )),mI_digits) ;
		sellVolume = MathMax(theTradeUnit,sellVolume) ;
		sellVolume = MathMin(theMaxTradeNum,sellVolume) ;
		if ( eCurrentTrend ==  Downtrend )
		{
		   tradePrice = NormalizeDouble(Ask + PendingDistancePrice,mI_digits) ;
		   子_do_20 = NormalizeDouble(tradePrice - StopLoss * Point(),mI_digits) ;
		   子_do_21 = NormalizeDouble(TakeProfit * Point() + tradePrice,mI_digits) ;
		   dStopLoss = 子_do_20 ;
		   if ( !(UseStopLoss) )
		   {
		      dStopLoss = 0.0 ;
		   }
		   dTakeProfit = 子_do_21 ;
		   if ( !(UseTakeProfit) )
		   {
		      dTakeProfit = 0.0 ;
		   }
		   iTktOfNewOrder = OrderSend(Symbol(),OP_BUYSTOP,buyVolume,tradePrice,Slippage,dStopLoss,dTakeProfit,TradeComment,MagicNumber,0,Blue) ;
		   if ( iTktOfNewOrder > 0 )   break;
		   iLastError = GetLastError() ;
		   strErrorDescription = ErrorDescription(iLastError) ;
		   Print("BUYSTOP Send Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " LT: " + DoubleToString(buyVolume,mI_digits) + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
		   break;
		}else{
		   tradePrice = NormalizeDouble(Bid - PendingDistancePrice,mI_digits) ;
		   子_do_20 = NormalizeDouble(StopLoss * Point() + tradePrice,mI_digits) ;
		   子_do_21 = NormalizeDouble(tradePrice - TakeProfit * Point(),mI_digits) ;
		   dStopLoss = 子_do_20 ;
		   if ( !(UseStopLoss) )
		   {
		      dStopLoss = 0.0 ;
		   }
		   dTakeProfit = 子_do_21 ;
		   if ( !(UseTakeProfit) )
		   {
		      dTakeProfit = 0.0 ;
		   }
		   iTktOfNewOrder = OrderSend(Symbol(),OP_SELLSTOP,sellVolume,tradePrice,Slippage,dStopLoss,dTakeProfit,TradeComment,MagicNumber,0,Red) ;
		   if ( iTktOfNewOrder > 0 )   break;
		   iLastError = GetLastError() ;
		   strErrorDescription = ErrorDescription(iLastError) ;
		   Print("SELLSTOP Send Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " LT: " + DoubleToString(sellVolume,mI_digits) + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
		   break;
		}
	case PendingStopOrderReversalTrend :
		if ( 挂单数量 != 0 || eCurrentTrend == Ambiguoustend || !(子_do_50<=总_do_36) || !(isTradeTime ()) )   break;
		basicVolume = AccountBalance() * AccountLeverage() * 交易比例 / MarketInfo(Symbol(),MODE_LOTSIZE) ;
		if ( !(UseMM) )
		{
			basicVolume = FixedLots;
		}
		buyVolume = NormalizeDouble(basicVolume * MathPow(LotsBase,CountTradesBuy()),mI_digits);
		buyVolume = MathMax(theTradeUnit,buyVolume) ;
		buyVolume = MathMin(theMaxTradeNum,buyVolume) ;
		sellVolume = NormalizeDouble(basicVolume * MathPow(LotsBase,CountTradesSell()),mI_digits) ;
		sellVolume = MathMax(theTradeUnit,sellVolume) ;
		sellVolume = MathMin(theMaxTradeNum,sellVolume) ;
		if ( eCurrentTrend == Downtrend )
		{//止损挂单卖单
			tradePrice = NormalizeDouble(Bid - PendingDistancePrice,mI_digits) ;
			子_do_20 = NormalizeDouble(StopLoss * Point() + tradePrice,mI_digits) ;
			子_do_21 = NormalizeDouble(tradePrice - TakeProfit * Point(),mI_digits) ;
			dStopLoss = 子_do_20 ;
			if ( !(UseStopLoss) )
			{
				dStopLoss = 0.0 ;
			}
			dTakeProfit = 子_do_21 ;
			if ( !(UseTakeProfit) )
			{
				dTakeProfit = 0.0 ;
			}
			iTktOfNewOrder = OrderSend(Symbol(),OP_SELLSTOP,sellVolume,tradePrice,Slippage,dStopLoss,dTakeProfit,TradeComment,MagicNumber,0,Red) ;
			if ( iTktOfNewOrder < 0 )
			{
				iLastError = GetLastError() ;
				strErrorDescription = ErrorDescription(iLastError) ;
				Print("SELLSTOP Send Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " LT: " + DoubleToString(sellVolume,mI_digits) + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
			}
		}else{//止损挂单买单
			tradePrice = NormalizeDouble(Ask + PendingDistancePrice,mI_digits) ;
			子_do_20 = NormalizeDouble(tradePrice - StopLoss * Point(),mI_digits) ;
			子_do_21 = NormalizeDouble(TakeProfit * Point() + tradePrice,mI_digits) ;
			dStopLoss = 子_do_20 ;
			if ( !(UseStopLoss) )
			{
				dStopLoss = 0.0 ;
			}
			dTakeProfit = 子_do_21 ;
			if ( !(UseTakeProfit) )
			{
				dTakeProfit = 0.0 ;
			}
			iTktOfNewOrder = OrderSend(Symbol(),OP_BUYSTOP,buyVolume,tradePrice,Slippage,dStopLoss,dTakeProfit,TradeComment,MagicNumber,0,Blue) ;
			if ( iTktOfNewOrder < 0 )
			{
				iLastError = GetLastError() ;
				strErrorDescription = ErrorDescription(iLastError) ;
				Print("BUYSTOP Send Error Code: " + string(iLastError) + " Message: " + strErrorDescription + " LT: " + DoubleToString(buyVolume,mI_digits) + " OP: " + DoubleToString(tradePrice,mI_digits) + " SL: " + DoubleToString(dStopLoss,mI_digits) + " TP: " + DoubleToString(dTakeProfit,mI_digits) + " Bid: " + DoubleToString(Bid,mI_digits) + " Ask: " + DoubleToString(Ask,mI_digits)); 
			}
		}
	}
	子_st_54 = "AvgSpread:" + DoubleToString(averageSpread,mI_digits) + "  Commission rate:" + DoubleToString(dCommissionRate,mI_digits + 1) + "  Real avg. spread:" + DoubleToString(子_do_50,mI_digits + 1) ;
	if ( 子_do_50>总_do_36 )
	{
		子_st_54 = 子_st_54 + "\n" + "The EA can not run with this spread ( " + DoubleToString(子_do_50,mI_digits + 1) + " > " + DoubleToString(总_do_36,mI_digits + 1) + " )" ;
	}
	return(0);
}
//start <<==
//---------- ----------  ---------- ----------
int deinit()
{
	Comment(""); 
	DeleteAllObjects ( ); 
	return(0); 
}
//deinit <<==
//---------- ----------  ---------- ----------
int isTradeTime()
{
	if ( ( ( Hour() > StartHour && Hour() < EndHour ) || ( Hour() == StartHour && Minute() >= StartMinute ) || (Hour() == EndHour && Minute() <  EndMinute) ) )
	{
		return(1); 
	}
	return(0); 
}
//isTradeTime <<==
//---------- ----------  ---------- ----------
//移动止损
void MoveTrailingStop()
{
	int       i;
	//----- -----

	for (i = 0 ; i < OrdersTotal() ; i = i + 1)
	{
		if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) || OrderType() > 1 || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber )   continue;

		if ( OrderType() == 0 )
		{
			if ( TrailingStop <= 0 || !(NormalizeDouble(Ask - TrailingStart * Point(),Digits())>NormalizeDouble(TrailingStop * Point() + OrderOpenPrice(),Digits())) )   continue;

			if ( ( !(NormalizeDouble(OrderStopLoss(),Digits())<NormalizeDouble(Bid - TrailingStop * Point(),Digits())) && !(OrderStopLoss()==0.0) ) || !(OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(Bid - TrailingStop * Point(),Digits()),OrderTakeProfit(),0,Blue)) || GetLastError() != 0 )   continue;
			Print(Symbol() + ": Trailing Buy OrderModify ok "); 
			continue;
		}
		if ( TrailingStop <= 0 || !(NormalizeDouble(TrailingStart * Point() + Bid,Digits())<NormalizeDouble(OrderOpenPrice() - TrailingStop * Point(),Digits())) )   continue;

		if ( ( !(NormalizeDouble(OrderStopLoss(),Digits())>NormalizeDouble(TrailingStop * Point() + Ask,Digits())) && !(OrderStopLoss()==0.0) ) || !(OrderModify(OrderTicket(),OrderOpenPrice(),NormalizeDouble(TrailingStop * Point() + Ask,Digits()),OrderTakeProfit(),0,Red)) || GetLastError() != 0 )   continue;
		Print(Symbol() + ": Trailing Sell OrderModify ok "); 
	}
}
//MoveTrailingStop <<==
//---------- ----------  ---------- ----------
//统计开单数量
int ScanOpenTrades()
{
	int       i;
	int       NumOfOpenTrade;
	int       j;
	//----- -----

	i = OrdersTotal() ;
	NumOfOpenTrade = 0 ;
	for (j = 0 ; j <= i - 1 ; j = j + 1)
	{
		if ( !(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)) || OrderType() > 1 )   continue;

		if ( 总_in_23 > 0 && OrderMagicNumber() == 总_in_23 )
		{
			NumOfOpenTrade = NumOfOpenTrade + 1;
		}
		if ( 总_in_23 != 0 )   continue;
		NumOfOpenTrade = NumOfOpenTrade + 1;
	}
	return(NumOfOpenTrade); 
}
//ScanOpenTrades <<==
//---------- ----------  ---------- ----------
//统计开单中货币对的数量
int ScanOpenTradessymbol()
{
	int       i;
	int       NumOfOpenTradeSymbol;
	int       j;
	//----- -----

	i = OrdersTotal() ;
	NumOfOpenTradeSymbol = 0 ;
	for (j = 0 ; j <= i - 1 ; j = j + 1)
	{
		if ( !(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)) || OrderType() > 1 )   continue;

		if ( OrderSymbol() == Symbol() && 总_in_23 > 0 && OrderMagicNumber() == 总_in_23 )
		{
			NumOfOpenTradeSymbol = NumOfOpenTradeSymbol + 1;
		}
		if ( OrderSymbol() != Symbol() || 总_in_23 != 0 )   continue;
		NumOfOpenTradeSymbol = NumOfOpenTradeSymbol + 1;
	}
	return(NumOfOpenTradeSymbol); 
}
//ScanOpenTradessymbol <<==
//---------- ----------  ---------- ----------
//平仓所有Open的买单，包括挂单
void OpenBuyOrdClose()
{
	int       totalorder;
	int       i;
	int       ot;
	bool      boRet;
	bool      boIsOrderOfCurrentEA;

	boIsOrderOfCurrentEA = false ;
	totalorder = OrdersTotal() ;
	for (i = 0 ; i < totalorder ; i = i + 1)
	{
		if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) )   continue;
		ot = OrderType() ;
		boRet = false ;
		boIsOrderOfCurrentEA = false ;
		if ( OrderSymbol() == Symbol() && MagicNumber > 0 && OrderMagicNumber() == MagicNumber )
		{
			boIsOrderOfCurrentEA = true ;
		}
		else
		{
			if ( OrderSymbol() == Symbol() && MagicNumber == 0 )
			{
				boIsOrderOfCurrentEA = true ;
			}
		}
		if ( !(boIsOrderOfCurrentEA) )   continue;
		switch(ot)
		{
			case OP_BUY :
				boRet = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),Slippage,Blue) ;
				break;
			case OP_BUYLIMIT :
				if ( !(OrderDelete(OrderTicket(),0xFFFFFFFF)) )   break;
			case OP_BUYSTOP :
				if ( !(OrderDelete(OrderTicket(),0xFFFFFFFF)) )   break;
			default :
				if ( boRet )   break;
				Print(" OrderClose failed with error #",GetLastError()); 
				Sleep(3000); 
		}
	}
}
//OpenBuyOrdClose <<==
//---------- ----------  ---------- ----------
//平仓所有卖单，包括挂单
void OpenSellOrdClose()
{
	int       numOfOrder;
	int       i;
	int       ot;
	bool      boRet;
	bool      boIsTargetOrder;
	//----- -----

	boIsTargetOrder = false ;
	numOfOrder = OrdersTotal() ;
	for (i = 0 ; i < numOfOrder ; i = i + 1)
	{
		if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) )continue;
		ot = OrderType() ;
		boRet = false ;
		boIsTargetOrder = false ;
		if ( OrderSymbol() == Symbol() && MagicNumber > 0 && OrderMagicNumber() == MagicNumber )
		{
			boIsTargetOrder = true ;
		}
		else
		{
		if ( OrderSymbol() == Symbol() && MagicNumber == 0 )
		{
			   boIsTargetOrder = true ;
		   }
		}
		if ( !(boIsTargetOrder) )   continue;
		switch(ot)
		{
			case OP_SELL :
			   boRet = OrderClose(OrderTicket(),OrderLots(),MarketInfo(OrderSymbol(),10),Slippage,Red) ;
			   break;
			case OP_SELLLIMIT :
			   if ( !(OrderDelete(OrderTicket(),0xFFFFFFFF)) )   break;
			case OP_SELLSTOP :
			   if ( !(OrderDelete(OrderTicket(),0xFFFFFFFF)) )   break;
			default :
			   if ( boRet )   break;
			   Print(" OrderClose failed with error #",GetLastError()); 
			   Sleep(3000); 
		}
	}
}
//OpenSellOrdClose <<==
//---------- ----------  ---------- ----------
//统计所有买单的利润
void TotalProfitbuy()
{
	int       numOfOrder;
	int       i;
	int       ot;
	bool      boIsTargetOrder;
	//----- -----

	numOfOrder = OrdersTotal() ;
	dTotalProfitBuy = 0.0 ;
	for (i = 0 ; i < numOfOrder ; i = i + 1)
	{
		if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) )   continue;
		ot = OrderType() ;
		boIsTargetOrder = false ;
		if ( OrderSymbol() == Symbol() && MagicNumber > 0 && OrderMagicNumber() == MagicNumber )
		{
			boIsTargetOrder = true ;
		}
		else
		{
			if ( OrderSymbol() == Symbol() && MagicNumber == 0 )
			{
			   boIsTargetOrder = true ;
			}
		}
		if ( !(boIsTargetOrder) || ot != OP_BUY )   continue;
		dTotalProfitBuy = OrderProfit() + OrderCommission() + OrderSwap() + dTotalProfitBuy ;
	}
}
//TotalProfitbuy <<==
//---------- ----------  ---------- ----------
//统计所有卖单的利润
void TotalProfitsell()
{
	int       numOfOrder;
	int       i;
	int       ot;
	bool      boIsTargetOrder;
	//----- -----

	numOfOrder = OrdersTotal() ;
	dTotalProfitSell = 0.0 ;
	for (i = 0 ; i < numOfOrder ; i = i + 1)
	{
		if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) )   continue;
		ot = OrderType() ;
		boIsTargetOrder = false ;
		if ( OrderSymbol() == Symbol() && MagicNumber > 0 && OrderMagicNumber() == MagicNumber )
		{
			boIsTargetOrder = true ;
		}
		else
		{
			if ( OrderSymbol() == Symbol() && MagicNumber == 0 )
			{
				boIsTargetOrder = true ;
			}
		}
		if ( !(boIsTargetOrder) || ot != OP_SELL )   continue;
		dTotalProfitSell = OrderProfit() + OrderCommission() + OrderSwap() + dTotalProfitSell ;
	}
}
//TotalProfitsell <<==
//---------- ----------  ---------- ----------
void ChartComment()
{
	string    子_st_1;
	string    子_st_2;
	string    子_st_3;
	//----- -----

	子_st_1 = "" ;
	子_st_2 = "----------------------------------------\n" ;
	子_st_3 = "\n" ;
	子_st_1 = "----------------------------------------\n" ;
	子_st_1 = "----------------------------------------\nName = " + AccountName() + "\n" ;
	子_st_1 = 子_st_1 + "Broker" + " " + "=" + " " + AccountCompany() + "\n" ;
	子_st_1 = 子_st_1 + "Account Leverage" + " " + "=" + " " + "1:" + DoubleToString(AccountLeverage(),0) + "\n" ;
	子_st_1 = 子_st_1 + "Account Balance" + " " + "=" + " " + DoubleToString(AccountBalance(),2) + "\n" ;
	子_st_1 = 子_st_1 + "Account Equity" + " " + "=" + " " + DoubleToString(AccountEquity(),2) + "\n" ;
	子_st_1 = 子_st_1 + "Day Profit" + " " + "=" + " " + DoubleToString(AccountBalance() - startBalanceD1 ( ),2) + 子_st_3 ;
	子_st_1 = 子_st_1 + 子_st_2;
	子_st_1 = 子_st_1 + "Open ALL Positions = " + string(ScanOpenTrades ( )) + 子_st_3 ;
	子_st_1 = 子_st_1 + Symbol() + " ALL Order = " + string(ScanOpenTradessymbol ( )) + 子_st_3 ;
	子_st_1 = 子_st_1 + "Open Buy  = " + string(CountTradesBuy ( )) + 子_st_3 ;
	子_st_1 = 子_st_1 + "Open Sell = " + string(CountTradesSell ( )) + 子_st_3 ;
	子_st_1 = 子_st_1 + 子_st_2;
	子_st_1 = 子_st_1 + "Target Money Buy = " + DoubleToString(总_do_56,2) + 子_st_3 ;
	子_st_1 = 子_st_1 + "Stoploss Money Buy = " + DoubleToString( -(总_do_58),2) + 子_st_3 ;
	子_st_1 = 子_st_1 + 子_st_2;
	子_st_1 = 子_st_1 + "Target Money Sell = " + DoubleToString(总_do_57,2) + 子_st_3 ;
	子_st_1 = 子_st_1 + "Stoploss Money Sell = " + DoubleToString( -(总_do_59),2) + 子_st_3 ;
	子_st_1 = 子_st_1 + 子_st_2;
	子_st_1 = 子_st_1 + "Buy Profit(USD) = " + DoubleToString(dTotalProfitBuy,2) + 子_st_3 ;
	子_st_1 = 子_st_1 + "Sell Profit(USD) = " + DoubleToString(dTotalProfitSell,2) + 子_st_3 ;
	子_st_1 = 子_st_1 + 子_st_2;
	Comment(子_st_1); 
}
//ChartComment <<==
//---------- ----------  ---------- ----------
//删除图标中所有附加元素
void DeleteAllObjects()
{
	int       子_in_1;
	string    strObjectName;
	int       i;
	//----- -----

	i = 0 ;
	子_in_1 = ObjectsTotal(-1) ;
	for (i = ObjectsTotal(-1) - 1 ; i >= 0 ; i = i - 1)
	{
		if ( HighToLow )
		{
			strObjectName = ObjectName(i) ;
			if ( StringFind(strObjectName,"v_u_hl",0) > -1 )
			{
				ObjectDelete(strObjectName); 
			}
			if ( StringFind(strObjectName,"v_l_hl",0) > -1 )
			{
				ObjectDelete(strObjectName); 
			}
			if ( StringFind(strObjectName,"Fibo_hl",0) > -1 )
			{
				ObjectDelete(strObjectName); 
			}
			if ( StringFind(strObjectName,"trend_hl",0) > -1 )
			{
				ObjectDelete(strObjectName); 
			}
			WindowRedraw(); 
			continue;
		}
		strObjectName = ObjectName(i) ;
		if ( StringFind(strObjectName,"v_u_lh",0) > -1 )
		{
			ObjectDelete(strObjectName); 
		}
		if ( StringFind(strObjectName,"v_l_lh",0) > -1 )
		{
			ObjectDelete(strObjectName); 
		}
		if ( StringFind(strObjectName,"Fibo_lh",0) > -1 )
		{
			ObjectDelete(strObjectName); 
		}
		if ( StringFind(strObjectName,"trend_lh",0) > -1 )
		{
			ObjectDelete(strObjectName); 
		}
		WindowRedraw(); 
	}
}
//DeleteAllObjects <<==
//---------- ----------  ---------- ----------
//计算一段时间内的Fibonacci分割点并且画在图表上
void CalcFibo()
{
	//int       子_in_1;
	//int       子_in_2;
	double    dLowest;
	double    dHighest;
	int       iIndexOfLowest;
	int       iIndexOfHighest;
	//double    子_do_7;
	//double    子_do_8;
	int       i;
	//----- -----

	iIndexOfLowest = iLowest(NULL,0,MODE_LOW,BarsBack,StartBar) ;
	iIndexOfHighest = iHighest(NULL,0,MODE_HIGH,BarsBack,StartBar) ;
	dHighest = High[iIndexOfHighest] ;
	dLowest = Low[iIndexOfLowest] ;
	if ( HighToLow )
	{
		DrawVerticalLine ( "v_u_hl",iIndexOfHighest,总_ui_9); 
		DrawVerticalLine ( "v_l_hl",iIndexOfLowest,总_ui_9); 
		if ( ObjectFind("trend_hl") == -1 )
		{
			ObjectCreate("trend_hl",OBJ_TREND,0,Time[iIndexOfHighest],dHighest,Time[iIndexOfLowest],dLowest,0,0.0); 
		}
		ObjectSet("trend_hl",OBJPROP_TIME1,Time[iIndexOfHighest]); 
		ObjectSet("trend_hl",OBJPROP_TIME2,Time[iIndexOfLowest]); 
		ObjectSet("trend_hl",OBJPROP_PRICE1,dHighest); 
		ObjectSet("trend_hl",OBJPROP_PRICE2,dLowest); 
		ObjectSet("trend_hl",OBJPROP_STYLE,2.0); 
		ObjectSet("trend_hl",OBJPROP_RAY,0.0); 
		if ( ObjectFind("Fibo_hl") == -1 )
		{
			ObjectCreate("Fibo_hl",OBJ_FIBO,0,0,dHighest,0,dLowest,0,0.0); 	
		}
		ObjectSet("Fibo_hl",OBJPROP_PRICE1,dHighest); 
		ObjectSet("Fibo_hl",OBJPROP_PRICE2,dLowest); 
		ObjectSet("Fibo_hl",OBJPROP_LEVELCOLOR,总_ui_10); 
		ObjectSet("Fibo_hl",OBJPROP_FIBOLEVELS,8.0); 
		ObjectSet("Fibo_hl",210,GoldenSectionBrkSt); 
		ObjectSetFiboDescription("Fibo_hl",0,"SWING LOW (0.0) - %$"); 
		ObjectSet("Fibo_hl",211,GoldenSectionBrk1); 
		ObjectSetFiboDescription("Fibo_hl",1,"BREAKOUT AREA (23.6) -  %$"); 
		ObjectSet("Fibo_hl",212,GoldenSectionBrk2); 
		ObjectSetFiboDescription("Fibo_hl",2,"CRITICAL AREA (38.2) -  %$"); 
		ObjectSet("Fibo_hl",213,GoldenSectionBrk3); 
		ObjectSetFiboDescription("Fibo_hl",3,"CRITICAL AREA (50.0) -  %$"); 
		ObjectSet("Fibo_hl",214,GoldenSectionBrk4); 
		ObjectSetFiboDescription("Fibo_hl",4,"CRITICAL AREA (61.8) -  %$"); 
		ObjectSet("Fibo_hl",215,GoldenSectionBrk5); 
		ObjectSetFiboDescription("Fibo_hl",5,"BREAKOUT AREA (76.4) -  %$"); 
		ObjectSet("Fibo_hl",217,GoldenSectionBrkEd); 
		ObjectSetFiboDescription("Fibo_hl",7,"SWING HIGH (100.0) - %$"); 
		ObjectSet("Fibo_hl",OBJPROP_RAY,1.0); 
		WindowRedraw(); 
		for (i = 0 ; i < 100 ; i = i + 1)
		{
			总_do17ko[i] = NormalizeDouble((dHighest - dLowest) * GoldenSectionBrkEd + dLowest,Digits());
			总_do16ko[i] = NormalizeDouble((dHighest - dLowest) * GoldenSectionBrk5 + dLowest,Digits());
			总_do15ko[i] = NormalizeDouble((dHighest - dLowest) * GoldenSectionBrk4 + dLowest,Digits());
			总_do14ko[i] = NormalizeDouble((dHighest - dLowest) * GoldenSectionBrk3 + dLowest,Digits());
			总_do13ko[i] = NormalizeDouble((dHighest - dLowest) * GoldenSectionBrk2 + dLowest,Digits());
			总_do12ko[i] = NormalizeDouble((dHighest - dLowest) * GoldenSectionBrk1 + dLowest,Digits());
			总_do11ko[i] = NormalizeDouble((dHighest - dLowest) * GoldenSectionBrkSt + dLowest,Digits());
		}
		return;
	}
	DrawVerticalLine ( "v_u_lh",iIndexOfHighest,总_ui_9); 
	DrawVerticalLine ( "v_l_lh",iIndexOfLowest,总_ui_9); 
	if ( ObjectFind("trend_hl") == -1 )
	{
		ObjectCreate("trend_lh",OBJ_TREND,0,Time[iIndexOfLowest],dLowest,Time[iIndexOfHighest],dHighest,0,0.0); 
	}
	ObjectSet("trend_lh",OBJPROP_TIME1,Time[iIndexOfLowest]); 
	ObjectSet("trend_lh",OBJPROP_TIME2,Time[iIndexOfHighest]); 
	ObjectSet("trend_lh",OBJPROP_PRICE1,dLowest); 
	ObjectSet("trend_lh",OBJPROP_PRICE2,dHighest); 
	ObjectSet("trend_lh",OBJPROP_STYLE,2.0); 
	ObjectSet("trend_lh",OBJPROP_RAY,0.0); 
	if ( ObjectFind("Fibo_lh") == -1 )
	{
		ObjectCreate("Fibo_lh",OBJ_FIBO,0,0,dLowest,0,dHighest,0,0.0); 
	}
	ObjectSet("Fibo_lh",OBJPROP_PRICE1,dLowest); 
	ObjectSet("Fibo_lh",OBJPROP_PRICE2,dHighest); 
	ObjectSet("Fibo_lh",OBJPROP_LEVELCOLOR,总_ui_10); 
	ObjectSet("Fibo_lh",OBJPROP_FIBOLEVELS,8.0); 
	ObjectSet("Fibo_lh",210,GoldenSectionBrkSt); 
	ObjectSetFiboDescription("Fibo_lh",0,"SWING LOW (0.0) - %$"); 
	ObjectSet("Fibo_lh",211,GoldenSectionBrk1); 
	ObjectSetFiboDescription("Fibo_lh",1,"BREAKOUT AREA (23.6) -  %$"); 
	ObjectSet("Fibo_lh",212,GoldenSectionBrk2); 
	ObjectSetFiboDescription("Fibo_lh",2,"CRITICAL AREA (38.2) -  %$"); 
	ObjectSet("Fibo_lh",213,GoldenSectionBrk3); 
	ObjectSetFiboDescription("Fibo_lh",3,"CRITICAL AREA (50.0) -  %$"); 
	ObjectSet("Fibo_lh",214,GoldenSectionBrk4); 
	ObjectSetFiboDescription("Fibo_lh",4,"CRITICAL AREA (61.8) -  %$"); 
	ObjectSet("Fibo_lh",215,GoldenSectionBrk5); 
	ObjectSetFiboDescription("Fibo_lh",5,"BREAKOUT AREA (76.4) -  %$"); 
	ObjectSet("Fibo_lh",217,GoldenSectionBrkEd); 
	ObjectSetFiboDescription("Fibo_lh",7,"SWING HIGH (100.0) - %$"); 
	ObjectSet("Fibo_lh",OBJPROP_RAY,1.0); 
	WindowRedraw(); 
	for (i = 0 ; i < 100 ; i = i + 1)
	{
		总_do11ko[i] = NormalizeDouble(dHighest,4);
		总_do12ko[i] = NormalizeDouble(dHighest - (dHighest - dLowest) * GoldenSectionBrk1,Digits());
		总_do13ko[i] = NormalizeDouble(dHighest - (dHighest - dLowest) * GoldenSectionBrk2,Digits());
		总_do14ko[i] = NormalizeDouble(dHighest - (dHighest - dLowest) * GoldenSectionBrk3,Digits());
		总_do15ko[i] = NormalizeDouble(dHighest - (dHighest - dLowest) * GoldenSectionBrk4,Digits());
		总_do16ko[i] = NormalizeDouble(dHighest - (dHighest - dLowest) * GoldenSectionBrk5,Digits());
		总_do17ko[i] = NormalizeDouble(dLowest,4);
	}
}
//CalcFibo <<==
//---------- ----------  ---------- ----------
//画垂直线
void DrawVerticalLine( string strObjectName,int iIndex,color cColor)
{
	if ( ObjectFind(strObjectName) == -1 )
	{
		ObjectCreate(strObjectName,OBJ_VLINE,0,Time[iIndex],0.0,0,0.0,0,0.0); 
		ObjectSet(strObjectName,OBJPROP_COLOR,cColor); 
		ObjectSet(strObjectName,OBJPROP_STYLE,1.0); 
		ObjectSet(strObjectName,OBJPROP_WIDTH,1.0); 
		WindowRedraw(); 
		return;
	}
	ObjectDelete(strObjectName); 
	ObjectCreate(strObjectName,OBJ_VLINE,0,Time[iIndex],0.0,0,0.0,0,0.0); 
	ObjectSet(strObjectName,OBJPROP_COLOR,cColor); 
	ObjectSet(strObjectName,OBJPROP_STYLE,1.0); 
	ObjectSet(strObjectName,OBJPROP_WIDTH,1.0); 
	WindowRedraw(); 
}
//DrawVerticalLine <<==
//---------- ----------  ---------- ----------
//获取最后一次买单的买入价
double FindLastBuyPrice_Hilo()
{
	double    dOrderOpenPrice;
	int       iOrderTkt;
	double    子_do_3;
	int       iMaxOrderTkt;
	//----- -----

	iOrderTkt = 0 ;
	子_do_3 = 0.0 ;
	iMaxOrderTkt = 0 ;
	for (总_in_24=OrdersTotal() - 1 ; 总_in_24 >= 0 ; 总_in_24=总_in_24 - 1)
	{
		if ( !(OrderSelect(总_in_24,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderType() != OP_BUY )   continue;
		iOrderTkt = OrderTicket() ;
		if ( iOrderTkt <= iMaxOrderTkt )   continue;
		dOrderOpenPrice = OrderOpenPrice() ;
		子_do_3 = dOrderOpenPrice ;
		iMaxOrderTkt = iOrderTkt ;
	}
	return(dOrderOpenPrice); 
}
//FindLastBuyPrice_Hilo <<==
//---------- ----------  ---------- ----------
//获取最后一次卖单的卖出价
double FindLastSellPrice_Hilo()
{
	double    dOrderOpenPrice;
	int       iOrderTkt;
	double    子_do_3;
	int       iMaxOrderTkt;
	//----- -----

	iOrderTkt = 0 ;
	子_do_3 = 0.0 ;
	iMaxOrderTkt = 0 ;
	for (总_in_24=OrdersTotal() - 1 ; 总_in_24 >= 0 ; 总_in_24=总_in_24 - 1)
	{
		if ( !(OrderSelect(总_in_24,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderType() != OP_SELL )   continue;
		iOrderTkt = OrderTicket() ;
		if ( iOrderTkt <= iMaxOrderTkt )   continue;
		dOrderOpenPrice = OrderOpenPrice() ;
		子_do_3 = dOrderOpenPrice ;
		iMaxOrderTkt = iOrderTkt ;
	}
	return(dOrderOpenPrice); 
}
//FindLastSellPrice_Hilo <<==
//---------- ----------  ---------- ----------
//统计卖单数量
int CountTradesSell()
{
	int       numOfSellOrder;
	int       i;
	//----- -----

	i = 0 ;
	numOfSellOrder = 0 ;
	for (i = OrdersTotal() - 1 ; i >= 0 ; i = i - 1)
	{
		if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderType() != OP_SELL )   continue;
		numOfSellOrder = numOfSellOrder + 1;
	}
	return(numOfSellOrder); 
}
//CountTradesSell <<==
//---------- ----------  ---------- ----------
//统计买单数量
int CountTradesBuy()
{
	int       numOfBuyOrder;
	int       i;
	//----- -----

	i = 0 ;
	numOfBuyOrder = 0 ;
	for (i = OrdersTotal() - 1 ; i >= 0 ; i = i - 1)
	{
		if ( !(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) || OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber || OrderType() != OP_BUY )   continue;
		numOfBuyOrder = numOfBuyOrder + 1;
	}
	return(numOfBuyOrder); 
}
//CountTradesBuy <<==
//---------- ----------  ---------- ----------
//获取一天前账户的结余
double startBalanceD1()
{
	double    子_do_1;
	int       numOfHistoyOrder;
	datetime  starttime;
	int       i;
	double    子_do_5;
	//----- -----
	
	numOfHistoyOrder = OrdersHistoryTotal() ;
	starttime = iTime(NULL,1440,0) ; //一天前的时间
	for (i = numOfHistoyOrder ; i >= 0 ; i = i - 1)
	{
		if ( !(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)) || OrderCloseTime() < starttime )   continue;
		子_do_1 = OrderProfit() + OrderCommission() + OrderSwap() + 子_do_1 ;
	}
	子_do_5 = NormalizeDouble(AccountBalance() - 子_do_1,2) ;
	return(子_do_5); 
}
//startBalanceD1 <<==
//---------- ----------  ---------- ----------
