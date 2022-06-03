clc
clear
close all
fclose('all');

disp(["Terminate by closing gauge window"]);

%% Initialize
data = [];
counter = 0;
smooth = 0.1;
buffer = 30;
datbuffer = 100;

sizeA = [70 inf];
cg = [];

figgg = uifigure('Position',[100 100 440 320]);
fig = uigridlayout(figgg, [2 4]);

labels = [  ""; ...
            "Collection Chamber"; ...
            "Evaporation Tank"; ...
            "Air Heat Ex Output"; ...
            "Input Sea Water"; ...
            "Air Heat Ex Input"; ...
            "Condenser Input"; ...
            "Condenser Output"];

for k=1:8
    cg = [cg uigauge(fig,'ScaleColors',{'yellow','red'},...
                     'ScaleColorLimits', [60 80; 80 100])];
end

%% Plot Whole Data
fileID = fopen('C:\Users\Saurav\PycharmProjects\DeSal\27May_test1.txt', 'r');
formatSpec = '%f';

% scan = textscan(fileID, '%f ','HeaderLines',10,'Delimiter',',');
% temp = cell2mat(scan);
% 
% temp = temp(1:(end-mod(length(temp),8)));
% temp = reshape(temp',8,[]);
% data = [data; temp'];

scan = textscan(fileID, '%q %f %f %f %f %f %f %f ','HeaderLines',10,'Delimiter',',');

time = split(scan{1}(1:length(scan{8}))," ");
time = datevec(cell2mat(erase(time(:,1),"[")),'HH:MM:SS');

for j=2:8
    temp(1:length(scan{8}),j) = scan{j}(1:length(scan{8}));
end
data = [data; [convertTo(datetime(time),'excel') temp(:,2:8)]];

computeTime = [];

%% Plot Live Data
while true
    t1 = cputime;
    
    figure(1)

    fileID = fopen('C:\Users\Saurav\PycharmProjects\DeSal\27May_test1_tail.txt', 'r');
    formatSpec = '%f';

    scan = textscan(fileID, '%q %f %f %f %f %f %f %f ','HeaderLines',0,'Delimiter',',');

    time = split(scan{1}{1}," ");
    time = datevec(cell2mat(erase(time(1),"[")),'HH:MM:SS.FFF');

    temp(2:8) = cell2mat(scan(2:8));
    data = [data; [convertTo(datetime(time),'excel') temp(2:8)]];

    a = [];
    for i=1:length(data)
        for j=2:8
            a(i,j) = (round(data(i,j)./smooth)).*smooth;

            if (~isnan(a(end,j)))
                cg(j).Value = a(end,j);
            end
        end
    end

    for j=2:8
        if (j<=4)
            subplot(6,6,j)                                  % Plot Individual with Buffer
            if (length(a) > datbuffer)
                plot(datetime(data(end-datbuffer:end,1),'convertfrom','excel'),a(end-datbuffer:end,j))
                xlim([datetime(data(end,1),'convertfrom','excel')-seconds(buffer) datetime(data(end,1),'convertfrom','excel')])
            end
            title(labels(j))
           
            subplot(6,6,j+6)                                % Plot Individual
            plot(datetime(data(:,1),'convertfrom','excel'),a(:,j))
            title([num2str(data(end,j)), 176, 'C'])
            xlim([datetime(data(1,1),'convertfrom','excel') datetime(data(end,1),'convertfrom','excel')])
        else
            subplot(6,6,j+8)
            if (length(a) > datbuffer)
                plot(datetime(data(end-datbuffer:end,1),'convertfrom','excel'),a(end-datbuffer:end,j))
                xlim([datetime(data(end,1),'convertfrom','excel')-seconds(buffer) datetime(data(end,1),'convertfrom','excel')])
            end
            title(labels(j))

            subplot(6,6,j+14)
            plot(datetime(data(:,1),'convertfrom','excel'),a(:,j))
            title([num2str(data(end,j)), 176, 'C'])
            xlim([datetime(data(1,1),'convertfrom','excel') datetime(data(end,1),'convertfrom','excel')])
        end
    end
    subplot(6,6,[1 7])
    bar(data(end,2:end))
    ylim([0 50])
    grid minor

    subplot(6,6,[5 6 11 12 17 18 23 24])                    % Plot All with Buffer
    if (length(a) > datbuffer)
        plot(datetime(data(end-datbuffer:end,1),'convertfrom','excel'),a(end-datbuffer:end,2:8), 'linewidth', 2)
        xlim([datetime(data(end,1),'convertfrom','excel')-seconds(buffer) datetime(data(end,1),'convertfrom','excel')])
        text([(datetime(data(end,1),'convertfrom','excel')+seconds(1)), ...
                (datetime(data(end,1),'convertfrom','excel')+seconds(1)), ...
                (datetime(data(end,1),'convertfrom','excel')+seconds(1)), ...
                (datetime(data(end,1),'convertfrom','excel')+seconds(1)), ...
                (datetime(data(end,1),'convertfrom','excel')+seconds(1)), ...
                (datetime(data(end,1),'convertfrom','excel')+seconds(1)), ...
                (datetime(data(end,1),'convertfrom','excel')+seconds(1)), ...
                (datetime(data(end,1),'convertfrom','excel')+seconds(1))],a(end,:),labels)
    end

    subplot(6,6,[25 26 27 28 29 30 31 32 33 34 35 36])      % Plot All
    plot(datetime(data(:,1),'convertfrom','excel'),a(:,2:8))
    xlim([datetime(data(1,1),'convertfrom','excel') datetime(data(end,1),'convertfrom','excel')])
    legend(labels(2:8),"Location", "eastoutside")

    pause(1)

%     figure(2)
    computeTime = [computeTime cputime-t1];
%     plot(computeTime)

    counter = counter + 1;
    if (counter == 100)
        fclose('all');
    end
end

