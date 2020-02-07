----------------------------------------------------------------------------------
-- Company: 		 Binghamton University
-- Engineer: 		 
-- 
-- Module Name:    HEXon7segDisp - Behavioral 
-- Project Name:   Lab3 - 7-Segment Display Controller
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity HEXon7segDisp is
    Port ( hex_data_in0 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in1 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in2 : in  STD_LOGIC_VECTOR (3 downto 0);
           hex_data_in3 : in  STD_LOGIC_VECTOR (3 downto 0);
           dp_in : in  STD_LOGIC_VECTOR (2 downto 0);
           seg_out : out  STD_LOGIC_VECTOR (6 downto 0);
           an_out : out  STD_LOGIC_VECTOR (3 downto 0);
           dp_out : out  STD_LOGIC;
           clk : in  STD_LOGIC);
end HEXon7segDisp;

architecture Behavioral of HEXon7segDisp is

	signal Counter : unsigned (10 downto 0) := (others => '0') ;
		alias MuxSel1 : unsigned (1 downto 0) is Counter(10 downto 9);
		alias MuxSel2 : unsigned (3 downto 0) is Counter(10 downto 7);
		
	constant tc : unsigned(10 downto 0) := (others => '1');
	signal HexSel : std_logic_vector (3 downto 0):= (others => '0');

begin

	
	-- Up Counter
	process(clk) begin
		if rising_edge(clk) then
			if (Counter = tc) then
				Counter <= (others => '0');
			else
				Counter <= (Counter + 1);
			end if;

		end if;
	end process;

	

	-- Create a mux which selects one of the hex data inputs according 
	-- to the value of MuxSel1
	-- Code using process with case statement:
	process(MuxSel1, hex_data_in0, hex_data_in1, hex_data_in2, hex_data_in3) begin
		case MuxSel1 is
			when "00" => HexSel<= hex_data_in0;
			when "01" => HexSel<= hex_data_in1;
			when "10" => HexSel<= hex_data_in2;
			when "11" => HexSel<= hex_data_in3;
			when others => HexSel<= hex_data_in0;
		end case;
	end process;
	 
	-- Create a mux that will enable one of the anodes. 
	-- Enable the anode of the digit to be displayed as selected by MuxSel2.
	-- A zero enables the respective anode.
	process(MuxSel2) begin
		case MuxSel2 is
			when "1111" | "0000" | "0011" | "0100" | "1011" | "1100" | "0111" | "1000" => an_out<= "1111";
			when "0001" | "0010" => an_out<= "1110";
			when "0101" | "0110" => an_out<= "1101";
			when "1001" | "1010" => an_out<= "1011";
			when "1101" | "1110" => an_out<= "0111";
			when others => an_out <= "0000";
		end case;
	end process;


	-- Create combinational logic to convert a four-bit hex character 
	-- value to a 7-segment vector, seg_out.  
	-- Map HEX character of selected data (in the HexSel register) 
	-- to value of seg_out using the following segment encoding:
	--      A
	--     ---  
	--  F |   | B
	--     ---  <- G
	--  E |   | C
	--     ---
	--      D
	-- seg_out has the order "GFEDCBA"	
	-- a zero lights the segment
	-- e.g. "1111001" lights segments B and C which is a "1"
	process(HexSel) begin
		case HexSel is
			when "0000" => seg_out<= "1000000";
			when "0001" => seg_out<= "1111001";
			when "0010" => seg_out<= "0100100";
			when "0011" => seg_out<= "0110000";
			when "0100" => seg_out<= "0011001";
			when "0101" => seg_out<= "0010010";
			when "0110" => seg_out<= "0000010";
			when "0111" => seg_out<= "1111000";
			when "1000" => seg_out<= "0000000";
			when "1001" => seg_out<= "0010000";
			when "1010" => seg_out<= "0001000";
			when "1011" => seg_out<= "0000011";
			when "1100" => seg_out<= "1000110";
			when "1101" => seg_out<= "0100001";
			when "1110" => seg_out<= "0000110";
			when "1111" => seg_out<= "0001110";
			when others => seg_out<= "1000000";
		end case;
	end process;
	
	


	-- Create combinational logic to enable the selected decimal point. 
	-- Enable the dp_out (enabled is '0') if selected by dp_in
	-- and only when its respective anode is enabled according to the
	-- value of MuxSel2
	-- dp_in    display
	-- "000"    8 8 8 8
	-- "001"    8.8 8 8	
	-- "010"    8 8.8 8	
	-- "011"    8 8 8.8	
	-- "100"    8 8 8 8.	
	process(dp_in, MuxSel2) begin
		if ((MuxSel2(3 downto 0) = "0010") or (MuxSel2(3 downto 0) = "0001")) then
			if (dp_in = "001") then
				dp_out <= '0';
			else dp_out <= '1';
			end if;
		elsif((MuxSel2(3 downto 0) = "0101") or (MuxSel2(3 downto 0) = "0110")) then
			if (dp_in = "010") then
				dp_out <= '0';
			else
				dp_out <= '1';
			end if;
		elsif((MuxSel2(3 downto 0) = "1001") or (MuxSel2(3 downto 0) = "1010")) then
			if (dp_in = "011") then
				dp_out <= '0';
			else
				dp_out <= '1';
			end if;
		elsif((MuxSel2(3 downto 0) = "1101") or (MuxSel2(3 downto 0) = "1110")) then
			if (dp_in = "100") then
				dp_out <= '0';
			else
				dp_out <= '1';
			end if;
		else
			dp_out <= '1';
		end if;
		
	end process;
	
end Behavioral ;