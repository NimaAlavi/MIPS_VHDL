library ieee;
	use ieee.std_logic_1164.ALL;
	use ieee.numeric_std.ALL;
	use IEEE.std_logic_unsigned.all;
	
entity ALU_main is
	generic (
		dataWidth 			: integer := 32
	);
	Port ( 
		srcA				: in std_logic_vector(dataWidth - 1 downto 0);
		srcB				: in std_logic_vector(dataWidth - 1 downto 0);

		op					: in std_logic_vector(2 downto 0);
	
		zero				: out std_logic;
		nzero				: out std_logic;
		HI					: out std_logic_vector(dataWidth - 1 downto 0);
		LO					: out std_logic_vector(dataWidth - 1 downto 0);
		ALU_result			: out std_logic_vector(dataWidth - 1 downto 0)
	);  
end entity;

architecture Behavioral of ALU_main is

signal multiplier			: std_logic_vector(63 downto 0) := (others => '0');
begin
	process(op, srcA, srcB)
	begin
		case op is 
			when "000" => 
				ALU_result		<= srcA and srcB;
			when "001" => 
				ALU_result		<= srcA or srcB;	
			when "010" => 
				ALU_result		<= srcA + srcB;
			when "011" => 
				ALU_result		<= srcA xor srcB;
			when "100" => 
				ALU_result		<= not(srcA or srcB);
			when "101" => 
				multiplier		<= std_logic_vector(resize(unsigned(srcA * srcB), 64));
			when "110" => 
				ALU_result		<= srcA - srcB;
			when "111" => 
				if srcA < srcB then
					ALU_result	<= std_logic_vector(to_unsigned(1, dataWidth));
				else	
					ALU_result	<= (others => '0');
				end if;
			when others => 
				ALU_result		<= (others => '0');
		end case;
		
		if srcA = srcB then
			zero				<= '1';
			nzero				<= '0';
		else
			zero				<= '0';
			nzero				<= '1';
		end if;
	end process;
	HI							<= multiplier(multiplier'left downto dataWidth);
	LO							<= multiplier(dataWidth - 1 downto 0);
end architecture;

