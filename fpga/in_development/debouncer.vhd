----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:55:44 01/04/2014 
-- Design Name: 
-- Module Name:    debouncer - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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

use IEEE.NUMERIC_STD.ALL;

--Maximum width of bounce should be << Tclk*2^(RegWidth-1)

entity debouncer is
    generic(RegWidth : integer := 16); 
	 Port ( b : in  STD_LOGIC;
           b_debounced : out  STD_LOGIC;
           clk : in  STD_LOGIC);
end debouncer;

architecture Behavioral of debouncer is
	signal bounce_cntr: std_logic_vector(RegWidth-1 downto 0);
	constant zero: std_logic_vector(RegWidth - 1 downto 0) := (others => '0');
	--constant ones: std_logic_vector(RegWidth - 1 downto 0) := (others => '1');
begin
	b_debounced<= bounce_cntr(RegWidth -1);
	process(clk) begin
		if rising_edge(clk) then
			if b = '0' then
				bounce_cntr <= zero;
			elsif bounce_cntr(RegWidth - 1) = '0' then 
				bounce_cntr <= std_logic_vector(unsigned(bounce_cntr) + 1);
			end if;
		end if;
end process;
end Behavioral;

