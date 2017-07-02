-------------------------------------------------------------------------------
-- Project    : Moving Average Filter
-------------------------------------------------------------------------------
-- File       : MovingAverage.vhd
-- Author     : M. Tarique Saleem  <mtariquesaleem@gmail.com>
-- Company    :
-- Created    : 2017-05-20
-- Last update: 2017-05-20
-- Platform   :
-------------------------------------------------------------------------------
-- Description: Application of Moving Average Filter on input data stream
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  		    Description
-- 2017-05-20  1.0      mtariquesaleem	Created
-------------------------------------------------------------------------------

-- Entity:
--  input Clock
--  input "Start-Signal"
--  output "Ready-Signal"
--  width of input and output data 16 Bit
--  variable window-width at the range of 8 to 256 only of power of two
--  to store the data use the internal memory of FPGA


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real."log2";

library work;



entity MovingAverage is
  
  Generic(
    C_WINDOW_WIDTH  : natural range 8 to 256 := 8; --! only power of two
    C_DWIDTH        : natural := 16
  );
  
  Port (
    i_rst       : in STD_LOGIC; -- active high reset input
    i_clk       : in STD_LOGIC; -- clock input
    
    i_start     : in STD_LOGIC; --! Start the calculation
    i_data_in   : in STD_LOGIC_VECTOR(C_DWIDTH-1 downto 0); --! Value to process
    
    o_ready     : out STD_LOGIC := '0'; --! The data_out signal makes sense
    o_data_out  : out STD_LOGIC_VECTOR(C_DWIDTH-1 downto 0) --! A new value
  );
  
end MovingAverage;

------------------------------------------------------------------------------
-- The logic applies the moving average filter to the input stream of data
-- The first output is calculated by applying window of filter to the first
-- incoming no. of values (equal to window size).And window is shifted by 1
-- to get following outputs. To calculate the average, "sum of previous 
-- window is reused, by holding its sum, then adding further the new 
-- input value to it and subtracting the first value of last window. Then 
-- output is divided by simply shift-right function to get the average value

-- The logic consists of 3-stage pipeline: 
-- Register data, Sum (and subtract 1st value of last window) and division .
-- And also a cyclic buffer for storing the values for a window 

-- i_start is taken as a valid signal for data, meaning it needs to be kept high
-- along with new input data to be processed by the logic.
--------------------------------------------------------------------------------

architecture behavioral of MovingAverage is

  constant C_DIV_SCALE  : integer := integer(log2(real(C_WINDOW_WIDTH)));
  
  -- port interface
  signal s_ready        : STD_LOGIC;
  
  -- process: p_reg
  signal s_start        : STD_LOGIC;
  signal s_data_in      : STD_LOGIC_VECTOR(C_DWIDTH-1 downto 0);
  
  -- process: p_buff
  type t_dbuff is array(0 to C_WINDOW_WIDTH-1) of STD_LOGIC_VECTOR(C_DWIDTH-1 downto 0);
  signal s_dbuff        : t_dbuff;
  signal s_wdata_last   : STD_LOGIC_VECTOR(C_DWIDTH-1 downto 0);
  
  signal s_ptr          : integer range 0 to C_WINDOW_WIDTH-1;
  
  -- process: p_div signals
  signal s_data_frac    : STD_LOGIC_VECTOR(C_DWIDTH-1 downto 0);
  signal s_wcnt         : integer range 0 to C_WINDOW_WIDTH;
  signal s_dvalid       : STD_LOGIC;
  
  -- process: p_window_sum signals
  signal s_sum          : STD_LOGIC_VECTOR(C_DWIDTH-1 downto 0);
  
  begin
  
  assert (2**C_DIV_SCALE)=C_WINDOW_WIDTH
    report "Window width not in power of 2" severity failure;
  
  ----------------------------------
  -- Cyclic buffer for storing input data 
  -- values equal to the window size.
  -- after filling up memory with data of 
  -- of 1st window, '1st value of the previous 
  -- window' is replaced by new oncoming data
  -- and also forwarded to the summation part 
  -- for sutraction
  ----------------------------------
  p_buff: process (i_clk)
  begin
    
    if (rising_edge(i_clk)) then
      if (i_rst = '1') then
        s_ptr <= 0;
      else
        
        if (i_start = '1') then        
        
          s_dbuff(s_ptr)  <= i_data_in;
          
          -- 1st value of the previous window read & forwarded
          -- to summation part
          s_wdata_last    <= s_dbuff(s_ptr);
          
          -- pointer for the cyclic buffer,
          -- reset to 0 when reaches last position
          s_ptr           <= s_ptr + 1;
          if (s_ptr = C_WINDOW_WIDTH-1) then -- to remove after testing
            s_ptr <= 0;
          end if;
          
        end if;
              
      end if; -- i_rst = '1'
    end if; -- rising_edge(i_clk)
  
  end process p_buff;
  
  
  ----------------------------------
  -- Register input data and start signal
  ----------------------------------
  p_reg: process(i_clk)
  begin
  
    if (rising_edge(i_clk)) then
      if (i_rst= '1') then
      
        s_start   <= '0';
        s_data_in <= (others => '0');
      
      else
      
        s_start   <= i_start;
        s_data_in <= i_data_in;
        
      end if;
    end if;
  
  end process p_reg;
  
  
  ----------------------------------
  -- Keeps accumulating the input data stream.
  -- Also moves the window by subtracting the 
  -- first value of previous window, so that
  -- summation of all values doesn't need to 
  -- be repeated
  ----------------------------------
  p_window_sum: process (i_clk)
  begin
    
    if (rising_edge(i_clk)) then
      if (i_rst = '1') then
        
        s_sum   <= (others => '0');
        s_wcnt  <= 0;
        
        s_dvalid    <= '0';
      else
      
        -- if start signal is high, indicating valid data values
        if (s_start = '1') then
          
          -- to check if initially no. of input values equivalent to window are received to 
          -- evaluate fist output
          if (s_wcnt = C_WINDOW_WIDTH) then         
            -- when data values are enough to generate the first output value, then for 2nd & further 
            -- outputs, 1st value from previous windows is subtracted
            s_sum       <= std_logic_vector(unsigned(s_sum) + unsigned(s_data_in) - unsigned(s_wdata_last));
            s_dvalid    <= s_start;
          
          else
            -- For first output value, subtraction is skipped as no valid data was there
            s_sum       <= std_logic_vector(unsigned(s_sum) + unsigned(s_data_in));
            
            -- counter for counting input values required for 1 window
            s_wcnt      <= s_wcnt + 1;
          end if;

        end if;
      
      end if; -- i_rst = '1'
    end if; -- rising_edge(i_clk)
    
  end process p_window_sum;
  

  ----------------------------------
  -- division of the sum is performed
  ----------------------------------
  p_div: process (i_clk)
  begin
    
    if (rising_edge(i_clk)) then
      if (i_rst = '1') then
      
        s_ready     <= '0';
        s_data_frac <= (others => '0');
        
      else
        
        -- if sum data is valid
        if (s_dvalid = '1') then          
          -- divide the sum result by window size, which is always in the power of 2
          -- So result can simply be divided by shifting-right the data by 
          -- log2(window_size) no. of bits.
          s_data_frac   <= (others => '0');
          s_data_frac(s_data_frac'HIGH - C_DIV_SCALE downto 0)  <= s_sum(s_sum'HIGH downto C_DIV_SCALE);
          
        end if;
                          
        -- forward the valid signal to output ready signal
        s_ready       <= s_dvalid;
      
      end if; -- i_rst = '1'
    end if; -- rising_edge(i_clk)
  
  end process p_div;
  
  
  -- output port map
  o_data_out <= s_data_frac;
  o_ready    <= s_ready;
  
    
end behavioral;
