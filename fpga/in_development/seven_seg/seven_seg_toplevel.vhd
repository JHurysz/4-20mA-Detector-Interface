------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz, Carl Betcher        --
------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity SEVEN_SEG_TOPLEVEL is
    Port ( I_SWITCH  : in  std_logic_vector (7 downto 0);
           I_BUTTON  : in  std_logic_vector (2 downto 0);
           I_CLK     : in  std_logic;
           O_SEG     : out  std_logic_vector (6 downto 0);
           O_ANODE   : out  std_logic_vector (4 downto 0);
           O_DP      : out  std_logic;
		   O_LED     : out std_logic_vector(7 downto 0));
end SEVEN_SEG_TOPLEVEL;


architecture BEHAVIORAL of SEVEN_SEG_TOPLEVEL is

component REG_WITH_LOAD
	port( I_CLK  : in   std_logic;
		  I_EN   : in   std_logic;
		  I_DATA : in   std_logic_vector (3 downto 0);
		  O_DATA : out  std_logic_vector (3 downto 0));
end component;

component Seven_Seg_Ctrl
	port(  I_CLK           : in   std_logic
		   I_HEX_DATA_IN_0 : in   std_logic_vector (3 downto 0);
           I_HEX_DATA_IN_1 : in   std_logic_vector (3 downto 0);
           I_HEX_DATA_IN_2 : in   std_logic_vector (3 downto 0);
           I_HEX_DATA_IN_3 : in   std_logic_vector (3 downto 0);
           I_DP            : in   std_logic_vector (2 downto 0);
           O_SEG           : out  std_logic_vector (6 downto 0);
           O_ANODE         : out  std_logic_vector (3 downto 0);
           O_DP            : out  std_logic);
end component;

signal reg1_out : std_logic_vector(3 downto 0);
signal reg2_out : std_logic_vector(3 downto 0);
signal reg3_out : std_logic_vector(3 downto 0);
signal reg4_out : std_logic_vector(3 downto 0);
signal reg5_out : std_logic_vector(3 downto 0);

begin
					
	Reg1: REG_WITH_LOAD 
		port map(
			I_CLK  => I_CLK,
			I_EN   => I_BUTTON(0),
			I_DATA => I_SWITCH(7 downto 4),
			O_DATA => reg1_out);
		);

	Reg2: REG_WITH_LOAD
		port map(	
			I_CLK  => I_CLK, 
			I_DATA => I_SWITCH(3 downto 0), 
			I_EN   => I_BUTTON(0), 
			O_DATA => reg2_out);

	Reg3: REG_WITH_LOAD
		port map(	
			I_CLK  => I_CLK, 
			I_DATA => I_SWITCH(7 downto 4), 
			I_EN   => I_BUTTON(1), 
			O_DATA => reg3_out);

	Reg4: REG_WITH_LOAD
		port map(	
			I_CLK  => I_CLK, 
			I_DATA => I_SWITCH(3 downto 0), 
			I_EN   => I_BUTTON(1), 
			O_DATA => reg4_out);

	Reg5: REG_WITH_LOAD
		port map(	
			I_CLK  => I_CLK, 
			I_DATA => I_SWITCH(3 downto 0), 
			I_EN   => I_BUTTON(2), 
			O_DATA => reg5_out);
			

Inst_Seven_Seg_Ctrl: Seven_Seg_Ctrl 
	PORT MAP(
		I_HEX_DATA_IN_0 => reg1_out,
		I_HEX_DATA_IN_1 => reg2_out,
		I_HEX_DATA_IN_2 => reg3_out,
		I_HEX_DATA_IN_3 => reg4_out,
		I_DP            => reg5_out(2 downto 0),
		O_SEG           => O_SEG,
		O_ANODE         => O_ANODE(3 downto 0),
		O_DP            => O_DP,
		I_CLK           => I_CLK
	);
	
O_ANODE(4) <= '1';
           
O_LED(7 downto 0) <= I_SWITCH(7 downto 0);

end BEHAVIORAL;

