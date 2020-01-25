------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz                      --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity DEBOUNCER_1_0 is
    generic(G_REG_WIDTH : integer := 16); 
	 Port ( 
		I_CLK              : in   std_logic;
		I_BUTTON_IN        : in   std_logic;
		O_BUTTON_DEBOUNCED : out  std_logic);
end DEBOUNCER_1_0;

architecture BEHAVIORAL of DEBOUNCER_1_0 is

	signal   bounce_cntr : std_logic_vector(G_REG_WIDTH-1 downto 0);
	constant C_ZEROS     : std_logic_vector(G_REG_WIDTH - 1 downto 0) := (others => '0');

begin

	-- MSB of bounce ctr (single pulse high as long as button not held high)
	O_BUTTON_DEBOUNCED <= bounce_cntr(G_REG_WIDTH -1);

	UP_Counter : process(I_CLK) begin
		if rising_edge(I_CLK) then
			if I_BUTTON_IN = '0' then
				bounce_cntr <= C_ZEROS;
			elsif bounce_cntr(G_REG_WIDTH - 1) = '0' then 
				bounce_cntr <= std_logic_vector(unsigned(bounce_cntr) + 1);
			end if;
		end if;
	end process UP_Counter;
end BEHAVIORAL;

