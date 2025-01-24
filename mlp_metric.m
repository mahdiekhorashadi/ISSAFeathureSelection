function [error_rate, weighted_precision, weighted_recall, weighted_f1_score, weighted_mcc] = mlp_metric(Train, train_label, Test, test_label)

    
    numInputs = size(Train, 2);
    numOutputs = numel(unique(train_label));
    hiddenLayerSizes = [round((numInputs + numOutputs) / 2)]; 

   
    maxEpochs = 1000;


    net = feedforwardnet(hiddenLayerSizes, 'trainlm'); 
    net.trainParam.epochs = maxEpochs; 
    net.trainParam.showWindow = false; 

    
    [Train, settings] = mapminmax(Train'); 
    Test = mapminmax('apply', Test', settings); 

    
    train_label_onehot = full(ind2vec(train_label'));

    
    net = train(net, Train, train_label_onehot);

    
    y_pred = net(Test);

   
    y_pred_classes = vec2ind(y_pred)';

   
    num_classes = max([train_label; test_label]);
    confusionMatrix = confusionmat(test_label, y_pred_classes, 'Order', 1:num_classes);

    
    TP = diag(confusionMatrix); % True Positives
    FP = sum(confusionMatrix, 1)' - TP; % False Positives
    FN = sum(confusionMatrix, 2) - TP; % False Negatives
    TN = sum(confusionMatrix(:)) - (TP + FP + FN); % True Negatives

    
    class_support = sum(confusionMatrix, 2);

   
    accuracy = sum(TP) / sum(confusionMatrix(:));
    error_rate = 1 - accuracy;

    precision = TP ./ (TP + FP);
    recall = TP ./ (TP + FN);
    f1_score = 2 * (precision .* recall) ./ (precision + recall);

    % MCC (Matthews Correlation Coefficient)
    mcc = (TP .* TN - FP .* FN) ./ sqrt((TP + FP) .* (TP + FN) .* (TN + FP) .* (TN + FN));

   
    precision(isnan(precision)) = 0;
    recall(isnan(recall)) = 0;
    f1_score(isnan(f1_score)) = 0;
    mcc(isnan(mcc)) = 0;

    
    weighted_precision = sum(precision .* class_support) / sum(class_support);
    weighted_recall = sum(recall .* class_support) / sum(class_support);
    weighted_f1_score = sum(f1_score .* class_support) / sum(class_support);
    weighted_mcc = sum(mcc .* class_support) / sum(class_support);
end
