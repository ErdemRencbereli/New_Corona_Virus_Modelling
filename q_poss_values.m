%Erdem Rencbereli 2378636 - Seyit Hasan Yaprak 2445146

%This function gives us the possible values of x and y

function possible_positions = q_poss_values(curr_location)

first_x = curr_location(1); first_y = curr_location(2); 
possible_x = [first_x]; possible_y = [first_y];

if first_x + 1 <= 25
    possible_x = [possible_x first_x+1];
end

if first_x - 1 >= 1
    possible_x = [first_x-1 possible_x];
end

if first_y + 1 <= 25
    possible_y = [possible_y first_y+1];
end

if first_y - 1 >= 1
    possible_y = [first_y-1 possible_y];
end

possible_positions = {possible_x;possible_y};

end