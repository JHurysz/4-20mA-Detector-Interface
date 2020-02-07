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

         I_HEX_DATA_IN_0 : in  std_logic_vector(3 downto 0);
         I_HEX_DATA_IN_1 : in  std_logic_vector(3 downto 0);
         I_HEX_DATA_IN_2 : in  std_logic_vector(3 downto 0);
         I_HEX_DATA_IN_3 : in  std_logic_vector(3 downto 0);
         I_DP            : in  std_logic_vector(2 downto 0);

         O_SEG           : out  std_logic_vector(6 downto 0);
         O_ANODE         : out  std_logic_vector(3 downto 0);
         O_DP            : out  std_logic);
    end component;
    

   --inputs
   signal I_HEX_DATA_IN_0 : std_logic_vector(3 downto 0) := (others => '0');
   signal I_HEX_DATA_IN_1 : std_logic_vector(3 downto 0) := (others => '0');
   signal I_HEX_DATA_IN_2 : std_logic_vector(3 downto 0) := (others => '0');
   signal I_HEX_DATA_IN_3 : std_logic_vector(3 downto 0) := (others => '0');
   signal I_DP : std_logic_vector(2 downto 0) := (others => '0');
   signal I_CLK : std_logic := '0';

 	--outputs
   signal O_SEG : std_logic_vector(6 downto 0);
   signal O_ANODE : std_logic_vector(3 downto 0);
   signal O_DP : std_logic;

   -- Clock period definitions
   constant I_CLK_period : time := 31.25 ns;
	
	
 type test_vector is record
		I_HEX_DATA_IN_0 : STD_LOGIC_VECTOR (3 downto 0);
		I_HEX_DATA_IN_1 : STD_LOGIC_VECTOR (3 downto 0);
      I_HEX_DATA_IN_2 : STD_LOGIC_VECTOR (3 downto 0);
      I_HEX_DATA_IN_3 : STD_LOGIC_VECTOR (3 downto 0);
      I_DP :  STD_LOGIC_VECTOR (2 downto 0);
	end record test_vector;
type test_data_array is array (natural range <>) of test_vector;
constant test_data : test_data_array := 
(("0101", "1010", "0011", "1100", "000" ),
("0110", "1001", "0111", "1000", "001" ),
("0001", "0010", "0100", "1011", "010" ),
("0000", "1101", "1110", "1111", "100" ));

BEGin
	
	-- instantiate the Unit Under Test (UUT)
   uut: HEXon7segDisp port MAP (
          I_HEX_DATA_IN_0 => I_HEX_DATA_IN_0,
          I_HEX_DATA_IN_1 => I_HEX_DATA_IN_1,
          I_HEX_DATA_IN_2 => I_HEX_DATA_IN_2,
          I_HEX_DATA_IN_3 => I_HEX_DATA_IN_3,
          I_DP => I_DP,
          O_SEG => O_SEG,
          O_ANODE => O_ANODE,
          O_DP => O_DP,
          I_CLK => I_CLK
        );

   -- Clock process definitions
   I_CLK_process :process
   begin
		I_CLK <= '0';
		wait for I_CLK_period/2;
		I_CLK <= '1';
		wait for I_CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for I_CLK_period*10;

      -- insert stimulus here 

      wait;
   end process;

end BEHAVIORAL;
