#ifndef CPOSITIONTRACKER_MQH
#define CPOSITIONTRACKER_MQH

//+------------------------------------------------------------------+
//|                                                      CPositionTracker.mqh |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://ttt.com      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, TableTopTrading"
#property link      "https://ttt.com"
#property version   "1.00"
#property strict

// MQL5 standard includes for position management
// Note: MQL5 includes are available in MetaEditor but may show errors in VSCode

//+------------------------------------------------------------------+
//| Position type enumeration                                       |
//+------------------------------------------------------------------+
enum ENUM_POSITION_TYPE
{
    POSITION_BUY,    // Buy position
    POSITION_SELL    // Sell position
};

//+------------------------------------------------------------------+
//| Position information structure                                  |
//+------------------------------------------------------------------+
struct PositionInfo
{
    string            symbol;         // Symbol name
    long              ticket;         // Position ticket
    double            volume;         // Position volume
    double            entry_price;    // Entry price
    datetime          entry_time;     // Entry time
    ENUM_POSITION_TYPE type;          // Position type (BUY/SELL)
    
    // Constructor
    PositionInfo() : symbol(""), ticket(0), volume(0.0), entry_price(0.0), entry_time(0), type(POSITION_BUY) {}
    
    // Parameterized constructor
    PositionInfo(string sym, long tkt, double vol, double price, datetime time, ENUM_POSITION_TYPE pos_type) :
        symbol(sym), ticket(tkt), volume(vol), entry_price(price), entry_time(time), type(pos_type) {}
};

//+------------------------------------------------------------------+
//| CPositionTracker class                                          |
//| Purpose: Track and manage open positions with state persistence |
//+------------------------------------------------------------------+
class CPositionTracker
{
private:
    PositionInfo      m_positions[];  // Array of tracked positions
    
public:
    //--- Constructor and destructor
                     CPositionTracker(void);
                    ~CPositionTracker(void);
    
    //--- Position management methods
    void              UpdatePositions(void);
    bool              AddPosition(string symbol, long ticket, double volume, 
                                 double entry_price, ENUM_POSITION_TYPE type);
    bool              RemovePosition(long ticket);
    PositionInfo      GetPosition(string symbol);
    bool              HasPosition(string symbol);
    int               GetOpenPositionCount(void);
    double            GetTotalExposure(void);
    
private:
    //--- Helper methods
    int               FindPositionIndex(string symbol);
    int               FindPositionIndex(long ticket);
    ENUM_POSITION_TYPE GetPositionTypeFromMQL(ENUM_POSITION_TYPE mql_type);
};

//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
CPositionTracker::CPositionTracker(void)
{
    ArrayResize(m_positions, 0);
    UpdatePositions(); // Initialize with current positions
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CPositionTracker::~CPositionTracker(void)
{
    ArrayFree(m_positions);
}

//+------------------------------------------------------------------+
//| Update positions by syncing with current open positions         |
//+------------------------------------------------------------------+
void CPositionTracker::UpdatePositions(void)
{
    // Clear existing positions
    ArrayResize(m_positions, 0);
    
    // Get total number of open positions
    int total_positions = PositionsTotal();
    
    if(total_positions > 0)
    {
        ArrayResize(m_positions, total_positions);
        
        for(int i = 0; i < total_positions; i++)
        {
            if(PositionGetSymbol(i) != "")
            {
                ulong ticket = PositionGetInteger(POSITION_TICKET);
                string symbol = PositionGetString(POSITION_SYMBOL);
                double volume = PositionGetDouble(POSITION_VOLUME);
                double price = PositionGetDouble(POSITION_PRICE_OPEN);
                datetime time = (datetime)PositionGetInteger(POSITION_TIME);
                ENUM_POSITION_TYPE mql_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
                
                m_positions[i] = PositionInfo(symbol, (long)ticket, volume, price, time, 
                                             GetPositionTypeFromMQL(mql_type));
            }
        }
    }
    
    Print("PositionTracker: Updated positions. Total: " + IntegerToString(total_positions));
}

//+------------------------------------------------------------------+
//| Add a new position to tracking                                  |
//+------------------------------------------------------------------+
bool CPositionTracker::AddPosition(string symbol, long ticket, double volume, 
                                  double entry_price, ENUM_POSITION_TYPE type)
{
    // Validate parameters
    if(symbol == "" || ticket <= 0 || volume <= 0.0 || entry_price <= 0.0)
    {
        Print("ERROR: Invalid position parameters");
        return false;
    }
    
    // Check if position already exists
    if(FindPositionIndex(ticket) >= 0)
    {
        Print("WARNING: Position with ticket " + IntegerToString(ticket) + " already exists");
        return false;
    }
    
    // Add new position
    int new_size = ArraySize(m_positions) + 1;
    ArrayResize(m_positions, new_size);
    
    m_positions[new_size - 1] = PositionInfo(symbol, ticket, volume, entry_price, TimeCurrent(), type);
    
    Print("PositionTracker: Added position " + symbol + " (Ticket: " + IntegerToString(ticket) + ")");
    return true;
}

//+------------------------------------------------------------------+
//| Remove a position from tracking                                 |
//+------------------------------------------------------------------+
bool CPositionTracker::RemovePosition(long ticket)
{
    int index = FindPositionIndex(ticket);
    
    if(index >= 0)
    {
        string symbol = m_positions[index].symbol;
        
        // Shift array to remove the element
        for(int i = index; i < ArraySize(m_positions) - 1; i++)
        {
            m_positions[i] = m_positions[i + 1];
        }
        
        ArrayResize(m_positions, ArraySize(m_positions) - 1);
        
        Print("PositionTracker: Removed position " + symbol + " (Ticket: " + IntegerToString(ticket) + ")");
        return true;
    }
    
    Print("WARNING: Position with ticket " + IntegerToString(ticket) + " not found");
    return false;
}

//+------------------------------------------------------------------+
//| Get position information for a symbol                           |
//+------------------------------------------------------------------+
PositionInfo CPositionTracker::GetPosition(string symbol)
{
    int index = FindPositionIndex(symbol);
    
    if(index >= 0)
    {
        return m_positions[index];
    }
    
    // Return empty position info if not found
    return PositionInfo();
}

//+------------------------------------------------------------------+
//| Check if a symbol has an open position                          |
//+------------------------------------------------------------------+
bool CPositionTracker::HasPosition(string symbol)
{
    return FindPositionIndex(symbol) >= 0;
}

//+------------------------------------------------------------------+
//| Get count of open positions                                     |
//+------------------------------------------------------------------+
int CPositionTracker::GetOpenPositionCount(void)
{
    return ArraySize(m_positions);
}

//+------------------------------------------------------------------+
//| Calculate total exposure across all positions                   |
//+------------------------------------------------------------------+
double CPositionTracker::GetTotalExposure(void)
{
    double total_exposure = 0.0;
    
    for(int i = 0; i < ArraySize(m_positions); i++)
    {
        // Simple exposure calculation: volume * entry price
        total_exposure += m_positions[i].volume * m_positions[i].entry_price;
    }
    
    return total_exposure;
}

//+------------------------------------------------------------------+
//| Find position index by symbol                                   |
//+------------------------------------------------------------------+
int CPositionTracker::FindPositionIndex(string symbol)
{
    for(int i = 0; i < ArraySize(m_positions); i++)
    {
        if(m_positions[i].symbol == symbol)
        {
            return i;
        }
    }
    
    return -1;
}

//+------------------------------------------------------------------+
//| Find position index by ticket                                   |
//+------------------------------------------------------------------+
int CPositionTracker::FindPositionIndex(long ticket)
{
    for(int i = 0; i < ArraySize(m_positions); i++)
    {
        if(m_positions[i].ticket == ticket)
        {
            return i;
        }
    }
    
    return -1;
}

//+------------------------------------------------------------------+
//| Convert MQL position type to our enum type                      |
//+------------------------------------------------------------------+
ENUM_POSITION_TYPE CPositionTracker::GetPositionTypeFromMQL(ENUM_POSITION_TYPE mql_type)
{
    switch(mql_type)
    {
        case POSITION_TYPE_BUY:
            return POSITION_BUY;
        case POSITION_TYPE_SELL:
            return POSITION_SELL;
        default:
            return POSITION_BUY; // Default to BUY
    }
}

//+------------------------------------------------------------------+
#endif // CPOSITIONTRACKER_MQH
