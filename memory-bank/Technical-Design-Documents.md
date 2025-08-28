# Technical Design Documents - Equity Curve Trading System

## Overview
This document provides detailed technical design specifications for the Equity Curve Signal EA (Epic 3) and Live Trading EA (Epic 4) architecture, following MVC patterns and best practices.

## Architecture Overview

### System Architecture
```
[EquityCurveSignalEA.mq5]                 [LiveTradingEA.mq5]
    ↑          ↑          ↑                   ↑          ↑          ↑
CEquityCurveController  CDataManager  CSignalGenerator  CEquityCurveReader  CEquityCurveAnalyzer  CBasketManager
    ↑          ↑          ↑                   ↑          ↑          ↑
CTradeManager  CPositionTracker  CEquityCurveWriter  CRiskManager
    ↑
SuperSlopeDashboard Components
```

## Epic 3: Equity Curve Signal EA Design

### Class Diagram
```
EquityCurveSignalEA.mq5
    ↑
CEquityCurveController
    ↑
CDataManager (from SuperSlopeDashboard)
    ↑
CSignalGenerator
    ↑
CTradeManager
    ↑  
CPositionTracker
    ↑
CEquityCurveWriter
```

### CSignalGenerator Class Design

#### Purpose
Process strength values and generate trading signals based on configured rules.

#### Class Definition
```mql5
class CSignalGenerator {
private:
    double m_strong_threshold;
    double m_weak_threshold;
    string m_symbols[];
    ENUM_STRENGTH_CATEGORY m_categories[];
    
public:
    CSignalGenerator();
    ~CSignalGenerator();
    
    bool Initialize(double strong_threshold, double weak_threshold);
    void SetSymbols(const string &symbols[]);
    ENUM_STRENGTH_CATEGORY CategorizeStrength(double strength);
    ENUM_TRADE_SIGNAL GenerateSignal(string symbol, double strength);
    void ProcessStrength(string symbol, double strength);
    ENUM_STRENGTH_CATEGORY GetCategory(string symbol);
};
```

#### Signal Generation Logic
```mql5
ENUM_TRADE_SIGNAL CSignalGenerator::GenerateSignal(string symbol, double strength) {
    ENUM_STRENGTH_CATEGORY category = CategorizeStrength(strength);
    m_categories[ArraySize(m_categories)] = category;
    
    switch(category) {
        case STRONG_BULL:
            return SIGNAL_BUY;
        case STRONG_BEAR:
            return SIGNAL_SELL;
        case NEUTRAL:
            return SIGNAL_CLOSE;
        default:
            return SIGNAL_HOLD;
    }
}
```

### CTradeManager Class Design

#### Purpose
Execute trades based on generated signals with proper position management.

#### Class Definition
```mql5
class CTradeManager {
private:
    CPositionTracker m_position_tracker;
    double m_position_size;
    ENUM_POSITION_SIZE_MODE m_size_mode;
    
public:
    CTradeManager();
    ~CTradeManager();
    
    bool Initialize(double position_size, ENUM_POSITION_SIZE_MODE size_mode);
    bool ExecuteSignal(ENUM_TRADE_SIGNAL signal, string symbol);
    bool OpenBuyPosition(string symbol);
    bool OpenSellPosition(string symbol);
    bool ClosePosition(string symbol);
    double CalculatePositionSize(string symbol);
    bool HasOpenPosition(string symbol);
};
```

#### Trade Execution Logic
```mql5
bool CTradeManager::ExecuteSignal(ENUM_TRADE_SIGNAL signal, string symbol) {
    switch(signal) {
        case SIGNAL_BUY:
            if(!HasOpenPosition(symbol)) {
                return OpenBuyPosition(symbol);
            }
            break;
        case SIGNAL_SELL:
            if(!HasOpenPosition(symbol)) {
                return OpenSellPosition(symbol);
            }
            break;
        case SIGNAL_CLOSE:
            if(HasOpenPosition(symbol)) {
                return ClosePosition(symbol);
            }
            break;
    }
    return false;
}
```

### CPositionTracker Class Design

#### Purpose
Track and manage open positions with state persistence.

#### Class Definition
```mql5
class CPositionTracker {
private:
    struct PositionInfo {
        string symbol;
        long ticket;
        double volume;
        double entry_price;
        datetime entry_time;
        ENUM_POSITION_TYPE type;
    };
    
    PositionInfo m_positions[];
    
public:
    CPositionTracker();
    ~CPositionTracker();
    
    void UpdatePositions();
    bool AddPosition(string symbol, long ticket, double volume, 
                    double entry_price, ENUM_POSITION_TYPE type);
    bool RemovePosition(long ticket);
    PositionInfo GetPosition(string symbol);
    bool HasPosition(string symbol);
    int GetOpenPositionCount();
    double GetTotalExposure();
};
```

### CEquityCurveWriter Class Design

#### Purpose
Write equity curve data to CSV files for consumption by Live Trading EA.

#### Class Definition
```mql5
class CEquityCurveWriter {
private:
    string m_output_path;
    int m_update_frequency;
    datetime m_last_update;
    
public:
    CEquityCurveWriter();
    ~CEquityCurveWriter();
    
    bool Initialize(string output_path, int update_frequency);
    bool WriteData(datetime timestamp, double balance, double equity,
                  double drawdown_percent, double signal_strength,
                  int open_positions, string symbol, string action,
                  double entry_price, double current_price);
    string GenerateFilename();
    bool RotateFiles();
    bool ValidateFileStructure();
};
```

## Epic 4: Live Trading EA Design

### Class Diagram
```
LiveTradingEA.mq5
    ↑
CEquityCurveReader
    ↑
CEquityCurveAnalyzer
    ↑
CBasketManager
    ↑
CRiskManager
```

### CEquityCurveReader Class Design

#### Purpose
Read and parse equity curve data files with validation and error handling.

#### Class Definition
```mql5
class CEquityCurveReader {
private:
    string m_filename;
    int m_read_frequency;
    datetime m_last_read;
    EquityData m_last_data;
    
public:
    CEquityCurveReader();
    ~CEquityCurveReader();
    
    bool Initialize(string filename, int read_frequency);
    bool ReadLatestData(EquityData &data);
    bool ValidateData(const EquityData &data);
    datetime GetDataFreshness();
    bool IsDataStale(datetime max_age_seconds = 300);
    string DetectLatestFile();
};

struct EquityData {
    datetime timestamp;
    double balance;
    double equity;
    double drawdown_percent;
    double signal_strength;
    int open_positions;
    string symbol;
    string action;
    double entry_price;
    double current_price;
};
```

### CEquityCurveAnalyzer Class Design

#### Purpose
Analyze equity curve data and generate trading signals using multiple methods.

#### Class Definition
```mql5
class CEquityCurveAnalyzer {
private:
    EquityData m_historical_data[];
    int m_ma_period;
    double m_slope_threshold;
    
public:
    CEquityCurveAnalyzer();
    ~CEquityCurveAnalyzer();
    
    bool Initialize(int ma_period = 20, double slope_threshold = 0.001);
    bool AddDataPoint(const EquityData &data);
    ENUM_TRADE_SIGNAL AnalyzeSignal();
    bool IsMACrossSignal();
    bool IsMomentumSignal();
    bool IsDrawdownRecoverySignal();
    bool IsStrengthConfirmationSignal();
    double CalculateEquityMA(int period);
    double CalculateEquitySlope();
};
```

#### Signal Analysis Methods
```mql5
bool CEquityCurveAnalyzer::IsMACrossSignal() {
    if(ArraySize(m_historical_data) < m_ma_period) return false;
    
    double current_equity = m_historical_data[ArraySize(m_historical_data)-1].equity;
    double ma = CalculateEquityMA(m_ma_period);
    
    return current_equity > ma;
}

bool CEquityCurveAnalyzer::IsMomentumSignal() {
    double slope = CalculateEquitySlope();
    return slope > m_slope_threshold;
}
```

### CBasketManager Class Design

#### Purpose
Manage basket trading with correlation-based position sizing and rebalancing.

#### Class Definition
```mql5
class CBasketManager {
private:
    string m_symbols[];
    double m_correlations[][];
    double m_position_sizes[];
    double m_risk_percentage;
    
public:
    CBasketManager();
    ~CBasketManager();
    
    bool Initialize(const string &symbols[], double risk_percentage);
    double CalculateCorrelation(string symbol1, string symbol2, int period = 100);
    void UpdateCorrelations();
    double CalculatePositionSize(string symbol);
    void RebalancePortfolio();
    double GetPortfolioExposure();
    double CalculateDiversificationScore();
};
```

#### Correlation Calculation
```mql5
double CBasketManager::CalculateCorrelation(string symbol1, string symbol2, int period) {
    double prices1[], prices2[];
    ArrayResize(prices1, period);
    ArrayResize(prices2, period);
    
    // Fill arrays with price data
    for(int i = 0; i < period; i++) {
        prices1[i] = iClose(symbol1, PERIOD_H1, i);
        prices2[i] = iClose(symbol2, PERIOD_H1, i);
    }
    
    return CalculatePearsonCorrelation(prices1, prices2, period);
}
```

### CRiskManager Class Design

#### Purpose
Implement multi-level risk management with individual and basket-level controls.

#### Class Definition
```mql5
class CRiskManager {
private:
    double m_individual_sl;
    double m_individual_tp;
    double m_basket_sl;
    double m_basket_tp;
    double m_max_drawdown;
    bool m_use_trailing_stop;
    
public:
    CRiskManager();
    ~CRiskManager();
    
    bool Initialize(double individual_sl, double individual_tp,
                   double basket_sl, double basket_tp,
                   double max_drawdown, bool use_trailing_stop);
    bool CheckIndividualRisk(string symbol, double entry_price, double current_price);
    bool CheckBasketRisk(double initial_equity, double current_equity);
    bool CheckDrawdownRisk(double peak_equity, double current_equity);
    void ApplyTrailingStop(string symbol, double current_price);
    bool ShouldCloseAllPositions();
    void EmergencyCloseAll();
};
```

#### Risk Management Logic
```mql5
bool CRiskManager::CheckIndividualRisk(string symbol, double entry_price, double current_price) {
    double risk_pct = MathAbs((current_price - entry_price) / entry_price) * 100;
    
    if(risk_pct >= m_individual_sl) {
        Print("Individual SL triggered for ", symbol);
        return true;
    }
    
    if(risk_pct >= m_individual_tp) {
        Print("Individual TP triggered for ", symbol);
        return true;
    }
    
    return false;
}
```

## New Component: CEquityCurveController

### Class Design

#### Purpose
Manage Equity Curve EA initialization, setup, and resource management including account validation, directory setup, and logging configuration.

#### Class Definition
```mql5
class CEquityCurveController {
private:
    bool            m_initialized;      // Flag indicating if controller is initialized
    string          m_log_path;         // Path for log files
    string          m_output_path;      // Path for output files (CSV, etc.)
    
public:
    //--- Constructor and destructor
                     CEquityCurveController(void);
                    ~CEquityCurveController(void);
    
    //--- Initialization and setup methods
    bool              Initialize(void);
    bool              ValidateAccountType(void);
    bool              SetupDirectories(void);
    bool              ConfigureLogging(void);
    void              Cleanup(void);
    
    //--- Getter methods
    bool              IsInitialized(void) const { return m_initialized; }
    string            GetLogPath(void) const { return m_log_path; }
    string            GetOutputPath(void) const { return m_output_path; }
};
```

#### Account Validation Logic
The ValidateAccountType() method implements strict account type restrictions:
- **Allowed**: Strategy Tester (MQL_TESTER) and Demo accounts (ACCOUNT_TRADE_MODE_DEMO)
- **Rejected**: Real accounts (ACCOUNT_TRADE_MODE_REAL), Contest accounts (ACCOUNT_TRADE_MODE_CONTEST)
- **Security**: Provides clear error messages and comprehensive logging for audit trail
- **Safety**: Prevents accidental execution on unauthorized account types

#### Logging Framework
The controller includes a comprehensive logging system with:
- **Log Levels**: INFO, WARN, ERROR with appropriate prefixing
- **File-based Logging**: Timestamped log files (EquityCurve_YYYYMMDD.log)
- **Initialization Logging**: LogInitializationParameters() method for recording startup configuration
- **Error Handling**: Robust error handling with fallback to standard Print() when file operations fail
- **Audit Trail**: Comprehensive logging for security and debugging purposes
- **Future Ready**: Structure in place for full file-based logging when standard includes are available

## Data Structures and Enums

### Common Enumerations
```mql5
enum ENUM_STRENGTH_CATEGORY {
    STRONG_BULL,
    WEAK_BULL, 
    NEUTRAL,
    WEAK_BEAR,
    STRONG_BEAR
};

enum ENUM_TRADE_SIGNAL {
    SIGNAL_BUY,
    SIGNAL_SELL,
    SIGNAL_CLOSE,
    SIGNAL_HOLD
};

enum ENUM_POSITION_TYPE {
    POSITION_BUY,
    POSITION_SELL
};

enum ENUM_POSITION_SIZE_MODE {
    SIZE_FIXED,
    SIZE_PERCENTAGE,
    SIZE_ATR_BASED
};

enum ENUM_SIGNAL_METHOD {
    SIGNAL_MA_CROSS,
    SIGNAL_MOMENTUM,
    SIGNAL_DRAWDOWN_RECOVERY,
    SIGNAL_STRENGTH_CONFIRMATION
};
```

### Configuration Structures
```mql5
struct SignalEAConfig {
    int slope_ma_period;
    int slope_atr_period;
    string symbol_list;
    ENUM_TIMEFRAMES timeframe;
    double strong_threshold;
    double weak_threshold;
    int max_bars;
    int update_frequency;
    string output_path;
    double position_size;
    ENUM_POSITION_SIZE_MODE size_mode;
};

struct LiveEAConfig {
    string equity_curve_file;
    int read_frequency;
    double risk_percentage;
    bool use_individual_sl;
    double individual_sl;
    bool use_basket_sl;
    double basket_sl;
    bool use_trailing_stop;
    bool use_time_filter;
    string trading_start_time;
    string trading_end_time;
    ENUM_SIGNAL_METHOD signal_method;
};
```

## Performance Optimization

### Memory Management
```mql5
// Optimized array handling
void OptimizeArrayManagement() {
    // Use ArrayResize with reserve
    ArrayResize(m_historical_data, 1000, 1000);
    
    // Implement circular buffer for historical data
    if(ArraySize(m_historical_data) >= MAX_HISTORICAL_DATA) {
        ArrayCopy(m_historical_data, m_historical_data, 0, 1);
        ArrayResize(m_historical_data, ArraySize(m_historical_data) - 1);
    }
}
```

### Calculation Optimization
```mql5
// Efficient strength calculation caching
void CacheStrengthCalculations() {
    // Cache results with timestamp validation
    static datetime last_calculation = 0;
    static double cached_strength = 0;
    
    if(TimeCurrent() - last_calculation < m_update_frequency) {
        return cached_strength;
    }
    
    // Perform calculation and update cache
    cached_strength = CalculateStrengthValue();
    last_calculation = TimeCurrent();
    return cached_strength;
}
```

## Error Handling Framework

### Comprehensive Error Handling
```mql5
class CErrorHandler {
private:
    string m_error_log[];
    
public:
    void LogError(int error_code, string context, string details = "");
    bool HandleError(int error_code, string context);
    string GetErrorDescription(int error_code);
    void ClearErrors();
    string GenerateErrorReport();
};

// Common error codes
#define ERROR_FILE_ACCESS 1001
#define ERROR_DATA_INVALID 1002
#define ERROR_TRADE_EXECUTION 1003
#define ERROR_MEMORY_ALLOCATION 1004
#define ERROR_CONFIGURATION 1005
```

## Integration Patterns

### Component Integration
```mql5
// Recommended integration pattern
void IntegratedOperation() {
    // 1. Data calculation
    double strength = data_manager.CalculateStrengthValue(symbol, timeframe);
    
    // 2. Signal generation
    ENUM_TRADE_SIGNAL signal = signal_generator.GenerateSignal(symbol, strength);
    
    // 3. Trade execution
    bool executed = trade_manager.ExecuteSignal(signal, symbol);
    
    // 4. Position tracking
    position_tracker.UpdatePositions();
    
    // 5. Data recording
    if(executed) {
        equity_writer.WriteData(TimeCurrent(), AccountBalance(), AccountEquity(),
                              CalculateDrawdown(), strength, 
                              position_tracker.GetOpenPositionCount(),
                              symbol, signal == SIGNAL_BUY ? "BUY" : "SELL",
                              SymbolInfoDouble(symbol, SYMBOL_ASK),
                              SymbolInfoDouble(symbol, SYMBOL_BID));
    }
}
```

## Testing Interfaces

### Testable Component Interfaces
```mql5
// Design for testability
interface ITestableComponent {
    bool RunSelfTest();
    string GetTestResults();
    bool ResetTestState();
};

class CTestableSignalGenerator : public CSignalGenerator, public ITestableComponent {
public:
    bool RunSelfTest() override {
        // Test categorization logic
        // Test signal generation
        // Return overall test result
    }
};
```

This technical design document provides comprehensive specifications for implementing the Equity Curve Trading System with proper architecture, error handling, and performance considerations.
