
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity modbus_master is
    Port (
        clk_27m  : in  STD_LOGIC;
        reset_n  : in  STD_LOGIC;

        -- UART TX interface
        tx_byte  : out STD_LOGIC_VECTOR(7 downto 0);
        tx_start : out STD_LOGIC;
        tx_done  : in  STD_LOGIC;

        -- UART RX interface
        rx_byte  : in  STD_LOGIC_VECTOR(7 downto 0);
        rx_done  : in  STD_LOGIC;

        -- PWM command
        pwm_value : out UNSIGNED(7 downto 0);

        -- Debug output
        comm_error : out STD_LOGIC
    );
end modbus_master;


architecture RTL of modbus_master is

    constant POLL_WAIT_CYCLES : integer := 2700000;
    constant RESPONSE_TIMEOUT : integer := 2700000;

    type request_array_t is array (0 to 7)
        of STD_LOGIC_VECTOR(7 downto 0);

    constant REQUEST_FRAME : request_array_t := (
        x"01",  -- Slave ID
        x"03",  -- Read Holding Registers
        x"00",  -- Starting address high
        x"00",  -- Starting address low
        x"00",  -- Quantity high
        x"01",  -- Quantity low
        x"84",  -- CRC low
        x"0A"   -- CRC high
    );

    type response_array_t is array (0 to 6)
        of STD_LOGIC_VECTOR(7 downto 0);

    signal response_buffer : response_array_t :=
        (others => (others => '0'));

    type master_state_t is (
        POLL_WAIT,
        SEND_REQ_BYTE,
        WAIT_REQ_TX,
        WAIT_RESPONSE
    );

    signal master_state : master_state_t := POLL_WAIT;

    signal request_index : integer range 0 to 7 := 0;
    signal response_index : integer range 0 to 6 := 0;

    signal poll_counter : integer range 0 to POLL_WAIT_CYCLES := 0;
    signal timeout_counter : integer range 0 to RESPONSE_TIMEOUT := 0;

    signal crc_result : STD_LOGIC_VECTOR(15 downto 0);

    signal pwm_reg : UNSIGNED(7 downto 0) := (others => '0');
    signal error_reg : STD_LOGIC := '0';

begin

    pwm_value <= pwm_reg;
    comm_error <= error_reg;

    --------------------------------------------------
    -- CRC MODULE
    --------------------------------------------------

    CRC_UNIT : entity work.modbus_crc
        port map (
            byte0   => response_buffer(0),
            byte1   => response_buffer(1),
            byte2   => response_buffer(2),
            byte3   => response_buffer(3),
            byte4   => response_buffer(4),
            crc_out => crc_result
        );


    --------------------------------------------------
    -- MODBUS MASTER FSM
    --------------------------------------------------

    process(clk_27m)
    begin

        if rising_edge(clk_27m) then

            -- Default: TX start pulse is inactive
            tx_start <= '0';

            if reset_n = '0' then

                master_state <= POLL_WAIT;

                request_index <= 0;
                response_index <= 0;

                poll_counter <= 0;
                timeout_counter <= 0;

                tx_byte <= (others => '0');

                response_buffer <=
                    (others => (others => '0'));

                pwm_reg <= (others => '0');
                error_reg <= '0';

            else

                case master_state is

                    ----------------------------------
                    -- WAIT BEFORE NEXT REQUEST
                    ----------------------------------

                    when POLL_WAIT =>

                        if poll_counter = POLL_WAIT_CYCLES - 1 then

                            poll_counter <= 0;
                            request_index <= 0;

                            master_state <= SEND_REQ_BYTE;

                        else

                            poll_counter <= poll_counter + 1;

                        end if;


                    ----------------------------------
                    -- SEND ONE REQUEST BYTE
                    ----------------------------------

                    when SEND_REQ_BYTE =>

                        tx_byte <= REQUEST_FRAME(request_index);
                        tx_start <= '1';

                        master_state <= WAIT_REQ_TX;


                    ----------------------------------
                    -- WAIT FOR TX COMPLETE
                    ----------------------------------

                    when WAIT_REQ_TX =>

                        if tx_done = '1' then

                            if request_index = 7 then

                                response_index <= 0;
                                timeout_counter <= 0;

                                response_buffer <=
                                    (others => (others => '0'));

                                master_state <= WAIT_RESPONSE;

                            else

                                request_index <= request_index + 1;

                                master_state <= SEND_REQ_BYTE;

                            end if;

                        end if;


                    ----------------------------------
                    -- RECEIVE PLC RESPONSE
                    ----------------------------------

                    when WAIT_RESPONSE =>

                        if rx_done = '1' then

                            response_buffer(response_index) <= rx_byte;
                            timeout_counter <= 0;

                            if response_index = 6 then

                                -- Check response format and CRC.
                                -- rx_byte is the final CRC high byte.

                                if
                                    response_buffer(0) = x"01" and
                                    response_buffer(1) = x"03" and
                                    response_buffer(2) = x"02" and
                                    response_buffer(5) =
                                        crc_result(7 downto 0) and
                                    rx_byte =
                                        crc_result(15 downto 8)
                                then

                                    -- Convert 16-bit register
                                    -- to 8-bit PWM command.

                                    if response_buffer(3) = x"00" then

                                        pwm_reg <=
                                            unsigned(response_buffer(4));

                                    else

                                        pwm_reg <= x"FF";

                                    end if;

                                    error_reg <= '0';

                                else

                                    pwm_reg <= (others => '0');
                                    error_reg <= '1';

                                end if;

                                poll_counter <= 0;
                                master_state <= POLL_WAIT;

                            else

                                response_index <= response_index + 1;

                            end if;

                        else

                            if timeout_counter < RESPONSE_TIMEOUT then

                                timeout_counter <= timeout_counter + 1;

                            else

                                -- Response timeout

                                pwm_reg <= (others => '0');
                                error_reg <= '1';

                                poll_counter <= 0;
                                master_state <= POLL_WAIT;

                            end if;

                        end if;

                end case;

            end if;

        end if;

    end process;

end RTL;
