#ifndef CTRADEMANAGER_MQH
#define CTRADEMANAGER_MQH

//+------------------------------------------------------------------+
//|                                                      CTradeManager.mqh |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://ttt.com      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025, TableTopTrading"
#property link      "https://ttt.com"
#property version   "1.00"
#property strict

// Forward declarations
class CPositionTracker;

// Include necessary enums from CSignalGenerator
#include "CSignalGenerator.mqh"

//+------------------------------------------------------------------+
//| Position size mode enumeration                                  |
//+------------------------------------------------------------------+
enum ENUM_POSITION_SIZE_MODE
{
    SIZE_FIXED,      // Fixed position size
    SIZE_PERCENTAGE, // Percentage of account balance
    SIZE_ATR_BASED   // Based on Average True Range
};

//+------------------------------------------------------------------+
//| CTradeManager class                                             |
//| Purpose: Execute trades based on signals with position management|
//+------------------------------------------------------------------+
class CTradeManager
{
private:
    CPositionTracker* m_position_tracker; // Position tracker instance
    double            m_position_size;    // Position size parameter
    ENUM_POSITION_SIZE_MODE m_size_mode;  // Position sizing mode
    
public:
    //--- Constructor and destructor
                     CTradeManager(void);
                    ~CTradeManager(void);
    
    //--- Initialization and configuration
    bool              Initialize(double position_size, ENUM_POSITION_SIZE_MODE size_mode, CPositionTracker* position_tracker);
    
    //--- Trade execution methods
    bool              ExecuteSignal(ENUM_TRADE_SIGNAL signal, string symbol);
    bool              OpenBuyPosition(string symbol);
    bool              OpenSellPosition(string symbol);
    bool              ClosePosition(string symbol);
    
    //--- Position management
    double            CalculatePositionSize(string symbol);
    bool              HasOpenPosition(string symbol);
    
private:
    //--- Helper methods
    bool              ValidateTradeParameters(string symbol);
    string            GetErrorDescription(int error_code);
    void              LogTradeError(string context, int error_code, string details = "");
};

//+------------------------------------------------------------------+
//| Constructor                                                     |
//+------------------------------------------------------------------+
CTradeManager::CTradeManager(void) : m_position_size(0.1),
                                     m_size_mode(SIZE_FIXED),
                                     m_position_tracker(NULL)
{
    Print("TradeManager: Initialized with default parameters");
}

//+------------------------------------------------------------------+
//| Destructor                                                      |
//+------------------------------------------------------------------+
CTradeManager::~CTradeManager(void)
{
    // Clean up
    m_position_tracker = NULL;
}

//+------------------------------------------------------------------+
//| Initialize trade manager with parameters                        |
//+------------------------------------------------------------------+
bool CTradeManager::Initialize(double position_size, ENUM_POSITION_SIZE_MODE size_mode, CPositionTracker* position_tracker)
{
    // Validate parameters
    if(position_size <= 0.0)
    {
        Print("ERROR: Position size must be greater than 0");
        return false;
    }
    
    if(position_tracker == NULL)
    {
        Print("ERROR: Position tracker cannot be NULL");
        return false;
    }
    
    m_position_size = position_size;
    m_size_mode = size_mode;
    m_position_tracker = position_tracker;
    
    Print("TradeManager: Initialized with size=" + DoubleToString(m_position_size, 2) + 
          ", mode=" + IntegerToString(m_size_mode));
    
    return true;
}

//+------------------------------------------------------------------+
//| Execute trade signal                                            |
//+------------------------------------------------------------------+
bool CTradeManager::ExecuteSignal(ENUM_TRADE_SIGNAL signal, string symbol)
{
    if(!ValidateTradeParameters(symbol))
    {
        return false;
    }
    
    switch(signal)
    {
        case SIGNAL_BUY:
            if(!HasOpenPosition(symbol))
            {
                return OpenBuyPosition(symbol);
            }
            break;
            
        case SIGNAL_SELL:
            if(!HasOpenPosition(symbol))
            {
                return OpenSellPosition(symbol);
            }
            break;
            
        case SIGNAL_CLOSE:
            if(HasOpenPosition(symbol))
            {
                return ClosePosition(symbol);
            }
            break;
            
        case SIGNAL_HOLD:
            // No action required
            break;
    }
    
    return false;
}

//+------------------------------------------------------------------+
//| Open buy position                                               |
//+------------------------------------------------------------------+
bool CTradeManager::OpenBuyPosition(string symbol)
{
    if(!ValidateTradeParameters(symbol))
    {
        return false;
    }
    
    if(HasOpenPosition(symbol))
    {
        Print("WARNING: Cannot open buy position - position already exists for " + symbol);
        return false;
    }
    
    double volume = CalculatePositionSize(symbol);
    double price = SymbolInfoDouble(symbol, SYMBOL_ASK);
    double sl = 0.0;
    double tp = 0.0;
    string comment = "EquityCurve_Buy";
    
    CTrade trade;
    trade.SetDeviationInPoints(10);
    trade.SetTypeFilling(ORDER_FILLING_FOK);
    
    if(trade.Buy(volume, symbol, price, sl, tp, comment))
    {
        long ticket = trade.ResultOrder();
        if(ticket > 0)
        {
            // Add position to tracker
            if(m_position_tracker.AddPosition(symbol, ticket, volume, price, POSITION_BUY))
            {
                Print("TradeManager: Successfully opened BUY position for " + symbol + 
                      " (Volume: " + DoubleToString(volume, 2) + 
                      ", Ticket: " + IntegerToString(ticket) + ")");
                return true;
            }
        }
    }
    
    // Log trade error
    LogTradeError("OpenBuyPosition", trade.ResultRetcode(), "Symbol: " + symbol);
    return false;
}

//+------------------------------------------------------------------+
//| Open sell position                                              |
//+------------------------------------------------------------------+
bool CTradeManager::OpenSellPosition(string symbol)
{
    if(!ValidateTradeParameters(symbol))
    {
        return false;
    }
    
    if(HasOpenPosition(symbol))
    {
        Print("WARNING: Cannot open sell position - position already exists for " + symbol);
        return false;
    }
    
    double volume = CalculatePositionSize(symbol);
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);
    double sl = 0.0;
    double tp = 0.0;
    string comment = "EquityCurve_Sell";
    
    CTrade trade;
    trade.SetDeviationInPoints(10);
    trade.SetTypeFilling(ORDER_FILLING_FOK);
    
    if(trade.Sell(volume, symbol, price, sl, tp, comment))
    {
        long ticket = trade.ResultOrder();
        if(ticket > 0)
        {
            // Add position to tracker
            if(m_position_tracker.AddPosition(symbol, ticket, volume, price, POSITION_SELL))
            {
                Print("TradeManager: Successfully opened SELL position for " + symbol + 
                      " (Volume: " + DoubleToString(volume, 2) + 
                      ", Ticket: " + IntegerToString(ticket) + ")");
                return true;
            }
        }
    }
    
    // Log trade error
    LogTradeError("OpenSellPosition", trade.ResultRetcode(), "Symbol: " + symbol);
    return false;
}

//+------------------------------------------------------------------+
//| Close position for symbol                                       |
//+------------------------------------------------------------------+
bool CTradeManager::ClosePosition(string symbol)
{
    if(!ValidateTradeParameters(symbol))
    {
        return false;
    }
    
    if(!HasOpenPosition(symbol))
    {
        Print("WARNING: Cannot close position - no open position for " + symbol);
        return false;
    }
    
    // Get position information
    PositionInfo position = m_position_tracker.GetPosition(symbol);
    if(position.ticket <= 0)
    {
        Print("ERROR: Invalid position ticket for " + symbol);
        return false;
    }
    
    CTrade trade;
    trade.SetDeviationInPoints(10);
    
    if(trade.PositionClose((ulong)position.ticket))
    {
        // Remove position from tracker
        if(m_position_tracker.RemovePosition(position.ticket))
        {
            Print("TradeManager: Successfully closed position for " + symbol + 
                  " (Ticket: " + IntegerToString(position.ticket) + ")");
            return true;
        }
    }
    
    // Log trade error
    LogTradeError("ClosePosition", trade.ResultRetcode(), 
                 "Symbol: " + symbol + ", Ticket: " + IntegerToString(position.ticket));
    return false;
}

//+------------------------------------------------------------------+
//| Calculate position size based on mode                           |
//+------------------------------------------------------------------+
double CTradeManager::CalculatePositionSize(string symbol)
{
    if(!ValidateTradeParameters(symbol))
    {
        return 0.0;
    }
    
    switch(m_size_mode)
    {
        case SIZE_FIXED:
            return m_position_size;
            
        case SIZE_PERCENTAGE:
        {
            double balance = AccountInfoDouble(ACCOUNT_BALANCE);
            double risk_amount = balance * (m_position_size / 100.0);
            double tick_value = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE_LOTS);
            double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
            
            if(tick_value > 0 && tick_size > 0)
            {
                return risk_amount / (tick_value * tick_size);
            }
            break;
        }
            
        case SIZE_ATR_BASED:
        {
            // Simple ATR-based sizing (placeholder implementation)
            // In real implementation, you would calculate based on ATR and stop loss
            double atr_value = 0.001; // Placeholder
            double risk_per_trade = AccountInfoDouble(ACCOUNT_BALANCE) * 0.01; // 1% risk
            return risk_per_trade / (atr_value * 10000); // Simplified calculation
        }
    }
    
    // Fallback to fixed size
    return m_position_size;
}

//+------------------------------------------------------------------+
//| Check if symbol has open position                               |
//+------------------------------------------------------------------+
bool CTradeManager::HasOpenPosition(string symbol)
{
    if(m_position_tracker == NULL)
    {
        Print("ERROR: Position tracker not initialized");
        return false;
    }
    
    return m_position_tracker.HasPosition(symbol);
}

//+------------------------------------------------------------------+
//| Validate trade parameters                                       |
//+------------------------------------------------------------------+
bool CTradeManager::ValidateTradeParameters(string symbol)
{
    if(symbol == "" || StringLen(symbol) == 0)
    {
        Print("ERROR: Invalid symbol parameter");
        return false;
    }
    
    if(m_position_tracker == NULL)
    {
        Print("ERROR: Position tracker not initialized");
        return false;
    }
    
    if(!SymbolInfoInteger(symbol, SYMBOL_SELECT))
    {
        Print("ERROR: Symbol " + symbol + " is not available for trading");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Get error description for trade operations                      |
//+------------------------------------------------------------------+
string CTradeManager::GetErrorDescription(int error_code)
{
    switch(error_code)
    {
        case 10004: return "Requote";
        case 10006: return "Request rejected";
        case 10007: return "Request canceled by trader";
        case 10008: return "Order placed";
        case 10009: return "Request completed";
        case 10010: return "Only part of the request was completed";
        case 10011: return "Request processing error";
        case 10012: return "Request canceled by timeout";
        case 10013: return "Invalid request";
        case 10014: return "Invalid volume in the request";
        case 10015: return "Invalid price in the request";
        case 10016: return "Invalid stops in the request";
        case 10017: return "Trade is disabled";
        case 10018: return "Market is closed";
        case 10019: return "There is not enough money to complete the request";
        case 10020: return "Prices changed";
        case 10021: return "There are no quotes to process the request";
        case 10022: return "Invalid order expiration date in the request";
        case 10023: return "Order state changed";
        case 10024: return "Too frequent requests";
        case 10025: return "No changes in request";
        case 10026: return "Autotrading disabled by server";
        case 10027: return "Autotrading disabled by client terminal";
        case 10028: return "Request locked for processing";
        case 10029: return "Order or position was already closed";
        case 10030: return "Trade context is busy";
        case 10031: return "Trade features not allowed";
        case 10032: return "Too many pending orders";
        default:    return "Unknown error: " + IntegerToString(error_code);
    }
}

//+------------------------------------------------------------------+
//| Log trade error with detailed information                       |
//+------------------------------------------------------------------+
void CTradeManager::LogTradeError(string context, int error_code, string details)
{
    string error_msg = "TradeManager ERROR in " + context + ": " + 
                      GetErrorDescription(error_code) + 
                      " (Code: " + IntegerToString(error_code) + ")";
    
    if(details != "")
    {
        error_msg += " - " + details;
    }
    
    Print(error_msg);
}

//+------------------------------------------------------------------+
#endif // CTRADEMANAGER_MQH
