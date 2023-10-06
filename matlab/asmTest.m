
readfilename        = 'assembly.txt';
writefilename       = 'machineCode.txt';
fileID                     = fopen(writefilename, 'w'); 

load('format.mat')
asembly        = readtable(readfilename);


for i = 1: height(asembly(:, "func"))
    line = string(table2array(asembly(i, :)));
    line = erase(line, "$");
    line = erase(line, "#");
    line = erase(line, ",");
    if isfield(opCodeFormat, line(1))
        if strcmp(line(1), 'lui')
            I_type(fileID, getfield(opCodeFormat, line(1)), getfield(registerFormat, line(2)), getfield(registerFormat, line(3)), line(4));
        else
            I_type(fileID, getfield(opCodeFormat, line(1)), getfield(registerFormat, line(2)), '00000', line(4));
        end
    elseif isfield(funcFormat, line(1))
        if (strcmp(line(1), 'jr') || strcmp(line(1), 'jalr'))
            R_type(fileID, getfield(funcFormat, line(1)), '00000', getfield(registerFormat, line(2)), getfield(registerFormat, line(3)));
        elseif strcmp(line(1), 'multu')
            R_type(fileID, getfield(funcFormat, line(1)), '00000', getfield(registerFormat, line(2)), getfield(registerFormat, line(3)));
        elseif (strcmp(line(1), 'mfhi') || strcmp(line(1), 'mflo'))
            R_type(fileID, getfield(funcFormat, line(1)), getfield(registerFormat, line(2)), '00000', '00000');
        else
            R_type(fileID, getfield(funcFormat, line(1)), getfield(registerFormat, line(2)), getfield(registerFormat, line(3)), getfield(registerFormat, line(4)));
        end
    else
        J_type(fileID, getfield(JFormat, line(1)), line(2));
    end
end
fprintf(fileID, '11111111111111111111111111111111');

function R_type(fileID, func, rd, rs, rt)
    code = strcat('000000', rs, rt, rd, '00000', func, '\n');
    fprintf(fileID, code); 
end

function I_type(fileID, opcode, rd, rs, Imm)
     code = strcat(opcode, rs, rd, string(dec2bin(double(Imm), 16)), '\n');
     fprintf(fileID, code);
end

function J_type(fileID, opcode, Imm)
     code = strcat(opcode, string(dec2bin(double(Imm), 26)), '\n');
     fprintf(fileID, code);
end