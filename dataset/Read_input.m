function [x,y,n_in,n_out,Name_matfile]=Read_input()

help Read_input.m
fprintf('___________________________________________________________________\n');
fprintf('     Dataset        Examples       Features        Classes        \n');        
fprintf('___________________________________________________________________\n');
fprintf('    1. Iris           150             4               3  \n');
fprintf('    2. Diabetes       768             8               2  \n');
fprintf('    3. Thyroid        7200            21              3  \n');
fprintf('    4. Cancer         699             10              2  \n');
fprintf('    5. Card           690             15              2  \n');
fprintf('    6. Glass          214             10              6  \n');
fprintf('___________________________________________________________________\n');
 mynumber = input('\nEnter a number of Data set:');
switch mynumber
    case 1
        Data = load('dataset/iris.data');
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 4;
        n_out=3;
        Name_matfile = 1;
        
    case 2
        Data = load('dataset/pima-indians-diabetes.data');
        x = Data(:,1:end-1);
        y = Data(:,end);
        d = find(y==0);
        y(d) = y(d)+2;
        n_in = 8;
        n_out = 2;
        Name_matfile = 2;
        
    case 3
        Data1 = load('dataset/ann-train.data');
        Data2 = load('dataset/ann-test.data');
        Data = [Data1;Data2];
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 21;
        n_out = 3;
        Name_matfile = 3;
     
    case 4
        Data = load('dataset/breast-cancer-wisconsin.data');
        x = Data(:,1:end-1);
        y = Data(:,end);
        k = find(y==2);
        y(k) = 1;
        k = find(y==4);
        y(k) = 2;
        n_in = 10;
        n_out = 2;
        Name_matfile = 4;
        
    case 5
       Data = load('dataset/card.txt');
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 15;
        n_out = 2;
        Name_matfile = 5;
        
    case 6
        Data = load('dataset/glass.data');
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 10;
        n_out = 6;
        Name_matfile = 6;
        
    case 7
        Data = load('dataset/zoo.data');
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 16;
        n_out = 7;
        Name_matfile = 7;
        
    case 8
        Data = load('dataset/heart.txt');
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 13;
        n_out = 2;
        Name_matfile = 8;
    case 9
        Data = load('dataset/wine.data');
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 13;
        n_out = 3;
        Name_matfile = 9;
        
        case 10
        Data = load('dataset/page_blocks.data');
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 10;
        n_out = 5;
        Name_matfile = 10;
        
    case 11
        Data = load('dataset/liver.txt');
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 6;
        n_out = 2;
        Name_matfile = 11;
        
    case 12
        Data = load('dataset/hepatite.txt');
        x = Data(:,1:end-1);
        y = Data(:,end);
        n_in = 6;
        n_out = 2;
        Name_matfile = 11;
        
    otherwise
        error('only six Daraset');
end
end