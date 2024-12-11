clc;
clear;
close all;

%% Problem Definition

[Data,data,Name_matfile,x,y] = Read_input();
% [q,qind] = mapminmax(y);

if Name_matfile ==12
    train = Data(:,1:4435);
    test = Data(:,4436:end);
    train = train';
    test = test';
    
else
    Data = Data';
    [r,c] = size(Data);
    TR = floor(0.7 * r);
    numTr = randperm(r,TR);
    train = Data(numTr,:);
    Data(numTr,:) = [];
    test = Data;
end

MaxRun = 15;
classification_Er = zeros(1,MaxRun);
num_feature = zeros(1,MaxRun);
CE = zeros(1,MaxRun);
CF = zeros(1,MaxRun);
CM = zeros(1,MaxRun);

for Run = 1:MaxRun
    [classification_Er(Run), num_feature(Run),CE(Run),CF(Run),CM(Run) ] = ISSA(train,test);
end

ACC = mean(classification_Er);
NumFea = mean (num_feature);
Fscore = mean (CF);
MCC = mean (CM);

disp([' The Mean Of Best Testing Costs = ' num2str(ACC)]);
disp([' The Mean Of The Number Of Selected Feature = ' num2str(NumFea)]);


