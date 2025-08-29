//+------------------------------------------------------------------+
//|                                                      IniFile.mqh |
//|                                  Copyright 2010, Henadiy Batohov |
//|                          https://login.mql5.com/ru/users/Batohov |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Henadiy Batohov"
#property link      "https://login.mql5.com/ru/users/Batohov"
#property version   "1.00"

//--- import WinAPI functions 
#import "kernel32.dll"
uint WritePrivateProfileStringW(string &lpAppName,string &lpKeyName,string &lpString,string &lpFileName);
uint GetPrivateProfileStringW(string &lpAppName,string &lpKeyName,string &lpDefault,ushort &lpReturnedString[],uint nSize,string &lpFileName);
#import

//--- CArrayString class will be used
#include <Arrays\ArrayString.mqh>
//+------------------------------------------------------------------+
//| CIniFile - a class for operations with .INI files                |
//+------------------------------------------------------------------+
class CIniFile
  {
private:
   string            m_file_name;
public:
                     CIniFile();
                    ~CIniFile();
   string               FileName() { return(m_file_name); }
   void              Init(const string FileName); // file name is passed when initialization
   bool              UpdateFile();

   //--- reading and writing the values
   virtual string    ReadString(string Section,string Ident,string Default);
   virtual bool      WriteString(string Section,string Ident,string Value);
   virtual long      ReadInteger(string Section,string Ident,long Default);
   virtual bool      WriteInteger(string Section,string Ident,long Value);
   virtual bool      ReadBool(string Section,string Ident,bool Default);
   virtual bool      WriteBool(string Section,string Ident,bool Value);
   virtual datetime  ReadDateTime(string Section,string Ident,datetime Default);
   virtual bool      WriteDateTime(string Section,string Ident,datetime Value,int Mode=TIME_DATE|TIME_SECONDS);
   virtual double    ReadFloat(string Section,string Ident,double Default);
   virtual bool      WriteFloat(string Section,string Ident,double Value);

   //--- working with data arrays
   virtual void      ReadSection(string Section,CArrayString &Strings);
   virtual void      ReadSections(CArrayString &Strings);
   virtual void      ReadSectionValues(string Section,CArrayString &Strings);

   //--- checking
   virtual bool      SectionExists(string Section);
   virtual bool      ValueExists(string Section,string Ident);

   //--- delete
   virtual bool      DeleteKey(string Section,string Ident);
   virtual bool      EraseSection(string Section);

  };
//+------------------------------------------------------------------+
//| CIniFile class constructor                                       |
//+------------------------------------------------------------------+
void CIniFile::CIniFile(void)
  {
   m_file_name="";
  }
//+------------------------------------------------------------------+
//| CIniFile class destructor                                        |
//+------------------------------------------------------------------+
void CIniFile::~CIniFile(void)
  {
   UpdateFile();
  }
//+------------------------------------------------------------------+
//| Init                                                             |
//+------------------------------------------------------------------+
void CIniFile::Init(const string FileName)
  {
   m_file_name=FileName;
  }
//+------------------------------------------------------------------+
//| ReadString                                                       |
//+------------------------------------------------------------------+
string CIniFile::ReadString(string Section,string Ident,string Default)
  {
   ushort buffer[4096];
   GetPrivateProfileStringW(Section,Ident,Default,buffer,ArraySize(buffer),m_file_name);

   string str_res=ShortArrayToString(buffer);
   return(str_res);
  }
//+------------------------------------------------------------------+
//| WriteString                                                      |
//+------------------------------------------------------------------+
bool CIniFile::WriteString(string Section,string Ident,string Value)
  {
   return(WritePrivateProfileStringW(Section,Ident,Value,m_file_name)!=0);
  }
//+------------------------------------------------------------------+
//| ReadInteger                                                      |
//+------------------------------------------------------------------+
long CIniFile::ReadInteger(string Section,string Ident,long Default)
  {
   string int_str=ReadString(Section,Ident,"");
   if(int_str=="") { return(Default); }

   long int_res= StringToInteger(int_str);
   if((int_res == 0) &&(int_str != "0"))
     {
      return(Default);
     }
   else
     {
      return(int_res);
     }
  }
//+------------------------------------------------------------------+
//| WriteInteger                                                     |
//+------------------------------------------------------------------+
bool CIniFile::WriteInteger(string Section,string Ident,long Value)
  {
   return(WriteString(Section,Ident,IntegerToString(Value)));
  }
//+------------------------------------------------------------------+
//| ReadBool                                                         |
//+------------------------------------------------------------------+
bool CIniFile::ReadBool(string Section,string Ident,bool Default)
  {
   return(ReadInteger(Section,Ident,(int)Default)!=0);
  }
//+------------------------------------------------------------------+
//| WriteBool                                                        |
//+------------------------------------------------------------------+
bool CIniFile::WriteBool(string Section,string Ident,bool Value)
  {
   return(WriteInteger(Section,Ident,(int)Value));
  }
//+------------------------------------------------------------------+
//| ReadDateTime                                                     |
//+------------------------------------------------------------------+
datetime CIniFile::ReadDateTime(string Section,string Ident,datetime Default)
  {
   string dt_str=ReadString(Section,Ident,"");
   if(dt_str=="") { return(Default); }

   datetime dt_res=StringToTime(dt_str);
   return(dt_res);
  }
//+------------------------------------------------------------------+
//| WriteDateTime                                                    |
//+------------------------------------------------------------------+
bool CIniFile::WriteDateTime(string Section,string Ident,datetime Value,int Mode=TIME_DATE|TIME_SECONDS)
  {
   return(WriteString(Section,Ident,TimeToString(Value,Mode)));
  }
//+------------------------------------------------------------------+
//| ReadFloat                                                        |
//+------------------------------------------------------------------+
double CIniFile::ReadFloat(string Section,string Ident,double Default)
  {
   string float_str=ReadString(Section,Ident,"");
   if(float_str=="") { return(Default); }

   double float_res=StringToDouble(float_str);
   if((float_res==0) && (float_str!="0.00000000"))
     {
      return(Default);
     }
   else
     {
      return(float_res);
     }
  }
//+------------------------------------------------------------------+
//| WriteFloat                                                       |
//+------------------------------------------------------------------+
bool CIniFile::WriteFloat(string Section,string Ident,double Value)
  {
   return(WriteString(Section,Ident,DoubleToString(Value)));
  }
//+------------------------------------------------------------------+
//| ReadSection                                                      |
//+------------------------------------------------------------------+
void CIniFile::ReadSection(string Section,CArrayString &Strings)
  {
   string ident = NULL;
   string value = NULL;
   int    char_count;
   ushort buffer[16384];
   string str_res="";

   Strings.Clear();
   char_count=(int)GetPrivateProfileStringW(Section,ident,value,buffer,ArraySize(buffer),m_file_name);
   for(int i=0; i<char_count; i++)
     {
      if((buffer[i]==0))
        {
         Strings.Add(str_res);
         str_res="";
        }
      else
        {
         str_res+=ShortToString(buffer[i]);
        }
     }
  }
//+------------------------------------------------------------------+
//| ReadSections                                                     |
//+------------------------------------------------------------------+
void CIniFile::ReadSections(CArrayString &Strings)
  {
   string section=NULL;
   ReadSection(section,Strings);
  }
//+------------------------------------------------------------------+
//| ReadSectionValues                                                |
//+------------------------------------------------------------------+
void CIniFile::ReadSectionValues(string Section,CArrayString &Strings)
  {
   CArrayString KeyList;
   ReadSection(Section,KeyList);

   Strings.Clear();
   for(int i=0; i<KeyList.Total(); i++)
     {
      Strings.Add(KeyList.At(i)+"="+ReadString(Section,KeyList.At(i),""));
     }
  }
//+------------------------------------------------------------------+
//| SectionExists                                                    |
//+------------------------------------------------------------------+
bool CIniFile::SectionExists(string Section)
  {
   CArrayString Strings;
   ReadSection(Section,Strings);
   return(Strings.Total()>0);
  }
//+------------------------------------------------------------------+
//| ValueExists                                                      |
//+------------------------------------------------------------------+
bool CIniFile::ValueExists(string Section,string Ident)
  {
   CArrayString Strings;
   ReadSection(Section,Strings);
   Strings.Sort();
   return(Strings.Search(Ident)>-1);
  }
//+------------------------------------------------------------------+
//| DeleteKey                                                        |
//+------------------------------------------------------------------+
bool CIniFile::DeleteKey(string Section,string Ident)
  {
   string value=NULL;
   return(WritePrivateProfileStringW(Section,Ident,value,m_file_name)!=0);
  }
//+------------------------------------------------------------------+
//| EraseSection                                                     |
//+------------------------------------------------------------------+
bool CIniFile::EraseSection(string Section)
  {
   string ident = NULL;
   string value = NULL;
   return(WritePrivateProfileStringW(Section,ident,value,m_file_name)!=0);
  }
//+------------------------------------------------------------------+
//| UpdateFile                                                       |
//+------------------------------------------------------------------+
bool CIniFile::UpdateFile()
  {
   string section=NULL;
   string ident = NULL;
   string value = NULL;
   return(WritePrivateProfileStringW(section,ident,value,m_file_name)!=0);
  }
//+------------------------------------------------------------------+
