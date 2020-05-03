library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity demodulate is
    generic
    (
        GAIN : natural :=  758 -- basically, to_integer(signed(QUANTIZE_F(real(QUAD_RATE) / (2.0 * PI * MAX_DEV))))
    );
    port 
    (
        signal clock 	    : in std_logic;
        signal reset 	    : in std_logic;
        signal real_din     : in std_logic_vector (31 downto 0);
        signal imag_din     : in std_logic_vector (31 downto 0);
        signal real_empty   : in std_logic;
        signal imag_empty   : in std_logic;
        signal demod_full   : in std_logic;
        signal real_rd_en   : out std_logic;
        signal imag_rd_en   : out std_logic;
        signal demod_dout   : out std_logic_vector (31 downto 0);
        signal demod_wr_en  : out std_logic
    );
end entity;

architecture behavioral of demodulate is

    function QUANTIZE (n : signed) return signed is
    begin
        return resize(shift_left(n, 10), 32);
    end function;

    function DEQUANTIZE (n : signed) return signed is
    begin
        return resize(shift_right(n, 10), 32);
    end function;
	
    function GET_MSB (n : signed) return natural is
    begin
        for i in n'length - 1 downto 0 loop
            if (n(i) = '1') then
                return i;
            end if;
        end loop;
        return 0;
    end function;
	
    type state_types is (s0, s1, s2, s3);
    signal state : state_types;
    signal next_state : state_types;
    signal real_prev, real_prev_c : std_logic_vector (31 downto 0);
    signal imag_prev, imag_prev_c : std_logic_vector (31 downto 0);
    signal dividend, dividend_c : signed (31 downto 0);
    signal divisor, divisor_c : signed (31 downto 0);
    signal quotient, quotient_c : signed (31 downto 0);
    signal quad_1, quad_1_c : integer := 0; 
    signal quad_3, quad_3_c : integer := 0;
    signal temp1, temp1_c : signed (31 downto 0) := (others => '0');
    signal temp2, temp2_c : signed (31 downto 0) := (others => '0');
    signal temp3, temp3_c : signed (31 downto 0) := (others => '0');
    signal temp4, temp4_c : signed (31 downto 0) := (others => '0');

begin

    demod_process : process (state, real_prev, imag_prev, dividend, divisor, quotient, quad_1, quad_3, real_din, imag_din, real_empty, imag_empty, demod_full, temp1, temp2, temp3, temp4)
        variable r, i : signed (31 downto 0) := (others => '0');
        variable dividend_v, divisor_v : signed (31 downto 0) := (others => '0');
        variable p : integer := 0;
        variable sign : std_logic := '0';
        variable angle : signed (31 downto 0) := (others => '0');
    begin
        next_state <= state;
        real_prev_c <= real_prev;
        imag_prev_c <= imag_prev;
        dividend_c <= dividend;
        divisor_c <= divisor;
        quotient_c <= quotient;
        quad_1_c <= quad_1;
        quad_3_c <= quad_3;
        temp1_c <= temp1; 
        temp2_c <= temp2; 
        temp3_c <= temp3; 
        temp4_c <= temp4; 
        real_rd_en <= '0';
        imag_rd_en <= '0';
        demod_wr_en <= '0';
        demod_dout <= (others => '0');
        dividend_v := (others => '0');
        divisor_v := (others => '0');
        angle := (others => '0');

        case (state) is
            when s0 =>
                if (real_empty = '0' and imag_empty = '0') then
                    real_prev_c <= (others => '0');
                    imag_prev_c <= (others => '0');
                    dividend_c <= (others => '0');
                    divisor_c <= (others => '0');
                    quotient_c <= (others => '0');
                    temp1_c <= (others => '0');
                    temp2_c <= (others => '0');
                    temp3_c <= (others => '0');
					temp4_c <= (others => '0');
                    quad_1_c <= 0;
                    quad_3_c <= 0; 
                    next_state <= s1;
                end if;

            when s1 =>
                if (real_empty = '0') then
                    dividend_c <= (others => '0');
                    divisor_c <= (others => '0');
                    quotient_c <= (others => '0');
                    temp1_c <= (others => '0');
                    temp2_c <= (others => '0');
                    temp3_c <= (others => '0');
                    temp4_c <= (others => '0');					
                    quad_1_c <= 0;
                    quad_3_c <= 0; 

                    real_rd_en <= '1';
                    imag_rd_en <= '1';
		    
		    -- k * atan(c1 * conj(c0))
		    -- int r = DEQUANTIZE(*real_prev * real) ?
		    -- DEQUANTIZE(-*imag_prev * imag);
        	    -- int i = DEQUANTIZE(*real_prev * imag) +
		    -- DEQUANTIZE(-*imag_prev * real);
                    r := DEQUANTIZE(signed(real_din) * signed(real_prev)) - DEQUANTIZE(-signed(imag_prev) * signed(imag_din));
                    i := DEQUANTIZE(signed(imag_din) * signed(real_prev)) + DEQUANTIZE(-signed(imag_prev) * signed(real_din));
                    temp4_c <= i;
                    i := abs(i) + 1;

                    real_prev_c <= real_din;
                    imag_prev_c <= imag_din;

                    if (r >= 0) then
                        -- angle = QUAD1 - DEQUANTIZE(QUAD1 * DIV(QUANTIZE(r - i), r + i))
                        quad_1_c <= 804; --to_integer(signed(QUANTIZE_F(PI / 4.0)));
                        quad_3_c <= 804; --to_integer(signed(QUANTIZE_F(PI / 4.0)));
						
                        dividend_v := QUANTIZE(r - i);
                        divisor_v := r + i;
                    else
                        --angle = QUAD3 - DEQUANTIZE(QUAD3 * DIV(QUANTIZE(r + i), i - r))
                        quad_1_c <= 2412; --to_integer(signed(QUANTIZE_F(3.0 * PI / 4.0)));
                        quad_3_c <= 804; --to_integer(signed(QUANTIZE_F(PI / 4.0)));
						
                        dividend_v := QUANTIZE(r + i);
                        divisor_v := i - r;
                    end if;
					
                    dividend_c <= dividend_v;
                    divisor_c <= divisor_v;
                    temp1_c <= abs(dividend_v);
                    temp2_c <= abs(divisor_v);
                    next_state <= s2;
                end if;

            when s2 =>
                if (temp2 = 1) then
                    temp3_c <= temp1;
                    temp1_c <= (others => '0'); 
                end if;

                if (temp1 >= temp2) then
                    p := GET_MSB(temp1) - GET_MSB(temp2);
                    if ((temp2 sll p) > temp1) then
                        p := p - 1;
                    end if;
                    temp3_c <= temp3 + (to_signed(1, 32) sll p);
                    temp1_c <= temp1 - (temp2 sll p);
                else
                    quotient_c <= temp3; 
                    sign := dividend(31) xor divisor(31);
                    if (sign = '1') then
                        quotient_c <= -temp3; 
                    end if;
                    next_state <= s3;
                end if;

            when s3 =>
		-- negate if in quad III or IV
		-- return ((y < 0) ? -angle : angle); 
                if (demod_full = '0') then
                    angle := quad_1 - DEQUANTIZE(quad_3 * quotient);
                    if (temp4 < 0) then
                        angle := -angle;
                    end if;
                    demod_dout <= std_logic_vector(DEQUANTIZE(GAIN * angle));
                    demod_wr_en <= '1';
                    next_state <= s1;
                end if;

            when others =>
                next_state <= state;

        end case;
    end process;

    clock_process : process (clock, reset)
    begin 
        if (reset = '1') then
            state <= s0;
            real_prev <= (others => '0'); 
            imag_prev <= (others => '0'); 
            dividend <= (others => '0');  
            divisor <= (others => '0');  
            quotient <= (others => '0');  
            quad_1 <= 0; 
            quad_3 <= 0; 
			
            temp1 <= (others => '0'); 
            temp2 <= (others => '0'); 
            temp3 <= (others => '0'); 
            temp4 <= (others => '0'); 
        elsif (rising_edge(clock)) then
            state <= next_state;
            real_prev <= real_prev_c;
            imag_prev <= imag_prev_c;
            dividend <= dividend_c;
            divisor <= divisor_c;
            quotient <= quotient_c;
            quad_1 <= quad_1_c;
            quad_3 <= quad_3_c;
			
            temp1 <= temp1_c;
            temp2 <= temp2_c;
            temp3 <= temp3_c;
            temp4 <= temp4_c;
        end if;
    end process;

end architecture;