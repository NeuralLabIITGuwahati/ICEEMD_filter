function raweeg_iceemdmodes(indir,modefile)

% Uses files in *filelist* to build a calculate ICEEMD modes for each
% single trial for channel Cz (channel 32) and saves it into a mat file
% with the name given in 'modefile'
% The files in *filelist* have to be built with extracttrials_modified.
%
% Example: raweeg_iceemdmodes({'d1','d2','d3','d4'},"subject_modes.mat");

% Author: Srihari Madhavan, 2021

tic; % timer to check time taken for processing


eegdata ={};
eegmodes = {};
eventslist = {};
NR = 200;

k=1;
for i = 1:length(indir)
    fprintf('loading %s\n',indir{i});
     load(indir{i});
    n_runs = length(runs);
    for cc = 1:n_runs;
       runs{cc}.elabel = strcat(indir{i}," rec ",num2str(cc)); 
    end
    eegdata = [eegdata runs]; % Store entire raw EEG data in a single file
    
end
clear runs;

fprintf('found %i files ...\n',length(indir));


%% Precalculate white noise modes for ICEEMD

for i=1:NR
    white_noise{i}=randn(1,2048);%creates the noise realizations
end;

fprintf('White noise iterations generated\n');

for i=1:NR
    modes_white_noise{i}=emd(white_noise{i});%calculates the modes of white gaussian noise
    
end;
fprintf('White noise mode iterations generated\n');
%% Find the ICEEMD IMFs for each trials from array and save to a .mat file

for i = 1:length(eegdata)
 
    fprintf('\n');

    for j = 1: size(eegdata{i}.x,3)
        % calculate modes for each trial and store it
    [eegmodes{i}.array{j}.modes,~] = ICEEMD_wn(eegdata{i}.x(32,:,j),...
                                        0.2,NR,modes_white_noise,8000,2);
    fprintf("modes of %dth trial in %d session calculated\n",j,i);
    end
    eegmodes{i}.elabel = eegdata{i}.elabel;
    % save with each session as a precaution (optional)
    %save(modefile,'eegmodes'); 
end
elapsed_time = toc;
save(modefile,'eegmodes','elapsed_time'); %save the eegmodes along with elapsed time
end
