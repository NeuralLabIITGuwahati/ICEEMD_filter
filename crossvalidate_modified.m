function [accuracy,x]=crossvalidate_modified(filelist)
%
% Modified Hoffman's crossvalidate(filelist) function
% 
% Uses n - 1 of the n files in *filelist* to build a classifier and tests the 
% classifier on the left-out file. This is done once for each file and 
% results are averaged. Average classification accuracy and bitrate are plotted.
% The files in *filelist* have to be built with extracttrials.
%
% Example: crossvalidate({'s1','s2','s3','s4'})

% Author: Ulrich Hoffmann - EPFL, 2006
% Copyright: Ulrich Hoffmann - EPFL

%% 



%% do the crossvalidation
n_correct = zeros(length(filelist),20);
figure
for i = 1:length(filelist)
    trainingfiles = filelist;
    trainingfiles(i) = [];
    subplot(floor(length(filelist)/2),2,i)
    n_correct(i,:) = testclassification_modified(trainingfiles,filelist{i});    
end



%% plot the results
accuracy = mean(n_correct) / 6;    % each file contains six runs
br = bitrate(accuracy);
x = 2.4:2.4:48;

figure
for i = 1:length(filelist)
   subplot(floor(length(filelist))/2,2,i) 
   
   plot(n_correct(i,:));
   title("Session "+num2str(i));
   ylim([0 6]);
   xlabel("Block Number")
   ylabel("No. of correct predictions")
   grid on
end




%% function to compute bits / min from classification accuracy
function br = bitrate(accuracy)

for i = 1:length(accuracy)
    if accuracy(i) > 0 && accuracy(i) < 1
       br(i) = log2(6) + accuracy(i)*log2(accuracy(i)) + ...
               (1-accuracy(i))*log2((1-accuracy(i))/5); 
    end
    if accuracy(i) == 0
        br(i) = 0;
    end
    if accuracy(i) == 1
        br(i) = log2(6);
    end
end

br = br*60./(2.4:2.4:48);