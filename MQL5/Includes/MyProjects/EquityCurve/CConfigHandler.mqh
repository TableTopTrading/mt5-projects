//+------------------------------------------------------------------+
//|                                              CConfigHandler.mqh |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://www.tabletoptrading.com |
//+------------------------------------------------------------------+
#ifndef CCONFIGHANDLER_MQH
#define CCONFIGHANDLER_MQH

// MQL5 standard includes
#include <Trade/Trade.mqh>

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
    
    // For FILE_COMMON operations, MQL5 handles directory creation automatically
    // Skip manual directory creation to avoid permission issues with system paths
    // MQL5 will create necessary directories when FileOpen is called with FILE_COMMON
    
    string formatted_key = FormatKey(section, key);
    string line_to_write = formatted_key + "=" + value;
    
    Print("[DEBUG] WriteString called - Section: " + section + ", Key: " + key + ", Value: " + value);
    Print("[DEBUG] Formatted key: " + formatted_key);
    Print("[DEBUG] Config file path: " + m_config_file_path);
    
    // Read existing content to preserve other settings
    string current_content = "";
    if(FileIsExist(m_config_file_path, FILE_COMMON))
    {
        Print("[DEBUG] Config file exists, reading current content");
        int file_handle = FileOpen(m_config_file_path, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
        if(file_handle != INVALID_HANDLE)
        {
            current_content = FileReadString(file_handle, (int)FileSize(file_handle));
            FileClose(file_handle);
            Print("[DEBUG] Current file content: " + current_content);
        }
        else
        {
            int error_code = GetLastError();
            Print("[DEBUG] Failed to open file for reading (Error " + IntegerToString(error_code) + ")");
        }
    }
    else
    {
        Print("[DEBUG] Config file does not exist, will create new");
    }
    
    // Parse and update content - simple line-by-line replacement
    string lines[];
    int line_count = StringSplit(current_content, '\n', lines);
    bool key_found = false;
    string new_content = "";
    
    Print("[DEBUG] Processing " + IntegerToString(line_count) + " lines from current content");
    
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
            
            Print("[DEBUG] Checking line: " + line + ", Current key: " + current_key);
            
            if(current_key == formatted_key)
            {
                // Replace existing key
                Print("[DEBUG] Key found, replacing with: " + line_to_write);
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
        Print("[DEBUG] Key not found, adding new: " + line_to_write);
        new_content += line_to_write + "\n";
    }
    
    Print("[DEBUG] Final content to write: " + new_content);
    
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
    Print("[DEBUG] WriteString completed successfully for key: " + formatted_key);
    return true;
}

//+------------------------------------------------------------------+
//| Read string value from configuration                             |
//+------------------------------------------------------------------+
string CConfigHandler::ReadString(string section, string key, string default_value)
{
    if(m_config_file_path == "" || !FileIsExist(m_config_file_path, FILE_COMMON))
    {
        Print("[DEBUG] Config file doesn't exist or path not set, returning default: " + default_value);
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
                Print("[DEBUG] ReadString found key: " + formatted_key + " = " + value);
                return value;
            }
        }
    }
    
    FileClose(file_handle);
    Print("[DEBUG] ReadString key not found: " + formatted_key + ", returning default: " + default_value);
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
    string string_value = DoubleToString(value);
    Print("[DEBUG] WriteDouble called - Section: " + section + ", Key: " + key + ", Value: " + string_value);
    return WriteString(section, key, string_value);
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
    // Split the path by backslashes to properly handle Windows paths
    string parts[];
    int part_count = StringSplit(file_path, '\\', parts);
    
    if(part_count <= 1)
    {
        return true; // No directory component or invalid path
    }
    
    // Remove the last part (filename) to get the directory
    string directory = "";
    for(int i = 0; i < part_count - 1; i++)
    {
        if(i > 0) directory += "\\";
        directory += parts[i];
    }
    
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
        
        // Try creating parent directories by building them step by step
        string current_path = "";
        for(int i = 0; i < part_count - 1; i++)
        {
            if(i > 0) current_path += "\\";
            current_path += parts[i];
            
            // Skip drive letter (e.g., "C:") as it already exists
            if(i == 0 && StringFind(parts[i], ":") != -1)
            {
                continue;
            }
            
            if(!FolderCreate(current_path, FILE_COMMON))
            {
                int create_error = GetLastError();
                if(create_error != 5016) // If not "already exists" error
                {
                    Print("[WARN] Failed to create subdirectory: " + current_path + " (Error " + IntegerToString(create_error) + ")");
                }
            }
        }
        
        // Final attempt to create the target directory
        if(FolderCreate(directory, FILE_COMMON))
        {
            return true;
        }
        
        error_code = GetLastError();
        if(error_code == 5016) // Directory now exists
        {
            return true;
        }
        
        Print("[ERROR] Failed to create directory after recursive attempt: " + directory + " (Error " + IntegerToString(error_code) + ")");
        return false;
    }
    
    return true;
}

//+------------------------------------------------------------------+
#endif // CCONFIGHANDLER_MQH
