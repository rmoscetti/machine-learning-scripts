clear all
clc
load methods.mat
mynew_methods = my_methods; % copy of the starting list of pre-treatments

% Smoothing points range
sp_min = 25; % min
sp_max = 45; % max
sm_points = sp_min:2:sp_max; % array of all tested smoothing points

% Mean centering and auto scaling settings
mc = preprocess('default', 'mean center');
auto = preprocess('default', 'autoscale');

% Computation of the number of pre-treaments
n = length(my_methods);
loops = length(sm_points);
npt = 3*(3 + (n-3)*loops); % number of pre-treatments

% Emptt list of pre-treatments
list = cell(npt, 3);

% Counter
c = 0;

for mc_auto = 1:3

for i = 1:3
    c = c + 1;
    if mc_auto == 1
        list(c,1) = cellstr(mynew_methods{1,c}.description);
        list(c,2) = cellstr('none');
        list(c,3) = cellstr('none');
    elseif mc_auto == 2
        mynew_methods{1,c} = [mynew_methods{1,c-cmax}, mc];
        mynew_methods{2,c} = mc;
        list(c,1) = cellstr(mynew_methods{1,c}(1,1).description);
        list(c,2) = cellstr('none');
        list(c,3) = cellstr(mynew_methods{1,c}(1,2).description);
    elseif mc_auto == 3
        mynew_methods{1,c} = [mynew_methods{1,c-cmax}, auto];
        mynew_methods{2,c} = mc;
        list(c,1) = cellstr(mynew_methods{1,c}(1,1).description);
        list(c,2) = cellstr('none');
        list(c,3) = cellstr(mynew_methods{1,c}(1,2).description);
    end
end

for i = 4:6
    for ii = sm_points
            c = c + 1;
        if mc_auto == 1
            mynew_methods{c} = my_methods{i};
            mynew_methods{1,c}.userdata.width = ii;
            mynew_methods{1,c}.description = [sprintf('%d', mynew_methods{1,c}.userdata.deriv) 'st Derivative (order: 2, window: ' sprintf('%d', ii) ' pt, incl only)'];
            list(c,2) = cellstr(mynew_methods{1,c}.description);
            list(c,1) = cellstr('none');
            list(c,3) = cellstr('none');
        elseif mc_auto == 2
            mynew_methods{1,c} = [mynew_methods{1,c-cmax}, mc];
            mynew_methods{2,c} = mc;
            list(c,2) = cellstr(mynew_methods{1,c}(1,1).description);
            list(c,1) = cellstr('none');
            list(c,3) = cellstr(mynew_methods{1,c}(1,2).description);
        elseif mc_auto == 3
            mynew_methods{1,c} = [mynew_methods{1,c-cmax}, auto];
            mynew_methods{2,c} = mc;
            list(c,2) = cellstr(mynew_methods{1,c}(1,1).description);
            list(c,1) = cellstr('none');
            list(c,3) = cellstr(mynew_methods{1,c}(1,2).description);
        end
    end
end

for i = 7:15
    for ii = sm_points
        c = c + 1;
        if mc_auto == 1
            mynew_methods{c} = my_methods{i};
            mynew_methods{1,c}(1,2).userdata.width = ii;
            mynew_methods{1,c}(1,2).description = [sprintf('%d', mynew_methods{1,c}(1,2).userdata.deriv) 'st Derivative (order: 2, window: ' sprintf('%d', ii) ' pt, incl only)'];
            list(c,1) = cellstr(mynew_methods{1,c}(1,1).description);
            list(c,2) = cellstr(mynew_methods{1,c}(1,2).description);
            list(c,3) = cellstr('none');
        elseif mc_auto == 2
            mynew_methods{1,c} = [mynew_methods{1,c-cmax}, mc];
            mynew_methods{2,c} = mc;
            list(c,1) = cellstr(mynew_methods{1,c}(1,1).description);
            list(c,2) = cellstr(mynew_methods{1,c}(1,2).description);
            list(c,3) = cellstr(mynew_methods{1,c}(1,3).description);
        elseif mc_auto == 3
            mynew_methods{1,c} = [mynew_methods{1,c-cmax}, auto];
            mynew_methods{2,c} = mc;
            list(c,1) = cellstr(mynew_methods{1,c}(1,1).description);
            list(c,2) = cellstr(mynew_methods{1,c}(1,2).description);
            list(c,3) = cellstr(mynew_methods{1,c}(1,3).description);
        end   
     end
end

for i = 16:18
    for ii = sm_points
        c = c + 1;
        if mc_auto == 1
            mynew_methods{c} = my_methods{i};
            mynew_methods{1,c}(1,2).userdata.width = ii;
            mynew_methods{1,c}(1,2).description = ['smoothing (order: 2, window: ' sprintf('%d', ii) ' pt, incl only)'];
            list(c,1) = cellstr(mynew_methods{1,c}(1,1).description);
            list(c,2) = cellstr(mynew_methods{1,c}(1,2).description);
            list(c,3) = cellstr('none');
        elseif mc_auto == 2
            mynew_methods{1,c} = [mynew_methods{1,c-cmax}, mc];
            mynew_methods{2,c} = mc;
            list(c,1) = cellstr(mynew_methods{1,c}(1,1).description);
            list(c,2) = cellstr(mynew_methods{1,c}(1,2).description);
            list(c,3) = cellstr(mynew_methods{1,c}(1,3).description);
        elseif mc_auto == 3
            mynew_methods{1,c} = [mynew_methods{1,c-cmax}, auto];
            mynew_methods{2,c} = mc;
            list(c,1) = cellstr(mynew_methods{1,c}(1,1).description);
            list(c,2) = cellstr(mynew_methods{1,c}(1,2).description);
            list(c,3) = cellstr(mynew_methods{1,c}(1,3).description);
        end   
    end
end

for ii = sm_points
    c = c + 1;
    if mc_auto == 1
        mynew_methods{c} = my_methods{4};
        mynew_methods{1,c}.userdata.width = ii;
        mynew_methods{1,c}.userdata.deriv = 0;
        mynew_methods{1,c}.description = ['smoothing (order: 2, window: ' sprintf('%d', ii) ' pt, incl only)'];
        list(c,1) = cellstr('none');
        list(c,2) = cellstr(mynew_methods{1,c}.description);
        list(c,3) = cellstr('none');
    elseif mc_auto == 2
        mynew_methods{1,c} = [mynew_methods{1,c-cmax}, mc];
        mynew_methods{2,c} = mc;
        list(c,1) = cellstr('none');
        list(c,2) = cellstr(mynew_methods{1,c}(1,1).description);
        list(c,3) = cellstr(mynew_methods{1,c}(1,2).description);
    elseif mc_auto == 3
        mynew_methods{1,c} = [mynew_methods{1,c-cmax}, auto];
        mynew_methods{2,c} = mc;
        list(c,1) = cellstr('none');
        list(c,2) = cellstr(mynew_methods{1,c}(1,1).description);
        list(c,3) = cellstr(mynew_methods{1,c}(1,2).description);
    end 
 end
    cmax = c;
end

save('pretreatment_list.mat', 'mynew_methods', 'list');
cell2csv('pretreatment_list.csv', list, '#');