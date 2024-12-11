function [Data, data, Name_matfile, x, y] = Read_input()


datasets = {
    'Vertebral', 'dataset/vertebral.dat';
    'Liver', 'dataset/liver.txt';
    'Ionosphere', 'dataset/ionosphere.data';
    'Credit', 'dataset/card.txt';
    'Spambase', 'dataset/spambase.data';
    'Heart', 'dataset/heart.txt';
    'Breast Cancer Wisconsin', 'dataset/lymphography.data';
    'SPECT', 'dataset/SPECT.train';
    'Vote', 'dataset/vote.data';
    'Australian', 'dataset/australian.dat';
    'Dermatology', 'dataset/dermatology.data';
    'Satellite', 'dataset/sat.trn';
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
Data = Data';

if mynumber==16
    y = (Data(:, 2));     
    Data(:, 2)=[];
    x = Data;
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
