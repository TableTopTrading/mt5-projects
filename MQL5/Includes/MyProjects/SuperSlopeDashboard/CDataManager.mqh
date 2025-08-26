//+------------------------------------------------------------------+
//|                                                    CDataManager.mqh |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+

//--- Include required files
#include <Trade/Trade.mqh>
#include <MovingAverages.mqh>

//+------------------------------------------------------------------+
//| Class for managing data calculations in SuperSlopeDashboard        |
//+------------------------------------------------------------------+
class CDataManager
{
private:
   int               m_ma_period;     // Moving Average period
   int               m_atr_period;    // ATR period
   int               m_max_bars;      // Maximum bars to calculate
   double            m_ma_buffer[];   // Buffer for MA values
   double            m_atr_buffer[];  // Buffer for ATR values

public:
   //--- Constructor and destructor
                     CDataManager(void);
                    ~CDataManager(void);
   
   //--- Initialization and deinitialization
   bool              Initialize(int ma_period, int atr_period, int max_bars);
   void              Deinitialize(void);
   
   //--- Main calculation method
   double            CalculateStrengthValue(string symbol);
   
   //--- Getters
   int               GetMAPeriod(void) const { return m_ma_period; }
   int               GetATRPeriod(void) const { return m_atr_period; }
   int               GetMaxBars(void) const { return m_max_bars; }
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CDataManager::CDataManager(void)
{
   m_ma_period = 7;    // default values from SuperSlope
   m_atr_period = 50;
   m_max_bars = 500;
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CDataManager::~CDataManager(void)
{
   Deinitialize();
}

//+------------------------------------------------------------------+
//| Initialize the data manager                                        |
//+------------------------------------------------------------------+
bool CDataManager::Initialize(int ma_period, int atr_period, int max_bars)
{
   if(ma_period <= 0 || atr_period <= 0 || max_bars <= 0)
   {
      Alert("Invalid parameters provided to CDataManager::Initialize");
      return false;
   }
   
   m_ma_period = ma_period;
   m_atr_period = atr_period;
   m_max_bars = max_bars;
   
   ArrayResize(m_ma_buffer, m_max_bars);
   ArrayResize(m_atr_buffer, m_max_bars);
   
   return true;
}

//+------------------------------------------------------------------+
//| Clean up resources                                                 |
//+------------------------------------------------------------------+
void CDataManager::Deinitialize(void)
{
   ArrayFree(m_ma_buffer);
   ArrayFree(m_atr_buffer);
}

//+------------------------------------------------------------------+
//| Calculate strength value for a symbol                              |
//+------------------------------------------------------------------+
double CDataManager::CalculateStrengthValue(string symbol)
{
   double closes[], highs[], lows[];
   ArraySetAsSeries(closes, true);
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   
   // Get sufficient historical data
   int bars_needed = MathMax(m_ma_period, m_atr_period);
   
   if(CopyClose(symbol, PERIOD_CURRENT, 0, bars_needed, closes) != bars_needed ||
      CopyHigh(symbol, PERIOD_CURRENT, 0, bars_needed, highs) != bars_needed ||
      CopyLow(symbol, PERIOD_CURRENT, 0, bars_needed, lows) != bars_needed)
   {
      Alert("Failed to copy price data for ", symbol);
      return 0.0;
   }
   
   // Calculate SMA of closes
   double sma = 0.0;
   for(int i = 0; i < m_ma_period; i++)
   {
      sma += closes[i];
   }
   sma /= m_ma_period;
   
   // Calculate ATR
   double atr = 0.0;
   for(int i = 0; i < m_atr_period; i++)
   {
      double tr = MathMax(highs[i] - lows[i],
                  MathMax(MathAbs(highs[i] - closes[i+1]),
                         MathAbs(lows[i] - closes[i+1])));
      atr += tr;
   }
   atr /= m_atr_period;
   
   // Avoid division by zero
   if(atr == 0.0) return 0.0;
   
   // Return (close[0] - SMA[0]) / ATR[0]
   return (closes[0] - sma) / atr;
}
