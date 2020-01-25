library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity DEVICE_ARBITER_1_0 is
  port (
    I_CLK         : in std_logic;
    I_RST         : in std_logic;

    I_VOLTAGE_ID  : in std_logic; -- ID 0 (LEFT   PB)
    I_CURRENT_ID  : in std_logic; -- ID 1 (TOP    PB)
    I_TEMP_ID     : in std_logic; -- ID 2 (RIGHT  PB)
    I_HUMIDITY_ID : in std_logic; -- ID 3 (BOTTOM PB)
    I_DATA_LOG_EN : in std_logic;

    O_DEVICE_ID   : out std_logic_vector(2 downto 0));
end DEVICE_ARBITER_1_0;

architecture BEHAVIORAL of DEVICE_ARBITER_1_0 is

    constant C_SAMPLE_VOLTAGE  : std_logic_vector(2 downto 0) := "000";
    constant C_SAMPLE_CURRENT  : std_logic_vector(2 downto 0) := "001";
    constant C_SAMPLE_TEMP     : std_logic_vector(2 downto 0) := "010";
    constant C_SAMPLE_HUMIDITY : std_logic_vector(2 downto 0) := "011";
    constant C_LOG_DATA        : std_logic_vector(2 downto 0) := "100";

begin

    -- NOTE: Will have to add some sort of storage for current ADC being sampled.
    -- This is relevant in the case that we want to give precedence to logging data over SPI
    -- and need to remember which DEVICE ID we were sampling before logging
    
    Arbiter : process(I_CLK) begin
        if rising_edge(I_CLK) then
            if I_RST = '1' then
                O_DEVICE_ID <= (others => '1'); -- Unrecognized DEVICE ID
            else
                if I_DATA_LOG_EN = '1' then
                    O_DEVICE_ID <= C_LOG_DATA;
                elsif I_VOLTAGE_ID = '1' then
                    O_DEVICE_ID <= C_SAMPLE_VOLTAGE;
                elsif I_CURRENT_ID = '1' then
                    O_DEVICE_ID <= C_SAMPLE_CURRENT;
                elsif I_TEMP_ID = '1' then
                    O_DEVICE_ID <= C_SAMPLE_TEMP;
                elsif I_HUMIDITY_ID = '1' then
                    O_DEVICE_ID <= C_SAMPLE_HUMIDITY;
                else
                    O_DEVICE_ID <= (others => '1'); -- Unrecognized DEVICE ID
                end if;
            end if;
        end if;
    end process Arbiter;
end BEHAVIORAL ; 