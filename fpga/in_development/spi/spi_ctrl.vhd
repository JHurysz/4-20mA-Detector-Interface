------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz                      --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity SPI_CTRL_1_0 is
    port (
        I_CLK       : in std_logic;
        I_RST       : in std_logic;
        I_DEVICE_ID : in std_logic_vector(2 downto 0);

        O_SCLK      : out std_logic;
        O_CS_0      : out std_logic;
        O_CS_1      : out std_logic;
        O_CS_2      : out std_logic;
        O_CS_3      : out std_logic;
        O_CS_4      : out std_logic);
end SPI_CTRL_1_0;

architecture BEHAVIORAL of SPI_CTRL_1_0 is

    -- Sampling Signals
    signal start_sample : std_logic
    signal sample_ctr   : std_logic_vector(9 downto 0) -- counts ticks b/w sample edges (10-bits is a guess)


    -- FSM Type(s)
    type T_SPI_COUNT is (S_CLEAR, S_DELAY, S_COUNT);
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
    start_sample <= '1' when (sample_ctr = (others => '1')) else '0';

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
    SPI_Count_Transition : process(spi_count) begin -- remember to add to sensitivity list
        case spi_count is
            when S_CLEAR =>

            when S_DELAY =>

            when S_COUNT =>

            when others  =>
        end case;
    end process SPI_Count_Transition;

    -- MISO Control Transition Logic
    MISO_Transition : process(spi_data_miso) begin -- remember to add to sensitivity list
        case spi_data_miso is
            when S_LOAD_MISO  =>

            when S_SHIFT_MISO =>

            when S_WAIT_MISO  =>

            when others       =>
        end case;
    end process MISO_Transition;

    -- MOSI Control Transition Logic
    MOSI_Transition : process(spi_data_mosi) begin -- remember to add to sensitivity list
        case spi_data_mosi is
            when S_LOAD_MOSI  =>

            when S_SHIFT_MOSI =>

            when S_WAIT_MOSI  =>

            when others       =>
        end case;
    end process MOSI_Transition;

    -- Chip Select Logic
    Chip_Select_Arbiter : process(spi_count, I_DEVICE_ID) begin
        if (spi_count = S_CLEAR) then
            O_CS_0 <= '1';
            O_CS_1 <= '1';
            O_CS_2 <= '1';
            O_CS_3 <= '1';
            O_CS_4 <= '1';
        else
            O_CS_0 <= '1';
            O_CS_1 <= '1';
            O_CS_2 <= '1';
            O_CS_3 <= '1';
            O_CS_4 <= '1';

            case I_DEVICE_ID is
                when "000" =>
                    O_CS_0 <= '0';

                when "001" =>
                    O_CS_1 <= '0';

                when "010" =>
                    O_CS_2 <= '0';

                when "011" =>
                    O_CS_3 <= '0';

                when "100" =>
                    O_CS_4 <= '0'

                when others =>
                    O_CS_0 <= '1';
                    O_CS_1 <= '1';
                    O_CS_2 <= '1';
                    O_CS_3 <= '1';
                    O_CS_4 <= '1';
            end case;
        end if;
    end process Chip_Select_Arbiter;

    -- Serial Clock Generation
    O_SCLK <= '1' when (spi_count = S_CLEAR or spi_count = S_DELAY) else '0';

end BEHAVIORAL;