function [Data, data, Name_matfile, x, y] = Read_input()


datasets = {
    'Vertebral', 'dataset/vertebral.dat';
    'Liver', 'dataset/liver.txt';
    'Ionosphere', 'dataset/ionosphere.data';
    'Credit', 'dataset/card.txt';
    'Spambase', 'dataset/spambase.data';
    'Heart', 'dataset/heart.txt';
    'Breast Cancer Wisconsin', 'dataset/breast-cancer-wisconsin.data';
    'SPECT', 'dataset/SPECT.data';
    'Vote', 'dataset/vote.data';
    'Australian', 'dataset/australian.dat';
    'Dermatology', 'dataset/dermatology.data';
    'Satellite', 'dataset/sattrn.data';
    'Waveform', 'dataset/waveform.data';
    'Sonar', 'dataset/sonar.all-data';
    'Biodeg','dataset/biodeg.txt';
    'Ceramic','dataset/Ceramic.csv'
    };


fprintf('Choose a dataset from the following list:\n');
for i = 1:size(datasets, 1)
    fprintf('%d: %s\n', i, datasets{i, 1});
end
mynumber = input('\nEnter a number to choose a Data set: ');


if mynumber < 1 || mynumber > size(datasets, 1)
    error('Invalid choice. Please choose a valid dataset.');
end


datasetName = datasets{mynumber, 1};
filePath = datasets{mynumber, 2};


disp([datasetName, ' Data']);
Data = load(filePath);
% Data = Data';

if mynumber == 12
    p1 = load('dataset/sattrn.data');
    p2 = load('dataset/sattst.data');
    Data = [ p1;p2];
end



if mynumber==16

    Data(:, [2, end]) = Data(:, [end, 2]);
     x = (Data(:, 1:end-1));
    y = (Data(:, end));
%     y = (Data(:, 2));
%     Data(:, 2)=[];
%     x = Data;

elseif mynumber==5

    x = (Data(:, 1:end-1));
    y = (Data(:, end));

    k = find(y==0);
    y(k) = 2;
    Data = [x y];
    
elseif mynumber==8

    x = (Data(:, 1:end-1));
    y = (Data(:, end));

    k = find(y==0);
    y(k) = 2;
    Data = [x y];

elseif mynumber==9

    x = (Data(:, 1:end-1));
    y = (Data(:, end));

    k = find(y==0);
    y(k) = 2;
    Data = [x y];

elseif mynumber==10

    x = (Data(:, 1:end-1));
    y = (Data(:, end));

    k = find(y==0);
    y(k) = 2;
    Data = [x y];

elseif mynumber==13

    x = (Data(:, 1:end-1));
    y = (Data(:, end));

    k = find(y==0);
    y(k) = 3;
    Data = [x y];


else

    x = (Data(:, 1:end-1));
    y = (Data(:, end));
end


% تنظیم داده‌ها
data.x = x;
data.t = y;
data.nx = size(x, 1);
data.nt = size(y, 1);
data.nSample = size(x, 2);
Name_matfile = mynumber;

end
