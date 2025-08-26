//+------------------------------------------------------------------+
//|                                                   SuperSlope.mq5 |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
// Reviewed and used calculations from Baluda Super Slope code.
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.0"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1

// Plot properties - Single line plot (instead of histogram)
#property indicator_label1  "Slope"
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_color1  clrDodgerBlue

// Level lines
#property indicator_level1  0.0

#include <CSuperSlope.mqh> // do not change as this is for live environment
//--- Input Parameters
input group "General Settings"
input int           InpMaxBars = 500;            // Max bars to calculate (0 = all)

input group "Slope Parameters"
input int           InpSlopeMAPeriod = 7;         // Slope MA period
input int           InpSlopeATRPeriod = 50;       // Slope ATR period

//--- Indicator buffers
double              SlopeBuffer[];

//--- Global variables for class instance
CSuperSlope ExtIndicator;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   // Set up single indicator buffer for line display
   SetIndexBuffer(0, SlopeBuffer, INDICATOR_DATA);
   
   // DON'T set array as time series - let MQL5 handle it normally
   // ArraySetAsSeries(SlopeBuffer, true);
   
   // Initialize the indicator
   return ExtIndicator.OnInit();
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // Call the class method and pass the single buffer along with max bars setting
   int result = ExtIndicator.OnCalculate(rates_total, prev_calculated, time, 
          open, high, low, close, tick_volume, volume, spread,
          SlopeBuffer, InpMaxBars);
   
   return result;
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // The ExtIndicator object will be automatically destroyed
}
