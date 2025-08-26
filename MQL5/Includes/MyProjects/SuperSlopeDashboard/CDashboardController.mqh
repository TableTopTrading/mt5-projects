//+------------------------------------------------------------------+
//|                                          CDashboardController.mqh |
//|                                       Copyright 2025, Cal Morgan |
//|                                          web3spotlight@gmail.com |
//+------------------------------------------------------------------+

//--- Include required components
#include <MyProjects/SuperSlopeDashboard/CDataManager.mqh>
#include <MyProjects/SuperSlopeDashboard/CRenderer.mqh>

//--- Constants for strength categorization
#define STRONG_BULL_THRESHOLD    2.0
#define WEAK_BULL_THRESHOLD      1.0
#define NEUTRAL_UPPER_THRESHOLD  1.0
#define NEUTRAL_LOWER_THRESHOLD -1.0
#define WEAK_BEAR_THRESHOLD     -2.0
#define MAX_SYMBOLS_PER_DASHBOARD 50

//+------------------------------------------------------------------+
//| Controller class that orchestrates Model and View components      |
//+------------------------------------------------------------------+
class CDashboardController
{
private:
   // Core component instances
   CDataManager      m_data_manager;        // Model: Calculation engine
   CRenderer         m_renderer;            // View: Dashboard rendering
   
   // Symbol management
   string            m_symbols[];           // Array of symbols to monitor
   int               m_symbol_count;        // Number of active symbols
   
   // Calculated data storage
   double            m_strength_values[];   // Strength values per symbol
   int               m_categories[];        // Category index per symbol
   bool              m_valid_data[];        // Data validity flags per symbol
   
   // Configuration parameters
   double            m_threshold_strong_bull;   // Strong bull threshold (default: 2.0)
   double            m_threshold_weak_bull;     // Weak bull threshold (default: 1.0)
   double            m_threshold_weak_bear;     // Weak bear threshold (default: -2.0)
   int               m_ma_period;               // Moving Average period
   int               m_atr_period;              // ATR period
   
   // Dashboard settings
   int               m_dashboard_x;         // Dashboard X position
   int               m_dashboard_y;         // Dashboard Y position
   bool              m_is_initialized;      // Initialization status
   
   // Internal helper methods
   int               CategorizeStrength(double strength_value);
   void              SortSymbolsByStrength(void);
   bool              IsValidSymbol(string symbol);
   void              ResizeArrays(int new_size);

public:
   //--- Constructor and destructor
                     CDashboardController(void);
                    ~CDashboardController(void);
   
   //--- Initialization and configuration
   bool              Initialize(int ma_period = 20, int atr_period = 14, 
                               int dashboard_x = 20, int dashboard_y = 50);
   bool              SetSymbols(string &symbols[]);
   bool              SetThresholds(double strong_bull = 2.0, double weak_bull = 1.0, 
                                  double weak_bear = -2.0);
   bool              SetDashboardPosition(int x, int y);
   void              SetColors(color strong_bull_color, color weak_bull_color, 
                              color neutral_color, color weak_bear_color, 
                              color strong_bear_color);
   
   //--- Main operational methods
   bool              Update(void);                    // Main update method for OnCalculate
   bool              Refresh(void);                   // Force refresh of all calculations
   void              Clear(void);                     // Clear dashboard display
   
   //--- Status and information methods
   bool              IsInitialized(void) { return m_is_initialized; }
   int               GetSymbolCount(void) { return m_symbol_count; }
   double            GetSymbolStrength(string symbol);
   int               GetSymbolCategory(string symbol);
   string            GetStatusInfo(void);
   
   //--- Cleanup
   void              Cleanup(void);
};

//+------------------------------------------------------------------+
//| Constructor                                                        |
//+------------------------------------------------------------------+
CDashboardController::CDashboardController(void)
{
   // Initialize configuration with default values
   m_threshold_strong_bull = STRONG_BULL_THRESHOLD;
   m_threshold_weak_bull = WEAK_BULL_THRESHOLD;
   m_threshold_weak_bear = WEAK_BEAR_THRESHOLD;
   m_ma_period = 20;
   m_atr_period = 14;
   
   // Initialize dashboard position
   m_dashboard_x = 20;
   m_dashboard_y = 50;
   
   // Initialize state
   m_symbol_count = 0;
   m_is_initialized = false;
   
   // Initialize arrays
   ArrayResize(m_symbols, 0);
   ArrayResize(m_strength_values, 0);
   ArrayResize(m_categories, 0);
   ArrayResize(m_valid_data, 0);
}

//+------------------------------------------------------------------+
//| Destructor                                                         |
//+------------------------------------------------------------------+
CDashboardController::~CDashboardController(void)
{
   Cleanup();
}

//+------------------------------------------------------------------+
//| Initialize the controller with all components                      |
//+------------------------------------------------------------------+
bool CDashboardController::Initialize(int ma_period = 20, int atr_period = 14, 
                                     int dashboard_x = 20, int dashboard_y = 50)
{
   Print("CDashboardController: Initializing...");
   
   // Store configuration
   m_ma_period = ma_period;
   m_atr_period = atr_period;
   m_dashboard_x = dashboard_x;
   m_dashboard_y = dashboard_y;
   
   // Initialize data manager (Model)
   if(!m_data_manager.Initialize(m_ma_period, m_atr_period, 1000))
   {
      Print("ERROR: Failed to initialize CDataManager");
      return false;
   }
   
   // Initialize renderer (View)
   if(!m_renderer.Initialize(m_dashboard_x, m_dashboard_y))
   {
      Print("ERROR: Failed to initialize CRenderer");
      return false;
   }
   
   // Set default colors for dashboard
   m_renderer.SetColors(clrLime, clrGreen, clrYellow, clrOrange, clrRed);
   m_renderer.SetDimensions(120, 25);
   
   m_is_initialized = true;
   Print("CDashboardController: Initialization completed successfully");
   
   return true;
}

//+------------------------------------------------------------------+
//| Set the list of symbols to monitor                                |
//+------------------------------------------------------------------+
bool CDashboardController::SetSymbols(string &symbols[])
{
   if(!m_is_initialized)
   {
      Print("ERROR: Controller not initialized. Call Initialize() first.");
      return false;
   }
   
   int symbol_count = ArraySize(symbols);
   if(symbol_count == 0)
   {
      Print("WARNING: Empty symbol list provided");
      return false;
   }
   
   if(symbol_count > MAX_SYMBOLS_PER_DASHBOARD)
   {
      Print("WARNING: Too many symbols (", symbol_count, "). Maximum allowed: ", MAX_SYMBOLS_PER_DASHBOARD);
      symbol_count = MAX_SYMBOLS_PER_DASHBOARD;
   }
   
   // Resize and copy symbol array
   ResizeArrays(symbol_count);
   
   int valid_count = 0;
   for(int i = 0; i < symbol_count; i++)
   {
      if(IsValidSymbol(symbols[i]))
      {
         m_symbols[valid_count] = symbols[i];
         m_strength_values[valid_count] = 0.0;
         m_categories[valid_count] = 2; // Default to neutral
         m_valid_data[valid_count] = false;
         valid_count++;
      }
      else
      {
         Print("WARNING: Invalid symbol '", symbols[i], "' - skipping");
      }
   }
   
   m_symbol_count = valid_count;
   
   if(m_symbol_count == 0)
   {
      Print("ERROR: No valid symbols found in the provided list");
      return false;
   }
   
   Print("CDashboardController: Set ", m_symbol_count, " symbols for monitoring");
   return true;
}

//+------------------------------------------------------------------+
//| Set strength categorization thresholds                            |
//+------------------------------------------------------------------+
bool CDashboardController::SetThresholds(double strong_bull = 2.0, double weak_bull = 1.0, 
                                         double weak_bear = -2.0)
{
   // Validate threshold logic
   if(strong_bull <= weak_bull || weak_bull <= 0 || weak_bear >= 0 || weak_bear >= weak_bull)
   {
      Print("ERROR: Invalid threshold values. Must satisfy: strong_bull > weak_bull > 0 > weak_bear");
      return false;
   }
   
   m_threshold_strong_bull = strong_bull;
   m_threshold_weak_bull = weak_bull;
   m_threshold_weak_bear = weak_bear;
   
   Print("CDashboardController: Thresholds set - Strong Bull: ", strong_bull, 
         ", Weak Bull: ", weak_bull, ", Weak Bear: ", weak_bear);
   
   return true;
}

//+------------------------------------------------------------------+
//| Set dashboard position on chart                                   |
//+------------------------------------------------------------------+
bool CDashboardController::SetDashboardPosition(int x, int y)
{
   if(x < 0 || y < 0)
   {
      Print("ERROR: Dashboard position coordinates must be positive");
      return false;
   }
   
   m_dashboard_x = x;
   m_dashboard_y = y;
   
   if(m_is_initialized)
   {
      m_renderer.SetPosition(x, y);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Set custom colors for dashboard columns                           |
//+------------------------------------------------------------------+
void CDashboardController::SetColors(color strong_bull_color, color weak_bull_color, 
                                     color neutral_color, color weak_bear_color, 
                                     color strong_bear_color)
{
   if(m_is_initialized)
   {
      m_renderer.SetColors(strong_bull_color, weak_bull_color, neutral_color, 
                          weak_bear_color, strong_bear_color);
   }
}

//+------------------------------------------------------------------+
//| Get strength value for specific symbol                            |
//+------------------------------------------------------------------+
double CDashboardController::GetSymbolStrength(string symbol)
{
   for(int i = 0; i < m_symbol_count; i++)
   {
      if(m_symbols[i] == symbol)
      {
         return m_strength_values[i];
      }
   }
   return 0.0; // Symbol not found
}

//+------------------------------------------------------------------+
//| Get category for specific symbol                                  |
//+------------------------------------------------------------------+
int CDashboardController::GetSymbolCategory(string symbol)
{
   for(int i = 0; i < m_symbol_count; i++)
   {
      if(m_symbols[i] == symbol)
      {
         return m_categories[i];
      }
   }
   return 2; // Default to neutral if not found
}

//+------------------------------------------------------------------+
//| Get status information string                                     |
//+------------------------------------------------------------------+
string CDashboardController::GetStatusInfo(void)
{
   if(!m_is_initialized)
      return "Controller not initialized";
   
   return StringFormat("Symbols: %d, MA: %d, ATR: %d, Position: (%d,%d)", 
                      m_symbol_count, m_ma_period, m_atr_period, 
                      m_dashboard_x, m_dashboard_y);
}

//+------------------------------------------------------------------+
//| Clear dashboard display                                            |
//+------------------------------------------------------------------+
void CDashboardController::Clear(void)
{
   if(m_is_initialized)
   {
      m_renderer.DeleteAllObjects();
   }
}

//+------------------------------------------------------------------+
//| Cleanup all resources                                             |
//+------------------------------------------------------------------+
void CDashboardController::Cleanup(void)
{
   if(m_is_initialized)
   {
      Clear();
      m_data_manager.Deinitialize();
      m_is_initialized = false;
   }
   
   // Clear arrays
   ArrayFree(m_symbols);
   ArrayFree(m_strength_values);
   ArrayFree(m_categories);
   ArrayFree(m_valid_data);
   
   m_symbol_count = 0;
}

//+------------------------------------------------------------------+
//| Categorize strength value into dashboard column                   |
//+------------------------------------------------------------------+
int CDashboardController::CategorizeStrength(double strength_value)
{
   if(strength_value >= m_threshold_strong_bull)
      return 0; // Strong Bull
   else if(strength_value >= m_threshold_weak_bull)
      return 1; // Weak Bull
   else if(strength_value >= m_threshold_weak_bear)
      return 2; // Neutral
   else if(strength_value >= (m_threshold_weak_bear * 2.0))
      return 3; // Weak Bear
   else
      return 4; // Strong Bear
}

//+------------------------------------------------------------------+
//| Validate if symbol is available in MT5                           |
//+------------------------------------------------------------------+
bool CDashboardController::IsValidSymbol(string symbol)
{
   if(StringLen(symbol) == 0)
      return false;
   
   // Check if symbol exists in Market Watch or can be selected
   return SymbolSelect(symbol, true);
}

//+------------------------------------------------------------------+
//| Resize internal arrays to accommodate symbol count               |
//+------------------------------------------------------------------+
void CDashboardController::ResizeArrays(int new_size)
{
   ArrayResize(m_symbols, new_size);
   ArrayResize(m_strength_values, new_size);
   ArrayResize(m_categories, new_size);
   ArrayResize(m_valid_data, new_size);
}

//+------------------------------------------------------------------+
//| Main update method - Core business logic implementation          |
//+------------------------------------------------------------------+
bool CDashboardController::Update(void)
{
   if(!m_is_initialized)
   {
      Print("ERROR: Controller not initialized");
      return false;
   }
   
   if(m_symbol_count == 0)
   {
      Print("WARNING: No symbols configured for monitoring");
      return false;
   }
   
   // Step 1: Calculate strength for each symbol
   int valid_symbol_count = 0;
   for(int i = 0; i < m_symbol_count; i++)
   {
      string symbol = m_symbols[i];
      
      // Calculate strength using CDataManager
      double strength = m_data_manager.CalculateStrengthValue(symbol);
      
      // Check if calculation was successful (valid data)
      if(strength != EMPTY_VALUE && strength != 0.0)
      {
         m_strength_values[i] = strength;
         m_categories[i] = CategorizeStrength(strength);
         m_valid_data[i] = true;
         valid_symbol_count++;
      }
      else
      {
         m_valid_data[i] = false;
         // Keep previous values for invalid data
      }
   }
   
   if(valid_symbol_count == 0)
   {
      Print("WARNING: No valid strength calculations available");
      return false;
   }
   
   // Step 2: Sort symbols within categories for proper display order
   SortSymbolsByStrength();
   
   // Step 3: Prepare categorized arrays for renderer
   string very_strong_symbols[];
   string strong_symbols[];
   string neutral_symbols[];
   string weak_symbols[];
   string very_weak_symbols[];
   
   double very_strong_values[];
   double strong_values[];
   double neutral_values[];
   double weak_values[];
   double very_weak_values[];
   
   // Clear arrays
   ArrayResize(very_strong_symbols, 0);
   ArrayResize(strong_symbols, 0);
   ArrayResize(neutral_symbols, 0);
   ArrayResize(weak_symbols, 0);
   ArrayResize(very_weak_symbols, 0);
   
   ArrayResize(very_strong_values, 0);
   ArrayResize(strong_values, 0);
   ArrayResize(neutral_values, 0);
   ArrayResize(weak_values, 0);
   ArrayResize(very_weak_values, 0);
   
   // Distribute symbols into category arrays
   for(int i = 0; i < m_symbol_count; i++)
   {
      if(!m_valid_data[i]) continue; // Skip invalid data
      
      int category = m_categories[i];
      string symbol = m_symbols[i];
      double strength = m_strength_values[i];
      
      switch(category)
      {
         case 0: // Strong Bull
            ArrayResize(very_strong_symbols, ArraySize(very_strong_symbols) + 1);
            ArrayResize(very_strong_values, ArraySize(very_strong_values) + 1);
            very_strong_symbols[ArraySize(very_strong_symbols) - 1] = symbol;
            very_strong_values[ArraySize(very_strong_values) - 1] = strength;
            break;
            
         case 1: // Weak Bull
            ArrayResize(strong_symbols, ArraySize(strong_symbols) + 1);
            ArrayResize(strong_values, ArraySize(strong_values) + 1);
            strong_symbols[ArraySize(strong_symbols) - 1] = symbol;
            strong_values[ArraySize(strong_values) - 1] = strength;
            break;
            
         case 2: // Neutral
            ArrayResize(neutral_symbols, ArraySize(neutral_symbols) + 1);
            ArrayResize(neutral_values, ArraySize(neutral_values) + 1);
            neutral_symbols[ArraySize(neutral_symbols) - 1] = symbol;
            neutral_values[ArraySize(neutral_values) - 1] = strength;
            break;
            
         case 3: // Weak Bear
            ArrayResize(weak_symbols, ArraySize(weak_symbols) + 1);
            ArrayResize(weak_values, ArraySize(weak_values) + 1);
            weak_symbols[ArraySize(weak_symbols) - 1] = symbol;
            weak_values[ArraySize(weak_values) - 1] = strength;
            break;
            
         case 4: // Strong Bear
            ArrayResize(very_weak_symbols, ArraySize(very_weak_symbols) + 1);
            ArrayResize(very_weak_values, ArraySize(very_weak_values) + 1);
            very_weak_symbols[ArraySize(very_weak_symbols) - 1] = symbol;
            very_weak_values[ArraySize(very_weak_values) - 1] = strength;
            break;
      }
   }
   
   // Step 4: Update renderer with categorized data
   m_renderer.Draw(very_strong_symbols, ArraySize(very_strong_symbols),
                   strong_symbols, ArraySize(strong_symbols),
                   neutral_symbols, ArraySize(neutral_symbols),
                   weak_symbols, ArraySize(weak_symbols),
                   very_weak_symbols, ArraySize(very_weak_symbols),
                   very_strong_values, strong_values, neutral_values, weak_values, very_weak_values);
   
   Print("CDashboardController: Updated dashboard with ", valid_symbol_count, " valid symbols");
   return true;
}

//+------------------------------------------------------------------+
//| Force refresh of all calculations                                 |
//+------------------------------------------------------------------+
bool CDashboardController::Refresh(void)
{
   return Update();
}

//+------------------------------------------------------------------+
//| Sort symbols by strength within their categories                  |
//+------------------------------------------------------------------+
void CDashboardController::SortSymbolsByStrength(void)
{
   // Use simple bubble sort to sort symbols by strength within the entire array
   // This ensures that when we distribute into categories, they're already ordered
   
   for(int i = 0; i < m_symbol_count - 1; i++)
   {
      for(int j = 0; j < m_symbol_count - 1 - i; j++)
      {
         // Skip invalid data entries
         if(!m_valid_data[j] || !m_valid_data[j + 1]) continue;
         
         // Sort by strength (descending order - strongest first)
         if(m_strength_values[j] < m_strength_values[j + 1])
         {
            // Swap all related arrays to maintain consistency
            
            // Swap symbols
            string temp_symbol = m_symbols[j];
            m_symbols[j] = m_symbols[j + 1];
            m_symbols[j + 1] = temp_symbol;
            
            // Swap strength values
            double temp_strength = m_strength_values[j];
            m_strength_values[j] = m_strength_values[j + 1];
            m_strength_values[j + 1] = temp_strength;
            
            // Swap categories
            int temp_category = m_categories[j];
            m_categories[j] = m_categories[j + 1];
            m_categories[j + 1] = temp_category;
            
            // Swap validity flags
            bool temp_valid = m_valid_data[j];
            m_valid_data[j] = m_valid_data[j + 1];
            m_valid_data[j + 1] = temp_valid;
         }
      }
   }
}
