library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SPI_MASTER_1_0 is
    generic(
        G_NUM_BITS            : integer := 8;      -- number of bit to serialize
        G_CLK_DIV             : integer := 100 );  -- input clock divider to generate output serial clock; O_SCLK frequency = I_CLK/(2*G_CLK_DIV)
    port (
        I_CLK                 : in  std_logic;
        I_RST                 : in  std_logic;
        I_TX_START            : in  std_logic;  -- start TX on serial line
        O_TX_END              : out std_logic;  -- TX data completed; O_DATA_PARRALLEL available
        I_DATA_PARRALLEL      : in  std_logic_vector(G_NUM_BITS-1 downto 0);  -- data to sent
        O_DATA_PARRALLEL      : out std_logic_vector(G_NUM_BITS-1 downto 0);  -- received data
        O_SCLK                : out std_logic;
        O_SS                  : out std_logic;
        O_MOSI                : out std_logic;
        I_MISO                : in  std_logic);
end SPI_MASTER_1_0;

architecture BEHAVIORAL of SPI_MASTER_1_0 is

    -- Signal Declarations --
    -- Clock Divider signals
    signal clk_cnt              : integer range 0 to G_CLK_DIV*2;
    signal clk_cnt_en           : std_logic;
    signal sclk_rise            : std_logic;
    signal sclk_fall            : std_logic;

    -- Serial SPI Bit Counter
    signal spi_bit_cnt          : integer range 0 to G_NUM_BITS;
    signal spi_bit_tc_met       : std_logic;

    -- Start Signal
    signal tx_start             : std_logic;  -- registered I_TX_START

    -- Tx/Rx Data
    signal tx_data              : std_logic_vector(G_NUM_BITS-1 downto 0);  
    signal rx_data              : std_logic_vector(G_NUM_BITS-1 downto 0);  

    -- FSM Declarations
    type T_SPI_CONTROLLER_FSM is (S_RST, S_TX_RX, S_END);
    signal state, next_state : T_SPI_CONTROLLER_FSM := S_RST;

begin

    spi_bit_tc_met  <= '0' when (spi_bit_cnt > 0) else '1';
    
    State_Process : process(I_CLK)
    begin
        if rising_edge(I_CLK) then
            if I_RST then
                state <= S_RST;
            else
                state <= next_state;
            end if;
        end if;
    end process State_Process;

    State_Transition_Logic : process(state, spi_bit_tc_met, tx_start, sclk_rise, sclk_fall)
    begin
        case state is
            when  S_TX_RX      => 
            if (spi_bit_tc_met = '1') and (sclk_rise = '1') then  
                next_state  <= S_END;
            else 
                next_state  <= S_TX_RX;
            end if;

            when  S_END  => 
                if (sclk_fall = '1') then
                    next_state  <= S_RST;  
                else
                    next_state  <= S_END;  
                end if;

            when  others  =>  -- S_RST
                if (tx_start = '1') then   
                    next_state  <= S_TX_RX;
                else                      
                    next_state  <= S_RST;
                end if;
        end case;
    end process State_Transition_Logic;

    State_Outputs : process(I_CLK)
    begin
        if rising_edge(I_CLK) then

            tx_start <= I_TX_START;
            case state is
                when S_TX_RX  =>

                    O_TX_END             <= '0';
                    clk_cnt_en           <= '1';
                    O_SS                 <= '0';

                    if (sclk_rise = '1') then
                        O_SCLK               <= '1';
                        rx_data              <= rx_data(G_NUM_BITS-2 downto 0) & I_MISO;

                        if(spi_bit_cnt>0) then
                            spi_bit_cnt      <= spi_bit_cnt - 1;
                        end if;

                    elsif (sclk_fall='1') then
                        O_SCLK               <= '0';
                        O_MOSI               <= tx_data(G_NUM_BITS-1);
                        tx_data              <= tx_data(G_NUM_BITS-2 downto 0) & '1';
                    end if;

                when S_END =>

                    O_TX_END              <= sclk_fall;
                    O_DATA_PARRALLEL      <= rx_data;
                    spi_bit_cnt           <= G_NUM_BITS-1;
                    clk_cnt_en            <= '1';
                    O_SS                  <= '0';
                
                when others =>  -- S_RST

                    tx_data              <= I_DATA_PARRALLEL;
                    O_TX_END             <= '0';
                    spi_bit_cnt          <= G_NUM_BITS-1;
                    clk_cnt_en           <= '0';
                    O_SCLK               <= '1';
                    O_SS                 <= '1';
                    O_MOSI               <= '1';    
                    
            end case;

            if I_RST then

                tx_start           <= '0';
                tx_data            <= (others=>'0');
                rx_data            <= (others=>'0');
                O_TX_END           <= '0';
                O_DATA_PARRALLEL   <= (others=>'0');
                
                spi_bit_cnt        <= G_NUM_BITS-1;
                clk_cnt_en         <= '0';
                O_SCLK             <= '1';
                O_SS               <= '1';
                O_MOSI             <= '1';
            end if;
        end if;
    end process State_Outputs;

    Generic_Clock_Count : process(I_CLK)
    begin
        if rising_edge(I_CLK) then
            if (clk_cnt_en = '1') then  -- sclk = '1' by default 
                if (clk_cnt = G_CLK_DIV-1) then  -- firse edge = fall
                    clk_cnt                  <= clk_cnt + 1;
                    sclk_rise                <= '0';
                    sclk_fall                <= '1';
                elsif (clk_cnt = (G_CLK_DIV*2)-1) then
                    clk_cnt                  <=  0;
                    sclk_rise                <= '1';
                    sclk_fall                <= '0';
                else
                    clk_cnt                  <= clk_cnt + 1;
                    sclk_rise                <= '0';
                    sclk_fall                <= '0';
                end if;
            else
                clk_cnt                  <=  0;
                sclk_rise                <= '0';
                sclk_fall                <= '0';
            end if;

            if I_RST then
                clk_cnt                  <=  0;
                sclk_rise                <= '0';
                sclk_fall                <= '0';
            end if;
        end if;
    end process Generic_Clock_Count;
end BEHAVIORAL;