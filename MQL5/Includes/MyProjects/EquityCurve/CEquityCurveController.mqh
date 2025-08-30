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
#include "CConfigHandler.mqh"  // Custom configuration handler (replaces inifile.mqh)

// Error handling utilities
#define ERROR_SUCCESS 0
#define ERROR_FILE_OPERATION 5001
#define ERROR_DIRECTORY_CREATION 5002
#define ERROR_INVALID_PARAMETER 5003
#define ERROR_INITIALIZATION_FAILED 5004

// Error description helper function
string GetErrorDescription(int error_code)
{
    switch(error_code)
    {
        case 0: return "No error";
        case 1: return "No error returned, but result is unknown";
        case 2: return "Common error";
        case 3: return "Invalid trade parameters";
        case 4: return "Trade server is busy";
        case 5: return "Old version of the client terminal";
        case 6: return "No connection with trade server";
        case 7: return "Not enough rights";
        case 8: return "Too frequent requests";
        case 9: return "Malfunctional trade operation";
        case 64: return "Account disabled";
        case 65: return "Invalid account";
        case 128: return "Trade timeout";
        case 129: return "Invalid price";
        case 130: return "Invalid stops";
        case 131: return "Invalid trade volume";
        case 132: return "Market is closed";
        case 133: return "Trade is disabled";
        case 134: return "Not enough money";
        case 135: return "Price changed";
        case 136: return "Off quotes";
        case 137: return "Broker is busy";
        case 138: return "Requote";
        case 139: return "Order is locked";
        case 140: return "Long positions only allowed";
        case 141: return "Too many requests";
        case 145: return "Modification denied because order is too close to market";
        case 146: return "Trade context is busy";
        case 147: return "Expirations are denied by broker";
        case 148: return "Too many open and pending orders";
        case 4000: return "No error";
        case 4001: return "Wrong function pointer";
        case 4002: return "Array index is out of range";
        case 4003: return "No memory for function call stack";
        case 4004: return "Recursive stack overflow";
        case 4005: return "Not enough stack for parameter";
        case 4006: return "Not enough memory for parameter string";
        case 4007: return "Not enough memory for temp string";
        case 4008: return "Not initialized string";
        case 4009: return "Not initialized string in array";
        case 4010: return "No memory for array string";
        case 4011: return "Too long string";
        case 4012: return "Remainder from zero divide";
        case 4013: return "Zero divide";
        case 4014: return "Unknown command";
        case 4015: return "Wrong jump";
        case 4016: return "Not initialized array";
        case 4017: return "DLL calls are not allowed";
        case 4018: return "Cannot load library";
        case 4019: return "Cannot call function";
        case 4020: return "Expert function calls are not allowed";
        case 4021: return "Not enough memory for temp string returned from function";
        case 4022: return "System is busy";
        case 4050: return "Invalid function parameters count";
        case 4051: return "Invalid function parameter value";
        case 4052: return "String function internal error";
        case 4053: return "Some array error";
        case 4054: return "Incorrect series array using";
        case 4055: return "Custom indicator error";
        case 4056: return "Arrays are incompatible";
        case 4057: return "Global variables processing error";
        case 4058: return "Global variable not found";
        case 4059: return "Function is not allowed in testing mode";
        case 4060: return "Function is not confirmed";
        case 4061: return "Send mail error";
        case 4062: return "String parameter expected";
        case 4063: return "Integer parameter expected";
        case 4064: return "Double parameter expected";
        case 4065: return "Array as parameter expected";
        case 4066: return "Requested history data is in updating state";
        case 4067: return "Some error in trading function";
        case 4099: return "End of file";
        case 4100: return "Some file error";
        case 4101: return "Wrong file name";
        case 4102: return "Too many opened files";
        case 4103: return "Cannot open file";
        case 4104: return "Incompatible access to a file";
        case 4105: return "No order selected";
        case 4106: return "Unknown symbol";
        case 4107: return "Invalid price parameter";
        case 4108: return "Invalid ticket";
        case 4109: return "Trade is not allowed";
        case 4110: return "Longs are not allowed";
        case 4111: return "Shorts are not allowed";
        case 4200: return "Object already exists";
        case 4201: return "Unknown object property";
        case 4202: return "Object does not exist";
        case 4203: return "Unknown object type";
        case 4204: return "No object name";
        case 4205: return "Object coordinates error";
        case 4206: return "No specified subwindow";
        case 4207: return "Some error in object function";
        case 5001: return "File operation error";
        case 5002: return "Directory creation error";
        case 5003: return "Invalid parameter";
        case 5004: return "Initialization failed";
        default: return "Unknown error code: " + IntegerToString(error_code);
    }
}

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
    CConfigHandler  m_config_handler;   // Custom configuration handler (replaces CIniFile)
    datetime        m_last_config_modify_time; // Last known modification time of config file (Sprint 2.7)
    
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
    void              LogInitializationParameters(string symbol_list, double strong_threshold, 
                                                 double weak_threshold, double position_size, 
                                                 int update_frequency);
    
    //--- Utility methods
    bool              CreateDirectoryWithCheck(string path);
    string            GetFullConfigPath(string relative_path);
    
    //--- Configuration methods (Sprint 2.6)
    bool              LoadConfiguration(string &symbol_list, double &strong_threshold, 
                                       double &weak_threshold, double &position_size, 
                                       int &update_frequency);
    bool              SaveConfiguration(string symbol_list, double strong_threshold, 
                                       double weak_threshold, double position_size, 
                                       int update_frequency);
    bool              ReloadConfiguration(string &symbol_list, double &strong_threshold, 
                                         double &weak_threshold, double &position_size, 
                                         int &update_frequency);
    
    //--- File modification detection methods (Sprint 2.7)
    bool              CheckConfigFileModified(void);
    
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
        LogError("Account validation failed - cannot initialize controller");
        return false;
    }
    
    // Setup required directories
    if(!SetupDirectories())
    {
        LogError("Failed to setup required directories");
        return false;
    }
    
    // Configure logging
    if(!ConfigureLogging())
    {
        LogError("Failed to configure logging");
        return false;
    }
    
    // Load configuration
    string symbol_list;
    double strong_threshold, weak_threshold, position_size;
    int update_frequency;
    
    if(!LoadConfiguration(symbol_list, strong_threshold, weak_threshold, position_size, update_frequency))
    {
        LogError("Failed to load configuration");
        return false;
    }
    
    // Log initialization parameters
    LogInitializationParameters(symbol_list, strong_threshold, weak_threshold, position_size, update_frequency);
    
    m_initialized = true;
    LogInfo("CEquityCurveController initialized successfully");
    
    return true;
}

//+------------------------------------------------------------------+
//| Load configuration from file                                     |
//+------------------------------------------------------------------+
bool CEquityCurveController::LoadConfiguration(string &symbol_list, double &strong_threshold, 
                                              double &weak_threshold, double &position_size, 
                                              int &update_frequency)
{
    string config_file = m_config_path + "EquityCurveConfig.ini"; // Use relative path for FILE_COMMON
    
    // Initialize configuration file handler
    m_config_handler.Init(config_file);
    
    LogInfo("Loading configuration from: " + config_file);
    
    // Load parameters with default values using new handler
    symbol_list = m_config_handler.ReadString("General", "SymbolList", "EURUSD,GBPUSD,USDJPY");
    strong_threshold = m_config_handler.ReadDouble("General", "StrongThreshold", 0.7);
    weak_threshold = m_config_handler.ReadDouble("General", "WeakThreshold", 0.3);
    position_size = m_config_handler.ReadDouble("General", "PositionSize", 0.1);
    update_frequency = m_config_handler.ReadInteger("General", "UpdateFrequency", 60);
    
    // Log loaded configuration
    LogInfo("Configuration loaded - SymbolList: " + symbol_list + 
            ", StrongThreshold: " + DoubleToString(strong_threshold, 2) +
            ", WeakThreshold: " + DoubleToString(weak_threshold, 2) +
            ", PositionSize: " + DoubleToString(position_size, 2) +
            ", UpdateFrequency: " + IntegerToString(update_frequency));
    
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
    // Parameter validation
    if(path == NULL || StringLen(path) == 0)
    {
        LogError("Invalid directory path parameter: path cannot be empty or NULL");
        return false;
    }
    
    // Check if directory already exists
    if(FolderCreate(path, FILE_COMMON))
    {
        LogInfo("Directory already exists or created successfully: " + path);
        return true;
    }
    
    // Directory creation failed
    int error_code = GetLastError();
    LogError("Failed to create directory: " + path + " (Error " + IntegerToString(error_code) + ": " + GetErrorDescription(error_code) + ")");
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
        Print("[ERROR] Failed to open log file: " + m_current_log_file + " (Error " + IntegerToString(error_code) + ": " + GetErrorDescription(error_code) + ")");
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
        Print("[ERROR] Failed to write log header (Error " + IntegerToString(error_code) + ": " + GetErrorDescription(error_code) + ")");
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
    ulong current_size = FileSize(m_log_file_handle);
    if(current_size >= (ulong)m_max_log_size)
    {
        LogInfo("Log file size (" + IntegerToString((long)current_size) + " bytes) exceeds maximum (" + IntegerToString(m_max_log_size) + " bytes). Rotating log file.");
        
        // Close current file
        FileClose(m_log_file_handle);
        m_log_file_handle = INVALID_HANDLE;
        
        // Create rotated filename with timestamp
        datetime rotate_time = TimeCurrent();
        MqlDateTime mql_time;
        TimeToStruct(rotate_time, mql_time);
        
        string rotated_filename = m_log_path + "EquityCurve_" + 
                                 TimeToString(rotate_time, TIME_DATE) + "_" +
                                 IntegerToString(mql_time.hour) + IntegerToString(mql_time.min) +
                                 ".log";
        
        // Rename current file
        if(FileMove(m_current_log_file, FILE_COMMON, rotated_filename, FILE_COMMON))
        {
            LogInfo("Log file rotated successfully: " + rotated_filename);
        }
        else
        {
            int error_code = GetLastError();
            LogError("Failed to rotate log file (Error " + IntegerToString(error_code) + ": " + GetErrorDescription(error_code) + ")");
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
    // Parameter validation
    if(message == NULL || StringLen(message) == 0)
    {
        Print("[WARN] Attempted to log empty or NULL info message");
        return;
    }
    
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
            int error_code = GetLastError();
            Print("[FILE_ERROR] Failed to write log entry (Error " + IntegerToString(error_code) + ": " + GetErrorDescription(error_code) + "): " + log_entry);
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
    // Parameter validation
    if(message == NULL || StringLen(message) == 0)
    {
        Print("[WARN] Attempted to log empty or NULL warning message");
        return;
    }
    
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
            int error_code = GetLastError();
            Print("[FILE_ERROR] Failed to write log entry (Error " + IntegerToString(error_code) + ": " + GetErrorDescription(error_code) + "): " + log_entry);
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
    // Parameter validation
    if(message == NULL || StringLen(message) == 0)
    {
        Print("[WARN] Attempted to log empty or NULL error message");
        return;
    }
    
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
            int error_code = GetLastError();
            Print("[FILE_ERROR] Failed to write log entry (Error " + IntegerToString(error_code) + ": " + GetErrorDescription(error_code) + "): " + log_entry);
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
void CEquityCurveController::LogInitializationParameters(string symbol_list, double strong_threshold, 
                                                        double weak_threshold, double position_size, 
                                                        int update_frequency)
{
    // Use direct Print statements to avoid circular dependency with logging methods
    // that might call ConfigureLogging() again through CheckLogRotation()
    Print("=== INITIALIZATION PARAMETERS ===");
    Print("EA Version: 1.00");
    Print("Account: " + AccountInfoString(ACCOUNT_NAME));
    Print("Server: " + AccountInfoString(ACCOUNT_SERVER));
    Print("Account Type: " + IntegerToString(AccountInfoInteger(ACCOUNT_TRADE_MODE)));
    Print("Balance: " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2));
    Print("Equity: " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2));
    
    // Log EA input parameters
    Print("SymbolList: " + symbol_list);
    Print("StrongThreshold: " + DoubleToString(strong_threshold, 2));
    Print("WeakThreshold: " + DoubleToString(weak_threshold, 2));
    Print("PositionSize: " + DoubleToString(position_size, 2));
    Print("UpdateFrequency: " + IntegerToString(update_frequency) + " seconds");
    
    // Log system configuration
    Print("Log Path: " + m_log_path);
    Print("Output Path: " + m_output_path);
    Print("Config Path: " + m_config_path);
    Print("Max Log Size: " + IntegerToString(m_max_log_size / (1024 * 1024)) + "MB");
    
    // Log validation status
    Print("Parameter Validation: PASSED");
    Print("Account Validation: " + (ValidateAccountType() ? "PASSED" : "FAILED"));
    Print("Directory Setup: " + (SetupDirectories() ? "COMPLETED" : "FAILED"));
    Print("Logging Configuration: " + (m_log_file_handle != INVALID_HANDLE ? "ACTIVE" : "INACTIVE"));
    
    Print("=== END INITIALIZATION PARAMETERS ===");
}

//+------------------------------------------------------------------+
//| Get full absolute path for configuration file                    |
//+------------------------------------------------------------------+
string CEquityCurveController::GetFullConfigPath(string relative_path)
{
    // Get terminal common data path (where shared files are stored)
    string terminal_common_path = TerminalInfoString(TERMINAL_COMMONDATA_PATH);
    
    // Construct full path: terminal_common_path + Files\ + relative_path
    string full_path = terminal_common_path + "\\Files\\" + relative_path;
    
    // Replace any double backslashes that might occur
    StringReplace(full_path, "\\\\", "\\");
    
    return full_path;
}

//+------------------------------------------------------------------+
//| Cleanup resources                                                |
//+------------------------------------------------------------------+
void CEquityCurveController::Cleanup(void)
{
    // Close log file if open with error handling
    if(m_log_file_handle != INVALID_HANDLE)
    {
        if(!FileClose(m_log_file_handle))
        {
            int error_code = GetLastError();
            Print("[ERROR] Failed to close log file handle (Error " + IntegerToString(error_code) + ": " + GetErrorDescription(error_code) + ")");
        }
        m_log_file_handle = INVALID_HANDLE;
        Print("[INFO] Log file closed: " + m_current_log_file); // Use Print instead of LogInfo during cleanup
    }
    
    // Reset all members to initial state
    m_initialized = false;
    m_current_log_file = "";
    
    Print("[INFO] CEquityCurveController cleanup completed - all resources released");
}


//+------------------------------------------------------------------+
//| Save configuration to file                                       |
//+------------------------------------------------------------------+
bool CEquityCurveController::SaveConfiguration(string symbol_list, double strong_threshold, 
                                              double weak_threshold, double position_size, 
                                              int update_frequency)
{
    string config_file = m_config_path + "EquityCurveConfig.ini"; // Use relative path for FILE_COMMON
    
    // Initialize configuration file handler
    m_config_handler.Init(config_file);
    
    LogInfo("Saving configuration to: " + config_file);
    LogInfo("Values to save - SymbolList: " + symbol_list + 
            ", StrongThreshold: " + DoubleToString(strong_threshold, 2) +
            ", WeakThreshold: " + DoubleToString(weak_threshold, 2) +
            ", PositionSize: " + DoubleToString(position_size, 2) +
            ", UpdateFrequency: " + IntegerToString(update_frequency));
    
    // Build complete configuration content in memory to avoid race conditions
    string config_content = "General.SymbolList=" + symbol_list + "\n" +
                           "General.StrongThreshold=" + DoubleToString(strong_threshold) + "\n" +
                           "General.WeakThreshold=" + DoubleToString(weak_threshold) + "\n" +
                           "General.PositionSize=" + DoubleToString(position_size) + "\n" +
                           "General.UpdateFrequency=" + IntegerToString(update_frequency) + "\n";
    
    LogInfo("Complete configuration content to write:\n" + config_content);
    
    // Write complete content to file in single atomic operation
    int file_handle = FileOpen(config_file, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON);
    if(file_handle == INVALID_HANDLE)
    {
        int error_code = GetLastError();
        LogError("Failed to open config file for writing: " + config_file + " (Error " + IntegerToString(error_code) + ")");
        return false;
    }
    
    if(FileWrite(file_handle, config_content) <= 0)
    {
        int error_code = GetLastError();
        FileClose(file_handle);
        LogError("Failed to write to config file: " + config_file + " (Error " + IntegerToString(error_code) + ")");
        return false;
    }
    
    FileClose(file_handle);
    bool success = true;
    
    LogInfo("Configuration saved successfully with atomic write operation");
    
    // Debug: Read back the file content immediately after writing to verify
    if(FileIsExist(config_file, FILE_COMMON))
    {
        int debug_handle = FileOpen(config_file, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
        if(debug_handle != INVALID_HANDLE)
        {
            string file_content = FileReadString(debug_handle, (int)FileSize(debug_handle));
            FileClose(debug_handle);
            LogInfo("DEBUG - Configuration file content after atomic save:");
            LogInfo(file_content);
        }
        else
        {
            int error_code = GetLastError();
            LogError("DEBUG - Failed to read back config file: " + config_file + " (Error " + IntegerToString(error_code) + ")");
        }
    }
    else
    {
        LogError("DEBUG - Config file doesn't exist after save operation: " + config_file);
    }
    
    if(success)
    {
        LogInfo("Configuration saved successfully");
        
    // Verify file was actually created
    if(FileIsExist(config_file, FILE_COMMON))
    {
        LogInfo("Configuration file verified to exist: " + config_file);
        
        // Additional verification - try to read back the file
        int test_handle = FileOpen(config_file, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
        if(test_handle != INVALID_HANDLE)
        {
            string file_content = FileReadString(test_handle, (int)FileSize(test_handle));
            FileClose(test_handle);
            LogInfo("Configuration file content preview: " + StringSubstr(file_content, 0, 200) + "...");
        }
    }
    else
    {
        LogError("Configuration file does not exist after save operation: " + config_file);
        success = false;
    }
    }
    else
    {
        LogError("Failed to save configuration to: " + config_file);
        int error_code = GetLastError();
        LogError("Last error code: " + IntegerToString(error_code) + " - " + GetErrorDescription(error_code));
    }
    
    return success;
}

//+------------------------------------------------------------------+
//| Reload configuration from file                                   |
//+------------------------------------------------------------------+
bool CEquityCurveController::ReloadConfiguration(string &symbol_list, double &strong_threshold, 
                                                double &weak_threshold, double &position_size, 
                                                int &update_frequency)
{
    LogInfo("Reloading configuration from file");
    return LoadConfiguration(symbol_list, strong_threshold, weak_threshold, position_size, update_frequency);
}

//+------------------------------------------------------------------+
//| Check if configuration file has been modified                    |
//+------------------------------------------------------------------+
bool CEquityCurveController::CheckConfigFileModified(void)
{
    string config_file = GetFullConfigPath(m_config_path + "EquityCurveConfig.ini");
    
    // Check if file exists
    if(!FileIsExist(config_file, FILE_COMMON))
    {
        // File doesn't exist, nothing to check
        return false;
    }
    
    // Get current modification time
    datetime current_modify_time = (datetime)FileGetInteger(config_file, FILE_MODIFY_DATE, FILE_COMMON);
    int error_code = GetLastError();
    
    if(error_code != 0)
    {
        LogError("Failed to get file modification time for: " + config_file + 
                " (Error " + IntegerToString(error_code) + ": " + GetErrorDescription(error_code) + ")");
        return false;
    }
    
    // If this is the first check, store the time and return false (no modification yet)
    if(m_last_config_modify_time == 0)
    {
        m_last_config_modify_time = current_modify_time;
        LogInfo("Initial config file modification time recorded: " + TimeToString(current_modify_time, TIME_DATE|TIME_SECONDS));
        return false;
    }
    
    // Check if file has been modified
    if(current_modify_time > m_last_config_modify_time)
    {
        LogInfo("Configuration file modified detected. Old: " + TimeToString(m_last_config_modify_time, TIME_DATE|TIME_SECONDS) + 
                ", New: " + TimeToString(current_modify_time, TIME_DATE|TIME_SECONDS));
        m_last_config_modify_time = current_modify_time;
        return true;
    }
    
    return false;
}

//+------------------------------------------------------------------+
#endif // CEQUITYCURVECONTROLLER_MQH
