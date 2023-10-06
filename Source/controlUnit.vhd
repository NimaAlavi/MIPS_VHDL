library ieee;
	use ieee.std_logic_1164.ALL;
	use ieee.numeric_std.ALL;
	
entity controlUnit is
	Port ( 
		clk 					: in std_logic;
		rst 					: in std_logic;
		
		opIn				: in std_logic_vector(5 downto 0);
		func				: in std_logic_vector(5 downto 0);
		jump				: in std_logic;
		
		mem2Reg			: out std_logic;
		regDst				: out std_logic_vector(1 downto 0);
		IorD				: out std_logic;
		IorDEn				: out std_logic;
		mulEn				: out std_logic;
		ALU_srcA			: out std_logic;
		pcSrc				: out std_logic_vector(1 downto 0); 
		ALU_srcB			: out std_logic_vector(1 downto 0);
		
		opOut				: out std_logic_vector(1 downto 0);
		
		memWrite			: out std_logic;
		pcWrite			: out std_logic;
		branch				: out std_logic;
		ENDERROR			: out std_logic;
		regWrite			: out std_logic;
		HIEn				: out std_logic;
		LOEn				: out std_logic
	);  
end entity;

architecture Behavioral of controlUnit is

---------------------------------------------
--Signals
---------------------------------------------
type stateType is (Idle_state, decode_state, RtypeAlu_state, j_state, jal_state, beq_state,ItypeAlu_state,
				    bne_state, lui_state, lw_state, lwDelay_state, sw_state, WriteBack_state, delay_state);

signal state						: stateType := Idle_state;

begin
	process(clk)
	begin
		if rising_edge(clk) then
			pcWrite		<= '0';
			regWrite		<= '0';
			branch			<= '0';
			IorDEn			<= '0';
			IorD			<= '0';
			memWrite		<= '0';
			mulEn			<= '0';
			HIEn			<= '0';
			LOEn			<= '0';
			ENDERROR		<= '0';
			
			case(state) is
				when Idle_state =>
					mem2Reg					<= '0';
					opOut						<= "00";
					pcWrite					<= '1';

					state						<= decode_state;
					
				when decode_state =>
					pcSrc						<= "01";	
					case opIn is
					-----------------------------------------------------------------
					-- R_type state
					-----------------------------------------------------------------
						when "000000" =>			
							ALU_srcA			<= '1';
							ALU_srcB			<= "00";
							opOut				<= "10";
							regDst				<= "01";
							mem2Reg			<= '0';
							regWrite			<= '1';
							
							state				<= delay_state;
							
							if func = "001000" then
								pcSrc			<= "01";
								IorDEn			<= '1';
								state			<= Idle_state;
							end if;
							if func = "011001" then
								regWrite		<= '0';
								mulEn			<= '1';
							end if;
							if func = "010000" then
								regWrite		<= '0';
							end if;
							if func = "010001" then
								regWrite		<= '0';
							end if;
							if func = "010000" then
								regWrite		<= '1';
							end if;
							if func = "010001" then
								regWrite		<= '1';
							end if;
							if func = "010000" then
								HIEn			<= '1';
							end if;
							if func = "010010" then
								LOEn			<= '1';
							end if;
					-----------------------------------------------------------------
					-- J 
					-----------------------------------------------------------------
						when "000010" =>
							pcSrc				<= "10";
							
							state				<= j_state;
					-----------------------------------------------------------------
					-- JAL
					-----------------------------------------------------------------
						when "000011" =>
							pcSrc				<= "10";
							
							state				<= jal_state;
					-----------------------------------------------------------------
					-- BEQ
					-----------------------------------------------------------------
						when "000100" =>
							state				<= beq_state;
					-----------------------------------------------------------------
					-- BNE
					-----------------------------------------------------------------
						when "000101" =>
							state				<= bne_state;
					-----------------------------------------------------------------
					-- ADDI
					-----------------------------------------------------------------
						when "001000" =>			
							ALU_srcA			<= '1';
							ALU_srcB			<= "10";
							opOut				<= "00";
							regDst				<= "00";
							mem2Reg			<= '0';
							regWrite			<= '1';
							
							state				<= delay_state;
					-----------------------------------------------------------------
					-- ADDIU
					-----------------------------------------------------------------
						when "001001" =>			
							ALU_srcA			<= '1';
							ALU_srcB			<= "10";
							opOut				<= "00";
							regDst				<= "00";
							mem2Reg			<= '0';
							regWrite			<= '1';
							
							state				<= delay_state;
					-----------------------------------------------------------------
					-- SLTI
					-----------------------------------------------------------------
						when "001010" =>			
							ALU_srcA			<= '1';
							ALU_srcB			<= "10";
							opOut				<= "00";
							regDst				<= "00";
							mem2Reg			<= '0';
							regWrite			<= '1';
							
							state				<= delay_state;
					-----------------------------------------------------------------
					-- SLTIU
					-----------------------------------------------------------------
						when "001011" =>			
							ALU_srcA			<= '1';
							ALU_srcB			<= "10";
							opOut				<= "00";
							regDst				<= "00";
							mem2Reg			<= '0';
							regWrite			<= '1';
							
							state				<= delay_state;
					-----------------------------------------------------------------
					-- ANDI
					-----------------------------------------------------------------
						when "001100" =>			
							ALU_srcA			<= '1';
							ALU_srcB			<= "10";
							opOut				<= "00";
							regDst				<= "00";
							mem2Reg			<= '0';
							regWrite			<= '1';
							
							state				<= delay_state;
					-----------------------------------------------------------------
					-- ORI
					-----------------------------------------------------------------
						when "001101" =>			
							ALU_srcA			<= '1';
							ALU_srcB			<= "10";
							opOut				<= "00";
							regDst				<= "00";
							mem2Reg			<= '0';
							regWrite			<= '1';
							
							state				<= delay_state;
					-----------------------------------------------------------------
					-- XORI
					-----------------------------------------------------------------
						when "001110" =>	
							ALU_srcA			<= '1';
							ALU_srcB			<= "10";
							opOut				<= "00";
							regDst				<= "00";
							mem2Reg			<= '0';
							regWrite			<= '1';
							
							state				<= delay_state;
					-----------------------------------------------------------------
					-- LUI
					-----------------------------------------------------------------
						when "001111" =>
							ALU_srcA			<= '1';
							ALU_srcB			<= "11";
							opOut				<= "00";
							regDst				<= "00";
							mem2Reg			<= '0';
							regWrite			<= '1';
							
							state				<= delay_state;
					-----------------------------------------------------------------
					-- LW
					-----------------------------------------------------------------
						when "100011" =>
							ALU_srcA			<= '1';
							ALU_srcB			<= "10";
							IorDEn				<= '1';
							
							state				<= lw_state;	
					-----------------------------------------------------------------
					-- SW
					-----------------------------------------------------------------
						when "101011" =>
							ALU_srcA			<= '1';
							ALU_srcB			<= "10";
							IorDEn				<= '1';
							
							state				<= sw_state;		
					-----------------------------------------------------------------
					-- Undefined
					-----------------------------------------------------------------
						when others => 
							state				<= Idle_state;
							ENDERROR			<= '1';
							
					end case;
	
				when RtypeAlu_state =>
				
				when j_state =>	
					mem2Reg		<= '0';
					IorDEn			<= '1';
					
					state			<= Idle_state;
					
				when jal_state =>	
					regWrite		<= '1';
					regDst			<= "10";
					
					state			<= j_state;
					
				when beq_state =>					
					ALU_srcA		<= '1';
					ALU_srcB		<= "00";
					opOut			<= "01";
					pcSrc			<= "01";
					branch			<= '1';
					
					state			<= delay_state;
					
				when bne_state =>							
					ALU_srcA		<= '1';
					ALU_srcB		<= "00";
					opOut			<= "01";
					pcSrc			<= "01";
					branch			<= '1';
					
					state			<= delay_state;
				
				when lui_state =>							
					state		<= Idle_state;	
				
				when lw_state =>							
					IorD				<= '1';
					regDst				<= "00";
					mem2Reg			<= '1';
					
					state				<= lwDelay_state;
				
				when lwDelay_state =>
					regWrite			<= '1';
					state				<= delay_state;
				
				when sw_state =>							
					memWrite			<= '1';
					regDst				<= "00";
					mem2Reg			<= '1';
					IorD				<= '1';
					
					state				<= delay_state;
				
				when delay_state =>
					state			<= Idle_state;
					ALU_srcA		<= '0';
					if jump = '1' then
						ALU_srcB		<= "10";
					else
						ALU_srcB		<= "01";
					end if;
					opOut			<= "11";
					IorDEn			<= '1';
					pcSrc			<= "00";
			
				when others =>
					state			<= delay_state;
			end case;	
			
			if rst = '1' then
				state				<= delay_state;
			end if;
		end if;			
	end process;
end architecture;

