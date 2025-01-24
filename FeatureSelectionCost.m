function [Ete,Fs,Mcc, out]=FeatureSelectionCost(s,train,test)

% Read Data Elements
x = train(:,1:end-1);
x2 = test(:,1:end-1);

% Selected Features
S=find(s~=0);

% Number of Selected Features
nf=numel(S);


% Ratio of Selected Features
rf=nf/numel(s);

% Selecting Features
Trains=x(:,S);
Tests=x2(:,S);

train_label = train(:,end);
test_label = test(:,end);


[Ete, precision, recall, Fs, Mcc] = mlp_metric(Trains, train_label, Tests, test_label);

% Set Outputs
out.S = S;
out.nf = nf;
out.rf = rf;
out.pr = precision;
out.rc = recall;
% out.E = Etr;
out.EE = Ete;
out.FS = Fs;
out.Mc = Mcc;

end