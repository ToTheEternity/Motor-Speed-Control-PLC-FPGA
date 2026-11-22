library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
    Port (
        clk_27m     : in  STD_LOGIC;         -- Үндсэн цаг (27 MHz)
        reset_n     : in  STD_LOGIC;         -- Систем шинэчлэх (0 үед унтарна)
        rs485_rxd   : in  STD_LOGIC;         -- RS485-аас орж ирж буй ганц утас (Бит битээр орно)
        
        rx_byte     : out STD_LOGIC_VECTOR(7 downto 0); -- Цуглуулж дууссан 8-бит багц тоо
        rx_done     : out STD_LOGIC          -- "1 byte амжилттай уншиж дууслаа!" гэдэг дохио (1 clock байна)
    );
end uart_rx;

architecture RTL of uart_rx is
constant CLKS_PER_BIT : integer := 2813;
type uart_fsm is (RX_IDLE, RX_STRT, RX_DATA, RX_STOP);
signal present_state : uart_fsm := RX_IDLE;

signal rx_meta : std_logic := '1';
signal rx_sync : std_logic := '1';

signal clk_counter : integer range 0 to CLKS_PER_BIT - 1 := 0;
signal bit_index : integer range 0 to 7 := 0;
signal rx_shift : std_logic_vector(7 downto 0) := (others => '0');

begin
process (clk_27m)
begin 
 if rising_edge(clk_27m) then 
    rx_meta <= rs485_rxd;
    rx_sync <= rx_meta;

 if reset_n = '0' then 
    present_state <= RX_IDLE;
    clk_counter <= 0;
    bit_index <= 0;
    rx_shift <= (others => '0');
    rx_byte <= (others => '0');
    rx_done <= '0';
 
 else 
     rx_done <= '0';
     
     case present_state is 
      
      when RX_IDLE =>
        clk_counter <= 0;
        bit_index <= 0;
       if rx_sync = '0' then 
          present_state <= RX_STRT;
       end if;

      
      when RX_STRT =>
       if clk_counter = (CLKS_PER_BIT / 2) then
          clk_counter <= 0;
          if rx_sync = '0' then 
             present_state <= RX_DATA;
          else 
              present_state <= RX_IDLE;
          end if;
       else clk_counter <= clk_counter + 1;
       end if;

      
      when RX_DATA =>
       if clk_counter = CLKS_PER_BIT - 1 then 
          clk_counter <= 0;
          rx_shift(bit_index) <= rx_sync;
         
         if bit_index = 7 then 
            present_state <= RX_STOP;
         else bit_index <= bit_index + 1;
         end if;
       else clk_counter <= clk_counter + 1;
       end if;


      when RX_STOP =>
       if clk_counter = CLKS_PER_BIT - 1 then 
          clk_counter <= 0;
        if rx_sync = '1' then 
           rx_byte <= rx_shift;
           rx_done <= '1';
        end if;
          present_state <= RX_IDLE; 
       else clk_counter <= clk_counter + 1;
       end if;
      end case;
     end if;
    end if;
   end process;

end RTL;





















