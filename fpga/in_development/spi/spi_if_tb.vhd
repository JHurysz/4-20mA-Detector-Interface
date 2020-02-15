------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz, Carl Betcher        --
------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
 
entity SPI_IF_TB is
end SPI_IF_TB;
 
architecture BEHAVIORAL of SPI_IF_TB is 
 
    -- Component Declaration for the Unit Under Test (UUT)
	 COMPONENT SPI_IF
	 PORT(
			  I_CLK : in std_logic;
			  I_RST : in std_logic;
			  I_DEVICE_ID : in std_logic_vector(1 downto 0);
			  
			  -- Physical Lines
			  I_MISO      : in  std_logic;
			  O_SCLK      : out std_logic;
			  O_MOSI      : out std_logic; 
			  O_CS_0      : out std_logic;
			  O_CS_1      : out std_logic;
			  O_CS_2      : out std_logic;
			  O_CS_3      : out std_logic;
			  
			  -- Register Values
			  O_VOLTAGE_REG          : out std_logic_vector(15 downto 0);
			  O_CURRENT_REG          : out std_logic_vector(15 downto 0);
			  O_TEMP_REG             : out std_logic_vector(15 downto 0);
			  O_HUMIDITY_REG         : out std_logic_vector(15 downto 0));
 	end COMPONENT;

   -- Inputs
   signal I_CLK : std_logic := '0';
   signal I_RST : std_logic := '0';
   signal I_DEVICE_ID : std_logic_vector(1 downto 0) := "00";
  
   -- ADC I/O
   signal I_MISO : std_logic := '0';
   signal O_MOSI : std_logic := '0';
   signal O_SCLK : std_logic;
   signal O_CS_0 : std_logic;
   signal O_CS_1 : std_logic;
   signal O_CS_2 : std_logic;
   signal O_CS_3 : std_logic;

   -- Outputs
   signal O_VOLTAGE_REG    : std_logic_vector(15 downto 0);
   signal O_CURRENT_REG    : std_logic_vector(15 downto 0);
   signal O_TEMP_REG       : std_logic_vector(15 downto 0);
   signal O_HUMIDITY_REG   : std_logic_vector(15 downto 0);

	-- Clock period definitions
   constant C_CLK_PERIOD : time := 31.25 ns;


	type test_data_array is array (natural range <>) of std_logic_vector(15 downto 0);
	constant C_TEST_DATA : test_data_array := ((x"AA5D"),
											  ( x"BF0B"),
											  ( x"C823"));

BEGIN
	-- Instantiate the UUT
   UUT : SPI_IF 
   port map (
	   I_CLK              => I_CLK, 
	   I_RST              => I_RST, 
	   I_DEVICE_ID        => I_DEVICE_ID, -- Should always latch to voltage reg
	   
	   -- Physical Lines
	   I_MISO             => I_MISO,
	   O_SCLK             => O_SCLK,
	   O_MOSI             => O_MOSI,
	   O_CS_0             => O_CS_0,
	   O_CS_1             => O_CS_1,
	   O_CS_2             => O_CS_2,
	   O_CS_3             => O_CS_3,
	   
	   -- Register Values
	   O_VOLTAGE_REG      => O_VOLTAGE_REG,
	   O_CURRENT_REG      => O_CURRENT_REG,
	   O_TEMP_REG         => O_TEMP_REG,
	   O_HUMIDITY_REG     => O_HUMIDITY_REG);

   -- Clock process definitions
   I_CLK <= not I_CLK after C_CLK_PERIOD/2;
 
   -- Stimulus process
   Stimulus : process
	
	-- Procedure to generate serial data stream from ADC for one sample
	procedure Generate_Data (data : in std_logic_vector(15 downto 0)) is
	begin
		-- Wait for ADC_CS falling edge
		wait until falling_edge(O_CS_0);
		
		-- Set ADC data to zero
		I_MISO <= '0';
		
		-- Output 16 consecutive bits of an ADC sample on I_MISO
		-- Sync'd to falling edge of O_SCLK
		for i in 15 downto 0 loop
			exit when O_CS_0 = '1';  -- check that CS stays low
			wait until falling_edge(O_SCLK);
			exit when O_CS_0 = '1';  -- check that CS stays low
			wait for 17 ns;  -- tDACC = 17 ns typical, 27 ns max.
			I_MISO <= data(i);
			exit when O_CS_0 = '1';  -- check that CS stays low
			wait until rising_edge(O_SCLK);
			exit when O_CS_0 = '1';  -- check that CS stays low
		end loop;
		
		-- set ADC data to zero
		wait until rising_edge(O_CS_0);
		I_MISO <= '0';
	end procedure;
	
   begin		

      -- insert stimulus here
		
		-- for each test vector, generate the signals and timing for the ADC SPI
		for k in C_TEST_DATA'range loop     
			Generate_Data(C_TEST_DATA(k));
		end loop;
		
      wait;
		
   end process;

end BEHAVIORAL;