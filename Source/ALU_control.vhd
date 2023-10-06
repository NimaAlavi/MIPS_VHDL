library ieee;
	use ieee.std_logic_1164.ALL;
	use ieee.numeric_std.ALL;
	use IEEE.std_logic_unsigned.all;
	
entity ALU_control is
	port ( 
		op					: in std_logic_vector(1 downto 0);
		func				: in std_logic_vector(5 downto 0);
		opcode				: in std_logic_vector(5 downto 0);
	
		ALU_result			: out std_logic_vector(2 downto 0)
	);  
end entity;

architecture Behavioral of ALU_control is

begin
	process(op, func, opcode)
	begin
		case op is 
			when "00" => 							-- I_type
				case opcode is
					when "001000" =>
						ALU_result		<= "010";  -- Addi
					when "001001" =>
						ALU_result		<= "010";  -- Addiu
					when "001100" =>
						ALU_result		<= "000";  -- Andi
					when "001111" =>
						ALU_result		<= "010";  -- LUI
					when "001101" =>
						ALU_result		<= "001";  -- Ori
					when "001010" =>
						ALU_result		<= "111";  -- Slti
					when "001011" =>
						ALU_result		<= "111";  -- Sltiu
					when "001110" =>
						ALU_result		<= "011";  -- Xori
					when others =>
						ALU_result		<= "010";  -- Sw / Lw
				end case;
				
			when "01" => 							-- Beq / Bne & J_type
				ALU_result				<= "000";	-- Don't care
				
			when "10" =>							-- R-type
				case func is	
					when "100000" =>
						ALU_result		<= "010";  -- Add
					when "100001" =>
						ALU_result		<= "010";  -- Addu
					when "100010" =>
						ALU_result		<= "110";  -- Sub
					when "100011" =>
						ALU_result		<= "110";  -- Subu
					when "100100" =>
						ALU_result		<= "000";  -- And
					when "100101" =>
						ALU_result		<= "001";  -- Or
					when "100110" =>
						ALU_result		<= "011";  -- Xor
					when "100111" =>
						ALU_result		<= "100";  -- Nor
					when "001000" =>
						ALU_result		<= "010";  -- Jr
					when "001001" =>
						ALU_result		<= "010";  -- Jr & LR
					when "011001" =>
						ALU_result		<= "101";  -- Mulu
					when "101010" =>
						ALU_result		<= "111";  -- Slt
					when others =>
						ALU_result		<= (others => '0');
				end case;
			
			when others => 
				ALU_result				<= "010";
		end case;
		
	end process;
end architecture;

