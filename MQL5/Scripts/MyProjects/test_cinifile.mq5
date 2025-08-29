//+------------------------------------------------------------------+
//|                                                Test_CIniFile.mq5 |
//+------------------------------------------------------------------+
#property version   "1.00"
#include <MyProjects\EquityCurve\IniFile.mqh>
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//--- create class instance
   CIniFile MyIniFile;
//--- specify file name (.ini)
//--- !!! note the doubled "\\" in the path
   MyIniFile.Init("D:\\test_file.ini");

//--- needed for working with data arrays
   CArrayString Strings;

//--- write
   bool     resb;
   resb=MyIniFile.WriteString("TestSection","TestStringKey","StringValue");
   if(resb)
     {Print("Ok write string");}
   else
     {Print("Error on write string");}

//--- write again
   resb=MyIniFile.WriteInteger("TestSection","TestIntegerKey",888);
   if(resb)
     {Print("Ok write integer");}
   else
     {Print("Error on write integer");}

   string   str;
//--- read the data, that exists
   str=MyIniFile.ReadString("TestSection","TestStringKey","Default Value");
   Print(str);
//--- read the unknown data, it returns the Default Value
   str=MyIniFile.ReadString("TestSection","Something","Default Value");
   Print(str);

//--- if the section is exists, read its KeyNames
   if(MyIniFile.SectionExists("TestSection"))
     {
      MyIniFile.ReadSection("TestSection",Strings);
      for(int i=0; i<Strings.Total(); i++)
        {Print(Strings.At(i));}
     }
  }
//+------------------------------------------------------------------+
