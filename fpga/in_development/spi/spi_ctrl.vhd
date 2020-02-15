------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz                      --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity SPI_CTRL is
    port (
        I_CLK       : in std_logic;
        I_RST       : in std_logic;
        I_DEVICE_ID : in std_logic_vector(1 downto 0);

        -- Control Signals
        I_ALL_BITS_TRANSFERRED : in  std_logic;
        I_START_OF_TRANSFER    : in  std_logic;
		I_END_CS_DELAY         : in  std_logic;
        O_CLR_SPI_COUNT        : out std_logic;
        O_LD_SPI_COUNT         : out std_logic;
        O_SHIFT_CONFIG_REG     : out std_logic;
        O_LD_CONFIG_REG        : out std_logic;
        O_LD_DATA_REG          : out std_logic;
        O_LD_DATA_OUT          : out std_logic;
		O_LD_CS_DELAY_PIPE     : out std_logic;
		O_SHIFT_CS_DELAY_PIPE  : out std_logic;

        -- Physical Data Lines
        O_SCLK      : out std_logic;
        O_CS_0      : out std_logic;
        O_CS_1      : out std_logic;
        O_CS_2      : out std_logic;
        O_CS_3      : out std_logic);
end SPI_CTRL;

architecture BEHAVIORAL of SPI_CTRL is

	 
	 --
	 Constant C_CSSC_SCCS_CYCLES : positive := 4;
	 
    -- Sampling Signals
    signal start_sample : std_logic;
    signal sample_ctr   : std_logic_vector(8 downto 0) := (others => '0'); -- counts ticks b/w sample edges (10-bits is a guess)
    signal internal_clk : std_logic;
	 
	 -- Othter Signals
	 signal config_flash : std_logic := '0';

    -- FSM Type(s)
    type T_SPI_COUNT is (S_CLEAR, S_WAIT_CSSC, S_DELAY, S_COUNT, S_WAIT_SCCS);
    signal spi_count, spi_count_next : T_SPI_COUNT := S_CLEAR;

    type T_SPI_DATA_MISO is (S_LOAD_MISO, S_SHIFT_MISO, S_WAIT_MISO);
    signal spi_data_miso, spi_data_miso_next : T_SPI_DATA_MISO := S_LOAD_MISO;

    type T_SPI_DATA_MOSI is (S_LOAD_MOSI, S_SHIFT_MOSI, S_WAIT_MOSI);
    signal spi_data_mosi, spi_data_mosi_next : T_SPI_DATA_MOSI := S_LOAD_MOSI;


begin

    Sample_Counter : process(I_CLK) begin
        if rising_edge(I_CLK) then
            if I_RST = '1' then
                sample_ctr   <= (others => '0');
            else
                sample_ctr   <= std_logic_vector(unsigned(sample_ctr) + 1);
            end if;
        end if;
    end process Sample_Counter;

    -- sample starts after 1024 cycles
    start_sample <= '1' when (sample_ctr(8 downto 0) = ("111111111")) else '0';

    State_Process : process(I_CLK) begin
        if rising_edge(I_CLK) then
            if I_RST = '1' then
                spi_count      <= S_CLEAR;
                spi_data_miso  <= S_LOAD_MISO;
                spi_data_mosi  <= S_LOAD_MOSI;
            else
                spi_count     <= spi_count_next;
                spi_data_miso <= spi_data_miso_next;
                spi_data_mosi <= spi_data_mosi_next;
            end if;
        end if;
    end process State_Process;

    -- Count Control Transition Logic
    SPI_Count_Transition : process(spi_count, start_sample, I_ALL_BITS_TRANSFERRED,I_END_CS_DELAY) begin -- remember to add to sensitivity list
        
		  -- Defaults
		  O_LD_CS_DELAY_PIPE <= '0';
		  
		  case spi_count is
            when S_CLEAR =>
                if start_sample = '1' then
                    spi_count_next <= S_WAIT_CSSC;
					O_LD_CS_DELAY_PIPE <= '1';
                else
                    spi_count_next <= S_CLEAR;
                end if;
					 
				when S_WAIT_CSSC =>
				
					if I_END_CS_DELAY = '1' then
						spi_count_next <= S_DELAY;
						O_LD_CS_DELAY_PIPE <= '1';
					else
						spi_count_next <= S_WAIT_CSSC;
					end if;
					

            when S_DELAY =>
                    if I_ALL_BITS_TRANSFERRED = '1' then
                        spi_count_next <= S_WAIT_SCCS;
                    else
                        spi_count_next <= S_COUNT;
                    end if;

            when S_COUNT =>
                    spi_count_next <= S_DELAY;
						  
				when S_WAIT_SCCS =>
					
					if I_END_CS_DELAY = '1' then
						spi_count_next <= S_CLEAR;
					else
						spi_count_next <= S_WAIT_SCCS;
					end if;

            when others =>
                    spi_count_next <= S_CLEAR;
                        
        end case;
    end process SPI_Count_Transition;

    -- MISO Control Transition Logic
    MISO_Transition : process(spi_data_miso, start_sample, I_ALL_BITS_TRANSFERRED) begin -- remember to add to sensitivity list
        case spi_data_miso is
            when S_LOAD_MISO  =>
                if (start_sample = '1') then
                    spi_data_miso_next <= S_WAIT_MISO;
                else
                    spi_data_miso_next <= S_LOAD_MISO;
                end if;

            when S_WAIT_MISO  =>
                    spi_data_miso_next <= S_SHIFT_MISO;

            when S_SHIFT_MISO =>
                if I_ALL_BITS_TRANSFERRED = '1' then
                    spi_data_miso_next <= S_LOAD_MISO;
                else
                    spi_data_miso_next <= S_WAIT_MISO;
                end if;

            when others =>
                    spi_data_miso_next <= S_LOAD_MISO;
        end case;
    end process MISO_Transition;

    -- MOSI Control Transition Logic
    MOSI_Transition : process(spi_data_mosi, config_flash, I_START_OF_TRANSFER, internal_clk, I_ALL_BITS_TRANSFERRED) begin -- remember to add to sensitivity list
        case spi_data_mosi is
            when S_LOAD_MOSI  =>
                if (config_flash = '1' and I_START_OF_TRANSFER = '1' and internal_clk = '0') then
                    spi_data_mosi_next <= S_SHIFT_MOSI;
                else
                    spi_data_mosi_next <= S_LOAD_MOSI;
                end if;

            when S_SHIFT_MOSI =>
                spi_data_mosi_next <= S_WAIT_MOSI;

            when S_WAIT_MOSI  =>
                if I_ALL_BITS_TRANSFERRED = '1' then
                    spi_data_mosi_next <= S_LOAD_MOSI;
                else 
                    spi_data_mosi_next <= S_SHIFT_MOSI;
                end if;

            when others       =>
                spi_data_mosi_next <= S_LOAD_MOSI;
        end case;
    end process MOSI_Transition;

    -- Chip Select Logic
    Chip_Select_Arbiter : process(spi_count, I_DEVICE_ID) begin
        if (spi_count = S_CLEAR) then
            O_CS_0 <= '1';
            O_CS_1 <= '1';
            O_CS_2 <= '1';
            O_CS_3 <= '1';
        else
            O_CS_0 <= '1';
            O_CS_1 <= '1';
            O_CS_2 <= '1';
            O_CS_3 <= '1';

            case I_DEVICE_ID is
                when "00" =>
                    O_CS_0 <= '0';

                when "01" =>
                    O_CS_1 <= '0';

                when "10" =>
                    O_CS_2 <= '0';

                when "11" =>
                    O_CS_3 <= '0';


                when others =>
                    O_CS_0 <= '1';
                    O_CS_1 <= '1';
                    O_CS_2 <= '1';
                    O_CS_3 <= '1';
            end case;
        end if;
    end process Chip_Select_Arbiter;

    -- Serial Clock Generation
    O_SCLK             <= '1' when (spi_count = S_DELAY) else '0';
    internal_clk       <= '1' when (spi_count = S_DELAY) else '0';
    O_CLR_SPI_COUNT    <= '1' when (spi_count = S_CLEAR)                        else '0';
    O_LD_SPI_COUNT     <= '1' when (spi_count = S_COUNT)                        else '0';
    O_SHIFT_CONFIG_REG <= '1' when (spi_data_mosi = S_SHIFT_MOSI)               else '0';
    O_LD_CONFIG_REG    <= '1' when (spi_data_mosi = S_LOAD_MOSI)                else '0';
    O_LD_DATA_OUT      <= '1' when (spi_data_miso = S_LOAD_MISO)                else '0';
    O_LD_DATA_REG      <= '1' when ((spi_data_miso = S_SHIFT_MISO) and (I_ALL_BITS_TRANSFERRED = '0'))              else '0';
	O_SHIFT_CS_DELAY_PIPE <= '1' when ((spi_count = S_WAIT_CSSC) or (spi_count = S_WAIT_SCCS)) else '0';

end BEHAVIORAL;