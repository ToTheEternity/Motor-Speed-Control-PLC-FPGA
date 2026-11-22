library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_tx is
    Port (
        clk_27m   : in  STD_LOGIC;         -- Үндсэн цаг (27 MHz)
        reset_n   : in  STD_LOGIC;         -- Систем шинэчлэх (0 үед унтарна)
        tx_start  : in  STD_LOGIC;         -- Илгээж эхэл! гэдэг тушаал (1 clock идэвхжинэ)
        tx_byte   : in  STD_LOGIC_VECTOR(7 downto 0); -- Илгээх 8-бит дата (Жишээ нь x"01")       
        tx_out    : out STD_LOGIC;         -- RS485 руу гарах ганц утас (Бит битээр гарна)
        tx_done   : out STD_LOGIC          -- "Илгээж дууслаа!" гэдгийг мэдэгдэх дохио (1 clock байна)
    );
end uart_tx;

architecture RTL of uart_tx is

constant CLKS_PER_BIT : integer := 2813;
type tx_fsm is (TX_IDLE, TX_STRT, TX_DATA, TX_STOP);
signal present_state : tx_fsm := TX_IDLE;

signal clk_counter : integer range 0 to CLKS_PER_BIT - 1 := 0;
signal bit_index : integer range 0 to 7 := 0;
signal tx_shift : std_logic_vector (7 downto 0) := "00000000";
signal tx_reg : std_logic := '0';


begin
tx_out <= tx_reg;

process(clk_27m)
begin 
 if rising_edge(clk_27m) then 
   if reset_n = '0' then 
      present_state <= TX_IDLE;
      clk_counter <= 0;
      bit_index <= 0;
      tx_reg <= '1';
      tx_done <= '0';
      tx_shift <= (others => '0');
   else 
     tx_done <= '0';
case present_state is
 when TX_IDLE =>
      tx_reg <= '1';
      if tx_start = '1' then  
         tx_shift <= tx_byte;
         tx_reg <= '0';
         bit_index <= 0;
         present_state <= TX_STRT;
      else present_state <= TX_IDLE;
      end if;

 when TX_STRT =>
      if clk_counter = CLKS_PER_BIT - 1 then 
         clk_counter <= 0;
         tx_reg <= tx_shift(0);
         bit_index <= 0;
         present_state <= TX_DATA;
      else clk_counter <= clk_counter + 1;
      end if;

 when TX_DATA =>
      if clk_counter = CLKS_PER_BIT - 1 then
         clk_counter <= 0;
        if bit_index = 7 then 
           tx_reg <= '1';
           present_state <= TX_STOP; 
        else 
           bit_index <= bit_index + 1;
           tx_reg <= tx_shift(bit_index + 1);
        end if; 
      else clk_counter <= clk_counter + 1;
      end if;


 when TX_STOP =>
      if clk_counter = CLKS_PER_BIT - 1 then 
         clk_counter <= 0;
         tx_done <= '1';
         present_state <= TX_IDLE;
      else clk_counter <= clk_counter + 1;
      end if;
end case;
end if;
end if;
end process;
     
end RTL;















