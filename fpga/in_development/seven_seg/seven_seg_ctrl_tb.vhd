------------------------------------------------
-- Team:      WCP03 4-20mA Detector interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz, Carl Betcher        --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
 
 
entity SEVEN_SEG_CTRL_TB is
end SEVEN_SEG_CTRL_TB;
 
architecture BEHAVIORAL OF SEVEN_SEG_CTRL_TB is 
 
    -- component Declaration for the Unit Under Test (UUT)
 
    component SEVEN_SEG_CTRL
    port(
         I_CLK           : in  std_logic;
         -- I_RST        : in std_logic;

         I_HEX_DATA_IN_0 : in   std_logic_vector(3 downto 0);
         I_HEX_DATA_IN_1 : in   std_logic_vector(3 downto 0);
         I_HEX_DATA_IN_2 : in   std_logic_vector(3 downto 0);
         I_HEX_DATA_IN_3 : in   std_logic_vector(3 downto 0);
         I_DP            : in   std_logic_vector(2 downto 0);

         O_SEG           : out  std_logic_vector(6 downto 0);
         O_ANODE         : out  std_logic_vector(3 downto 0);
         O_DP            : out  std_logic);
    end component;
    

   -- Inputs
   signal I_HEX_DATA_IN_0 : std_logic_vector(3 downto 0) := (others => '0');
   signal I_HEX_DATA_IN_1 : std_logic_vector(3 downto 0) := (others => '0');
   signal I_HEX_DATA_IN_2 : std_logic_vector(3 downto 0) := (others => '0');
   signal I_HEX_DATA_IN_3 : std_logic_vector(3 downto 0) := (others => '0');
   signal I_DP            : std_logic_vector(2 downto 0) := (others => '0');
   signal I_CLK           : std_logic := '0';

 	-- Outputs
   signal O_SEG           : std_logic_vector(6 downto 0);
   signal O_ANODE         : std_logic_vector(3 downto 0);
   signal O_DP            : std_logic;

   -- Clock period definitions
   constant C_CLK_PERIOD : time := 31.25 ns;
	
	
    type test_vector is record
		I_HEX_DATA_IN_0 : STD_LOGIC_VECTOR (3 downto 0);
		I_HEX_DATA_IN_1 : STD_LOGIC_VECTOR (3 downto 0);
        I_HEX_DATA_IN_2 : STD_LOGIC_VECTOR (3 downto 0);
        I_HEX_DATA_IN_3 : STD_LOGIC_VECTOR (3 downto 0);
        I_DP            : STD_LOGIC_VECTOR (2 downto 0);
    end record test_vector;
    
    type test_data_array is array (natural range <>) of test_vector;

    constant C_TEST_DATA : test_data_array := 
    (("0101", "1010", "0011", "1100", "000"),
    ("0110", "1001", "0111", "1000", "001" ),
    ("0001", "0010", "0100", "1011", "010" ),
    ("0000", "1101", "1110", "1111", "100" ));

begin
	
	-- instantiate the Unit Under Test (UUT)
   UUT : SEVEN_SEG_CTRL port map (
          I_CLK           => I_CLK,
          -- I_RST        => I_RST,

          I_HEX_DATA_IN_0 => I_HEX_DATA_IN_0,
          I_HEX_DATA_IN_1 => I_HEX_DATA_IN_1,
          I_HEX_DATA_IN_2 => I_HEX_DATA_IN_2,
          I_HEX_DATA_IN_3 => I_HEX_DATA_IN_3,
          I_DP            => I_DP,

          O_SEG           => O_SEG,
          O_ANODE         => O_ANODE,
          O_DP            => O_DP);

   -- Clock process definitions
   I_CLK_Process : process
   begin
		I_CLK <= '0';
		wait for C_CLK_PERIOD/2;
		I_CLK <= '1';
		wait for C_CLK_PERIOD/2;
   end process I_CLK_Process;
 

   -- Stimulus process
   Stimulus: process
   begin		

      wait for 100 ns;
      wait for C_CLK_PERIOD*10;

      for i in C_TEST_DATA'range loop
          I_HEX_DATA_IN_0       <= C_TEST_DATA(i).I_HEX_DATA_IN_0;
          I_HEX_DATA_IN_1       <= C_TEST_DATA(i).I_HEX_DATA_IN_1;
          I_HEX_DATA_IN_2       <= C_TEST_DATA(i).I_HEX_DATA_IN_2;
          I_HEX_DATA_IN_3       <= C_TEST_DATA(i).I_HEX_DATA_IN_3;
          I_DP                  <= C_TEST_DATA(i).I_DP;
          wait for C_CLK_PERIOD * 4095;
      end loop;
      wait;
   end process Stimulus;
end BEHAVIORAL;
