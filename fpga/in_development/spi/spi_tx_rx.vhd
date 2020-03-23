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
      I_CLK                       : in std_logic;
      I_RST                       : in std_logic;
      I_DEVICE_ID                 : in std_logic_vector(1 downto 0);


      -- Data Lines
      I_MISO                      : in  std_logic;
      O_MOSI                      : out std_logic;

      -- Control Signals
      I_CLR_SPI_COUNT             : in  std_logic;
      I_LD_SPI_COUNT              : in  std_logic;
      I_CONFIG_IN_PROCESS         : in  std_logic;
      I_LD_CONFIG_READBACK        : in  std_logic;
      I_LD_READBACK_OUT           : in  std_logic;
      I_SHIFT_CONFIG_REG          : in  std_logic;
      I_LD_CONFIG_REG             : in  std_logic;
      I_LD_DATA_REG               : in  std_logic;
      I_LD_DATA_OUT               : in  std_logic;
      O_ALL_BYTES_TRANSFERRED     : out std_logic;
      O_START_OF_TRANSFER         : out std_logic;
      O_SPI_CNT_LT_16             : out std_logic;

      O_VOLTAGE_REG               : out std_logic_vector(15 downto 0);
      O_CURRENT_REG               : out std_logic_vector(15 downto 0);
      O_TEMP_REG                  : out std_logic_vector(15 downto 0);
      O_HUMIDITY_REG              : out std_logic_vector(15 downto 0);
		
      O_VOLTAGE_READBACK          : out std_logic_vector(15 downto 0);
      O_CURRENT_READBACK          : out std_logic_vector(15 downto 0);
      O_TEMP_READBACK             : out std_logic_vector(15 downto 0);
      O_HUMIDITY_READBACK         : out std_logic_vector(15 downto 0));
end SPI_TX_RX;

architecture BEHAVIORAL of SPI_TX_RX is 

	 -- Config Register Structure
	 -- Bit 15: Single-Shot Mode -> 0 no effect if not in single shot mode
	 -- ADC Mux Input Structure  -> 000 for + on Ain0 and - on Ain1
	 -- PGA                      -> 000 for FSR of +-6.144V
	 -- Operating Mode           -> 0 for Continous mode
	 -- Data Rate                -> 100 will do 128 samples second
	 -- Temperature sensor mode  -> 0 for adc mode
	 -- pull-up enable           -> 1 default
	 -- config register write    -> 01 to write config reg
	 -- no effect reserved       -> 1 no effect
	 
	 -- full string 0000 0000 1000 1011
	 --             0    0    8    B          
    constant C_CONFIG_WORDS      : std_logic_vector(15 downto 0) := x"008B";
    constant C_CSSC_SCCS_CYCLES  : positive := 4;

    signal   spi_bit_count         : std_logic_vector( 5 downto 0);
    signal   config_reg            : std_logic_vector(16 downto 0) := '0' & C_CONFIG_WORDS; -- just a guess on size
    signal   data_reg              : std_logic_vector(15 downto 0);
    signal   config_readback       : std_logic_vector(15 downto 0);
    signal   tmp_voltage_reg       : std_logic_vector(15 downto 0) := (others => '0');
    signal   tmp_current_reg       : std_logic_vector(15 downto 0) := (others => '0');
    signal   tmp_temp_reg          : std_logic_vector(15 downto 0) := (others => '0');
    signal   tmp_humidity_reg      : std_logic_vector(15 downto 0) := (others => '0');
    signal   tmp_voltage_readback  : std_logic_vector(15 downto 0) := (others => '0');
    signal   tmp_current_readback  : std_logic_vector(15 downto 0) := (others => '0');
    signal   tmp_temp_readback     : std_logic_vector(15 downto 0) := (others => '0');
    signal   tmp_humidity_readback : std_logic_vector(15 downto 0) := (others => '0');
	 
begin

    -- 6 Bit SPI Counter --
    SPI_Count : process(I_CLK) begin
        if rising_edge(I_CLK) then
            if I_CLR_SPI_COUNT = '1' then
                spi_bit_count <= (others => '0');
            elsif I_LD_SPI_COUNT = '1' then
                spi_bit_count <= std_logic_vector(unsigned(spi_bit_count) + 1);
            end if;
        end if;
    end process SPI_Count;

    -- Bytes per transfer
    O_ALL_BYTES_TRANSFERRED <= '1' when ((unsigned(spi_bit_count) = 15 and I_CONFIG_IN_PROCESS = '0') or ((unsigned(spi_bit_count) = 31 and I_CONFIG_IN_PROCESS = '1'))) else '0';
    O_START_OF_TRANSFER     <= '1' when ( unsigned(spi_bit_count) = 1 ) else '0';
    O_SPI_CNT_LT_16         <= '1' when ( unsigned(spi_bit_Count) < 16) else '0';
    
    -- Configuration Register
    Configuration_Shift_Register : process(I_CLK) begin
        if rising_edge(I_CLK) then
            if I_LD_CONFIG_REG = '1' then
                config_reg <= '0' & C_CONFIG_WORDS;
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
		if I_LD_DATA_OUT = '1' then

			-- Defaults
			tmp_voltage_reg  <= tmp_voltage_reg;
			tmp_current_reg  <= tmp_current_reg;
			tmp_temp_reg     <= tmp_temp_reg;
			tmp_humidity_reg <= tmp_humidity_reg;

			case I_DEVICE_ID is
				 when "00" => -- Voltage
					  tmp_voltage_reg  <= data_reg;

				 when "01" => -- Current
					  tmp_current_reg  <= data_reg;

				 when "10" => -- Temp
					  tmp_temp_reg     <= data_reg;

				 when "11" => -- Humidity
					  tmp_humidity_reg <= data_reg;

				 when others => -- Shouldn't Happen
					  tmp_voltage_reg <= tmp_voltage_reg;
					  tmp_current_reg <= tmp_current_reg;
					  tmp_temp_reg    <= tmp_temp_reg;
					  tmp_humidity_reg<= tmp_humidity_reg;
			end case;
		end if;
        end if;    
    end process Output_Shift_Register;

    -- Output Register Assignments
    O_VOLTAGE_REG  <= tmp_voltage_reg;
    O_CURRENT_REG  <= tmp_current_reg;
    O_TEMP_REG     <= tmp_temp_reg;
    O_HUMIDITY_REG <= tmp_humidity_reg;
	 
    -- Config Readback
    Config_Readback_Register : process(I_CLK) begin
	if rising_edge(I_CLK) then
 		if I_LD_CONFIG_READBACK = '1' then
			config_readback <= config_readback(14 downto 0) & I_MISO;
		end if;
	end if;
    end process Config_Readback_Register;
	 
    Latch_Readback : process(I_CLK) begin
        if rising_edge(I_CLK) then
		if I_LD_READBACK_OUT = '1' then

			-- Defaults
			tmp_voltage_readback  <= tmp_voltage_readback;
			tmp_current_readback  <= tmp_current_readback;
			tmp_temp_readback     <= tmp_temp_readback;
			tmp_humidity_readback <= tmp_humidity_readback;

			case I_DEVICE_ID is
				 when "00" => -- Voltage
					  tmp_voltage_readback  <= config_readback;

				 when "01" => -- Current
					  tmp_current_readback  <= config_readback;

				 when "10" => -- Temp
					  tmp_temp_readback     <= config_readback;

				 when "11" => -- Humidity
					  tmp_humidity_readback <= config_readback;

				 when others => -- Shouldn't Happen
					  tmp_voltage_readback  <= tmp_voltage_readback;
					  tmp_current_readback  <= tmp_current_readback;
					  tmp_temp_readback     <= tmp_temp_readback;
					  tmp_humidity_readback <= tmp_humidity_readback;
			end case;
		end if;
        end if;    
    end process Latch_Readback;
	 
    O_VOLTAGE_READBACK  <= tmp_voltage_readback;
    O_CURRENT_READBACK  <= tmp_current_readback;
    O_TEMP_READBACK     <= tmp_temp_readback;
    O_HUMIDITY_READBACK <= tmp_humidity_readback;
    
end BEHAVIORAL;
