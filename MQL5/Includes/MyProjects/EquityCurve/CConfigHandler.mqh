//+------------------------------------------------------------------+
//|                                              CConfigHandler.mqh |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://www.tabletoptrading.com |
//+------------------------------------------------------------------+
#ifndef CCONFIGHANDLER_MQH
#define CCONFIGHANDLER_MQH

// MQL5 standard includes - built-in functions are available by default
// No additional includes needed for basic file operations

//+------------------------------------------------------------------+
//| Simplified configuration handler using MQL5 native file functions|
//+------------------------------------------------------------------+
class CConfigHandler
{
private:
    string            m_config_file_path;
    
public:
                     CConfigHandler(void);
                    ~CConfigHandler(void);
    
    //--- Initialization methods
    void              Init(string file_path);
    string            GetConfigPath(void) const { return m_config_file_path; }
    
    //--- Configuration operations
    bool              WriteString(string section, string key, string value);
    string            ReadString(string section, string key, string default_value);
    bool              WriteInteger(string section, string key, int value);
    int               ReadInteger(string section, string key, int default_value);
    bool              WriteDouble(string section, string key, double value);
    double            ReadDouble(string section, string key, double default_value);
    
private:
    //--- Utility methods
    string            FormatKey(string section, string key);
    bool              EnsureDirectoryExists(string file_path);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CConfigHandler::CConfigHandler(void)
{
    m_config_file_path = "";
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CConfigHandler::~CConfigHandler(void)
{
}

//+------------------------------------------------------------------+
//| Initialize with configuration file path                          |
//+------------------------------------------------------------------+
void CConfigHandler::Init(string file_path)
{
    m_config_file_path = file_path;
}

//+------------------------------------------------------------------+
//| Write string value to configuration                              |
//+------------------------------------------------------------------+
bool CConfigHandler::WriteString(string section, string key, string value)
{
    if(m_config_file_path == "" || StringLen(m_config_file_path) == 0)
    {
        Print("[ERROR] Config file path not initialized");
        return false;
    }
    
    // Ensure directory exists before writing
    if(!EnsureDirectoryExists(m_config_file_path))
    {
        Print("[ERROR] Failed to ensure directory exists for: " + m_config_file_path);
        return false;
    }
    
    string formatted_key = FormatKey(section, key);
    string line_to_write = formatted_key + "=" + value;
    
    // Read existing content to preserve other settings
    string current_content = "";
    if(FileIsExist(m_config_file_path, FILE_COMMON))
    {
        int file_handle = FileOpen(m_config_file_path, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
        if(file_handle != INVALID_HANDLE)
        {
            current_content = FileReadString(file_handle, (int)FileSize(file_handle));
            FileClose(file_handle);
        }
    }
    
    // Parse and update content - simple line-by-line replacement
    string lines[];
    int line_count = StringSplit(current_content, '\n', lines);
    bool key_found = false;
    string new_content = "";
    
    for(int i = 0; i < line_count; i++)
    {
        string line = lines[i];
        StringTrimLeft(line);
        StringTrimRight(line);
        
        // Skip empty lines and comments
        if(StringLen(line) == 0 || StringFind(line, ";") == 0)
        {
            new_content += line + "\n";
            continue;
        }
        
        // Check if this line contains our key
        int separator_pos = StringFind(line, "=");
        if(separator_pos > 0)
        {
            string current_key = StringSubstr(line, 0, separator_pos);
            StringTrimRight(current_key);
            
            if(current_key == formatted_key)
            {
                // Replace existing key
                new_content += line_to_write + "\n";
                key_found = true;
            }
            else
            {
                // Keep other keys
                new_content += line + "\n";
            }
        }
        else
        {
            // Keep malformed lines
            new_content += line + "\n";
        }
    }
    
    // Add new key if not found
    if(!key_found)
    {
        new_content += line_to_write + "\n";
    }
    
    // Write updated content
    int file_handle = FileOpen(m_config_file_path, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON);
    if(file_handle == INVALID_HANDLE)
    {
        int error_code = GetLastError();
        Print("[ERROR] Failed to open config file for writing: " + m_config_file_path + 
              " (Error " + IntegerToString(error_code) + ")");
        return false;
    }
    
    if(FileWrite(file_handle, new_content) <= 0)
    {
        int error_code = GetLastError();
        FileClose(file_handle);
        Print("[ERROR] Failed to write to config file: " + m_config_file_path + 
              " (Error " + IntegerToString(error_code) + ")");
        return false;
    }
    
    FileClose(file_handle);
    return true;
}

//+------------------------------------------------------------------+
//| Read string value from configuration                             |
//+------------------------------------------------------------------+
string CConfigHandler::ReadString(string section, string key, string default_value)
{
    if(m_config_file_path == "" || !FileIsExist(m_config_file_path, FILE_COMMON))
    {
        return default_value;
    }
    
    string formatted_key = FormatKey(section, key);
    int file_handle = FileOpen(m_config_file_path, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
    
    if(file_handle == INVALID_HANDLE)
    {
        int error_code = GetLastError();
        Print("[ERROR] Failed to open config file for reading: " + m_config_file_path + 
              " (Error " + IntegerToString(error_code) + ")");
        return default_value;
    }
    
    while(!FileIsEnding(file_handle))
    {
        string line = FileReadString(file_handle);
        StringTrimLeft(line);
        StringTrimRight(line);
        
        // Skip empty lines and comments
        if(StringLen(line) == 0 || StringFind(line, ";") == 0)
        {
            continue;
        }
        
        // Check if this line contains our key
        int separator_pos = StringFind(line, "=");
        if(separator_pos > 0)
        {
            string current_key = StringSubstr(line, 0, separator_pos);
            StringTrimRight(current_key);
            
            if(current_key == formatted_key)
            {
                string value = StringSubstr(line, separator_pos + 1);
                StringTrimLeft(value);
                FileClose(file_handle);
                return value;
            }
        }
    }
    
    FileClose(file_handle);
    return default_value;
}

//+------------------------------------------------------------------+
//| Write integer value to configuration                             |
//+------------------------------------------------------------------+
bool CConfigHandler::WriteInteger(string section, string key, int value)
{
    return WriteString(section, key, IntegerToString(value));
}

//+------------------------------------------------------------------+
//| Read integer value from configuration                            |
//+------------------------------------------------------------------+
int CConfigHandler::ReadInteger(string section, string key, int default_value)
{
    string str_value = ReadString(section, key, "");
    if(str_value == "")
    {
        return default_value;
    }
    
    return (int)StringToInteger(str_value);
}

//+------------------------------------------------------------------+
//| Write double value to configuration                              |
//+------------------------------------------------------------------+
bool CConfigHandler::WriteDouble(string section, string key, double value)
{
    return WriteString(section, key, DoubleToString(value));
}

//+------------------------------------------------------------------+
//| Read double value from configuration                             |
//+------------------------------------------------------------------+
double CConfigHandler::ReadDouble(string section, string key, double default_value)
{
    string str_value = ReadString(section, key, "");
    if(str_value == "")
    {
        return default_value;
    }
    
    return StringToDouble(str_value);
}

//+------------------------------------------------------------------+
//| Format key with section prefix                                   |
//+------------------------------------------------------------------+
string CConfigHandler::FormatKey(string section, string key)
{
    return section + "." + key;
}

//+------------------------------------------------------------------+
//| Ensure directory exists for the given file path                  |
//+------------------------------------------------------------------+
bool CConfigHandler::EnsureDirectoryExists(string file_path)
{
    // Extract directory from file path - find last backslash
    int last_slash = StringFind(file_path, "\\", -1);
    if(last_slash <= 0)
    {
        return true; // No directory component or invalid path
    }
    
    // Extract directory path (everything before the last backslash)
    string directory = StringSubstr(file_path, 0, last_slash);
    
    // Debug output to verify path extraction
    Print("[DEBUG] Extracted directory: " + directory + " from file: " + file_path);
    
    // Check if directory already exists first
    if(FolderCreate(directory, FILE_COMMON))
    {
        return true;
    }
    
    int error_code = GetLastError();
    
    // Error 5016 means directory already exists, which is fine
    if(error_code == 5016)
    {
        return true;
    }
    
    // For other errors, try to create parent directories recursively
    if(error_code != 0)
    {
        Print("[WARN] Failed to create directory: " + directory + " (Error " + IntegerToString(error_code) + ")");
        
        // Try creating parent directories
        int prev_slash = StringFind(directory, "\\", -2); // Find second-to-last slash
        if(prev_slash > 0)
        {
            string parent_dir = StringSubstr(directory, 0, prev_slash);
            if(EnsureDirectoryExists(parent_dir + "\\dummy.txt")) // Recursive call with dummy filename
            {
                // Retry creating the target directory
                if(FolderCreate(directory, FILE_COMMON))
                {
                    return true;
                }
                error_code = GetLastError();
                if(error_code == 5016) // Directory now exists
                {
                    return true;
                }
            }
        }
        
        Print("[ERROR] Failed to create directory after recursive attempt: " + directory + " (Error " + IntegerToString(error_code) + ")");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
#endif // CCONFIGHANDLER_MQH
