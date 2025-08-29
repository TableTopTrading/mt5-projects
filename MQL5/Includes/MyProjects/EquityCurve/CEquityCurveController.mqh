//+------------------------------------------------------------------+
//|                                              CEquityCurveController.mqh |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://www.tabletoptrading.com |
//+------------------------------------------------------------------+
#ifndef CEQUITYCURVECONTROLLER_MQH
#define CEQUITYCURVECONTROLLER_MQH

// Standard MT5 includes (Sprint 2.1 - Integrated)
#include <Trade/Trade.mqh>
#include <Trade/AccountInfo.mqh>
#include <Trade/SymbolInfo.mqh>
#include <Trade/PositionInfo.mqh>

// Project includes
// #include <Files/File.mqh>  // Not needed - using MQL5 built-in functions

class CEquityCurveController
{
private:
    bool            m_initialized;      // Flag indicating if controller is initialized
    string          m_log_path;         // Path for log files
    string          m_output_path;      // Path for output files (CSV, etc.)
    string          m_config_path;      // Path for configuration files
    int             m_log_file_handle;  // File handle for logging
    string          m_current_log_file; // Current log filename
    long            m_max_log_size;     // Maximum log file size in bytes (10MB)
    
public:
    //--- Constructor and destructor
                     CEquityCurveController(void);
                    ~CEquityCurveController(void);
    
    //--- Initialization and setup methods
    bool              Initialize(void);
    bool              ValidateAccountType(void);
    bool              SetupDirectories(void);
    bool              ConfigureLogging(void);
    bool              CheckLogRotation(void);
    void              Cleanup(void);
    
    //--- Logging methods (to be upgraded to file logging in Sprint 2.3)
    void              LogInfo(string message);
    void              LogWarning(string message);
    void              LogError(string message);
    void              LogInitializationParameters(void);
    
    //--- Utility methods
    bool              CreateDirectoryWithCheck(string path);
    
    //--- Getter methods
    bool              IsInitialized(void) const { return m_initialized; }
    string            GetLogPath(void) const { return m_log_path; }
    string            GetOutputPath(void) const { return m_output_path; }
    string            GetConfigPath(void) const { return m_config_path; }
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CEquityCurveController::CEquityCurveController(void) : m_initialized(false)
{
    // Set base paths
    m_log_path = "EquityCurveSignals\\Logs\\";
    m_output_path = "EquityCurveSignals\\Output\\";
    m_config_path = "EquityCurveSignals\\Configuration\\";
    m_log_file_handle = INVALID_HANDLE;
    m_current_log_file = "";
    m_max_log_size = 10 * 1024 * 1024; // 10MB max log size
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
    long account_mode = AccountInfoInteger(ACCOUNT_TRADE_MODE);
    
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
    // Set paths for EquityCurveSignals directories
    m_log_path = "EquityCurveSignals\\Logs\\";
    m_output_path = "EquityCurveSignals\\Output\\";
    string config_path = "EquityCurveSignals\\Configuration\\";
    
    // Create all required directories with error handling
    if(!CreateDirectoryWithCheck(m_log_path))
    {
        LogError("Failed to create log directory: " + m_log_path);
        return false;
    }
    
    if(!CreateDirectoryWithCheck(m_output_path))
    {
        LogError("Failed to create output directory: " + m_output_path);
        return false;
    }
    
    if(!CreateDirectoryWithCheck(config_path))
    {
        LogError("Failed to create configuration directory: " + config_path);
        return false;
    }
    
    LogInfo("Directory structure created successfully for EquityCurveSignals");
    LogInfo("Log path: " + m_log_path);
    LogInfo("Output path: " + m_output_path);
    LogInfo("Configuration path: " + config_path);
    
    return true;
}

//+------------------------------------------------------------------+
//| Create directory with existence check and error handling         |
//+------------------------------------------------------------------+
bool CEquityCurveController::CreateDirectoryWithCheck(string path)
{
    // Check if directory already exists
    if(FolderCreate(path, FILE_COMMON))
    {
        LogInfo("Directory already exists or created successfully: " + path);
        return true;
    }
    
    // Directory creation failed
    int error_code = GetLastError();
    LogError("Failed to create directory: " + path + " (Error: " + IntegerToString(error_code) + ")");
    return false;
}

//+------------------------------------------------------------------+
//| Configure logging settings                                       |
//+------------------------------------------------------------------+
bool CEquityCurveController::ConfigureLogging(void)
{
    // Generate timestamped log filename
    datetime current_time = TimeCurrent();
    string date_string = TimeToString(current_time, TIME_DATE);
    StringReplace(date_string, ".", "");
    m_current_log_file = m_log_path + "EquityCurve_" + date_string + ".log";
    
    // Open log file for writing (append mode, Unicode, write through)
    m_log_file_handle = FileOpen(m_current_log_file, FILE_WRITE|FILE_READ|FILE_TXT|FILE_UNICODE|FILE_COMMON);
    
    if(m_log_file_handle == INVALID_HANDLE)
    {
        int error_code = GetLastError();
        Print("[ERROR] Failed to open log file: " + m_current_log_file + " (Error: " + IntegerToString(error_code) + ")");
        return false;
    }
    
    // Write log header
    string header = "=== Equity Curve Signal EA Log File ===";
    header += "\nStart Time: " + TimeToString(current_time, TIME_DATE|TIME_SECONDS);
    header += "\nAccount: " + AccountInfoString(ACCOUNT_NAME);
    header += "\nServer: " + AccountInfoString(ACCOUNT_SERVER);
    header += "\nMax Log Size: " + IntegerToString(m_max_log_size / (1024 * 1024)) + "MB";
    header += "\n===========================================";
    
    if(FileWrite(m_log_file_handle, header) <= 0)
    {
        int error_code = GetLastError();
        Print("[ERROR] Failed to write log header (Error: " + IntegerToString(error_code) + ")");
        FileClose(m_log_file_handle);
        m_log_file_handle = INVALID_HANDLE;
        return false;
    }
    
    Print("[INFO] File-based logging initialized successfully: " + m_current_log_file);
    return true;
}

//+------------------------------------------------------------------+
//| Check if log rotation is needed and perform if necessary         |
//+------------------------------------------------------------------+
bool CEquityCurveController::CheckLogRotation(void)
{
    if(m_log_file_handle == INVALID_HANDLE)
        return false;
    
    // Check current file size
    long current_size = FileSize(m_log_file_handle);
    if(current_size >= m_max_log_size)
    {
        LogInfo("Log file size (" + IntegerToString(current_size) + " bytes) exceeds maximum (" + IntegerToString(m_max_log_size) + " bytes). Rotating log file.");
        
        // Close current file
        FileClose(m_log_file_handle);
        m_log_file_handle = INVALID_HANDLE;
        
        // Create rotated filename with timestamp
        datetime rotate_time = TimeCurrent();
        string rotated_filename = m_log_path + "EquityCurve_" + 
                                 TimeToString(rotate_time, TIME_DATE) + "_" +
                                 IntegerToString(TimeHour(rotate_time)) + IntegerToString(TimeMinute(rotate_time)) +
                                 ".log";
        
        // Rename current file
        if(FileMove(m_current_log_file, FILE_COMMON, rotated_filename, FILE_COMMON))
        {
            LogInfo("Log file rotated successfully: " + rotated_filename);
        }
        else
        {
            int error_code = GetLastError();
            LogError("Failed to rotate log file (Error: " + IntegerToString(error_code) + ")");
        }
        
        // Reconfigure logging to create new file
        return ConfigureLogging();
    }
    
    return true;
}

//+------------------------------------------------------------------+
//| Log informational message                                        |
//+------------------------------------------------------------------+
void CEquityCurveController::LogInfo(string message)
{
    string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
    string log_entry = "[" + timestamp + "] [INFO] " + message;
    
    // Check if log rotation is needed before writing
    CheckLogRotation();
    
    // Write to file if logging is configured
    if(m_log_file_handle != INVALID_HANDLE)
    {
        if(FileWrite(m_log_file_handle, log_entry) <= 0)
        {
            // Fallback to Print if file writing fails
            Print("[FILE_ERROR] Failed to write log entry: " + log_entry);
        }
    }
    else
    {
        // Fallback to Print if file logging not available
        Print("[INFO] " + message);
    }
}

//+------------------------------------------------------------------+
//| Log warning message                                              |
//+------------------------------------------------------------------+
void CEquityCurveController::LogWarning(string message)
{
    string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
    string log_entry = "[" + timestamp + "] [WARN] " + message;
    
    // Check if log rotation is needed before writing
    CheckLogRotation();
    
    // Write to file if logging is configured
    if(m_log_file_handle != INVALID_HANDLE)
    {
        if(FileWrite(m_log_file_handle, log_entry) <= 0)
        {
            // Fallback to Print if file writing fails
            Print("[FILE_ERROR] Failed to write log entry: " + log_entry);
        }
    }
    else
    {
        // Fallback to Print if file logging not available
        Print("[WARN] " + message);
    }
}

//+------------------------------------------------------------------+
//| Log error message                                                |
//+------------------------------------------------------------------+
void CEquityCurveController::LogError(string message)
{
    string timestamp = TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS);
    string log_entry = "[" + timestamp + "] [ERROR] " + message;
    
    // Check if log rotation is needed before writing
    CheckLogRotation();
    
    // Write to file if logging is configured
    if(m_log_file_handle != INVALID_HANDLE)
    {
        if(FileWrite(m_log_file_handle, log_entry) <= 0)
        {
            // Fallback to Print if file writing fails
            Print("[FILE_ERROR] Failed to write log entry: " + log_entry);
        }
    }
    else
    {
        // Fallback to Print if file logging not available
        Print("[ERROR] " + message);
    }
}

//+------------------------------------------------------------------+
//| Log initialization parameters                                    |
//+------------------------------------------------------------------+
void CEquityCurveController::LogInitializationParameters(void)
{
    LogInfo("=== INITIALIZATION PARAMETERS ===");
    LogInfo("EA Version: 1.00");
    LogInfo("Account: " + AccountInfoString(ACCOUNT_NAME));
    LogInfo("Server: " + AccountInfoString(ACCOUNT_SERVER));
    LogInfo("Account Type: " + IntegerToString(AccountInfoInteger(ACCOUNT_TRADE_MODE)));
    LogInfo("Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
    LogInfo("Equity: " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
    LogInfo("Log Path: " + m_log_path);
    LogInfo("Output Path: " + m_output_path);
    LogInfo("Config Path: " + m_config_path);
    LogInfo("Max Log Size: " + IntegerToString(m_max_log_size / (1024 * 1024)) + "MB");
    LogInfo("=== END INITIALIZATION PARAMETERS ===");
}

//+------------------------------------------------------------------+
//| Cleanup resources                                                |
//+------------------------------------------------------------------+
void CEquityCurveController::Cleanup(void)
{
    // Close log file if open
    if(m_log_file_handle != INVALID_HANDLE)
    {
        FileClose(m_log_file_handle);
        m_log_file_handle = INVALID_HANDLE;
        LogInfo("Log file closed: " + m_current_log_file);
    }
    
    // Reset initialization flag
    m_initialized = false;
    
    // Clear file tracking
    m_current_log_file = "";
    
    LogInfo("CEquityCurveController cleanup completed - all resources released");
}

//+------------------------------------------------------------------+
#endif // CEQUITYCURVECONTROLLER_MQH
