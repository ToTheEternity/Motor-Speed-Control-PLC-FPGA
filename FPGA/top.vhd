
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top is
    Port (
        clk_27m  : in  STD_LOGIC;
        reset_n  : in  STD_LOGIC;

        -- MAX13487E connections
        rs485_rxd : in  STD_LOGIC;
        rs485_txd : out STD_LOGIC;

        -- PWM output
        pwm_out : out STD_LOGIC;

        -- Communication status
        comm_error : out STD_LOGIC
    );
end top;


architecture RTL of top is

    -- UART TX signals
    signal tx_byte  : STD_LOGIC_VECTOR(7 downto 0);
    signal tx_start : STD_LOGIC;
    signal tx_done  : STD_LOGIC;

    -- UART RX signals
    signal rx_byte : STD_LOGIC_VECTOR(7 downto 0);
    signal rx_done : STD_LOGIC;

    -- PWM command
    signal pwm_value : UNSIGNED(7 downto 0);

begin

    --------------------------------------------------
    -- UART TRANSMITTER
    --------------------------------------------------

    UART_TX_UNIT : entity work.uart_tx
        port map (
            clk_27m  => clk_27m,
            reset_n  => reset_n,
            tx_start => tx_start,
            tx_byte  => tx_byte,
            tx_out   => rs485_txd,
            tx_done  => tx_done
        );


    --------------------------------------------------
    -- UART RECEIVER
    --------------------------------------------------

    UART_RX_UNIT : entity work.uart_rx
        port map (
            clk_27m  => clk_27m,
            reset_n  => reset_n,
            rs485_rxd    => rs485_rxd,
            rx_byte  => rx_byte,
            rx_done  => rx_done
        );


    --------------------------------------------------
    -- MODBUS MASTER
    --------------------------------------------------

    MODBUS_UNIT : entity work.modbus_master
        port map (
            clk_27m    => clk_27m,
            reset_n    => reset_n,

            tx_byte    => tx_byte,
            tx_start   => tx_start,
            tx_done    => tx_done,

            rx_byte    => rx_byte,
            rx_done    => rx_done,

            pwm_value  => pwm_value,
            comm_error => comm_error
        );


    --------------------------------------------------
    -- PWM GENERATOR
    --------------------------------------------------

    PWM_UNIT : entity work.pwm_generator
        port map (
            clk_27m    => clk_27m,
            reset_n    => reset_n,
            duty_value => pwm_value,
            pwm_out    => pwm_out
        );

end RTL;



