------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz, Carl Betcher        --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity SEVEN_SEG_CTRL is
    Port ( 
           I_CLK           : in   STD_LOGIC;
           -- I_RST           : in   STD_LOGIC;

           I_HEX_DATA_IN_0 : in   STD_LOGIC_VECTOR (3 downto 0);
           I_HEX_DATA_IN_1 : in   STD_LOGIC_VECTOR (3 downto 0);
           I_HEX_DATA_IN_2 : in   STD_LOGIC_VECTOR (3 downto 0);
           I_HEX_DATA_IN_3 : in   STD_LOGIC_VECTOR (3 downto 0);
           I_DP            : in   STD_LOGIC_VECTOR (2 downto 0);

           O_SEG           : out  STD_LOGIC_VECTOR (6 downto 0);
           O_ANODE         : out  STD_LOGIC_VECTOR (3 downto 0);
           O_DP            : out  STD_LOGIC);
end SEVEN_SEG_CTRL;

architecture BEHAVIORAL of SEVEN_SEG_CTRL is

	signal ctr : unsigned (10 downto 0) := (others => '0') ;
		alias multiplexer_s1 : unsigned (1 downto 0) is ctr(10 downto 9);
		alias multiplexer_s2 : unsigned (3 downto 0) is ctr(10 downto 7);
		
	constant C_TERMINAL_COUNT : unsigned        (10 downto 0) := (others => '1');
	signal   data_selected    : std_logic_vector (3 downto 0) := (others => '0');

begin

	
	-- Counter Block
	Up_Counter : process(I_CLK) begin
		if rising_edge(I_CLK) then
			if (ctr = C_TERMINAL_COUNT) then
				ctr <= (others => '0');
			else
				ctr <= (ctr + 1);
			end if;
		end if;
	end process Up_Counter;

	

	-- Create a mux which selects one of the hex data inputs according 
	-- to the value of multiplexer_s1
	-- Code using process with case statement:
	process(multiplexer_s1, I_HEX_DATA_IN_0, I_HEX_DATA_IN_1, I_HEX_DATA_IN_2, I_HEX_DATA_IN_3) begin
		case multiplexer_s1 is
			when "00" =>   data_selected <= I_HEX_DATA_IN_0;
			when "01" =>   data_selected <= I_HEX_DATA_IN_1;
			when "10" =>   data_selected <= I_HEX_DATA_IN_2;
			when "11" =>   data_selected <= I_HEX_DATA_IN_3;
			when others => data_selected <= I_HEX_DATA_IN_0;
		end case;
	end process;
	 
	-- Create a mux that will enable one of the anodes. 
	-- Enable the anode of the digit to be displayed as selected by multiplexer_s2.
	-- A zero enables the respective anode.
	process(multiplexer_s2) begin
		case multiplexer_s2 is
            when "1111" | "0000" | 
                 "0011" | "0100" | 
                 "1011" | "1100" | 
                 "0111" | "1000" => O_ANODE<= "1111";
			when "0001" | "0010" => O_ANODE <= "1110";
			when "0101" | "0110" => O_ANODE <= "1101";
			when "1001" | "1010" => O_ANODE <= "1011";
			when "1101" | "1110" => O_ANODE <= "0111";
			when others          => O_ANODE <= "0000";
		end case;
	end process;


	-- Create combinational logic to convert a four-bit hex character 
	-- value to a 7-segment vector, O_SEG.  
	-- Map HEX character of selected data (in the data_selected register) 
	-- to value of O_SEG using the following segment encoding:
	--      A
	--     ---  
	--  F |   | B
	--     ---  <- G
	--  E |   | C
	--     ---
	--      D
	-- O_SEG has the order "GFEDCBA"	
	-- a zero lights the segment
	-- e.g. "1111001" lights segments B and C which is a "1"
	process(data_selected) begin
		case data_selected is
			when "0000" => O_SEG <= "1000000"; -- 0
			when "0001" => O_SEG <= "1111001"; -- 1
			when "0010" => O_SEG <= "0100100"; -- 2
			when "0011" => O_SEG <= "0110000"; -- 3
			when "0100" => O_SEG <= "0011001"; -- 4
			when "0101" => O_SEG <= "0010010"; -- 5
			when "0110" => O_SEG <= "0000010"; -- 6
			when "0111" => O_SEG <= "1111000"; -- 7
			when "1000" => O_SEG <= "0000000"; -- 8
			when "1001" => O_SEG <= "0010000"; -- 9
			when "1010" => O_SEG <= "0001000"; -- A
			when "1011" => O_SEG <= "0000011"; -- B
			when "1100" => O_SEG <= "1000110"; -- C
			when "1101" => O_SEG <= "0100001"; -- D
			when "1110" => O_SEG <= "0000110"; -- E
			when "1111" => O_SEG <= "0001110"; -- F
			when others => O_SEG <= "1000000"; -- 0 
		end case;
	end process;
	
	-- Create combinational logic to enable the selected decimal point. 
	-- Enable the O_DP (enabled is '0') if selected by I_DP
	-- and only when its respective anode is enabled according to the
	-- value of multiplexer_s2
	-- I_DP    display
	-- "000"    8 8 8 8
	-- "001"    8.8 8 8	
	-- "010"    8 8.8 8	
	-- "011"    8 8 8.8	
	-- "100"    8 8 8 8.	
	process(I_DP, multiplexer_s2) begin
		if ((multiplexer_s2(3 downto 0) = "0010") or (multiplexer_s2(3 downto 0) = "0001")) then
			if (I_DP = "001") then
				O_DP <= '0';
            else 
                O_DP <= '1';
			end if;
		elsif((multiplexer_s2(3 downto 0) = "0101") or (multiplexer_s2(3 downto 0) = "0110")) then
			if (I_DP = "010") then
				O_DP <= '0';
			else
				O_DP <= '1';
			end if;
		elsif((multiplexer_s2(3 downto 0) = "1001") or (multiplexer_s2(3 downto 0) = "1010")) then
			if (I_DP = "011") then
				O_DP <= '0';
			else
				O_DP <= '1';
			end if;
		elsif((multiplexer_s2(3 downto 0) = "1101") or (multiplexer_s2(3 downto 0) = "1110")) then
			if (I_DP = "100") then
				O_DP <= '0';
			else
				O_DP <= '1';
			end if;
		else
			O_DP <= '1';
		end if;
	end process;
end BEHAVIORAL ;