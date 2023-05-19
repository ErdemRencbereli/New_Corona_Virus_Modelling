%Erdem Rencbereli 2378636 - Seyit Hasan Yaprak 2445146

%There are 8 available moves, input is the integer and output is the
%changes in x and y coordinates as an array.

function coordinate_change = Movements(a)
if a == 1
    row_change = -1;  column_change = 0;
elseif a == 2
    row_change = -1; column_change = -1;
elseif a == 3
    row_change = 0; column_change = -1;
elseif a == 4
    row_change = 1; column_change = -1;    
elseif a == 5
    row_change = 1;  column_change = 0;
elseif a == 6
    row_change = 1;  column_change = 1;
elseif a == 7
    row_change = 0;  column_change = 1;
elseif a == 8
    row_change = -1;  column_change = 1;
else
    fprintf("Not a valid move, give integer between 1 & 8")
end
coordinate_change = [row_change,column_change];
end

