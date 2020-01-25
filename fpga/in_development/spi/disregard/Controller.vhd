library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity Controller is
port(
	clk, Sample, Compare_1, Compare_4, Compare_16 : in STD_LOGIC;
	SPI_SCLK : out STD_LOGIC;
	SPI_CS, clr_count, ld_count, ld_controlReg, controlReg_S, ld_DataReg, ld_ADC_data_out : out STD_LOGIC);

end Controller;


architecture Behavioral of Controller is

type Count_State_Type is (clear, delay, count);-- State Definition
signal CountState, CountNextState : Count_State_type;

type Data_State_Type is (loadData,shiftData, waitData); -- State Definition
signal DataState, DataNextState : Data_State_type;

type Control_State_Type is (loadControl, shiftControl, waitControl); -- State Definition
signal ControlState, ControlNextState : Control_State_type;


signal internalclk : std_logic;

begin

	process(clk) begin
		if rising_edge(clk) then
			CountState <= CountNextState;
			ControlState <= ControlNextState;
			DataState <= DataNextState;
		end if;
	end process;

    process(Sample, Compare_16, CountState)
	 begin
		case CountState is
			When clear =>
				if Sample = '1' then
					CountNextState <= delay;
				else
					CountNextState <= clear;
				end if;

			When delay =>
                if Compare_16 = '0' then
                    CountNextState <= Count;
                elsif Compare_16 = '1' then
                    CountNextState <= clear;
                end if;

			When Count =>
				CountNextState <= delay;
				
			When others =>
				CountNextState <=  clear;
		end case;
	end process;
	
	process(Compare_4, Compare_1, internalclk, ControlState)
	begin
		case ControlState is
			When loadControl =>
				controlReg_S <= '0';
				if (Compare_1 = '1' and internalclk = '0') then
                    ControlNextState <= shiftControl;
                else
                    ControlNextState <= loadControl;
                end if;

			When shiftControl =>
				ControlNextState <= waitControl;
				controlReg_S <= '1';

			When waitControl =>
				if Compare_4 = '1' then
                    ControlNextState <= loadControl;
				else
                    ControlNextState <= shiftControl;
				end if;
				controlReg_S <= '0';
			 When others =>
				ControlNextState <=  loadControl;
		end case;
	end process;
	
	process(Compare_4, Compare_16, DataState)
	begin
		case DataState is
			When loadData =>
                if Compare_4 = '1' then
                    DataNextState <= waitData;
                else
                    DataNextState <= loadData;
                end if;

			When shiftData =>
                if Compare_16 = '1' then
                    DataNextState <= loadData;
                else
                    DataNextState <= waitData;
                end if;

			When waitData =>
    			DataNextState <= shiftData;

			When others =>
				DataNextState <=  loadData;

		end case;
	end process;

SPI_SCLK <= internalclk;

    clr_count <= '1' when (CountState = clear) else '0';
    SPI_CS <= '1' when (CountState = clear) else '0';
    internalclk <='1' when (CountState = clear or CountState = delay) else '0';
    ld_count <= '1' when (CountState = Count) else '0';
    --controlReg_S <= '1' when (ControlState = shiftControl) else '0';
    ld_controlReg <= '1' when (ControlState = loadControl) else '0';
    ld_ADC_data_out <= '1' when (DataState = loadData) else '0';
    ld_DataReg <= '1' when (DataState = shiftData) else '0';
	 
end behavioral;
	 
	 
	 
	 
