function [E,F1ScoreMacro,MCC] = Acc(hid,neron,pop,train,n_in,n_out,dim,bias,train_ind,Target,struct1)

% Define Variable Problem ---------------
 
num_w = dim - bias;

Bias = pop(1,num_w+1:dim);
pop = pop(1,1:num_w);

individual.x = [];
B_hh =individual;

Bih = Bias(1:neron);
for g=1:hid-1
    B_hh(g).x = Bias(g*neron+1:(g+1)*neron);
end
index = (hid*neron)+1;
Boh = Bias(index:end);

w_ih = zeros(n_in,neron);
W_HO = zeros(neron,n_out);
w_hh.x =[];

nweight_ih1 = n_in*neron;
nweight_out = neron*n_out;
wIH = pop(1:nweight_ih1);
WHH = pop(nweight_ih1+1:num_w-nweight_out);
WHO = pop((num_w-nweight_out)+1:end);


for i=1 : n_in
    w_ih(i,:) = wIH((i-1)*neron+1 : i*neron);
end

for k =1:hid-1
    for j=1:neron
        w_hh(k).x(:,j) = WHH((j-1)*neron+1 : j*neron); %#ok
    end
end

for h = 1:n_out
    W_HO(:,h) = WHO((h-1)*neron+1 : h*neron);
end


% Dimensions
[rowTR,~] = size(train);
nT = rowTR;

% Input 1
x1 = train;

% Layer 1
a1 = tansig_apply(repmat(Bih',1,nT) + w_ih'*x1');

% Hidden Layer
for k = 1:hid-1
        
        B = B_hh(k).x';
        X = w_hh(k).x';
        a2 = tansig_apply(repmat(B,1,nT) + X*a1);
        a1 = a2;
        
end
    % end Layer
   
a2 = repmat(Boh',1,nT) + W_HO'*a1;

y1 = mapminmax('reverse',a2',struct1);

y1 = y1';

[~,MaxInd] = max(y1);

[~,maxInd] = find(train_ind~=MaxInd);

matchInd = numel(maxInd);

E = 100*(matchInd/nT);

Pc = n_in*neron+(hid-1)*neron^2+neron*n_out+bias;           %#ok

f = perform_MSE(Target,y1);                                                   %#ok


classes = unique(train_ind);
numClasses = length(classes);

Precision = zeros(1, numClasses);
Recall = zeros(1, numClasses);
F1Scores = zeros(1, numClasses);
MCCs = zeros(1, numClasses);


for c = 1:numClasses
    class = classes(c);
    
    % Binary representation for current class
    actual = (train_ind == class);
    predicted = (MaxInd == class);
    
    % True Positive, False Positive, False Negative, True Negative
    TP = sum((actual == 1) & (predicted == 1));
    TN = sum((actual == 0) & (predicted == 0));
    FP = sum((actual == 0) & (predicted == 1));
    FN = sum((actual == 1) & (predicted == 0));
    
    % Precision, Recall, F1 Score for current class
    if TP + FP == 0
        Precision(c) = 0;
    else
        Precision(c) = TP / (TP + FP);
    end
    
    if TP + FN == 0
        Recall(c) = 0;
    else
        Recall(c) = TP / (TP + FN);
    end
    
    if Precision(c) + Recall(c) == 0
        F1Scores(c) = 0;
    else
        F1Scores(c) = 2 * (Precision(c) * Recall(c)) / (Precision(c) + Recall(c));
    end
    
    % MCC for current class
    denominator = sqrt((TP + FP) * (TP + FN) * (TN + FP) * (TN + FN));
    if denominator == 0
        MCCs(c) = 0;
    else
        MCCs(c) = ((TP * TN) - (FP * FN)) / denominator;
    end
end

% Macro-Averaged F1 Score
F1ScoreMacro = mean(F1Scores);

% Macro-Averaged MCC
MCC = mean(MCCs);

end

function a = tansig_apply(n,~)
a = 2 ./ (1 + exp(-2*n)) - 1;
end


function perf = perform_MSE(targets,outputs)

% Error
error = gsubtract(targets,outputs);

%calculate performance by the MSE criterion
perfs = error.^2;

perf = 0;
perfN = 0;

perf = perf + sum(perfs(:));
perfN = perfN + numel(perfs);

%perform normalization
perf = perf / perfN;
end