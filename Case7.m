%Erdem Rencbereli 2378636 - Seyit Hasan Yaprak 2445146
clear
clc

T = 25; %Grid size, a square grid of size 25
grid = zeros(T,T);

N = 150; %population = N; , fixed
delta_1 = 1/100;  %percentage of infected people initially - [1% - 15%]
index_person = 0; %Starting from the first person
p = 0.5; %infection probability in scenario of encounter [0.1 0.7], fixed
delta_2 = 5/100; %percentage of isolated infected people at the initialization, fixed
q_s = 1; %isolation probability of a newly infected person
capital_m = 30; %infectious period duration (in number of iterations), fixed
p_healing = 0.95; %each infected point will be healed with a 0.95 probability after M 
                  %iterations of infectious period.
p_death = 1 - p_healing; 
t_s = 20; %iteration number where vaccination starts
r_s = 0.05; %infection probability of vaccinated healthy people
k = 1.5;   %k = {1.5,2,3,4}
%t_v =t_s,t_s+1,t_s+2, ...
%delta_3 = (1)/(k*(t_v-19));
t_sec = 4; %number of iterations between two vaccinations 
w = 0.4; %Second vaccination probability of healthy people [0.4 - 0.8]

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
    %with single and double vaccinated(1 vaccination + infection) respectively. 
    %In addition to those, the number 2.5 denotes the sick ones on quarantine.
    
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
    People_states_each_iter = zeros(5,x); %Healthy, sick, vaccinated, immune, dead
    
    %x iteration later, initial coordinates and situation is included.
    for index_iter = 1:x
        information_new = zeros(4,N);
        current_infected = 0; current_dead = 0; current_healed = 0; current_vaccinated = 0; 
        healthy_current_count = 0; vaccinated_healthy_count= 0;
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
            if information(1,index_info) == 2 || information(1,index_info) == 2.5 || information(1,index_info) == 3
                information_new(4,index_info) = information(4,index_info) + 1;
                if information_new(4,index_info) == (capital_m + 1)
                    if rand() < p_healing
                        if information(1,index_info) == 3
                            information_new(1,index_info) = 5;
                            information_new(4,index_info) = 0;
                            current_healed = current_healed + 1;
                        else
                            information_new(1,index_info) = 1;
                            information_new(4,index_info) = 0;
                            current_healed = current_healed + 1;
                        end
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
        
        if index_iter >= t_s
            vaccination_index = 0;
            t_v = index_iter;
            delta_3 = (1)/(k*(t_v-19));
            second_vac = 0;
            for vac_index = 1:N
                if information(1,vac_index) == 1
                    healthy_current_count = healthy_current_count + 1;
                elseif information(1,vac_index) == 4 
                    vaccinated_healthy_count = vaccinated_healthy_count +1;
                else
                    continue
                end
            end
        
            while second_vac < vaccinated_healthy_count * delta_3 * w 
                randomized_two = randi(N);
                if information(1,randomized_two) == 4
                    information_new(1,randomized_two) = 5;
                    second_vac = second_vac + 1;
                    current_vaccinated = current_vaccinated + 1;
                else
                    continue
                end
            end
            while vaccination_index < healthy_current_count* delta_3
                randomized_one = randi(N);
                if information(1,randomized_one) == 1
                    information_new(1,randomized_one) = 4;
                    vaccination_index = vaccination_index + 1;
                    current_vaccinated = current_vaccinated + 1;
                else
                    continue
                end
            end
        end
            for vac_control_index = 1 : N
                if information(1,vac_control_index) == 4
                    information_new(4,vac_control_index) = information(4,vac_control_index) +1;
                    if information(4,vac_control_index) >= t_sec
                        information_new(1,vac_control_index) = 1;
                        information_new(4,vac_control_index) = 0;
                    end
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
                if information(1,vector_curr(index_vector)) == 1 || information(1,vector_curr(index_vector)) == 4
                    healthy_ones = [healthy_ones vector_curr(index_vector)];
                elseif (information(1,vector_curr(index_vector)) == 2) || (information(1,vector_curr(index_vector)) == 5/2 || information(1,index_info) == 3)
                    sick_ones = [sick_ones vector_curr(index_vector)];
                end 
            end
            %Making somebody sick
            len_sick_ones = length(sick_ones); len_healthy_ones = length(healthy_ones);
            if len_sick_ones > 0
                for index_health = 1:len_healthy_ones
                    if information(1,healthy_ones(index_health)) == 4
                        if rand() <= r_s
                            information_new(1,healthy_ones(index_health)) = 3;
                            information_new(4,healthy_ones(index_health)) = 1;
                            current_infected = current_infected + 1;
                        else 
                            continue
                        end
                    elseif information(1,healthy_ones(index_health)) == 1
                        if rand() <= p
                            information_new(1,healthy_ones(index_health)) = 2;
                            information_new(4,healthy_ones(index_health)) = 1;
                            current_infected = current_infected + 1;
                            if rand() <= q_s
                                information_new(1,healthy_ones(index_health)) = 2.5;
                                information_new(4,healthy_ones(index_health)) = 1;
                            else
                                continue
                            end
                        else
                            continue
                        end
                    end
                end
            else
                continue
            end
        end
        infected_people_iterations(1,index_iter) = current_infected;
        dead_people_iterations(1,index_iter) = current_dead;
        healed_people_iterations(1,index_iter) = current_healed;
        vaccinated_people_iterations(1,index_iter) = current_vaccinated;
    
        [row_overall,col_overall] = size(information_overall);
        information_overall(row_overall-3:row_overall,:) = information_new;
        information = information_new;
        for people_state_index = 1:N
            if information(1,people_state_index) == 1 
                People_states_each_iter(1, index_iter) = People_states_each_iter(1, index_iter) +1;
            elseif information(1,people_state_index) == 2
                People_states_each_iter(2, index_iter) = People_states_each_iter(2, index_iter) +1;
            elseif information(1,people_state_index) == 3
                People_states_each_iter(2, index_iter) = People_states_each_iter(2, index_iter) +1;
            elseif information(1,people_state_index) == 2.5
                People_states_each_iter(2, index_iter) = People_states_each_iter(2, index_iter) +1;
            elseif information(1,people_state_index) == 4
                People_states_each_iter(3, index_iter) = People_states_each_iter(3, index_iter) +1;
                People_states_each_iter(1, index_iter) = People_states_each_iter(1, index_iter) +1;
            elseif information(1,people_state_index) == 5
                People_states_each_iter(4, index_iter) = People_states_each_iter(4, index_iter) +1;
                People_states_each_iter(1, index_iter) = People_states_each_iter(1, index_iter) +1;
            elseif information(1,people_state_index) == 0
                People_states_each_iter(5, index_iter) = People_states_each_iter(5, index_iter) +1;
            end
        end
    end
    ending_no = capital_m + 1;
    max_infecteds = max(People_states_each_iter(2,ending_no:x));


%After several experiments, we reached the following data
table = [28, 122;
         49, 101;
         38, 112;
         62, 88];

colors = [0 1 1;       %Cyan color for the first slice in each plot
          0 0 0.85];   %Magenta color for the second slice in each plot

figure;
title('Case 7 scenarios')
subplot(2, 2, 1);
pie3(table(1, :));
colormap(colors);
title('Case 7-1, k = 1.5, w = 0.8');
subplot(2, 2, 2);
pie3(table(2, :));
colormap(colors);
title('Case 7-2, k = 3, w = 0.8');
subplot(2, 2, 3);
pie3(table(3, :));
colormap(colors);
title('Case 7-3, k = 1.5, w = 0.4');
subplot(2, 2, 4);
pie3(table(4, :));
colormap(colors);
title('Case 7-4, k = 3, w = 0.4');
lgd = legend({'Maximum number of infected people', 'Maximum number of non-infected people'});
set(lgd, 'Location', 'northwest', 'FontSize', 20);