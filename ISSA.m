function [FoodFitness,numOfFeature,CE,CF,CM]=ISSA(train,test)

CostFunction=@(s) FeatureSelectionCost(s,train, test);     % Cost Function

dim = size(train,2);       % Number of Decision Variables
threshold = floor(dim/2);

dim = dim-1;
% VarSize = [1 dim];   % Decision Variables Matrix Size

VarMin = -1;       % Unknown Variables Lower Bound
VarMax = 1;       % Unknown Variables Upper

ub=ones(dim,1)*VarMax;
lb=ones(dim,1)*VarMin;


%% TLBO Parameters

Max_iter = 100;        % Maximum Number of Iterations

PopSize = 50;           % Population Size
IC = 0;
allowedLimit = 3;
z = 0.03;

% Convergence_curve = zeros(1,Max_iter);

%% Initialization

% Empty Structure for Individuals
empty_individual.Position = [];
empty_individual.BPosition = [];

empty_individual.Cost = [];
empty_individual.Fs = [];
empty_individual.Mcc = [];
empty_individual.Out=[];

% Initialize Population Array
pop = repmat(empty_individual, PopSize, 1);


if isscalar(VarMin)
    VarMin = VarMin * ones(1, dim);
end
if isscalar(VarMax)
    VarMax = VarMax * ones(1, dim);
end

% Initialize Population Members
for i = 1:PopSize

    pop(i).Position = rand(1, dim).*(VarMax-VarMin)+VarMin;
    pop(i).BPosition = Mappingg(pop(i).Position);

    [pop(i).Cost,~,~, pop(i).Out]=CostFunction(pop(i).BPosition);

end

Costs = [pop.Cost];

% Sort Costs and Get Sorting Indices
[~, SortOrder] = sort(Costs);

% Reorder Population Based on Sorted Indices
pop = pop(SortOrder);

Conv_curve_E = inf*ones(1,Max_iter);
Con_curve_Fs = zeros(1,Max_iter);
Con_curve_Mcc = zeros(1,Max_iter);

%Main loop
Iter = 2;
while Iter<Max_iter+1

    values = [pop.Cost];
    [~, idx] = min(values);
    [~, idmx] = max(values);

    FoodPosition = pop(idx).Position;
    FoodFitness = pop(idx).Cost;
    %     FoodBPosition = pop(idx).BPosition;
    PosWrost = pop(idmx).Position;

    currentBest = FoodFitness;
    %currentBestPos = FoodPosition;

    c1 = 2*exp(-(4*Iter/Max_iter)^2);

    for i=1:PopSize
        newPop = zeros(1,dim);

        if i == 1
            UbBest = max(FoodPosition);
            LbBest = min(FoodPosition);
            PosNB = rand(1,dim).*(UbBest-LbBest)+LbBest;

            for j=1:1:dim
                c2=rand();
                c3=rand();
                %%%%%%%%%%%%% % Eq. (3.1) in the paper %%%%%%%%%%%%%%
                if c3<z && c3>0
                    newPop(j) = FoodPosition(j)+c1*(PosNB(j)-PosWrost(j));

                elseif c3>=z
                    newPop(j) = FoodPosition(j)+c1*((ub(j)-lb(j))*c2+lb(j));

                elseif c3<0
                    newPop(j) = FoodPosition(j)-c1*((ub(j)-lb(j))*c2+lb(j));
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            end

            newBPop = Mappingg(newPop);
            [newFit, newFS,newMCC,~] = CostFunction(newBPop);

            if newFit<pop(i).Cost
                pop(i).x = newPop;
                pop(i).Cost = newFit;
                pop(i).Fs = newFS;
                pop(i).Mcc =newMCC;
            end
        else
            point1=pop(i-1).Position;
            point2=pop(i).Position;

            newPop  = (point2+point1)/2;

            newBPop = Mappingg(newPop);
            [newFit, newFS, newMCC, ~] = CostFunction(newBPop);

            if newFit<pop(i).Cost
                pop(i).x = newPop;
                pop(i).Cost = newFit;
                pop(i).Fs = newFS;
                pop(i).Mcc =newMCC;
            end
        end

        %         SalpPositions= SalpPositions';
    end



    values = [pop.Cost];
    [~, idx] = min(values);


    FoodPosition = pop(idx).Position;
    FoodFitness = pop(idx).Cost;
    FoodBPosition = pop(idx).BPosition;
    FoodFs =  pop(idx).Fs;
    FoodMcc =  pop(idx).Mcc;


    newBest = FoodFitness;
    %nweBestPos = FoodPosition;

    if newBest == currentBest
        IC = IC+1;
    end

    flag = 'false';

    if IC >= allowedLimit
        %% Local search algorithm
        flag = 'false';
        Temp = FoodBPosition;
        Tempf = FoodFitness;
        L1 = 1;
        MaxL = 10;

        while (L1<MaxL)

            NF =  randi([2,threshold ], 1, 1);

            j = randi(dim,1,NF);
            if Temp(j)==1
                Temp(j) = 0;
            else
                Temp(j) = 1;
            end
            [Tempfit,TempFs,TempMcc, ~]=CostFunction(Temp);

            if Tempfit<Tempf
                FoodBPosition = Temp;
                FoodFitness = Tempfit;
                FoodFs = TempFs;
                FoodMcc = TempMcc;
                flag = 'true';
                break;
            end
            L1 = L1+1;
        end

    end

    pop(idx).Position = FoodPosition;
    pop(idx).BPosition = FoodBPosition;
    pop(idx).Cost = FoodFitness;
    pop(idx).Fs = FoodFs;
    pop(idx).Mcc = FoodMcc;
    indTeach = zeros (1,PopSize);

    if strcmp(flag, 'false')

        [neighbour] = Find_neighbour(pop);

        for ii=1:PopSize

            Neigh = neighbour(ii).index;

            Fit = [pop(Neigh).Cost];

            [~,ind] = min(Fit);
            indTeach(ii) = Neigh(ind);
        end

        for i=2:PopSize

            newPop = pop(i).Position+rand*(FoodPosition-pop(i).Position)+rand*(pop(indTeach(i)).Position-pop(i).Position);

            newBPop = Mappingg(newPop);
            [newFit,newFS,newMCC, ~] = CostFunction(newBPop);

            if newFit<pop(i).Cost
                pop(i).x = newPop;
                pop(i).Cost = newFit;
                pop(i).Fs = newFS;
                pop(i).Mcc =newMCC;
            end

        end
    end

    values = [pop.Cost];
    [~, idx] = min(values);


    %     FoodPosition = pop(idx).Position;
    FoodFitness = pop(idx).Cost;
    FoodBPosition = pop(idx).BPosition;


    FscB = pop(idx).Fs;
    MccB = pop(idx).Mcc;


    if FoodFitness < Conv_curve_E(Iter-1)
        Conv_curve_E(Iter) = FoodFitness;
        Con_curve_Fs(Iter) = FscB;
        Con_curve_Mcc(Iter) = MccB;
    else
        Conv_curve_E(Iter) = Conv_curve_E(Iter-1);
        Con_curve_Fs(Iter) = Con_curve_Fs(Iter-1);
        Con_curve_Mcc(Iter) = Con_curve_Mcc(Iter-1);

    end

    disp (num2str(Conv_curve_E(Iter)));
    numOfFeature = numel(find(FoodBPosition==1));
    Iter = Iter + 1;
end

CE = Conv_curve_E(end);
CF = Con_curve_Fs(end);
CM = Con_curve_Mcc(end);
