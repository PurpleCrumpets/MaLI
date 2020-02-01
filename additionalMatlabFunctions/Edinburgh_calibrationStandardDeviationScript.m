%% calibrationStandardDeviationScript.m
%
% Script to obtain the arthmetic mean, geometric mean and median for
% the output of the initial sampling of DEcalioc and produce the
% corresponding figures.
% 
% Tim Churchfield
%
% Last Edited: 01/02/2020
%




%% Prepare Workspace
clc
clear
close all
% fclose('all');


%% User Input
%pathOptim = 'D:\calibration\DEcaliocTest\DEcalioc\optim';
pathOptim = 'C:\Users\timch\OneDrive - University of Edinburgh\University\Year 5\Placement\Edinburgh\calibration\24_01_2020\optim';
numSimulations = 105;

%% Execution

% Get directory listing
listOptim = dir(pathOptim);
listOptim = listOptim(~ismember({listOptim.name},{'.','..'}));

% Loop
%stdDev = zeros(numSimulations,6,length(listOptim));
stdDev = zeros(numSimulations,3,length(listOptim)); % No nnl
% resultsStd = 

for i = 1:length(listOptim)
    listStd = dir(fullfile(pathOptim,listOptim(i).name));
    listStd = listStd(~ismember({listStd.name},{'.','..'}));
    
    for j = 1:numSimulations 
        % load data from simulation
        pathStd = dir(fullfile(pathOptim,listOptim(i).name,listStd(j).name,'analysis','*_results.mat'));
        pathStd = fullfile(pathOptim,listOptim(i).name,listStd(j).name,'analysis',pathStd.name);
        load(pathStd);
        
        % calculate     
        for k = 1:length(results)
            % standard deviation for a single simulation 
            stdDev(j,k,i) = std([results{k}.angle_av]); % No nnl
            %stdDev(j,2*k-1,i) = std([results{k}.angle_av]); % No nnl
            %stdDev(j,2*k,i)   = std([results{k}.angle_nnl]); % No nnl
            
            % arithmetic mean, geometric mean and median angle
            arithMean(j,k,i) = -1*mean([results{k}.angle_av]); % no nnl
            %arithMean(j,2*k-1,i) = -1*mean([results{k}.angle_av]); % no nnl
            %arithMean(j,2*k,i)   = -1*mean([results{k}.angle_nnl]); % No
            %nnl
            
%             geoMean(j,2*k-1,i) = geomean(-1*[results{k}.angle_av]);
%             geoMean(j,2*k,i)   = geomean(-1*[results{k}.angle_nnl]);
            
            Median(j,k,i) = -1*median([results{k}.angle_av]); % no nnl
            %Median(j,2*k-1,i) = -1*median([results{k}.angle_av]); % no nnl
            %Median(j,2*k,i)   = -1*median([results{k}.angle_nnl]); % No
            %nnl
            
        end  
        

        
        
    end 
end

% Save results as structure
Test.fill20stdDev = stdDev(:,:,1);
Test.fill35stdDev = stdDev(:,:,2);
Test.fill50stdDev = stdDev(:,:,3);

Test.fill20arithMean = arithMean(:,:,1);
Test.fill35arithMean = arithMean(:,:,2);
Test.fill50arithMean = arithMean(:,:,3);

Test.fill20median = Median(:,:,1);
Test.fill35median = Median(:,:,2);
Test.fill50median = Median(:,:,3);

clear stdDev Median

%maxstdDev = zeros(3,6); % No nnl
maxstdDev = zeros(3,3); % No nnl
for i = 1:3 % No nnl
%for i = 1:6 % no nnl
    maxstdDev(1,i) = max(Test.fill20stdDev(:,i));
    maxstdDev(2,i) = max(Test.fill35stdDev(:,i));
    maxstdDev(3,i) = max(Test.fill50stdDev(:,i));
end

%% Find Second Largest Standard Deviation
%max2stdDev = zeros(3,3);


    
stdDevSorted(:,:,1) = sort(Test.fill20stdDev(:,1:3));
stdDevSorted(:,:,2) = sort(Test.fill35stdDev(:,1:3));
stdDevSorted(:,:,3) = sort(Test.fill50stdDev(:,1:3));



max2stdDev = stdDevSorted((size(stdDevSorted,1)-1),:,:);
max2stdDev = reshape(permute(max2stdDev,[1,3,2]),[],size(max2stdDev,2)); % Sorting results

%% Sorted Results
Test.fill20arithMeanSorted = sortrows([Test.fill20arithMean]);
Test.fill35arithMeanSorted = sortrows([Test.fill35arithMean]);
Test.fill50arithMeanSorted = sortrows([Test.fill50arithMean]);


% Basis will be simulation results obtained for the simulation closest to
% the average value obtained for 35% filling degree, 20 rpm as a nice
% centre value.
basis.Mean = Test.fill35arithMean(:,2);
basis.MeanSorted = sort(basis.Mean);
basis.MeanVal = mean(basis.Mean);


%% Inner and Outer Fences for Standard Deviation

% Step 1: Sort the Data 
% stdDevSorted

% Step 2: Quartiles
Q1 = quantile(stdDevSorted,0.25);
Q2 = quantile(stdDevSorted,0.50);
Q3 = quantile(stdDevSorted,0.75);

% Step 3: Inner and Outer Fences
innerFenceLower = Q1 - (1.5 * (Q3-Q1));
innerFenceUpper = Q3 + (1.5 * (Q3-Q1));

outerFenceLower = Q1 - (3 * (Q3-Q1));
outerFenceUpper = Q3 + (3 * (Q3-Q1));


return
%% Plot Results

% legend key
legendAll = {'5 av', '5 nnl', '20 av', '20 nnl', '40 av', '40 nnl'};
legendAverageStd = {'5 av', '20 av', '40 av'};
legendAverageMeanMedian = {'5 av mean', '5 av median', '20 av mean',...
    '20 av median', '40 av mean', '40 av median'};
% All Standard Deviations

% % fill20
% figure;
% plot(Test.fill20stdDev)
% xlabel('Sample');
% ylabel('Standard Deviation');
% title('20% Filling Degree: Standard Deviation')
% legend(legendAll,'Location','best')
% 
% % fill35
% figure;
% plot(Test.fill35stdDev)
% xlabel('Sample');
% ylabel('Standard Deviation');
% title('35% Filling Degree: Standard Deviation')
% 
% % fill50
% figure;
% plot(Test.fill50stdDev)
% xlabel('Sample');
% ylabel('Standard Deviation');
% title('50% Filling Degree: Standard Deviation')

%-----------------------------------------------

% Standard deviation of average
% fill20
% figure;
% plot(Test.fill20stdDev(:,1:2:5))
% xlabel('Sample');
% ylabel('Standard Deviation');
% title('20% Filling Degree: Standard Deviation of Average')
% legend(legendAverageStd,'Location','best')
% 
% % fill35
% figure;
% plot(Test.fill35stdDev(:,1:2:5))
% xlabel('Sample');
% ylabel('Standard Deviation');
% title('35% Filling Degree: Standard Deviation of Average')
% legend(legendAverageStd,'Location','best')
% 
% % fill50
% figure;
% plot(Test.fill50stdDev(:,1:2:5))
% xlabel('Sample');
% ylabel('Standard Deviation');
% title('50% Filling Degree: Standard Deviation of Average')
% legend(legendAverageStd,'Location','best')

%-----------------------------------------------

% Plot of arithmetic and median of average
% % fill20
% figure;
% plot(Test.fill20arithMean(:,1:2:5))
% hold on 
% plot(Test.fill20median(:,1:2:5))
% xlabel('Sample');
% ylabel('Angle');
% title('20% Filling Degree: Arithmetic Mean and Median of Average')
% legend(legendAverageMeanMedian,'Location','best')
% 
% % fill35
% figure;
% plot(Test.fill35arithMean(:,1:2:5))
% hold on 
% plot(Test.fill35median(:,1:2:5))
% xlabel('Sample');
% ylabel('Angle');
% title('35% Filling Degree: Arithmetic Mean and Median of Average')
% legend(legendAverageMeanMedian,'Location','best')
% 
% % fill50
% figure;
% plot(Test.fill50arithMean(:,1:2:5))
% hold on 
% plot(Test.fill50median(:,1:2:5))
% xlabel('Sample');
% ylabel('Angle');
% title('50% Filling Degree: Arithmetic Mean and Median of Average')
% legend(legendAverageMeanMedian,'Location','best')


%----------------------------------------

% Plot Averages
% fill20
figure;
plot(Test.fill20arithMeanSorted(:,1:2:5))
xlabel('Sample');
ylabel('Angle');
title('20% Filling Degree: Averages')
legend(legendAverageStd,'Location','best')

% fill35
figure;
plot(Test.fill35arithMeanSorted(:,1:2:5))
xlabel('Sample');
ylabel('Angle');
title('35% Filling Degree: Averages')
legend(legendAverageStd,'Location','best')

% fill50
figure;
plot(Test.fill50arithMeanSorted(:,1:2:5))
xlabel('Sample');
ylabel('Angle');
title('50% Filling Degree: Averages')
legend(legendAverageStd,'Location','best')





