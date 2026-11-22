
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity modbus_crc is
    Port (
        byte0   : in  STD_LOGIC_VECTOR(7 downto 0);
        byte1   : in  STD_LOGIC_VECTOR(7 downto 0);
        byte2   : in  STD_LOGIC_VECTOR(7 downto 0);
        byte3   : in  STD_LOGIC_VECTOR(7 downto 0);
        byte4   : in  STD_LOGIC_VECTOR(7 downto 0);
        crc_out : out STD_LOGIC_VECTOR(15 downto 0)
    );
end modbus_crc;

architecture RTL of modbus_crc is
begin

    process(byte0, byte1, byte2, byte3, byte4)

        variable crc       : unsigned(15 downto 0);
        variable data_byte : STD_LOGIC_VECTOR(7 downto 0);

    begin

        crc := x"FFFF";

        for k in 0 to 4 loop

            case k is
                when 0 => data_byte := byte0;
                when 1 => data_byte := byte1;
                when 2 => data_byte := byte2;
                when 3 => data_byte := byte3;
                when 4 => data_byte := byte4;
                when others => data_byte := x"00";
            end case;

            crc := crc xor resize(unsigned(data_byte), 16);

            for i in 0 to 7 loop

                if crc(0) = '1' then
                    crc := shift_right(crc, 1) xor x"A001";
                else
                    crc := shift_right(crc, 1);
                end if;

            end loop;

        end loop;

        crc_out <= std_logic_vector(crc);

    end process;

end RTL;
