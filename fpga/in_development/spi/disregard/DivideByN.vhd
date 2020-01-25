-- Company Name:   Binghamton University
-- Engineer(s):    
-- Create Date:    10/11/2017 
-- Module Name:    DivideByN - Behavioral 
-- Project Name:   Lab6
-- Description:    The frequency of the output (clk_out) of this counter is the
--						 frequency of the input (clk_in) divided by the generic 
-- 					 parameter N.  The number of bits implemented for the counter
--						 is "ctr_width" computed as the log base 2 of N rounded up to
--						 the next integer value.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.Math_Real.all;

entity DivideByN is
	 Generic ( N : positive := 64 ); -- N = divide by value
    Port ( clk_in : in  STD_LOGIC;
           clk_out : out  STD_LOGIC);
end DivideByN;

architecture Behavioral of DivideByN is

	-- Constant for setting counter width 
	-- calculated from the required counter range specified by N
	constant ctr_width : positive := positive(ceil(log2(real(N))));
	
	signal counter : unsigned(ctr_width - 1 downto 0) := to_unsigned(10,ctr_width);
	signal TC : std_logic;
	
begin

-- ############### Your Divide by N Counter Code ###############
	process(clk_in, counter) begin
		if rising_edge(clk_in) then
			if(counter = "000000") then
				TC <= '1';
				counter <= to_unsigned(N-1,ctr_width);
			else
				counter <= counter - 1;
				TC <= '0';
			end if;
		end if;
	end process;
	
	clk_out <= TC;
		
end Behavioral;