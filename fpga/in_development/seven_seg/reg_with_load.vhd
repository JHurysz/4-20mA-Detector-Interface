------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz, Carl Betcher        --
------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity REG_WITH_LOAD is
	Port ( I_CLK       : in   std_logic
		   I_EN        : in   std_logic;
           I_DATA      : in   std_logic_vector (3 downto 0);
           O_DATA      : out  std_logic_vector (3 downto 0));
end REG_WITH_LOAD;

architecture BEHAVIORAL of REG_WITH_LOAD is

begin
	
	Register : process(I_CLK)
	begin
		if rising_edge(I_CLK) then
			if I_EN = '1' then
				O_DATA <= I_DATA;
			end if;
		end if;
	end process Register;
	
end BEHAVIORAL;

