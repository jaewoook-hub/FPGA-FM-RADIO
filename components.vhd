library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.constants.all;

package components is

    component fifo is
        generic
        (
            constant DWIDTH : integer := 32;
            constant BUFFER_SIZE : integer := 32
        );
        port
        (
            signal rd_clk : in std_logic;
            signal wr_clk : in std_logic;
            signal reset : in std_logic;
            signal rd_en : in std_logic;
            signal wr_en : in std_logic;
            signal din : in std_logic_vector ((DWIDTH - 1) downto 0);
            signal dout : out std_logic_vector ((DWIDTH - 1) downto 0);
            signal full : out std_logic;
            signal empty : out std_logic
        );
    end component;

	component add_sub is
		 port 
		 (
			-- top is the add, bottom is the subtraction --
			signal clock 		: in std_logic;
			signal reset 		: in std_logic;
			signal top_din 		: in std_logic_vector (31 downto 0);
			signal bottom_din 	: in std_logic_vector (31 downto 0);
			signal top_in_empty 	: in std_logic;
			signal bottom_in_empty  : in std_logic;
			signal top_out_full 	: in std_logic;
			signal bottom_out_full  : in std_logic;
			signal top_in_rd_en 	: out std_logic;
			signal bottom_in_rd_en  : out std_logic;
			signal top_dout 	: out std_logic_vector (31 downto 0);
			signal bottom_dout 	: out std_logic_vector (31 downto 0);
			signal top_out_wr_en 	: out std_logic;
			signal bottom_out_wr_en : out std_logic
		 );
	end component;

    component demodulate is
        port 
        (
            signal clock : in std_logic;
            signal reset : in std_logic;
            signal real_din : in std_logic_vector (31 downto 0);
            signal imag_din : in std_logic_vector (31 downto 0);
            signal real_empty : in std_logic;
            signal imag_empty : in std_logic;
            signal demod_full : in std_logic;
            signal real_rd_en : out std_logic;
            signal imag_rd_en : out std_logic;
            signal demod_dout : out std_logic_vector (31 downto 0);
            signal demod_wr_en : out std_logic
        );
    end component;

    component fir_decimated is
        generic
        (
            TAPS : natural := 20;
            DECS : natural := 8
        );
        port 
        (
           signal clock : in std_logic;
           signal reset : in std_logic;
           signal din : in std_logic_vector (31 downto 0);
           signal coeffs : in quant_array (0 to TAPS - 1);
           signal in_empty : in std_logic;
           signal out_full : in std_logic;
           signal in_rd_en : out std_logic;
           signal dout : out std_logic_vector (31 downto 0);
           signal out_wr_en : out std_logic
        );
    end component;

    component multiply is
        port 
        (
            signal clock : in std_logic;
            signal reset : in std_logic;
            signal x_din : in std_logic_vector (31 downto 0);
            signal y_din : in std_logic_vector (31 downto 0);
            signal x_empty : in std_logic;
            signal y_empty : in std_logic;
            signal z_full : in std_logic;
            signal x_rd_en : out std_logic;
            signal y_rd_en : out std_logic;
            signal z_dout : out std_logic_vector (31 downto 0);
            signal z_wr_en : out std_logic
        );
    end component;

	component iq_reader is
		 port 
		 (
			  signal clock 	: in std_logic;
			  signal reset 	: in std_logic;
			  signal iq_din 	: in std_logic_vector (31 downto 0);
			  signal iq_empty : in std_logic;
			  signal i_full 	: in std_logic;
			  signal q_full 	: in std_logic;
			  signal iq_rd_en : out std_logic;
			  signal i_wr_en 	: out std_logic;
			  signal q_wr_en 	: out std_logic;
			  signal i_dout 	: out std_logic_vector (31 downto 0);
			  signal q_dout   : out std_logic_vector (31 downto 0)
		 );
	end component;

    component fir_complex is
        generic
        (
            TAPS : natural := 20
        );
        port 
        (
            signal clock : in std_logic;
            signal reset : in std_logic;
            signal real_din : in std_logic_vector (31 downto 0);
            signal imag_din : in std_logic_vector (31 downto 0);
            signal real_in_empty : in std_logic;
            signal imag_in_empty : in std_logic;
            signal real_out_full : in std_logic;
            signal imag_out_full : in std_logic;
            signal real_in_rd_en : out std_logic;
            signal imag_in_rd_en : out std_logic;
            signal real_dout : out std_logic_vector (31 downto 0);
            signal imag_dout : out std_logic_vector (31 downto 0);
            signal real_out_wr_en : out std_logic;
            signal imag_out_wr_en : out std_logic
        );
    end component;

    component fir is
        generic
        (
            TAPS : natural := 20
        );
        port 
        (
            signal clock : in std_logic;
            signal reset : in std_logic;
            signal din : in std_logic_vector (31 downto 0);
            signal coeffs : in quant_array (0 to TAPS - 1);
            signal in_empty : in std_logic;
            signal out_full : in std_logic;
            signal in_rd_en : out std_logic;
            signal dout : out std_logic_vector (31 downto 0);
            signal out_wr_en : out std_logic
        );
    end component;

    component gain is
        port 
        (
            signal clock : in std_logic;
            signal reset : in std_logic;
            signal volume : in integer;
            signal din : in std_logic_vector (31 downto 0);
            signal in_empty : in std_logic;
            signal out_full : in std_logic;
            signal in_rd_en : out std_logic;
            signal dout : out std_logic_vector (31 downto 0);
            signal out_wr_en : out std_logic
        );
    end component;

    component iir is
        generic
        (
            TAPS : natural := 20
        );
        port 
        (
            signal clock : in std_logic;
            signal reset : in std_logic;
            signal din : in std_logic_vector (31 downto 0);
            signal x_coeffs : in quant_array (0 to TAPS - 1);
            signal y_coeffs : in quant_array (0 to TAPS - 1);
            signal in_empty : in std_logic;
            signal out_full : in std_logic;
            signal in_rd_en : out std_logic;
            signal dout : out std_logic_vector (31 downto 0);
            signal out_wr_en : out std_logic
        );
    end component;

    component square is
        port 
        (
			signal clock 	: in std_logic;
			signal reset : in std_logic;
			signal in_din 	: in std_logic_vector (31 downto 0);
			signal in_empty 	: in std_logic;
			signal out_full 	: in std_logic;
			signal in_rd_en 	: out std_logic;
			signal out_dout 	: out std_logic_vector (31 downto 0);
			signal out_wr_en : out std_logic
        );
    end component;

    component radio is
        port 
        (
            signal clock : in std_logic;
            signal reset : in std_logic;
            signal volume : in integer;
            signal din : in std_logic_vector (31 downto 0);
            signal input_wr_en : in std_logic;
            signal left_rd_en : in std_logic;
            signal right_rd_en : in std_logic;
            signal input_full : out std_logic;
            signal left : out std_logic_vector (31 downto 0);
            signal right : out std_logic_vector (31 downto 0);
            signal left_empty : out std_logic;
            signal right_empty : out std_logic
        );
    end component;

end package;