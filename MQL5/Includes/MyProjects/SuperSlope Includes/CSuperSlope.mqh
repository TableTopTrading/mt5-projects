//+------------------------------------------------------------------+
//|                                                   SuperSlope.mq5 |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+
// Reviewed and used calculations from Baluda Super Slope code.
#property copyright "Copyright 2025, Cal Morgan"
#property link      "web3spotlight@gmail.com"
#property version   "1.0"

//+------------------------------------------------------------------+
//| CSuperSlope class definition                                     |
//+------------------------------------------------------------------+
class CSuperSlope
{
private:
    // Time series arrays
    datetime       m_timeBuffer[];
    
    // Configuration
    bool           m_brokerHasSundayCandles;
    
    // State variables
    int            m_lastCalculated;
    
    // Indicator handles for efficiency
    int            m_atrHandle;
    int            m_maHandle;
    
    // No separate timeframe; always use chart timeframe (Period())
    
    // Private methods
    bool           InitBuffers();
    bool           InitParameters();
    bool           InitVisualElements();
    double         GetSlope(int maPeriod, int atrPeriod, int shift, int bufferSize = 100);
    
protected:
    // Protected methods
    virtual bool   Initialize(void);
    
public:
    // Constructor/Destructor
    CSuperSlope(void);
    ~CSuperSlope(void);
    
    // Public methods
    virtual int    OnInit(void);
    virtual int    OnCalculate(const int rates_total,
                             const int prev_calculated,
                             const datetime &time[],
                             const double &open[],
                             const double &high[],
                             const double &low[],
                             const double &close[],
                             const long &tick_volume[],
                             const long &volume[],
                             const int &spread[],
                             double &slopeBuffer[],
                             const int maxBars = 0);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSuperSlope::CSuperSlope(void) : m_lastCalculated(0),
                                 m_brokerHasSundayCandles(false),
                                 m_atrHandle(INVALID_HANDLE),
                                 m_maHandle(INVALID_HANDLE)
{
    // Simplified constructor
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSuperSlope::~CSuperSlope(void)
{
    // Cleanup indicator handles
    if(m_atrHandle != INVALID_HANDLE)
    {
        IndicatorRelease(m_atrHandle);
        m_atrHandle = INVALID_HANDLE;
    }
    
    if(m_maHandle != INVALID_HANDLE)
    {
        IndicatorRelease(m_maHandle);
        m_maHandle = INVALID_HANDLE;
    }
}

//+------------------------------------------------------------------+
//| Initialize indicator buffers                                     |
//+------------------------------------------------------------------+
bool CSuperSlope::InitBuffers(void)
{
    // Buffers are handled by the main indicator file
    // Just initialize the working arrays
    ArraySetAsSeries(m_timeBuffer, true);
    
    return(true);
}

//+------------------------------------------------------------------+
//| Calculate slope for given parameters                             |
//+------------------------------------------------------------------+
double CSuperSlope::GetSlope(int maPeriod, int atrPeriod, int shift, int bufferSize)
{
    // Bounds checking - ensure shift is reasonable
    if(shift < 0 || shift > 10000) 
    {
        return 0.0;
    }
    
    // Check for Sunday candles using the correct timeframe
    int actualShift = shift;
    if(m_brokerHasSundayCandles && Period() == PERIOD_D1)
    {
        MqlDateTime dt;
        datetime barTime = iTime(Symbol(), Period(), shift);
        TimeToStruct(barTime, dt);
        if(dt.day_of_week == 0) actualShift++;
    }
    
    // Calculate ATR - use pre-created handle
    if(m_atrHandle == INVALID_HANDLE)
    {
        return 0.0;
    }
    
    double atr_values[];
    ArraySetAsSeries(atr_values, true);
    // Use dynamic buffer size instead of hardcoded limit
    int atr_count = MathMin(actualShift + 20, bufferSize);
    if(CopyBuffer(m_atrHandle, 0, 0, atr_count, atr_values) <= 0) 
    {
        return 0.0;
    }
    
    // Make sure we have enough data
    if(ArraySize(atr_values) <= actualShift + 10)
    {
        return 0.0;
    }
    
    // ATR calculation exactly like MQ4: use shift+10 position, then divide by 10
    double atr = atr_values[actualShift + 10] / 10.0;
    if(atr == 0.0) 
    {
        return 0.0;
    }
    
    // Calculate MA values - use pre-created handle
    if(m_maHandle == INVALID_HANDLE)
    {
        return 0.0;
    }
    
    double ma_values[];
    ArraySetAsSeries(ma_values, true);
    // Use dynamic buffer size instead of hardcoded limit
    int ma_count = MathMin(actualShift + 5, bufferSize);
    if(CopyBuffer(m_maHandle, 0, 0, ma_count, ma_values) <= 0) 
    {
        return 0.0;
    }
    
    // Make sure we have enough data
    if(ArraySize(ma_values) <= actualShift + 1)
    {
        return 0.0;
    }
    
    double dblTma = ma_values[actualShift];
    // Use the same timeframe for close price as for MA and ATR data with validation
    double closePrice = iClose(Symbol(), Period(), actualShift);
    if(closePrice <= 0.0)
    {
        return EMPTY_VALUE;
    }
    double dblPrev = (ma_values[actualShift + 1] * 231 + closePrice * 20) / 251;
    
    double result = (dblTma - dblPrev) / atr;
    
    return result;
}

//+------------------------------------------------------------------+
//| OnInit function implementation                                   |
//+------------------------------------------------------------------+
int CSuperSlope::OnInit(void)
{
    // Initialize buffers
    if(!InitBuffers()) 
    {
        return(INIT_FAILED);
    }
    
    // Initialize parameters
    if(!InitParameters()) 
    {
        return(INIT_FAILED);
    }
    
    // Initialize visual elements
    if(!InitVisualElements()) 
    {
        return(INIT_FAILED);
    }
    
    // Create indicator handles using resolved timeframe
    m_atrHandle = iATR(Symbol(), Period(), InpSlopeATRPeriod);
    if(m_atrHandle == INVALID_HANDLE)
    {
        return(INIT_FAILED);
    }
    
    m_maHandle = iMA(Symbol(), Period(), InpSlopeMAPeriod, 0, MODE_LWMA, PRICE_CLOSE);
    if(m_maHandle == INVALID_HANDLE)
    {
        return(INIT_FAILED);
    }
    
    // Check for Sunday candles using the resolved timeframe
    for(int i = 0; i < 8; i++)
    {
        MqlDateTime dt;
    datetime barTime = iTime(Symbol(), Period(), i);
        TimeToStruct(barTime, dt);
        if(dt.day_of_week == 0)
        {
            m_brokerHasSundayCandles = true;
            break;
        }
    }
    
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| OnCalculate function implementation                              |
//+------------------------------------------------------------------+
int CSuperSlope::OnCalculate(const int rates_total,
                            const int prev_calculated,
                            const datetime &time[],
                            const double &open[],
                            const double &high[],
                            const double &low[],
                            const double &close[],
                            const long &tick_volume[],
                            const long &volume[],
                            const int &spread[],
                            double &slopeBuffer[],
                            const int maxBars = 0)
{
    // Check for data
    if(rates_total < InpSlopeMAPeriod + InpSlopeATRPeriod) 
    {
        return(0);
    }
    
    // Copy time values
    if(CopyTime(Symbol(), Period(), 0, rates_total, m_timeBuffer) <= 0) 
    {
        return(0);
    }
    
    // Calculate the effective range to process based on maxBars parameter
    int bars_to_calculate = rates_total;
    int start_from = 0;
    
    if(maxBars > 0)
    {
        // Limit calculation to maxBars from the most recent bars
        bars_to_calculate = MathMin(maxBars, rates_total);
        start_from = rates_total - bars_to_calculate;
    }
    
    // Calculate start position considering maxBars limitation
    int start = MathMax((prev_calculated > 0) ? prev_calculated - 1 : 0, start_from);
    
    // Calculate slope values with maxBars consideration
    for(int i = start; i < rates_total && !IsStopped(); i++)
    {
        // Skip calculation if this bar is outside our maxBars range
        if(maxBars > 0 && i < start_from)
        {
            slopeBuffer[i] = EMPTY_VALUE;
            continue;
        }
        
        // Calculate relative shift (0 = current bar, 1 = previous bar, etc.)
        int shift = rates_total - 1 - i;
        
        // Ensure we have enough buffer space for the calculation
        int required_buffer_size = shift + InpSlopeATRPeriod + 20;
        
        // Calculate primary slope using relative shift and resolved timeframe
        double slope_value = GetSlope(InpSlopeMAPeriod, InpSlopeATRPeriod, shift, required_buffer_size);
        
        // Use the ATR-normalized slope directly (no additional scaling needed)
        slopeBuffer[i] = slope_value;
    }
    
    // Store last calculated bar
    m_lastCalculated = rates_total;
    
    return(rates_total);
}

//+------------------------------------------------------------------+
//| Initialize parameters                                            |
//+------------------------------------------------------------------+
bool CSuperSlope::InitParameters(void)
{
    // Set up initial values
    m_lastCalculated = 0;
    
    return true;
}

//+------------------------------------------------------------------+
//| Initialize visual elements                                       |
//+------------------------------------------------------------------+
bool CSuperSlope::InitVisualElements(void)
{
    // No visual elements needed for simplified version
    return true;
}

//+------------------------------------------------------------------+
//| Initialize method                                                |
//+------------------------------------------------------------------+
bool CSuperSlope::Initialize(void)
{
    return true;
}
