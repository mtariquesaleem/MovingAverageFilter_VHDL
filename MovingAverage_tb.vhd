----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/13/2017 03:01:38 AM
-- Design Name: 
-- Module Name: MovingAverage_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MovingAverage_tb is
--  Port ( );
end MovingAverage_tb;

architecture Behavioral of MovingAverage_tb is

constant C_DWIDTH : natural := 16; 
constant C_WINDOW_WIDTH : natural := 256;

signal i_rst       :  STD_LOGIC; 
signal i_clk       :  STD_LOGIC := '1';
    
signal i_start     :  STD_LOGIC; --! Start the calculation
signal i_data_in   :  STD_LOGIC_VECTOR(C_DWIDTH-1 downto 0) := std_logic_vector(TO_UNSIGNED(0,16)); --! Value to process
    
signal o_ready     :  STD_LOGIC := '0'; --! The data_out signal makes sense
signal o_data_out  :  STD_LOGIC_VECTOR(C_DWIDTH-1 downto 0); --! A new value
    
begin

uut: entity work.MovingAverage
  Generic map(
    C_WINDOW_WIDTH => C_WINDOW_WIDTH, --! only power of two
    C_DWIDTH => C_DWIDTH
  )  
  Port map(
    i_rst       => i_rst,
    i_clk       => i_clk,
    
    i_start     => i_start,
    i_data_in   => i_data_in,
    
    o_ready     => o_ready,
    o_data_out  => o_data_out
  );
  
  i_clk <= not i_clk after 10 ns;
  i_rst <= '1', '0' after 30 ns;
  
  i_start <= '0', '1' after 60 ns;
  
  
  process
  begin
  
    i_data_in <= std_logic_vector(TO_UNSIGNED(16,C_DWIDTH));
    
    wait until (i_start = '1');
    
    for i in 0 to 1024 loop
      
      i_data_in <= std_logic_vector(TO_UNSIGNED(i,C_DWIDTH));
      
      wait until rising_edge(i_clk);
    
    end loop;
    
--    i_data_in <= std_logic_vector(TO_UNSIGNED(32,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(16,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(16,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(16,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(16,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(16,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(16,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(16,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(8,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(8,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(12,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(12,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(14,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(16,16)); wait until rising_edge(i_clk);
--    i_data_in <= std_logic_vector(TO_UNSIGNED(16,16)); wait until rising_edge(i_clk);
    
    wait;
    
  end process;

end Behavioral;
