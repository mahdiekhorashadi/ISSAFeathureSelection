function [EE,F1ScoreMacro,MCC,g_fit] = CreateANNandtrain(Trains,train2,Tests,test)

%% TLBO Parameters Definition
n_in =size(Trains,2);
tar_tr = train2(:,end);
T = unique(tar_tr);
[n_out,~] = size(T);

z = 0.03;

MaxEpoch = 100;

PopSize = 50;
lb = -1;
ub =  1;

n_layer = 1;

n_neroun = floor(((n_in + n_out)/2)/2);

nweight_ih = n_in*n_neroun;
nweight_ho = n_neroun*n_out;
Bias = (n_neroun*n_layer)+n_out;
num_w = nweight_ih+nweight_ho;
dim = num_w+Bias;

UB = ones(1,dim).*ub;
LB = ones(1,dim).*lb;

Pc = 0.5;
M = 10;

teacher = zeros(1,PopSize);
indTeach = zeros(1,PopSize);

Target_mat = eye(n_out);
class = zeros(n_out,n_out);

for i = 1:n_out
    class(i,:) =  Target_mat(:,i);
end

tar_ts = test(:,end);
Ts = unique(tar_ts);
[n_out_test,~] = size(Ts);
Target_mat_test = eye(n_out_test);
class_test = zeros(n_out_test,n_out_test);

for i = 1:n_out_test
    class_test(i,:) =  Target_mat_test(:,i);
end

n_layer = 1;


%% Define Training & Test Set -------------------

No_Train_data = size(Trains,1);
No_Test_data = size(test,1);

%% Define Targets Set ---------------------------
target_test = zeros(n_out_test,No_Test_data);
target = zeros(n_out,No_Train_data);
test_ind = zeros(1,No_Test_data);
train_ind = zeros(1,No_Train_data);

y_train = train2(:,end);
y_num_train = unique(y_train);
y_num_tn = numel(y_num_train);
y_train = y_train';

yt = zeros(1,y_num_tn);
yt(1) = 1;
for ii=2:y_num_tn
    if y_train(ii)==y_train(ii-1)
        yt(ii)=yt(ii-1);
    else
        yt(ii)=yt(ii-1)+1;
    end

end


y_test = test(:,end);
y_num_test = unique(y_test);
y_num_tt = numel(y_num_test);

y_test=y_test';

for iii=1:y_num_tt
    for ii =1:No_Test_data
        if y_test(ii) == y_num_test(iii)
            target_test(:,ii) = class_test(iii,:);
            test_ind(ii) = iii;
        end
    end
end
for iii=1:y_num_tn
    for ii =1:No_Train_data
        if y_train(ii) == y_num_train(iii)
            target(:,ii) = class(iii,:);
            train_ind(ii) = iii;
        end
    end
end

[Trains,struct1]=mapminmax(Trains);

[Tests,struct2]=mapminmax(Tests);


%% Initialization
empty.x = [];
empty.E = [];
empty. Fscore= [];
empty.MCC = [];

pop = repmat(empty,1,PopSize);

for i = 1: PopSize

    pop(i).x = rand(1,dim)*(ub-lb)+lb;
    [pop(i).E,pop(i).Fscore,pop(i).MCC] = Acc(n_layer,n_neroun,pop(i).x,Trains,n_in,n_out,dim,Bias,train_ind,target,struct1);


end

[bestCurr,ind] = min([pop.E]);

g_best = pop(ind);
%% determine the neighbour

[neighbour] = Find_neighbour2(PopSize);

for ii=1:PopSize

    Neigh = neighbour(ii).index;

    Fit = [pop(Neigh).E];

    [teacher(ii),ind] = min(Fit);
    indTeach(ii) = Neigh(ind);
end

%%  Main Loop
Epoch = 0;

while Epoch < MaxEpoch

    Epoch = Epoch + 1;

    values = [pop.E];
    [~, idx] = sort(values);
    pop = pop(idx);

    FoodPosition = pop(1).x;

    c1 = 2*exp(-(4*Epoch/MaxEpoch)^2);

    for i=1:PopSize

        newPop = zeros(1,dim);
        if i == 1

            for j=1:1:dim
                c2=rand();
                c3=rand();
                %%%%%%%%%%%%% % Eq. (3.1) in the paper %%%%%%%%%%%%%%
                if c3>=z
                    newPop(j) = FoodPosition(j)+c1*((UB(j)-LB(j))*c2+LB(j));

                elseif c3<0
                    newPop(j) = FoodPosition(j)-c1*((ub(j)-lb(j))*c2+lb(j));
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end

        else
            point1=pop(i-1).x;
            point2=pop(i).x;

            newPop = (point2+point1)/2; % % Eq. (3.4) in the paper
        end

        [newFit,pop(i).Fscore,pop(i).MCC] = Acc(n_layer,n_neroun,newPop,Trains,n_in,n_out,dim,Bias,train_ind,target,struct1);
        if newFit<pop(i).E
            pop(i).x = newPop;
            pop(i).E = newFit;
            if newFit < bestCurr
                bestCurr = newFit;
            end
        end
        %         SalpPositions= SalpPositions';
    end



    Pre_pop = pop;

    MD = sum([pop.x])/PopSize;

    TF = round(1+rand);

    % Select Foodfitness -----------------------
    [~,indm] = min([pop.E]);
    Foodfitness = pop(indm).x;


    for i=1 : PopSize
        newPop = pop(i).x + rand(1,dim).*(Foodfitness - TF*MD);


        for ii = 1:dim
            if newPop(ii)<lb
                newPop(ii) = (2*lb) - newPop(ii);
            elseif newPop(ii)>ub
                newPop(ii) = (2*ub) - newPop(ii);
            end
        end

        [newFit,pop(i).Fscore,pop(i).MCC] = Acc(n_layer,n_neroun,newPop,Trains,n_in,n_out,dim,Bias,train_ind,target,struct1);
        if newFit<pop(i).E
            pop(i).x = newPop;
            pop(i).E = newFit;
            if newFit < bestCurr
                bestCurr = newFit;
            end
        end
    end


    for i=1:PopSize

        if rand<Pc
            jj = randi(PopSize);
            newPop = pop(i).x+(rand*(pop(indTeach(i)).x-pop(i).x))+...
                rand*(pop(jj).x-pop(i).x);


            for ii = 1:dim
                if newPop(ii)<lb
                    newPop(ii) = (2*lb) - newPop(ii);
                elseif newPop(ii)>ub
                    newPop(ii) = (2*ub) - newPop(ii);
                end
            end
            [newFit,pop(i).Fscore,pop(i).MCC] = Acc(n_layer,n_neroun,newPop,Trains,n_in,n_out,dim,Bias,train_ind,target,struct1);
            if newFit<pop(i).E                                     % Comparision
                pop(i).x = newPop;
                pop(i).E = newFit;
                if newFit < bestCurr
                    bestCurr = newFit;
                end
            end
        else

            A = 1:PopSize;
            A(i)=[];
            j = A(randi(PopSize-1));

            step = pop(i).x - pop(j).x;
            if pop(j).E < pop(i).E
                step = -step;
            end
            newPop = pop(i).x + rand(1,dim).*step;               % Teaching (moving towards teacher)
            %             newPop = max(min(newPop,ub_rep),lb_rep);             % Clipping
            for ii = 1:dim
                if newPop(ii)<lb
                    newPop(ii) = (2*lb) - newPop(ii);
                elseif newPop(ii)>ub
                    newPop(ii) = (2*ub) - newPop(ii);
                end
            end
            [newFit,pop(i).Fscore,pop(i).MCC] = Acc(n_layer,n_neroun,newPop,Trains,n_in,n_out,dim,Bias,train_ind,target,struct1);
            if newFit<pop(i).E                                     % Comparision
                pop(i).x = newPop;
                pop(i).E = newFit;
                if newFit < bestCurr
                    bestCurr = newFit;
                end
            end
        end


        if Pre_pop(i).x ~= pop(i).x
            newPop = pop(i).x+ (rand*(pop(i).x-Pre_pop(i).x));

            for ii = 1:dim
                if newPop(ii)<lb
                    newPop(ii) = (2*lb) - newPop(ii);
                elseif newPop(ii)>ub
                    newPop(ii) = (2*ub) - newPop(ii);
                end
            end
            [newFit,pop(i).Fscore,pop(i).MCC] = Acc(n_layer,n_neroun,newPop,Trains,n_in,n_out,dim,Bias,train_ind,target,struct1);
            % Evaluation
            if newFit<pop(i).E                                     % Comparision
                pop(i).x = newPop;
                pop(i).E = newFit;
                if newFit < bestCurr
                    bestCurr = newFit;
                end
            end
        else
            newPop = normrnd((Foodfitness-MD)/2,abs(Foodfitness-rand*(MD)));

            for ii = 1:dim
                if newPop(ii)<lb
                    newPop(ii) = (2*lb) - newPop(ii);
                elseif newPop(ii)>ub
                    newPop(ii) = (2*ub) - newPop(ii);
                end
            end

            [newFit,pop(i).Fscore,pop(i).MCC] = Acc(n_layer,n_neroun,newPop,Trains,n_in,n_out,dim,Bias,train_ind,target,struct1);
            if newFit<pop(i).E                                     % Comparision
                pop(i).x = newPop;
                pop(i).E = newFit;
                if newFit < bestCurr
                    bestCurr = newFit;
                end
            end

        end
    end

    if (mod(Epoch,M)==0)

        [neighbour] = Find_neighbour3(PopSize);

        for ii=1:PopSize

            Neigh = neighbour(ii).index;

            Fit = [pop(Neigh).E];
            [teacher(ii),ind] = min(Fit);
            indTeach(ii) = Neigh(ind);
        end
    end


    [g_fit,indd] = min([pop.E]);

    g_best = pop(indd).x;

    if g_fit < bestCurr
        bestCurr = g_fit;
    end

end

[EE,F1ScoreMacro,MCC] = Exprimental(n_layer,n_neroun,g_best,Tests,n_in,n_out,target_test,test_ind,struct2);

end
