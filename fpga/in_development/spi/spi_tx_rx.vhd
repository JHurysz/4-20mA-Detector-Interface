------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz                      --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity SPI_TX_RX is
  port (
      I_CLK   : in std_logic;
      I_RST   : in std_logic;
      I_DEVICE_ID : in std_logic_vector(1 downto 0);


      -- Data Lines
      I_MISO  : in std_logic;
      O_MOSI  : out std_logic;

      -- Control Signals
      I_CLR_SPI_COUNT        : in std_logic;
      I_LD_SPI_COUNT         : in std_logic;
      I_SHIFT_CONFIG_REG     : in std_logic;
      I_LD_CONFIG_REG        : in std_logic;
      I_LD_DATA_REG          : in std_logic;
      I_LD_DATA_OUT          : in std_logic;
      O_ALL_BYTES_TRANSFERRED: out std_logic;

      O_VOLTAGE_REG          : out std_logic_vector(15 downto 0);
      O_CURRENT_REG          : out std_logic_vector(15 downto 0);
      O_TEMP_REG             : out std_logic_vector(15 downto 0);
      O_HUMIDITY_REG         : out std_logic_vector(15 downto 0);
      
    );
end SPI_TX_RX;

architecture BEHAVIORAL of SPI_TX_RX is 

    constant C_CONFIG_WORDS : std_logic_vector(15 downto 0) := WORDS;

    signal spi_bit_count : std_logic_vector( 4 downto 0);
    signal config_reg    : std_logic_vector(16 downto 0); -- just a guess on size
    signal data_reg      : std_logic_vector(15 downto 0);
    signal tmp_voltage_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal tmp_current_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal tmp_temp_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal tmp_humidity_reg : std_logic_vector(15 downto 0) := (others => '0');
begin

    -- 5 Bit SPI Counter --
    SPI_Count : process(I_CLK) begin
        if rising_edge(I_CLK) then
            if I_CLR_SPI_COUNT = '1' then
                spi_bit_count <= (others <= '0');
            elsif I_LD_SPI_COUNT = '1' then
                spi_bit_count <= std_logic_vector(unsigned(spi_bit_count) + 1);
            end if;
        end if;
    end process SPI_Count;

    -- Bytes per transfer
    O_ALL_BYTES_TRANSFERRED <= '1' when (unsigned(spi_bit_count) = 16) else '0';
    -- Maybe need another compare (how many bits are in config register?)
    O_START_OF_TRANSFER     <= '1' when (unsigned(spi_bit_count)  = 1) else '0';
    
    -- Configuration Register
    Configuration_Shift_Register : process(I_CLK) begin
        if rising_edge(I_CLK) then
            if I_LD_CONFIG_REG = '1' then
                config_reg <= '0' and C_CONFIG_WORDS;
            elsif I_SHIFT_CONFIG_REG = '1' then
                config_reg <= config_reg(15 downto 0) & '0';
            else
                config_reg <= config_reg;
            end if;
        end if;
    end process Configuration_Shift_Register;

    O_MOSI <= config_reg(16); -- MSB

    -- Data Register --
    Data_Shift_Register : process(I_CLK) begin
        if rising_edge(I_CLK) then
			if I_LD_DATA_REG = '1' then
				 data_reg <= data_reg(14 downto 0) & I_MISO;
			end if;
		end if;
    end process Data_Shift_Register;
    
    -- Data out Register -- 
    Output_Shift_Register : process(I_CLK) begin
        if rising_edge(I_CLK) then

            -- Defaults
            tmp_voltage_reg  <= tmp_voltage_reg;
            tmp_current_reg  <= tmp_current_reg;
            tmp_temp_reg     <= tmp_temp_reg;
            tmp_humidity_reg <= tmp_humidity_reg;

            case I_DEVICE_ID is
                when "00" => -- Voltage
                    tmp_voltage_reg  <= data_reg;

                when "00" => -- Current
                    tmp_current_reg  <= data_reg;

                when "00" => -- Temp
                    tmp_temp_reg     <= data_reg;

                when "00" => -- Humidity
                    tmp_humidity_reg <= data_reg

                when others => -- Shouldn't Happen
                    tmp_voltage_reg <= tmp_voltage_reg;
                    tmp_current_reg <= tmp_current_reg;
                    tmp_temp_reg    <= tmp_temp_reg;
                    tmp_humidity_reg<= tmp_humidity_reg;
            end case;
        end if;    
    end process Output_Shift_Register;

    -- Output Register Assignments
    O_VOLTAGE_REG <= tmp_voltage_reg;
    O_CURRENT_REG <= tmp_current_reg;
    O_TEMP_REG    <= tmp_temp_reg;
    O_HUMIDITY_REG <= tmp_humidity_reg;
    
end BEHAVIORAL;