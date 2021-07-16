% clc
% clear

%% Trials with IMF filter (by hari) 

imf_channels = [32]; % EEG channels for analysis
sublist = [1:4 6:9]; % Total sublist
trialfilelist = {}; %File list to store the sessions
setpath %set path to folder to access utility functions
sample_sublist = [4,6,7,8,9]; % subject to analyse
accuracy_12hz = [];  % Hoffman's accuracy
accuracy_imf = [];  % IMF filter accuracy

for i = sample_sublist 
    
   for j = 1:4
      trialfilelist{j} = "s" + num2str(i)+num2str(j);     
   end


    
    %% ---------------------------------------------------------------
    %% Package filtered signal into trial run matrix

   
    
    for t = 1:4
    extracttrials("subject"+num2str(i)+"\session"+num2str(t)+"\",trialfilelist{t})
   
    end
   
    %% Calculate performance of original Butterworth Filter for comparison
    % 
    [accuracy,x]=crossvalidate_modified(trialfilelist); %crossvalidate and store accuracies
    accuracy_12hz = [accuracy_12hz; accuracy];
    %% ---------------------------------------------------------------
       
    % Extract raw 2048 Hz signal into trials
     for t = 1:4
    extracttrials_raw("subject"+num2str(i)+"\session"+num2str(t)+"\",trialfilelist{t})
   
     end
     
    %Calculate ICEEMD modes for each trial.
    raweeg_iceemdmodes(trialfilelist,"iceemd_sub"+num2str(i)+"raw.mat");  %
    
    %% ---------------------------------------------------------------
    % Packages filtered signal from IMFs into the trial signals
    
    for t = 1:4
    extracttrials("subject"+num2str(i)+"\session"+num2str(t)+"\",trialfilelist{t})
   
    end
   
    sigfrommodes(trialfilelist,"iceemd_sub"+num2str(i)+"raw"); % Pack signal
   
    
    %% Calculate performance of IMF Filter and store accuracies
    [accuracy,x]=crossvalidate_modified(trialfilelist); 
    accuracy_imf = [accuracy_imf ; accuracy];
end  
    %% ---------------------------------------------------------------
    % Plot Accuracies of IMF filter and hoffmans filter
    figure
    plot(x,100*mean(accuracy_imf),'-x','LineWidth',1.5);
    hold on
    plot(x,100*mean(accuracy_12hz),'-o','LineWidth',1.5)
    grid on
    xlabel("Time (s)");
    ylabel("Accuracy (%)");
    title("Subject "+num2str(sample_sublist)+": Performance comparison")
    legend(["ICEEMD filter","Original Filter"],'Location','northwest')
    hold off


