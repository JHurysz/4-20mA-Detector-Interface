------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz                      --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity DEVICE_ARBITER_TOPLEVEL is
    port (
      I_CLK         : in  std_logic;
 
      I_BUTTONS     : in  std_logic_vector(3 downto 0);
      O_LEDS        : out std_logic_vector(3 downto 0));
end DEVICE_ARBITER_TOPLEVEL;

architecture BEHAVIORAL of DEVICE_ARBITER_TOPLEVEL is

    component DEBOUNCER
    generic (G_REG_WIDTH : integer := 16);
    port(
         I_CLK              : in  std_logic;
         I_BUTTON_IN        : in  std_logic;
         O_BUTTON_DEBOUNCED : out std_logic);
    end component;

    component DEVICE_ARBITER
    port(
        I_CLK         : in std_logic;
        I_RST         : in std_logic;
    
        I_VOLTAGE_ID  : in std_logic; -- ID 0 (LEFT   PB)
        I_CURRENT_ID  : in std_logic; -- ID 1 (TOP    PB)
        I_TEMP_ID     : in std_logic; -- ID 2 (RIGHT  PB)
        I_HUMIDITY_ID : in std_logic; -- ID 3 (BOTTOM PB)
        I_DATA_LOG_EN : in std_logic;
    
        O_DEVICE_ID   : out std_logic_vector(2 downto 0));
    end component;

    -- Signal Declarations
    signal voltage_discrete  : std_logic;
    signal current_discrete  : std_logic;
    signal temp_discrete     : std_logic;
    signal humidity_discrete : std_logic;

    signal device_id         : std_logic_vector(2 downto 0);

begin

    Voltage_Debouncer : DEBOUNCER
        generic map (G_REG_WIDTH => 16)
        port map (
            I_CLK              => I_CLK,
            I_BUTTON_IN        => I_BUTTONS(0),
            O_BUTTON_DEBOUNCED => voltage_discrete);

    Current_Debouncer : DEBOUNCER
        generic map (G_REG_WIDTH => 16)
        port map (
            I_CLK              => I_CLK,
            I_BUTTON_IN        => I_BUTTONS(1),
            O_BUTTON_DEBOUNCED => current_discrete);

    Temp_Debouncer   : DEBOUNCER
        generic map (G_REG_WIDTH => 16)
        port map (
            I_CLK              => I_CLK,
            I_BUTTON_IN        => I_BUTTONS(2),
            O_BUTTON_DEBOUNCED => temp_discrete);

    Humidity_Debouncer : DEBOUNCER
        generic map (G_REG_WIDTH => 16)
        port map (
            I_CLK              => I_CLK,
            I_BUTTON_IN        => I_BUTTONS(3),
            O_BUTTON_DEBOUNCED => humidity_discrete);

    Arbiter : DEVICE_ARBITER
        port map (
            I_CLK         => I_CLK,
            I_RST         => '0', -- not active

            I_VOLTAGE_ID  => voltage_discrete,
            I_CURRENT_ID  => current_discrete,
            I_TEMP_ID     => temp_discrete,
            I_HUMIDITY_ID => humidity_discrete,

            O_DEVICE_ID   => device_id);

    
    -- Combinational LED Multiplixer
    LED_Logic : process(device_id) begin

        -- Defaults
        O_LEDS <= (others => '0');

        case LED_Logic is
            when "000"  => O_LEDS <= ("0001");
            when "001"  => O_LEDS <= ("0010");
            when "010"  => O_LEDS <= ("0100");
            when "011"  => O_LEDS <= ("1000");
            when "100"  => O_LEDS <= ("1001"); -- Should not occur as Data logging never gets toggled.is
            when others => O_LEDS <= (others => '1') -- Error if this occurs.
        end case;
    end process LED_Logic;

end BEHAVIORAL;
