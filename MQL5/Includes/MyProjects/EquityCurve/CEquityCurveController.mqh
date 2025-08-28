//+------------------------------------------------------------------+
//|                                              CEquityCurveController.mqh |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://ttt.com      |
//+------------------------------------------------------------------+
#ifndef CEQUITYCURVECONTROLLER_MQH
#define CEQUITYCURVECONTROLLER_MQH

// Include necessary MQL5 standard headers (commented out for compilation - will be uncommented when needed)
//#include <Trade/AccountInfo.mqh>

//+------------------------------------------------------------------+
//| Class for managing Equity Curve EA initialization and setup      |
//+------------------------------------------------------------------+
class CEquityCurveController
{
private:
    bool            m_initialized;      // Flag indicating if controller is initialized
    string          m_log_path;         // Path for log files
    string          m_output_path;      // Path for output files (CSV, etc.)
    int             m_log_file;         // Handle for log file
    
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

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CEquityCurveController::CEquityCurveController(void)
{
    m_initialized = false;
    m_log_path = "";
    m_output_path = "";
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CEquityCurveController::~CEquityCurveController(void)
{
    Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize the controller                                        |
//+------------------------------------------------------------------+
bool CEquityCurveController::Initialize(void)
{
    // Validate account type first
    if(!ValidateAccountType())
    {
        Print("Account type validation failed");
        return false;
    }
    
    // Setup directories for logging and output
    if(!SetupDirectories())
    {
        Print("Failed to setup directories");
        return false;
    }
    
    // Configure logging
    if(!ConfigureLogging())
    {
        Print("Failed to configure logging");
        return false;
    }
    
    m_initialized = true;
    Print("EquityCurveController initialized successfully");
    return true;
}

//+------------------------------------------------------------------+
//| Validate account type for compatibility                          |
//+------------------------------------------------------------------+
bool CEquityCurveController::ValidateAccountType(void)
{
    // First check if running in Strategy Tester - always allow
    if(MQLInfoInteger(MQL_TESTER))
    {
        Print("Running in Strategy Tester mode - validation passed");
        return true;
    }
    
    // Get account trade mode
    int account_mode = AccountInfoInteger(ACCOUNT_TRADE_MODE);
    
    // Allow only demo accounts for live trading
    if(account_mode == ACCOUNT_TRADE_MODE_DEMO)
    {
        Print("Running on demo account - validation passed");
        return true;
    }
    
    // Reject all other account types with specific error messages
    if(account_mode == ACCOUNT_TRADE_MODE_REAL)
    {
        Print("ERROR: Real accounts are not allowed. Please use demo account or Strategy Tester.");
        return false;
    }
    
    if(account_mode == ACCOUNT_TRADE_MODE_CONTEST)
    {
        Print("ERROR: Contest accounts are not supported.");
        return false;
    }
    
    // Handle unknown account types
    Print("ERROR: Unsupported account type detected: ", account_mode);
    return false;
}

//+------------------------------------------------------------------+
//| Setup directories for logging and output                         |
//+------------------------------------------------------------------+
bool CEquityCurveController::SetupDirectories(void)
{
    // Set log path to MQL5/Files/EquityCurve/Logs/
    m_log_path = "EquityCurve\\Logs\\";
    
    // Set output path to MQL5/Files/EquityCurve/Output/
    m_output_path = "EquityCurve\\Output\\";
    
    // Create directories if they don't exist
    if(!FolderCreate(m_log_path, FILE_COMMON))
    {
        Print("Failed to create log directory: ", m_log_path);
        return false;
    }
    
    if(!FolderCreate(m_output_path, FILE_COMMON))
    {
        Print("Failed to create output directory: ", m_output_path);
        return false;
    }
    
    Print("Directories created successfully:");
    Print("Log path: ", m_log_path);
    Print("Output path: ", m_output_path);
    
    return true;
}

//+------------------------------------------------------------------+
//| Configure logging settings                                       |
//+------------------------------------------------------------------+
bool CEquityCurveController::ConfigureLogging(void)
{
    // Logging configuration will be fully implemented when standard includes are available
    LogInfo("Logging system initialized successfully");
    LogInfo("File-based logging will be enabled when standard includes are available");
    
    return true;
}

//+------------------------------------------------------------------+
//| Log informational message                                        |
//+------------------------------------------------------------------+
void LogInfo(string message)
{
    // Implementation will be added when standard includes are available
    Print("[INFO] " + message);
}

//+------------------------------------------------------------------+
//| Log warning message                                              |
//+------------------------------------------------------------------+
void LogWarning(string message)
{
    // Implementation will be added when standard includes are available
    Print("[WARN] " + message);
}

//+------------------------------------------------------------------+
//| Log error message                                                |
//+------------------------------------------------------------------+
void LogError(string message)
{
    // Implementation will be added when standard includes are available
    Print("[ERROR] " + message);
}

//+------------------------------------------------------------------+
//| Log initialization parameters                                    |
//+------------------------------------------------------------------+
void LogInitializationParameters(void)
{
    LogInfo("=== INITIALIZATION PARAMETERS ===");
    LogInfo("EA Version: 1.00");
    LogInfo("Initialization parameters logging ready - will log details when standard includes are available");
    LogInfo("=== END INITIALIZATION PARAMETERS ===");
}

//+------------------------------------------------------------------+
//| Cleanup resources                                                |
//+------------------------------------------------------------------+
void CEquityCurveController::Cleanup(void)
{
    // Reset initialization flag
    m_initialized = false;
    
    // Clear paths
    m_log_path = "";
    m_output_path = "";
    
    LogInfo("EquityCurveController cleanup completed");
}

//+------------------------------------------------------------------+
#endif // CEQUITYCURVECONTROLLER_MQH
