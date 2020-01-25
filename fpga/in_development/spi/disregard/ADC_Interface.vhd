----------------------------------------------------------------------------------
-- Company Name:   Binghamton University
-- Engineer(s):    
-- Create Date:    10/18/2016 
-- Module Name:    ADC_Interface - Behavioral 
-- Project Name:   Lab6
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ADC_Interface is
    Port ( clk : in  STD_LOGIC;
			  ADC_number : in std_logic_vector(2 downto 0);
           Sample : in  STD_LOGIC;
           SPI_CS : out  STD_LOGIC;
           SPI_SCLK : out  STD_LOGIC;
           SPI_MOSI : out  STD_LOGIC;
           SPI_MISO : in  STD_LOGIC;
           ADC_data_out : out  STD_LOGIC_VECTOR (11 downto 0));
end ADC_Interface;

architecture Behavioral of ADC_Interface is

-- #############################################################
-- ########## Your Component and Signal Declarations ###########
-- #############################################################
		COMPONENT Controller
		PORT(
		clk : IN std_logic;
		Sample : IN std_logic;
		Compare_1 : IN std_logic;
		Compare_4 : IN std_logic;
		Compare_16 : IN std_logic;    
		SPI_SCLK : OUT std_logic;      
		SPI_CS : OUT std_logic;
		clr_count : OUT std_logic;
		ld_count : OUT std_logic;
		ld_controlReg : OUT std_logic;
		controlReg_S : OUT std_logic;
		ld_DataReg : OUT std_logic;
		ld_ADC_data_out : OUT std_logic
		);
	END COMPONENT;
	
	COMPONENT Datapath
	PORT(
		ADC_Number : IN std_logic_vector(2 downto 0);
		SPI_MISO : IN std_logic;
		clk : IN std_logic;
		clr_count : IN std_logic;
		ld_count : IN std_logic;
		ld_controlReg : IN std_logic;
		controlReg_S : IN std_logic;
		ld_DataReg : IN std_logic;
		ld_ADC_data_out : IN std_logic;          
		SPI_MOSI : OUT std_logic;
		Compare_16 : OUT std_logic;
		Compare_4 : OUT std_logic;
		Compare_1 : OUT std_logic;
		ADC_data_out : OUT std_logic_vector(11 downto 0)
		);
	END COMPONENT;
	
	signal clr_count, ld_count, ld_controlReg, controlReg_S, ld_DataReg, ld_ADC_data_out, Compare_1, Compare_4, Compare_16 : std_logic;
		

begin

-- #############################################################
-- ########## Your Component Instantiations with ###############
-- ################## Signal Connections #######################
-- #############################################################





	Inst_Controller: Controller PORT MAP(
		clk => clk,
		Sample => Sample,
		Compare_1 => Compare_1,
		Compare_4 => Compare_4,
		Compare_16 => Compare_16,
		SPI_SCLK => SPI_SCLK,
		SPI_CS => SPI_CS,
		clr_count => clr_count,
		ld_count => ld_count,
		ld_controlReg => ld_controlReg,
		controlReg_S => controlReg_S,
		ld_DataReg => ld_DataReg,
		ld_ADC_data_out => ld_ADC_data_out 
	);
	
	Inst_Datapath: Datapath PORT MAP(
		ADC_Number => ADC_Number,
		SPI_MISO => SPI_MISO,
		clk => clk,
		clr_count => clr_count,
		ld_count => ld_count,
		ld_controlReg => ld_controlReg,
		controlReg_S => controlReg_S,
		ld_DataReg => ld_DataReg,
		ld_ADC_data_out => ld_ADC_data_out,
		SPI_MOSI => SPI_MOSI,
		Compare_16 => Compare_16,
		Compare_4 => Compare_4,
		Compare_1 => Compare_1,
		ADC_data_out => ADC_data_out
	);


end Behavioral;