//+------------------------------------------------------------------+
//|                                              CConfigHandler.mqh |
//|                        Copyright 2025, TableTopTrading           |
//|                                             https://www.tabletoptrading.com |
//+------------------------------------------------------------------+
#ifndef CCONFIGHANDLER_MQH
#define CCONFIGHANDLER_MQH

// MQL5 standard includes - these are built-in functions in MQL5

//+------------------------------------------------------------------+
//| Configuration handler using MQL5 native file functions           |
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
    bool              WriteBool(string section, string key, bool value);
    bool              ReadBool(string section, string key, bool default_value);
    
    //--- Section operations
    bool              SectionExists(string section);
    bool              KeyExists(string section, string key);
    bool              DeleteKey(string section, string key);
    bool              DeleteSection(string section);
    
private:
    //--- Utility methods
    string            FormatKey(string section, string key);
    bool              ParseLine(string line, string &out_key, string &out_value);
    string            EscapeString(string value);
    string            UnescapeString(string value);
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
    
    string formatted_key = FormatKey(section, key);
    string escaped_value = EscapeString(value);
    string line_to_write = formatted_key + "=" + escaped_value;
    
    // Read existing content
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
    
    // Parse and update content
    string lines[];
    int line_count = StringSplit(current_content, '\n', lines);
    bool key_found = false;
    string new_content = "";
    
    for(int i = 0; i < line_count; i++)
    {
        string line = lines[i];
        StringTrimLeft(line);
        StringTrimRight(line);
        
        if(StringLen(line) == 0 || StringGetCharacter(line, 0) == ';')
        {
            // Keep comments and empty lines
            new_content += line + "\n";
            continue;
        }
        
        string current_key, current_value;
        if(ParseLine(line, current_key, current_value))
        {
            if(current_key == formatted_key)
            {
                // Replace existing key
                new_content += formatted_key + "=" + escaped_value + "\n";
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
            // Keep malformed lines (shouldn't happen in valid config)
            new_content += line + "\n";
        }
    }
    
    // Add new key if not found
    if(!key_found)
    {
        new_content += formatted_key + "=" + escaped_value + "\n";
    }
    
    // Write updated content
    int file_handle = FileOpen(m_config_file_path, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON);
    if(file_handle == INVALID_HANDLE)
    {
        Print("[ERROR] Failed to open config file for writing: " + m_config_file_path);
        return false;
    }
    
    if(FileWrite(file_handle, new_content) <= 0)
    {
        FileClose(file_handle);
        Print("[ERROR] Failed to write to config file: " + m_config_file_path);
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
        Print("[ERROR] Failed to open config file for reading: " + m_config_file_path);
        return default_value;
    }
    
    while(!FileIsEnding(file_handle))
    {
        string line = FileReadString(file_handle);
        StringTrimLeft(line);
        StringTrimRight(line);
        
        if(StringLen(line) == 0 || StringGetCharacter(line, 0) == ';')
        {
            continue; // Skip comments and empty lines
        }
        
        string current_key, current_value;
        if(ParseLine(line, current_key, current_value))
        {
            if(current_key == formatted_key)
            {
                FileClose(file_handle);
                return UnescapeString(current_value);
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
    
    int result = (int)StringToInteger(str_value);
    if(result == 0 && str_value != "0")
    {
        return default_value;
    }
    
    return result;
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
    
    double result = StringToDouble(str_value);
    if(result == 0.0 && str_value != "0.0")
    {
        return default_value;
    }
    
    return result;
}

//+------------------------------------------------------------------+
//| Write boolean value to configuration                             |
//+------------------------------------------------------------------+
bool CConfigHandler::WriteBool(string section, string key, bool value)
{
    return WriteString(section, key, value ? "true" : "false");
}

//+------------------------------------------------------------------+
//| Read boolean value from configuration                            |
//+------------------------------------------------------------------+
bool CConfigHandler::ReadBool(string section, string key, bool default_value)
{
    string str_value = ReadString(section, key, "");
    if(str_value == "")
    {
        return default_value;
    }
    
    str_value = StringToLower(str_value);
    if(str_value == "true" || str_value == "1" || str_value == "yes")
    {
        return true;
    }
    else if(str_value == "false" || str_value == "0" || str_value == "no")
    {
        return false;
    }
    
    return default_value;
}

//+------------------------------------------------------------------+
//| Check if section exists                                          |
//+------------------------------------------------------------------+
bool CConfigHandler::SectionExists(string section)
{
    if(m_config_file_path == "" || !FileIsExist(m_config_file_path, FILE_COMMON))
    {
        return false;
    }
    
    int file_handle = FileOpen(m_config_file_path, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
    if(file_handle == INVALID_HANDLE)
    {
        return false;
    }
    
    string search_pattern = "[" + section + "]";
    
    while(!FileIsEnding(file_handle))
    {
        string line = FileReadString(file_handle);
        StringTrimLeft(line);
        StringTrimRight(line);
        
        if(StringFind(line, search_pattern) == 0)
        {
            FileClose(file_handle);
            return true;
        }
    }
    
    FileClose(file_handle);
    return false;
}

//+------------------------------------------------------------------+
//| Check if key exists in section                                   |
//+------------------------------------------------------------------+
bool CConfigHandler::KeyExists(string section, string key)
{
    if(m_config_file_path == "" || !FileIsExist(m_config_file_path, FILE_COMMON))
    {
        return false;
    }
    
    string formatted_key = FormatKey(section, key);
    int file_handle = FileOpen(m_config_file_path, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
    
    if(file_handle == INVALID_HANDLE)
    {
        return false;
    }
    
    while(!FileIsEnding(file_handle))
    {
        string line = FileReadString(file_handle);
        StringTrimLeft(line);
        StringTrimRight(line);
        
        if(StringLen(line) == 0 || StringGetCharacter(line, 0) == ';')
        {
            continue;
        }
        
        string current_key, current_value;
        if(ParseLine(line, current_key, current_value) && current_key == formatted_key)
        {
            FileClose(file_handle);
            return true;
        }
    }
    
    FileClose(file_handle);
    return false;
}

//+------------------------------------------------------------------+
//| Delete key from configuration                                    |
//+------------------------------------------------------------------+
bool CConfigHandler::DeleteKey(string section, string key)
{
    if(m_config_file_path == "" || !FileIsExist(m_config_file_path, FILE_COMMON))
    {
        return true; // Nothing to delete
    }
    
    string formatted_key = FormatKey(section, key);
    int file_handle = FileOpen(m_config_file_path, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
    
    if(file_handle == INVALID_HANDLE)
    {
        return false;
    }
    
    string current_content = FileReadString(file_handle, (int)FileSize(file_handle));
    FileClose(file_handle);
    
    string lines[];
    int line_count = StringSplit(current_content, '\n', lines);
    string new_content = "";
    bool key_found = false;
    
    for(int i = 0; i < line_count; i++)
    {
        string line = lines[i];
        StringTrimLeft(line);
        StringTrimRight(line);
        
        if(StringLen(line) == 0 || StringGetCharacter(line, 0) == ';')
        {
            new_content += line + "\n";
            continue;
        }
        
        string current_key, current_value;
        if(ParseLine(line, current_key, current_value))
        {
            if(current_key != formatted_key)
            {
                new_content += line + "\n";
            }
            else
            {
                key_found = true;
            }
        }
        else
        {
            new_content += line + "\n";
        }
    }
    
    if(!key_found)
    {
        return true; // Key didn't exist, nothing to do
    }
    
    // Write updated content
    file_handle = FileOpen(m_config_file_path, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON);
    if(file_handle == INVALID_HANDLE)
    {
        return false;
    }
    
    bool success = (FileWrite(file_handle, new_content) > 0);
    FileClose(file_handle);
    
    return success;
}

//+------------------------------------------------------------------+
//| Delete entire section from configuration                         |
//+------------------------------------------------------------------+
bool CConfigHandler::DeleteSection(string section)
{
    if(m_config_file_path == "" || !FileIsExist(m_config_file_path, FILE_COMMON))
    {
        return true; // Nothing to delete
    }
    
    int file_handle = FileOpen(m_config_file_path, FILE_READ|FILE_TXT|FILE_ANSI|FILE_COMMON);
    if(file_handle == INVALID_HANDLE)
    {
        return false;
    }
    
    string current_content = FileReadString(file_handle, (int)FileSize(file_handle));
    FileClose(file_handle);
    
    string lines[];
    int line_count = StringSplit(current_content, '\n', lines);
    string new_content = "";
    bool in_target_section = false;
    bool section_found = false;
    
    for(int i = 0; i < line_count; i++)
    {
        string line = lines[i];
        StringTrimLeft(line);
        StringTrimRight(line);
        
        if(StringLen(line) == 0)
        {
            new_content += "\n";
            continue;
        }
        
        // Check for section headers
        if(StringGetCharacter(line, 0) == '[' && StringGetCharacter(line, StringLen(line)-1) == ']')
        {
            if(in_target_section)
            {
                in_target_section = false; // Exiting target section
            }
            
            string current_section = StringSubstr(line, 1, StringLen(line)-2);
            if(current_section == section)
            {
                in_target_section = true;
                section_found = true;
                continue; // Skip the section header
            }
            
            new_content += line + "\n";
        }
        else if(!in_target_section)
        {
            // Only add lines not in the target section
            new_content += line + "\n";
        }
    }
    
    if(!section_found)
    {
        return true; // Section didn't exist, nothing to do
    }
    
    // Write updated content
    file_handle = FileOpen(m_config_file_path, FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_COMMON);
    if(file_handle == INVALID_HANDLE)
    {
        return false;
    }
    
    bool success = (FileWrite(file_handle, new_content) > 0);
    FileClose(file_handle);
    
    return success;
}

//+------------------------------------------------------------------+
//| Format key with section prefix                                   |
//+------------------------------------------------------------------+
string CConfigHandler::FormatKey(string section, string key)
{
    return section + "." + key;
}

//+------------------------------------------------------------------+
//| Parse a configuration line into key and value                    |
//+------------------------------------------------------------------+
bool CConfigHandler::ParseLine(string line, string &out_key, string &out_value)
{
    int separator_pos = StringFind(line, "=");
    if(separator_pos == -1)
    {
        return false;
    }
    
    out_key = StringSubstr(line, 0, separator_pos);
    out_value = StringSubstr(line, separator_pos + 1);
    
    StringTrimLeft(out_key);
    StringTrimRight(out_key);
    StringTrimLeft(out_value);
    StringTrimRight(out_value);
    
    return (StringLen(out_key) > 0);
}

//+------------------------------------------------------------------+
//| Escape special characters in string values                       |
//+------------------------------------------------------------------+
string CConfigHandler::EscapeString(string value)
{
    StringReplace(value, "\\", "\\\\");
    StringReplace(value, "\n", "\\n");
    StringReplace(value, "\r", "\\r");
    StringReplace(value, "\t", "\\t");
    StringReplace(value, "=", "\\=");
    return value;
}

//+------------------------------------------------------------------+
//| Unescape special characters in string values                     |
//+------------------------------------------------------------------+
string CConfigHandler::UnescapeString(string value)
{
    StringReplace(value, "\\=", "=");
    StringReplace(value, "\\t", "\t");
    StringReplace(value, "\\r", "\r");
    StringReplace(value, "\\n", "\n");
    StringReplace(value, "\\\\", "\\");
    return value;
}

//+------------------------------------------------------------------+
#endif // CCONFIGHANDLER_MQH
