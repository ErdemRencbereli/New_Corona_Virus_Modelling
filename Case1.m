%Erdem Rencbereli 2378636 - Seyit Hasan Yaprak 2445146
clear
clc

T = 25; %Grid size, a square grid of size 25
grid = zeros(T,T);

N = 400; %population = N; [120,500]
delta_1 = 10/100;  %percentage of infected people initially - [1% - 15%]
                   %Randomly distributing n-many healthy people into the determined grid.
index_person = 0; %Starting from the first person
p = 0.4; %infection probability in scenario of encounter [0.1 0.7]
delta_2 = 100/100; %percentage of isolated infected people at the initialization [0% 100%]
q_s = 0.5; %isolation probability of a newly infected person
capital_m = 10; %infectious period duration (in number of iterations) [10,50]
p_healing = 0.95; %each infected point will be healed with a 0.95 probability after M 
                  %iterations of infectious period.
p_death = 1 - p_healing; 
death_people_count = 0; %Dead people at the beginning

while index_person < N
    rand_x = ceil(25*rand()); rand_y = ceil(25*rand());
    if grid(rand_x,rand_y) == 1 %Healthy person
        continue
    else
        grid(rand_x,rand_y) = 1; %Healthy_person
        index_person = index_person + 1;
    end
end

%Now we infect the delta_1% of those N-many people distributed randomly.
index_infected = 0;
while index_infected < delta_1*N
    rand_infect_x = randi(25); rand_infect_y = randi(25);
    if grid(rand_infect_x,rand_infect_y) == 1
        grid(rand_infect_x,rand_infect_y) = 2;
        index_infected = index_infected + 1;
    end
end

%Now we isolate the delta_2% of those sick people.
index_quarantine = 0;
while index_quarantine < delta_2*delta_1*N
    rand_isolate_x = randi(25); rand_isolate_y = randi(25);
    if grid(rand_isolate_x,rand_isolate_y) == 2
        grid(rand_isolate_x,rand_isolate_y) = 2.5;
        index_quarantine = index_quarantine + 1;
    end
end
%Up to this point, we initialized the grid. Randomly distributed N people
%to the T*T grid, all in different places. Then we infected delta_1% of
%them.


%Columns of information matrix gives the number of people and rows of this
%matrix gives info about those people. 1st row is the current situation of
%the person: 1 denotes healthy with no vaccine , 2 and 3 denotes ill ones 
%with and without vaccine respectively, 4 and 5 denotes the healthy ones
%with single and double vaccinated respectively. In addition to those, the
%number 2.5 denotes the sick ones on quarantine.

information = zeros(4,N);

n = 1;
for row = 1:T
    for column = 1:T
        if grid(row,column) ~= 0
            information(1,n) = grid(row,column); %current situation
            information(2,n) = row; %x-coordinate
            information(3,n) = column; %y-coordinate
            information(4,n) = 0; %number of sick-days
            n = n +1;
        end
    end
end

information_overall = information; x = 200; %x is no of iterations.
iter_situations = zeros(x,3);

healed_people_iterations = zeros(2,x);
infected_people_iterations = zeros(2,x);
dead_people_iterations = zeros(2,x);

%x iteration later, initial coordinates and situation is included.
for index_iter = 1:x
    information_new = zeros(4,N);
    current_infected = 0; current_dead = 0; current_healed = 0;
    for index_info = 1:N
        x_coordinate_info = information(2,index_info);
        y_coordinate_info = information(3,index_info);
        if information(1,index_info) == 2.5
            poss_all = q_poss_values([x_coordinate_info,y_coordinate_info]);
            poss_x = poss_all{1}; poss_y = poss_all{2};
            no_of_x = length(poss_x); no_of_y = length(poss_y);
            next_location_x = poss_x(randi(no_of_x));    
            next_location_y = poss_y(randi(no_of_y));
            information_new(1,index_info) = information(1,index_info);
            information_new(2,index_info) = next_location_x;
            information_new(3,index_info) = next_location_y;
        else
            av_moves_info = availablemoves([x_coordinate_info,y_coordinate_info],T);
            steps_multiplier = av_moves_info(length(av_moves_info));
            random_dir = av_moves_info(randi(length(av_moves_info)-1));
            coord_change_rand = Movements(random_dir)*steps_multiplier;
            information_new(1,index_info) = information(1,index_info);
            information_new(2,index_info) = information(2,index_info) + coord_change_rand(1);
            information_new(3,index_info) = information(3,index_info) + coord_change_rand(2);
        end
        %no of infected days + 1
        if information(1,index_info) == 2 || information(1,index_info) == 2.5
            information_new(4,index_info) = information(4,index_info) + 1;
            if information_new(4,index_info) == 11
                if rand() < p_healing
                    information_new(1,index_info) = 1;
                    information_new(4,index_info) = 0;
                    current_healed = current_healed + 1;
                else
                    information_new(1,index_info) = 0;
                    information_new(4,index_info) = 0;
                    current_dead = current_dead + 1;
                end
            end
        elseif information(1,index_info) == 1
            information_new(4,index_info) = 0;
        end
    end
    information_overall = [information_overall;information_new];
    information = information_new;
    whole_cells = issamelocation(information_overall,index_iter);
    for index_samelocation = 1:length(whole_cells)
        healthy_ones = []; sick_ones = [];
        vector_curr = whole_cells{index_samelocation}{1};
        len_vectorcurr = length(vector_curr);
        for index_vector = 1:len_vectorcurr       
            if information(1,vector_curr(index_vector)) == 1
                healthy_ones = [healthy_ones vector_curr(index_vector)];
            elseif (information(1,vector_curr(index_vector)) == 2) || (information(1,vector_curr(index_vector)) == 5/2)
                sick_ones = [sick_ones vector_curr(index_vector)];
            end 
        end
        %Making somebody sick
        len_sick_ones = length(sick_ones); len_healthy_ones = length(healthy_ones);
        if len_sick_ones > 0
            for index_health = 1:len_healthy_ones
                if rand() <= p
                    information_new(1,healthy_ones(index_health)) = 2;
                    current_infected = current_infected + 1;
                    if rand() <= q_s
                        information_new(1,healthy_ones(index_health)) = 2.5;
                    else
                        continue
                    end
                else
                    continue
                end
            end
        else
            continue
        end
    end
    infected_people_iterations(1,index_iter) = current_infected;
    dead_people_iterations(1,index_iter) = current_dead;
    healed_people_iterations(1,index_iter) = current_healed;

    [row_overall,col_overall] = size(information_overall);
    information_overall(row_overall-3:row_overall,:) = information_new;
    information = information_new;
end


cumulative_infected = zeros(1,x);
cumulative_infected(1,1) = infected_people_iterations(1,1);
for index_infected_iters = 1:x-1
    cumulative_infected(index_infected_iters+1) = cumulative_infected(index_infected_iters) + infected_people_iterations(1,index_infected_iters+1);
end
infected_people_iterations(2,:) = cumulative_infected;

cumulative_healed = zeros(1,x);
cumulative_healed(1,1) = healed_people_iterations(1,1);
for index_healed_iters = 1:x-1
    cumulative_healed(index_healed_iters+1) = cumulative_healed(index_healed_iters) + healed_people_iterations(1,index_healed_iters+1);
end
healed_people_iterations(2,:) = cumulative_healed;

cumulative_dead = zeros(1,x);
cumulative_dead(1,1) = dead_people_iterations(1,1);
for index_dead_iters = 1:x-1
    cumulative_dead(index_dead_iters+1) = cumulative_dead(index_dead_iters) + dead_people_iterations(1,index_dead_iters+1);
end
dead_people_iterations(2,:) = cumulative_dead;

%Now we have the information overall matrix and we want to check the people
%on the same location for a given step. For step 1, we have rows 4,5,6
%meaning that 1+3k, 2+3k, 3+3k with a given integer for the requested
%iteration gives us situation, x and y coordinates respectively.

for plot_iterations = 1:x
    plot1(plot_iterations) = infected_people_iterations(1,plot_iterations);
    plot2(plot_iterations) = infected_people_iterations(2,plot_iterations);
    plot5(plot_iterations) = healed_people_iterations(1,plot_iterations);
    plot6(plot_iterations) = healed_people_iterations(2,plot_iterations);
    plot7(plot_iterations) = dead_people_iterations(1,plot_iterations);
    plot8(plot_iterations) = dead_people_iterations(2,plot_iterations);
    xaxis(plot_iterations) = plot_iterations;
end

figure
tiledlayout(3,2)
nexttile
bar(xaxis,plot1)
title('Newly Infected')
nexttile
bar(xaxis,plot2)
title('Total Number of Infected People')
nexttile
bar(xaxis,plot5)
title('Newly Healed')
nexttile
bar(xaxis,plot6)
title('Total Number of Healed People')
nexttile
bar(xaxis,plot7)
title('Newly Dead')
nexttile
bar(xaxis,plot8)
title('Total Number of Dead People')