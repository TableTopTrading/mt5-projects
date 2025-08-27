//+------------------------------------------------------------------+
//|                                                    CDataManager.mqh |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Class for managing data calculations in SuperSlopeDashboard        |
//+------------------------------------------------------------------+
class CDataManager
{
private:
   int               m_ma_period;     // Moving Average period (LWMA)
   int               m_atr_period;    // ATR period
   int               m_max_bars;      // Maximum bars to calculate
   
   // Private helper methods
   double            CalculateLWMA(const double &price[], int shift, int period);
   double            CalculateATR(const double &highs[], const double &lows[], const double &closes[], int shift, int period);

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
   
   return true;
}

//+------------------------------------------------------------------+
//| Clean up resources                                                 |
//+------------------------------------------------------------------+
void CDataManager::Deinitialize(void)
{
   // No dynamic resources to clean up in this version
}

//+------------------------------------------------------------------+
//| Calculate LWMA manually                                            |
//+------------------------------------------------------------------+
double CDataManager::CalculateLWMA(const double &price[], int shift, int period)
{
   double sum = 0.0;
   double weight_sum = 0.0;
   
   for (int i = 0; i < period; i++)
   {
      double weight = period - i;
      sum += price[shift + i] * weight;
      weight_sum += weight;
   }
   
   if (weight_sum == 0.0) return 0.0;
   return sum / weight_sum;
}

//+------------------------------------------------------------------+
//| Calculate ATR manually                                             |
//+------------------------------------------------------------------+
double CDataManager::CalculateATR(const double &highs[], const double &lows[], const double &closes[], int shift, int period)
{
   double atr = 0.0;
   
   for (int i = 0; i < period; i++)
   {
      double true_range = MathMax(highs[shift + i], closes[shift + i + 1]) - MathMin(lows[shift + i], closes[shift + i + 1]);
      atr += true_range;
   }
   
   atr /= period;
   return atr;
}

//+------------------------------------------------------------------+
//| Calculate strength value for a symbol                              |
//+------------------------------------------------------------------+
double CDataManager::CalculateStrengthValue(string symbol)
{
   // Copy price data for calculations
   double closes[];
   double highs[];
   double lows[];
   
   int bars_needed = MathMax(m_ma_period, m_atr_period) + 20; // Buffer for calculations
   
   if (CopyClose(symbol, _Period, 0, bars_needed, closes) != bars_needed ||
       CopyHigh(symbol, _Period, 0, bars_needed, highs) != bars_needed ||
       CopyLow(symbol, _Period, 0, bars_needed, lows) != bars_needed)
   {
      Print("Failed to copy price data for ", symbol);
      return 0.0;
   }
   
   ArraySetAsSeries(closes, true);
   ArraySetAsSeries(highs, true);
   ArraySetAsSeries(lows, true);
   
   // Calculate LWMA for current and previous bars
   double lwma_current = CalculateLWMA(closes, 0, m_ma_period);
   double lwma_prev = CalculateLWMA(closes, 1, m_ma_period);
   
   // Calculate ATR manually
   double atr = CalculateATR(highs, lows, closes, 10, m_atr_period); // Using shift=10 to match original logic
   atr = atr / 10.0; // Scale down by 10 to match MQ4 behavior
   
   if (atr == 0.0) 
   {
      return 0.0;
   }
   
   // Calculate previous value using the same formula as in GetSlope
   double closePrice = closes[0];
   double dblPrev = (lwma_prev * 231 + closePrice * 20) / 251;
   
   double result = (lwma_current - dblPrev) / atr;
   
   Print("DEBUG: Symbol '", symbol, "' - Manual calculation: LWMA=", lwma_current, ", Prev=", dblPrev, ", ATR=", atr, ", Result=", result);
   return result;
}
