------------------------------------------------
-- Team:      WCP03 4-20mA Detector Interface --
-- Company:   Binghamton University           --
-- Author(s): Joe Hurysz                      --
------------------------------------------------

library ieee;
use     ieee.std_logic_1164.all;
use     ieee.numeric_std.all;

entity SPI_IF is
    port (
        I_CLK       : in std_logic;
        I_RST       : in std_logic;
        I_DEVICE_ID : in std_logic_vector(1 downto 0);



        -- Physical Data Lines
        I_MISO      : in  std_logic;
        O_MOSI      : out std_logic;
        O_SCLK      : out std_logic;
        O_CS_0      : out std_logic;
        O_CS_1      : out std_logic;
        O_CS_2      : out std_logic;
        O_CS_3      : out std_logic;
        
        -- Register Values
        O_VOLTAGE_REG          : out std_logic_vector(15 downto 0);
        O_CURRENT_REG          : out std_logic_vector(15 downto 0);
        O_TEMP_REG             : out std_logic_vector(15 downto 0);
        O_HUMIDITY_REG         : out std_logic_vector(15 downto 0));
end SPI_IF;

architecture BEHAVIORAL of SPI_IF is

    -- Component Declarations
    Component SPI_CTRL
    port(
        I_CLK       : in std_logic;
        I_RST       : in std_logic;
        I_DEVICE_ID : in std_logic_vector(1 downto 0);

        -- Control Signals
        I_ALL_BITS_TRANSFERRED : in  std_logic;
        I_START_OF_TRANSFER    : in  std_logic;
        O_CLR_SPI_COUNT        : out std_logic;
        O_LD_SPI_COUNT         : out std_logic;
        O_SHIFT_CONFIG_REG     : out std_logic;
        O_LD_CONFIG_REG        : out std_logic;
        O_LD_DATA_REG          : out std_logic;
        O_LD_DATA_OUT          : out std_logic;

        -- Physical Data Lines
        O_SCLK      : out std_logic;
        O_CS_0      : out std_logic;
        O_CS_1      : out std_logic;
        O_CS_2      : out std_logic;
        O_CS_3      : out std_logic);
    end Component SPI_CTRL;

    Component SPI_TX_RX
    port(
        I_CLK   : in std_logic;
        I_RST   : in std_logic;
        I_DEVICE_ID : in std_logic_vector(1 downto 0);
  
  
        -- Data Lines
        I_MISO  : in std_logic;
        O_MOSI  : out std_logic;
  
        -- Control Signals
        I_CLR_SPI_COUNT        : in std_logic;
        I_LD_SPI_COUNT         : in std_logic;
        I_SHIFT_CONFIG_REG     : in std_logic;
        I_LD_CONFIG_REG        : in std_logic;
        I_LD_DATA_REG          : in std_logic;
        I_LD_DATA_OUT          : in std_logic;
        O_ALL_BYTES_TRANSFERRED: out std_logic;
        O_START_OF_TRANSFER    : out std_logic;
  
        O_VOLTAGE_REG          : out std_logic_vector(15 downto 0);
        O_CURRENT_REG          : out std_logic_vector(15 downto 0);
        O_TEMP_REG             : out std_logic_vector(15 downto 0);
        O_HUMIDITY_REG         : out std_logic_vector(15 downto 0));
    end Component SPI_TX_RX;

    -- Signal Declarations
    signal all_bits_transferred : std_logic;
    signal start_of_transfer    : std_logic;
    signal clr_spi_cnt          : std_logic;
    signal ld_spi_cnt           : std_logic;
    signal shift_config_reg     : std_logic;
    signal ld_config_reg        : std_logic;
    signal ld_data_reg          : std_logic;
    signal ld_data_out          : std_logic;

begin

    -- Component Instantions
    Instantiate_Ctrl : SPI_CTRL
    port map(
        I_CLK                       => I_CLK,    
        I_RST                       => I_RST,       
        I_DEVICE_ID                 => I_DEVICE_ID,

        -- Control Signals
        I_ALL_BITS_TRANSFERRED      => all_bits_transferred,
        I_START_OF_TRANSFER         => start_of_transfer,    
        O_CLR_SPI_COUNT             => clr_spi_cnt,        
        O_LD_SPI_COUNT              => ld_spi_cnt,         
        O_SHIFT_CONFIG_REG          => shift_config_reg,     
        O_LD_CONFIG_REG             => ld_config_reg,        
        O_LD_DATA_REG               => ld_data_reg,          
        O_LD_DATA_OUT               => ld_data_out,          

        -- Physical Data Lines
        O_SCLK                      => O_SCLK,
        O_CS_0                      => O_CS_0,
        O_CS_1                      => O_CS_1,
        O_CS_2                      => O_CS_2,
        O_CS_3                      => O_CS_3
    );

    Instantiate_TX_RX : SPI_TX_RX
    port map(
        I_CLK                      => I_CLK,
        I_RST                      => I_RST,
        I_DEVICE_ID                => I_DEVICE_ID,
  
  
        -- Data Lines
        I_MISO                     => I_MISO,
        O_MOSI                     => O_MOSI,
  
        -- Control Signals
        I_CLR_SPI_COUNT            => clr_spi_cnt,
        I_LD_SPI_COUNT             => ld_spi_cnt,
        I_SHIFT_CONFIG_REG         => shift_config_reg,
        I_LD_CONFIG_REG            => ld_config_reg,     
        I_LD_DATA_REG              => ld_data_reg,
        I_LD_DATA_OUT              => ld_data_out,
        O_ALL_BYTES_TRANSFERRED    => all_bits_transferred,
        O_START_OF_TRANSFER        => start_of_transfer,
  
        O_VOLTAGE_REG              => O_VOLTAGE_REG,
        O_CURRENT_REG              => O_CURRENT_REG,
        O_TEMP_REG                 => O_TEMP_REG,
        O_HUMIDITY_REG             => O_HUMIDITY_REG
    );

end BEHAVIORAL;