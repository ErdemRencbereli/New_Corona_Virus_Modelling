%Erdem Rencbereli 2378636 - Seyit Hasan Yaprak 2445146

%This code gives us the points that are coinciding for a given iteration,
%using the information_overall matrix where we store all the moves

function unique_last = issamelocation(information_overall,iteration)

info_curr_iter = information_overall(1+(4*iteration):4+(4*iteration),:);
coord_info_curr = info_curr_iter(2:3,:);
N = length(information_overall(1,:)); curr_coincide = []; coincides = {};

for index_item_2 = 1:N %applying the procedure to all elements
    for index_item_1 = 1:N %checking all the coincides from beginning to end
        if coord_info_curr(:,index_item_2) == coord_info_curr(:,index_item_1)
            curr_coincide = [curr_coincide index_item_1];
        else
            continue
        end        
    end
    [m,n] = size(coincides);
    coincides{m+1,1} = curr_coincide;
    curr_coincide = [];
end

last_coincides = {};
for index_coincides = 1:N
    current_one = coincides{index_coincides,1};
    if length(current_one) == 1
        continue
    else
        [a,b] = size(last_coincides);
        last_coincides{a+1,1} = coincides(index_coincides,1);
    end
end
%Up to this point, this function gives the coincides doubled such as
%(12,60) and (12,60). But we need the ones which are unique.

unique_last = {};
for index_last_coin = 1:(length(last_coincides)-1)
    similarity = 0;
    for index_inside = (index_last_coin+1):length(last_coincides)        
        cell_1 = last_coincides{index_last_coin,1}{1};
        cell_2 = last_coincides{index_inside,1}{1};
        size_1 = length(cell_1); size_2 = length(cell_2);
        if size_1 == size_2
            if cell_1 == cell_2
                similarity = similarity + 1;       
            else
                continue
            end
        else
            continue
        end
    end
    if similarity == 0
        [abc,bcd] = size(unique_last);
        unique_last{abc+1,1} = last_coincides{index_last_coin,1};
    else
        continue
    end
end

end