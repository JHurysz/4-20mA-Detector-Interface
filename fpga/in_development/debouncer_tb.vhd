------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz                      --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity DEBOUNCER_TB is 
end    DEBOUNCER_TB;

architecture BEHAVIORAL of DEBOUNCER_TB is

    -- component Declaration for the Unit Under Test (UUT)
    component DEBOUNCER
    generic( G_REG_WIDTH : integer := 16);
    port(
        I_CLK              : in  std_logic;
        I_BUTTON_IN        : in  std_logic;
        O_BUTTON_DEBOUNCED : out std_logic);
    end component;

    -- Signal Definitions
    signal I_CLK              : std_logic := '0';
    signal I_BUTTON_IN        : std_logic := '0';
    signal O_BUTTON_DEBOUNCED : std_logic;

    -- Clock period definitions
    constant C_CLK_PERIOD : time := 31.25 ns;

begin

    -- Clock Generation
    I_CLK <= not I_CLK after C_CLK_PERIOD/2;

    -- instantiate the Unit Under Test (UUT)
    UUT : DEBOUNCER 
        generic map (G_REG_WIDTH => 16)
        port map (
           I_CLK              => I_CLK,
           I_BUTTON_IN        => I_BUTTON_IN,
           O_BUTTON_DEBOUNCED => O_BUTTON_DEBOUNCED);

    -- Stimulus process
    Stimulus: process
    begin		

        -- Initial wait
       wait for 100 ns;
       wait for C_CLK_PERIOD*10;

       -- Single Pulse, should not toggle output.
       I_BUTTON_IN <= '1';
       wait for C_CLK_PERIOD;
       I_BUTTON_IN <= '0';
       wait for C_CLK_PERIOD;

       -- 5 Pulse Wide, should not toggle output
       I_BUTTON_IN <= '1';
       wait for C_CLK_PERIOD*5;
       I_BUTTON_IN <= '0';
       wait for C_CLK_PERIOD;

       -- 10 Pulse Wide, should not toggle output
       I_BUTTON_IN <= '1';
       wait for C_CLK_PERIOD*10;
       I_BUTTON_IN <= '0';
       wait for C_CLK_PERIOD;

       -- 25 Pulse Wide, should not toggle output
       I_BUTTON_IN <= '1';
       wait for C_CLK_PERIOD*25;
       I_BUTTON_IN <= '0';
       wait for C_CLK_PERIOD;

       -- Wait long enough for output to toggle.
       I_BUTTON_IN <= '1';
       wait until O_BUTTON_DEBOUNCED = '1';
       I_BUTTON_IN <= '0';

       wait for 100 ns;

       wait;
    end process Stimulus;

end BEHAVIORAL;

