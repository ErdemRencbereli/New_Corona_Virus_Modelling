%Erdem Rencbereli 2378636 - Seyit Hasan Yaprak 2445146

%This function gives us the possible moves for a given point. Last element
%of this row vector gives the number of steps.

function a = availablemoves(curr_coordinates,N)

a = [];

steps = randi(3);
%In each direction, a point can move with a random amount of step(s) 
%distributed with U[0,3].

for i = 1:8
    before_move = curr_coordinates; 
    after_move = before_move + Movements(i)*steps;
    if insidegrid(after_move,N) == true
        a = [a i];
    else
        continue
    end
end
a = [a steps];

end

