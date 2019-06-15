function [rows,cols] = calculate_xls_size(filename)

[~,aa] = xlsread(filename);

[bb,A] = size(aa);


rows = bb;

if A < 26
    
    cols = char(64 + A);
    
else
    
    R = floor(A / 26);
    
    L = A - (26 * R);
    
   cols = [char(64+R) char(65+L)];
    
end