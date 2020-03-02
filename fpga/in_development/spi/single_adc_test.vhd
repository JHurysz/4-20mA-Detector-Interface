------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz                      --
------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity SINGLE_ADC_TEST is
	port(
		I_CLK        : in  std_logic;
		I_MISO       : in  std_logic;
		I_SWITCH_MUX : in  std_logic;
		
		O_MOSI       : out std_logic;
		O_SCLK       : out std_logic;
		O_CS         : out std_logic;
		
		O_SEG        : out std_logic_vector(6 downto 0);
		O_LEDS       : out std_logic_vector(7 downto 0);
		O_ANODE      : out std_logic_vector(4 downto 0);
		O_DP         : out std_logic);
end SINGLE_ADC_TEST;

architecture Behavioral of SINGLE_ADC_TEST is

	component Seven_Seg_Ctrl
	port(  
		I_CLK           : in   std_logic;
		I_HEX_DATA_IN_0 : in   std_logic_vector (3 downto 0);
        I_HEX_DATA_IN_1 : in   std_logic_vector (3 downto 0);
        I_HEX_DATA_IN_2 : in   std_logic_vector (3 downto 0);
        I_HEX_DATA_IN_3 : in   std_logic_vector (3 downto 0);
        I_DP            : in   std_logic_vector (2 downto 0);
        O_SEG           : out  std_logic_vector (6 downto 0);
        O_ANODE         : out  std_logic_vector (3 downto 0);
        O_DP            : out  std_logic);
	end component;
	
	COMPONENT SPI_IF
	PORT(
		I_CLK                : in  std_logic;
		I_RST                : in  std_logic;
		I_DEVICE_ID          : in  std_logic_vector(1 downto 0);
		I_MISO               : in  std_logic;          
		O_MOSI               : out std_logic;
		O_SCLK               : out std_logic;
		O_CS_0               : out std_logic;
		O_CS_1               : out std_logic;
		O_CS_2               : out std_logic;
		O_CS_3               : out std_logic;
		O_VOLTAGE_REG        : out std_logic_vector(15 downto 0);
		O_CURRENT_REG        : out std_logic_vector(15 downto 0);
		O_TEMP_REG           : out std_logic_vector(15 downto 0);
		O_HUMIDITY_REG       : out std_logic_vector(15 downto 0);
		O_VOLTAGE_READBACK   : out std_logic_vector(15 downto 0);
		O_CURRENT_READBACK   : out std_logic_vector(15 downto 0);
		O_TEMP_READBACK      : out std_logic_vector(15 downto 0);
		O_HUMIDITY_READBACK  : out std_logic_vector(15 downto 0)
		);
	END COMPONENT;
	
	signal tmp_voltage_reg       : std_logic_vector(15 downto 0);
    signal tmp_current_reg       : std_logic_vector(15 downto 0);
    signal tmp_temp_reg          : std_logic_vector(15 downto 0);
    signal tmp_humidity_reg      : std_logic_vector(15 downto 0);
	signal tmp_voltage_readback  : std_logic_vector(15 downto 0);
	signal tmp_current_readback  : std_logic_vector(15 downto 0);
	signal tmp_temp_readback     : std_logic_vector(15 downto 0);
	signal tmp_humidity_readback : std_logic_vector(15 downto 0);
	 
	signal cs_1 : std_logic;
	signal cs_2 : std_logic;
	signal cs_3 : std_logic;

begin

	Inst_Seven_Seg_Ctrl: Seven_Seg_Ctrl 
	PORT MAP(
		I_HEX_DATA_IN_0 => tmp_voltage_reg(15 downto 12),
		I_HEX_DATA_IN_1 => tmp_voltage_reg(11 downto 8),
		I_HEX_DATA_IN_2 => tmp_voltage_reg(7 downto 4),
		I_HEX_DATA_IN_3 => tmp_voltage_reg(3 downto 0),
		I_DP            => "000",
		O_SEG           => O_SEG,
		O_ANODE         => O_ANODE(3 downto 0),
		O_DP            => O_DP,
		I_CLK           => I_CLK
	);
	
	Inst_SPI_IF : SPI_IF 
	PORT MAP(
		I_CLK => I_CLK,
		I_RST => '0', -- not used
		I_DEVICE_ID => "00", -- Voltage ID for now
		I_MISO => I_MISO,
		O_MOSI => O_MOSI,
		O_SCLK => O_SCLK,
		O_CS_0 => O_CS,
		O_CS_1 => cs_1,
		O_CS_2 => cs_2,
		O_CS_3 => cs_3,
		O_VOLTAGE_REG => tmp_voltage_reg,
		O_CURRENT_REG => tmp_current_reg,
		O_TEMP_REG => tmp_temp_reg,
		O_HUMIDITY_REG => tmp_humidity_reg,
		O_VOLTAGE_READBACK => tmp_voltage_readback,
		O_CURRENT_READBACK => tmp_current_readback,
		O_TEMP_READBACK => tmp_temp_readback,
		O_HUMIDITY_READBACK => tmp_humidity_readback
	);
	
	O_ANODE(4) <= '1';
	
	O_LEDS <= tmp_voltage_readback(15 downto 8) when I_SWITCH_MUX = '1' else tmp_voltage_readback(7 downto 0);

end Behavioral;

