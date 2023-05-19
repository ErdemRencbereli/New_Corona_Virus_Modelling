%Erdem Rencbereli 2378636 - Seyit Hasan Yaprak 2445146

%This function helps us to understand whether the given point (x and y
%coordinates of that point) is inside the determined grid or not. Takes
%input as a row vector with 2 elements and the output is a logical either
%true or false.

function a = insidegrid(curr_coordinates,N)
x = curr_coordinates(1,1); y = curr_coordinates(1,2);
if x >= 1 && x <= N && y >= 1 && y <= N
    a = true;
else
    a = false;
end


