clc;
clear;
close all;

%% Problem Definition

[Data,data,Name_matfile,x,y] = Read_input();


MaxRun = 15;
classification_Er = zeros(1,MaxRun);
num_feature = zeros(1,MaxRun);
CE = zeros(1,MaxRun);
CF = zeros(1,MaxRun);
CM = zeros(1,MaxRun);
% Data = Data';

for Run = 1:MaxRun
    
    if Name_matfile ==12
        train = Data(1:4435,:);
        test = Data(4436:end,:);

    else
        D = Data;
        [r,c] = size(D);
        TR = floor(0.7 * r);
        numTr = randperm(r,TR);
        train = D(numTr,:);
        D(numTr,:) = [];
        test = D;
    end


    [classification_Er(Run), num_feature(Run),CE(Run),CF(Run),CM(Run) ] = ISSA(train,test);
end

ACC = mean(classification_Er);
sstd = std(classification_Er);
NumFea = mean (num_feature);
Fscore = mean (CF);
MCC = mean (CM);

disp([' The Mean Of Best Testing Costs = ' num2str(ACC)]);
disp([' The Mean Of Best Testing Costs = ' num2str(sstd)]);
disp([' The Mean Of The Number Of Selected Feature = ' num2str(NumFea)]);


