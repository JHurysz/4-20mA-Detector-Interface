------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz                      --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity DEVICE_ARBITER_TB is
end    DEVICE_ARBITER_TB;

architecture BEHAVIORAL of DEVICE_ARBITER_TB is

    -- component Declaration for the Unit Under Test (UUT)
    component DEVICE_ARBITER
    port(
        I_CLK              : in  std_logic;
        I_RST              : in  std_logic;

        I_VOLTAGE_ID       : in std_logic; -- ID 0 (LEFT   PB)
        I_CURRENT_ID       : in std_logic; -- ID 1 (TOP    PB)
        I_TEMP_ID          : in std_logic; -- ID 2 (RIGHT  PB)
        I_HUMIDITY_ID      : in std_logic; -- ID 3 (BOTTOM PB)
        I_DATA_LOG_EN      : in std_logic;

        O_DEVICE_ID : out std_logic_vector(2 downto 0));
    end component;

    -- Signal Definitions
    signal I_CLK              : std_logic := '0';
    signal I_RST              : std_logic := '0';
    signal I_VOLTAGE_ID       : std_logic := '0';
    signal I_CURRENT_ID       : std_logic := '0';
    signal I_TEMP_ID          : std_logic := '0';
    signal I_HUMIDITY_ID      : std_logic := '0';
    signal I_DATA_LOG_EN      : std_logic := '0';
    signal O_DEVICE_ID        : std_logic_vector(2 downto 0);

    -- Clock period definitions
    constant C_CLK_PERIOD : time := 31.25 ns;

begin

    -- Clock Generation
    I_CLK <= not I_CLK after C_CLK_PERIOD/2;

    -- instantiate the Unit Under Test (UUT)
    UUT : DEVICE_ARBITER 
    port map (
        I_CLK              => I_CLK,
        I_RST              => I_RST,

        I_VOLTAGE_ID       => I_VOLTAGE_ID,
        I_CURRENT_ID       => I_CURRENT_ID,
        I_TEMP_ID          => I_TEMP_ID,
        I_HUMIDITY_ID      => I_HUMIDITY_ID,
        I_DATA_LOG_EN      => I_DATA_LOG_EN,
        O_DEVICE_ID        => O_DEVICE_ID);

    -- Stimulus process
    Stimulus: process
    begin		

        -- Initial wait
       wait for 100 ns;
       wait for C_CLK_PERIOD*10;

       -- Make sure Reset works.
       I_RST <= '1';
       wait for C_CLK_PERIOD;
       I_RST <= '0';
       wait for C_CLK_PERIOD;

       -- Simulate Buttons being pressed.
       I_DATA_LOG_EN <= '1';
       I_VOLTAGE_ID  <= '1';
       I_CURRENT_ID  <= '1';
       I_TEMP_ID     <= '1';
       I_HUMIDITY_ID <= '1';

       -- DEVICE ID should be "100"
       wait for C_CLK_PERIOD*10;
       I_DATA_LOG_EN <= '0';

       -- DEVICE ID should be "000"
       wait for C_CLK_PERIOD*10;
       I_VOLTAGE_ID <= '0';

       -- DEVICE ID should be "001"
       wait for C_CLK_PERIOD*10;
       I_CURRENT_ID <= '0';

       -- DEVICE ID should be "010"
       wait for C_CLK_PERIOD*10;
       I_TEMP_ID <= '0';

       -- DEVICE ID should be "011"
       wait for C_CLK_PERIOD*10;
       I_HUMIDITY_ID <= '0';

       wait for C_CLK_PERIOD*10; -- Make sure DEVICE ID Sticks.

       -- Give precedence back to Voltage
       I_VOLTAGE_ID <= '1';
       wait for C_CLK_PERIOD*10; 

       I_RST <= '1';
       wait for C_CLK_PERIOD*10; 
       I_RST <= '0';

       wait for 100 ns;
       wait;
    end process Stimulus;
end BEHAVIORAL;