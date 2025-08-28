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
    // Check if this is a demo account (recommended for testing)
    if(AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO)
    {
        Print("Running on demo account - suitable for testing");
        return true;
    }
    
    // Allow real accounts but with warning
    if(AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_REAL)
    {
        Print("WARNING: Running on real account - use with caution");
        return true;
    }
    
    // Check for sufficient balance
    double balance = AccountInfoDouble(ACCOUNT_BALANCE);
    if(balance < 100.0) // Minimum balance check
    {
        Print("Insufficient account balance: ", balance);
        return false;
    }
    
    return true;
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
    // Enable expert logging
    if(!LogEnable(true))
    {
        Print("Failed to enable logging");
        return false;
    }
    
    // Set log level to include all messages
    if(!LogLevel(LOG_LEVEL_ALL))
    {
        Print("Failed to set log level");
        return false;
    }
    
    Print("Logging configured successfully");
    return true;
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
    
    Print("EquityCurveController cleanup completed");
}

//+------------------------------------------------------------------+
#endif // CEQUITYCURVECONTROLLER_MQH
