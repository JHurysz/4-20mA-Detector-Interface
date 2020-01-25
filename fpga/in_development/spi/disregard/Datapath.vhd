library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Datapath is
	port( ADC_Number : in std_logic_vector(2 downto 0);
         SPI_MISO, clk, clr_count, ld_count, ld_controlReg, controlReg_S, ld_DataReg, ld_ADC_data_out : in std_logic;
         SPI_MOSI,Compare_16, Compare_4, Compare_1 : out std_logic;
         ADC_data_out : out std_logic_vector(11 downto 0));
end Datapath;

architecture Behavioral of Datapath is

    signal Counter : std_logic_vector(4 downto 0) := (others => '0');
    signal controlReg, controlRegIn : std_logic_vector(3 downto 0):= (others => '0');
    signal dataReg : std_logic_vector(11 downto 0):= (others => '0');
--	 signal SPI_MOSI_Sig : std_logic;

begin

    -- 5 Bit Counter --
    process(clk) begin
        if rising_edge(clk) then
            if clr_count = '1' then
                Counter <= "00000";
            elsif ld_count = '1' then
                Counter <= std_logic_vector(unsigned(Counter) + 1);
            end if;
        end if;
    end process;

    -- Compare_16 --
    process(Counter)
	begin
		if Counter = "10000" then
			Compare_16 <= '1';
		else
			Compare_16 <= '0';
		end if;
	end process;

    -- Compare_4 --
    process(Counter)
	begin
		if Counter = "00100" then
			Compare_4 <= '1';
		else
			Compare_4 <= '0';
		end if;
	end process;

    -- Compare_1 --
    process(Counter)
	begin
		if Counter = "00001" then
			Compare_1 <= '1';
		else
			Compare_1 <= '0';
		end if;
	end process;

    -- Control Register --
    process(clk, controlReg_S, controlReg(2 downto 0), ADC_Number)
	begin
		if rising_edge(clk) then
			if ld_controlReg = '1' then
				controlReg <= '0'&ADC_Number;
			elsif ControlReg_S = '1' then
				controlReg <= controlReg(2 downto 0) & '0';
			else
				controlReg <= controlReg;
			end if;
		end if;
	end process;
	SPI_MOSI <= controlReg(3);

    -- Data Register --
    process(clk) begin
        if rising_edge(clk) then
			if ld_DataReg = '1' then
				 dataReg <= dataReg(10 downto 0) & SPI_MISO;
			end if;
		end if;
	end process;

    -- ADC_data_out Register --
    process(clk) begin
        if rising_edge(clk) then
			if ld_ADC_data_out = '1' then
				 ADC_data_out <= dataReg;
			end if;
		end if;
	end process;


end Behavioral;
