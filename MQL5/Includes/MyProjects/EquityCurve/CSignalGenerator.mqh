#ifndef CSIGNALGENERATOR_MQH
#define CSIGNALGENERATOR_MQH

//+------------------------------------------------------------------+
//|                                                      CSignalGenerator.mqh |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://ttt.com      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, TableTopTrading"
#property link      "https://ttt.com"
#property version   "1.00"
#property strict


// Forward declaration for CDataManager
class CDataManager;

//+------------------------------------------------------------------+
//| Strength categorization enumeration                             |
//+------------------------------------------------------------------+
enum ENUM_STRENGTH_CATEGORY
{
    STRONG_BULL,    // Strong bullish signal
    WEAK_BULL,      // Weak bullish signal  
    NEUTRAL,        // Neutral/no clear signal
    WEAK_BEAR,      // Weak bearish signal
    STRONG_BEAR     // Strong bearish signal
};

//+------------------------------------------------------------------+
//| Trade signal enumeration                                        |
//+------------------------------------------------------------------+
enum ENUM_TRADE_SIGNAL
{
    SIGNAL_BUY,     // Buy signal
    SIGNAL_SELL,    // Sell signal
    SIGNAL_CLOSE,   // Close position signal
    SIGNAL_HOLD     // Hold/no action signal
};

//+------------------------------------------------------------------+
//| CSignalGenerator class                                          |
//| Purpose: Process strength values and generate trading signals   |
//|          based on configured threshold rules                    |
//+------------------------------------------------------------------+
class CSignalGenerator
{
private:
    double            m_strong_threshold;  // Threshold for strong signals
    double            m_weak_threshold;    // Threshold for weak signals
    string            m_symbols[];         // Array of symbols to monitor
    ENUM_STRENGTH_CATEGORY m_categories[]; // Strength categories for each symbol
    
    // Reference to data manager for strength value access
    CDataManager*     m_data_manager;
    
public:
    //--- Constructor and destructor
                     CSignalGenerator(void);
                    ~CSignalGenerator(void);
    
    //--- Initialization and configuration methods
    bool              Initialize(double strong_threshold, double weak_threshold, CDataManager* data_manager);
    void              SetSymbols(const string &symbols[]);
    
    //--- Signal generation methods
    ENUM_STRENGTH_CATEGORY CategorizeStrength(double strength);
    ENUM_TRADE_SIGNAL GenerateSignal(string symbol, double strength);
    void              ProcessStrength(string symbol, double strength);
    ENUM_STRENGTH_CATEGORY GetCategory(string symbol);
    
    //--- Utility methods
    int               GetSymbolCount(void) const { return ArraySize(m_symbols); }
    string            GetSymbol(int index) const;
    
private:
    //--- Helper methods
    int               FindSymbolIndex(string symbol);
};

//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
CSignalGenerator::CSignalGenerator(void) : m_strong_threshold(0.7),
                                           m_weak_threshold(0.3),
                                           m_data_manager(NULL)
{
    ArrayResize(m_symbols, 0);
    ArrayResize(m_categories, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CSignalGenerator::~CSignalGenerator(void)
{
    // Clean up arrays
    ArrayFree(m_symbols);
    ArrayFree(m_categories);
}

//+------------------------------------------------------------------+
//| Initialize signal generator with thresholds and data manager    |
//+------------------------------------------------------------------+
bool CSignalGenerator::Initialize(double strong_threshold, double weak_threshold, CDataManager* data_manager)
{
    // Validate thresholds
    if(strong_threshold <= weak_threshold)
    {
        Print("ERROR: Strong threshold must be greater than weak threshold");
        return false;
    }
    
    if(strong_threshold < 0.0 || strong_threshold > 1.0 || weak_threshold < 0.0 || weak_threshold > 1.0)
    {
        Print("ERROR: Thresholds must be between 0.0 and 1.0");
        return false;
    }
    
    if(data_manager == NULL)
    {
        Print("ERROR: Data manager cannot be NULL");
        return false;
    }
    
    m_strong_threshold = strong_threshold;
    m_weak_threshold = weak_threshold;
    m_data_manager = data_manager;
    
    Print("Signal Generator initialized with thresholds: Strong=" + DoubleToString(m_strong_threshold, 2) + 
          ", Weak=" + DoubleToString(m_weak_threshold, 2));
    
    return true;
}

//+------------------------------------------------------------------+
//| Set symbols to monitor                                          |
//+------------------------------------------------------------------+
void CSignalGenerator::SetSymbols(const string &symbols[])
{
    int count = ArraySize(symbols);
    ArrayResize(m_symbols, count);
    ArrayResize(m_categories, count);
    
    // Initialize categories to NEUTRAL
    for(int i = 0; i < count; i++)
    {
        m_symbols[i] = symbols[i];
        m_categories[i] = NEUTRAL;
    }
    
    Print("Signal Generator monitoring " + IntegerToString(count) + " symbols");
}

//+------------------------------------------------------------------+
//| Categorize strength value into strength category                |
//+------------------------------------------------------------------+
ENUM_STRENGTH_CATEGORY CSignalGenerator::CategorizeStrength(double strength)
{
    // Validate strength value
    if(!MathIsValidNumber(strength))
    {
        Print("WARNING: Invalid strength value received: " + DoubleToString(strength));
        return NEUTRAL;
    }
    
    // Categorize based on thresholds
    if(strength >= m_strong_threshold)
        return STRONG_BULL;
    else if(strength >= m_weak_threshold)
        return WEAK_BULL;
    else if(strength >= -m_weak_threshold)
        return NEUTRAL;
    else if(strength >= -m_strong_threshold)
        return WEAK_BEAR;
    else
        return STRONG_BEAR;
}

//+------------------------------------------------------------------+
//| Generate trade signal from strength category                    |
//+------------------------------------------------------------------+
ENUM_TRADE_SIGNAL CSignalGenerator::GenerateSignal(string symbol, double strength)
{
    ENUM_STRENGTH_CATEGORY category = CategorizeStrength(strength);
    
    // Update category for this symbol
    int index = FindSymbolIndex(symbol);
    if(index >= 0)
    {
        m_categories[index] = category;
    }
    
    // Generate trade signal based on category
    switch(category)
    {
        case STRONG_BULL:
            return SIGNAL_BUY;
        case STRONG_BEAR:
            return SIGNAL_SELL;
        case NEUTRAL:
            return SIGNAL_CLOSE;
        case WEAK_BULL:
        case WEAK_BEAR:
        default:
            return SIGNAL_HOLD;
    }
}

//+------------------------------------------------------------------+
//| Process strength value for a symbol and update category         |
//+------------------------------------------------------------------+
void CSignalGenerator::ProcessStrength(string symbol, double strength)
{
    ENUM_STRENGTH_CATEGORY category = CategorizeStrength(strength);
    
    int index = FindSymbolIndex(symbol);
    if(index >= 0)
    {
        m_categories[index] = category;
        
        // Debug logging
        if(false) // Change to true for debug output
        {
            string category_str;
            switch(category)
            {
                case STRONG_BULL: category_str = "STRONG_BULL"; break;
                case WEAK_BULL: category_str = "WEAK_BULL"; break;
                case NEUTRAL: category_str = "NEUTRAL"; break;
                case WEAK_BEAR: category_str = "WEAK_BEAR"; break;
                case STRONG_BEAR: category_str = "STRONG_BEAR"; break;
            }
            
            Print("Processed " + symbol + " strength: " + DoubleToString(strength, 3) + " -> " + category_str);
        }
    }
}

//+------------------------------------------------------------------+
//| Get current category for a symbol                               |
//+------------------------------------------------------------------+
ENUM_STRENGTH_CATEGORY CSignalGenerator::GetCategory(string symbol)
{
    int index = FindSymbolIndex(symbol);
    if(index >= 0)
    {
        return m_categories[index];
    }
    
    return NEUTRAL;
}

//+------------------------------------------------------------------+
//| Get symbol by index                                             |
//+------------------------------------------------------------------+
string CSignalGenerator::GetSymbol(int index) const
{
    if(index >= 0 && index < ArraySize(m_symbols))
    {
        return m_symbols[index];
    }
    
    return "";
}

//+------------------------------------------------------------------+
//| Find index of symbol in symbols array                           |
//+------------------------------------------------------------------+
int CSignalGenerator::FindSymbolIndex(string symbol)
{
    for(int i = 0; i < ArraySize(m_symbols); i++)
    {
        if(m_symbols[i] == symbol)
        {
            return i;
        }
    }
    
    return -1;
}
//+------------------------------------------------------------------+
#endif // CSIGNALGENERATOR_MQH
