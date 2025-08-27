//+------------------------------------------------------------------+
//|                                                     CRenderer.mqh |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+

//--- Include required MQL5 standard libraries
// Note: MQL5 standard libraries are automatically available in MT5 environment

//--- Layout constants
#define COLUMNS 5                    // Number of strength columns
#define MAX_SYMBOLS_PER_COL 10      // Max symbols per column

//+------------------------------------------------------------------+
//| Class for rendering the SuperSlopeDashboard visualization         |
//+------------------------------------------------------------------+
class CRenderer
{
private:
   // Position and layout attributes
   int               m_start_x;           // Dashboard X start position
   int               m_start_y;           // Dashboard Y start position
   int               m_column_width;      // Width of each column
   int               m_row_height;        // Height of each row
   int               m_header_height;     // Height of header row
   
   // Styling attributes
   string            m_font_name;         // Font name for text
   int               m_font_size;         // Font size for text
   color             m_column_colors[5];  // Colors for each strength column
   color             m_text_color;        // Text color
   color             m_background_color;  // Background color

public:
   //--- Constructor and destructor
                     CRenderer(void);
                    ~CRenderer(void);
   
   //--- Initialization
   bool              Initialize(int start_x = 20, int start_y = 50);
   
   //--- Main rendering methods
   void              DrawDashboardHeaders(void);
   void              Draw(string &symbols_strong_bull[], int count_strong_bull,
                         string &symbols_weak_bull[], int count_weak_bull,
                         string &symbols_neutral[], int count_neutral,
                         string &symbols_weak_bear[], int count_weak_bear,
                         string &symbols_strong_bear[], int count_strong_bear,
                         double &values_strong_bull[], double &values_weak_bull[],
                         double &values_neutral[], double &values_weak_bear[],
                         double &values_strong_bear[]);
   void              DeleteAllObjects(void);
   void              DrawSymbolRow(int column, int row, string symbol, double value);
   
   //--- Utility methods
   void              GetSymbolsForCategory(string &symbols[], double &values[], 
                                          int strength_category, string &out_symbols[], 
                                          double &out_values[], int &count);
   int               GetStrengthCategory(double value);
   bool              ObjectsExist(void);
   int               GetObjectCount(void);
   void              MakeObjectPersistent(string obj_name);
   
   //--- Utility methods
   void              SetColors(color strong_bull, color weak_bull, color neutral, 
                              color weak_bear, color strong_bear);
   void              SetPosition(int x, int y);
   void              SetDimensions(int col_width, int row_height);
   
   //--- Getters
   int               GetStartX(void) const { return m_start_x; }
   int               GetStartY(void) const { return m_start_y; }
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CRenderer::CRenderer(void)
{
   // Default position and dimensions
   m_start_x = 20;
   m_start_y = 50;
   m_column_width = 120;
   m_row_height = 20;
   m_header_height = 25;
   
   // Default styling
   m_font_name = "Arial";
   m_font_size = 9;
   m_text_color = clrWhite;
   m_background_color = clrBlack;
   
   // Default color scheme
   m_column_colors[0] = clrLime;        // Strong Bull
   m_column_colors[1] = clrGreen;       // Weak Bull
   m_column_colors[2] = clrYellow;      // Neutral
   m_column_colors[3] = clrOrange;      // Weak Bear
   m_column_colors[4] = clrRed;         // Strong Bear
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CRenderer::~CRenderer(void)
{
   DeleteAllObjects();
}

//+------------------------------------------------------------------+
//| Initialize the renderer                                            |
//+------------------------------------------------------------------+
bool CRenderer::Initialize(int start_x = 20, int start_y = 50)
{
   m_start_x = start_x;
   m_start_y = start_y;
   
   // Clean up any existing objects
   DeleteAllObjects();
   
   return true;
}

//+------------------------------------------------------------------+
//| Utility method to get symbols for strength category              |
//+------------------------------------------------------------------+
void CRenderer::GetSymbolsForCategory(string &symbols[], double &values[], 
                                      int strength_category, string &out_symbols[], double &out_values[], int &count)
{
   count = 0;
   ArrayResize(out_symbols, 0);
   ArrayResize(out_values, 0);
   
   int total_symbols = ArraySize(symbols);
   for(int i = 0; i < total_symbols && count < MAX_SYMBOLS_PER_COL; i++)
   {
      double value = values[i];
      int category = GetStrengthCategory(value);
      
      if(category == strength_category)
      {
         ArrayResize(out_symbols, count + 1);
         ArrayResize(out_values, count + 1);
         out_symbols[count] = symbols[i];
         out_values[count] = value;
         count++;
      }
   }
}

//+------------------------------------------------------------------+
//| Determine strength category based on value                        |
//+------------------------------------------------------------------+
int CRenderer::GetStrengthCategory(double value)
{
   // Use the same thresholds as the controller for consistency
   // These should match the controller's CategorizeStrength method
   if(value >= 2.0) return 0;      // Strong Bull (Very Strong)
   if(value >= 1.0) return 1;      // Weak Bull (Strong)  
   if(value >= -1.0) return 2;     // Neutral
   if(value >= -2.0) return 3;     // Weak Bear (Weak)
   return 4;                       // Strong Bear (Very Weak)
}

//+------------------------------------------------------------------+
//| Check if dashboard objects exist                                   |
//+------------------------------------------------------------------+
bool CRenderer::ObjectsExist(void)
{
   return ObjectFind(0, "SSD_Header_0") >= 0;
}

//+------------------------------------------------------------------+
//| Get total count of dashboard objects                              |
//+------------------------------------------------------------------+
int CRenderer::GetObjectCount(void)
{
   int count = 0;
   int total = ObjectsTotal(0);
   
   for(int i = 0; i < total; i++)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, "SSD_") == 0)
         count++;
   }
   
   return count;
}

//+------------------------------------------------------------------+
//| Make object persistent across script executions                   |
//+------------------------------------------------------------------+
void CRenderer::MakeObjectPersistent(string obj_name)
{
   ObjectSetInteger(0, obj_name, OBJPROP_BACK, false);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, obj_name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, obj_name, OBJPROP_HIDDEN, false);
}

//+------------------------------------------------------------------+
//| Draw dashboard headers                                             |
//+------------------------------------------------------------------+
void CRenderer::DrawDashboardHeaders(void)
{
   string headers[5] = {"Strong Bull", "Weak Bull", "Neutral", "Weak Bear", "Strong Bear"};
   
   for(int i = 0; i < COLUMNS; i++)
   {
      string obj_name = "SSD_Header_" + IntegerToString(i);
      int x_pos = m_start_x + (i * m_column_width);
      
      // Create header background rectangle
      ObjectCreate(0, obj_name + "_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj_name + "_BG", OBJPROP_XDISTANCE, x_pos);
      ObjectSetInteger(0, obj_name + "_BG", OBJPROP_YDISTANCE, m_start_y);
      ObjectSetInteger(0, obj_name + "_BG", OBJPROP_XSIZE, m_column_width - 2);
      ObjectSetInteger(0, obj_name + "_BG", OBJPROP_YSIZE, m_header_height);
      ObjectSetInteger(0, obj_name + "_BG", OBJPROP_BGCOLOR, m_column_colors[i]);
      ObjectSetInteger(0, obj_name + "_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
      ObjectSetInteger(0, obj_name + "_BG", OBJPROP_COLOR, clrBlack);
      
      // Create header text
      ObjectCreate(0, obj_name + "_TEXT", OBJ_LABEL, 0, 0, 0);
      ObjectSetInteger(0, obj_name + "_TEXT", OBJPROP_XDISTANCE, x_pos + 5);
      ObjectSetInteger(0, obj_name + "_TEXT", OBJPROP_YDISTANCE, m_start_y + 5);
      ObjectSetString(0, obj_name + "_TEXT", OBJPROP_TEXT, headers[i]);
      ObjectSetString(0, obj_name + "_TEXT", OBJPROP_FONT, m_font_name);
      ObjectSetInteger(0, obj_name + "_TEXT", OBJPROP_FONTSIZE, m_font_size + 1);
      ObjectSetInteger(0, obj_name + "_TEXT", OBJPROP_COLOR, clrBlack);
   }
}

//+------------------------------------------------------------------+
//| Main draw method with symbol data                                  |
//+------------------------------------------------------------------+
void CRenderer::Draw(string &symbols_strong_bull[], int count_strong_bull,
                    string &symbols_weak_bull[], int count_weak_bull,
                    string &symbols_neutral[], int count_neutral,
                    string &symbols_weak_bear[], int count_weak_bear,
                    string &symbols_strong_bear[], int count_strong_bear,
                    double &values_strong_bull[], double &values_weak_bull[],
                    double &values_neutral[], double &values_weak_bear[],
                    double &values_strong_bear[])
{
   // Clear existing objects
   DeleteAllObjects();
   
   // Draw headers
   DrawDashboardHeaders();
   
   // Draw symbols in each column
   // Column 0: Strong Bull
   for(int i = 0; i < count_strong_bull && i < MAX_SYMBOLS_PER_COL; i++)
   {
      DrawSymbolRow(0, i, symbols_strong_bull[i], values_strong_bull[i]);
   }
   
   // Column 1: Weak Bull
   for(int i = 0; i < count_weak_bull && i < MAX_SYMBOLS_PER_COL; i++)
   {
      DrawSymbolRow(1, i, symbols_weak_bull[i], values_weak_bull[i]);
   }
   
   // Column 2: Neutral
   for(int i = 0; i < count_neutral && i < MAX_SYMBOLS_PER_COL; i++)
   {
      DrawSymbolRow(2, i, symbols_neutral[i], values_neutral[i]);
   }
   
   // Column 3: Weak Bear
   for(int i = 0; i < count_weak_bear && i < MAX_SYMBOLS_PER_COL; i++)
   {
      DrawSymbolRow(3, i, symbols_weak_bear[i], values_weak_bear[i]);
   }
   
   // Column 4: Strong Bear
   for(int i = 0; i < count_strong_bear && i < MAX_SYMBOLS_PER_COL; i++)
   {
      DrawSymbolRow(4, i, symbols_strong_bear[i], values_strong_bear[i]);
   }
}

//+------------------------------------------------------------------+
//| Delete all dashboard objects                                       |
//+------------------------------------------------------------------+
void CRenderer::DeleteAllObjects(void)
{
   // Delete all objects with SSD_ prefix
   int total_objects = ObjectsTotal(0);
   
   for(int i = total_objects - 1; i >= 0; i--)
   {
      string obj_name = ObjectName(0, i);
      if(StringFind(obj_name, "SSD_") == 0)
      {
         ObjectDelete(0, obj_name);
      }
   }
   
   // Refresh chart to ensure objects are removed
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Draw a symbol row in specified column                             |
//+------------------------------------------------------------------+
void CRenderer::DrawSymbolRow(int column, int row, string symbol, double value)
{
   if(column < 0 || column >= COLUMNS || row < 0 || row >= MAX_SYMBOLS_PER_COL)
      return;
      
   string obj_name = "SSD_Symbol_" + IntegerToString(column) + "_" + IntegerToString(row);
   int x_pos = m_start_x + (column * m_column_width);
   int y_pos = m_start_y + m_header_height + (row * m_row_height);
   
   // Create row background for better readability
   ObjectCreate(0, obj_name + "_BG", OBJ_RECTANGLE_LABEL, 0, 0, 0);
   ObjectSetInteger(0, obj_name + "_BG", OBJPROP_XDISTANCE, x_pos);
   ObjectSetInteger(0, obj_name + "_BG", OBJPROP_YDISTANCE, y_pos);
   ObjectSetInteger(0, obj_name + "_BG", OBJPROP_XSIZE, m_column_width - 2);
   ObjectSetInteger(0, obj_name + "_BG", OBJPROP_YSIZE, m_row_height - 1);
   ObjectSetInteger(0, obj_name + "_BG", OBJPROP_BGCOLOR, clrWhiteSmoke);
   ObjectSetInteger(0, obj_name + "_BG", OBJPROP_BORDER_TYPE, BORDER_FLAT);
   ObjectSetInteger(0, obj_name + "_BG", OBJPROP_COLOR, clrSilver);
   
   // Create symbol text
   string display_text = symbol + " " + DoubleToString(value, 2);
   
   ObjectCreate(0, obj_name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0, obj_name, OBJPROP_XDISTANCE, x_pos + 5);
   ObjectSetInteger(0, obj_name, OBJPROP_YDISTANCE, y_pos + 3);
   ObjectSetString(0, obj_name, OBJPROP_TEXT, display_text);
   ObjectSetString(0, obj_name, OBJPROP_FONT, m_font_name);
   ObjectSetInteger(0, obj_name, OBJPROP_FONTSIZE, m_font_size);
   ObjectSetInteger(0, obj_name, OBJPROP_COLOR, clrBlack);
}

//+------------------------------------------------------------------+
//| Set custom colors for columns                                     |
//+------------------------------------------------------------------+
void CRenderer::SetColors(color strong_bull, color weak_bull, color neutral, 
                         color weak_bear, color strong_bear)
{
   m_column_colors[0] = strong_bull;
   m_column_colors[1] = weak_bull;
   m_column_colors[2] = neutral;
   m_column_colors[3] = weak_bear;
   m_column_colors[4] = strong_bear;
}

//+------------------------------------------------------------------+
//| Set dashboard position                                             |
//+------------------------------------------------------------------+
void CRenderer::SetPosition(int x, int y)
{
   m_start_x = x;
   m_start_y = y;
}

//+------------------------------------------------------------------+
//| Set column and row dimensions                                      |
//+------------------------------------------------------------------+
void CRenderer::SetDimensions(int col_width, int row_height)
{
   m_column_width = col_width;
   m_row_height = row_height;
}
