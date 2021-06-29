function sigfrommodes(filelist,raweegmodes)

% Uses files in *raweegmodes* to calculate the filtered signal and pack it
% into the appropriate position in the *filelist*
% The files in *filelist* have to be built with extracttrials_modified.
%
% Example: sigfrommodes({'s1','s2','s3','s4'},"subject_modes.mat");

% Author: Srihari Madhavan, 2021


load(raweegmodes);
fs = 2048; % Sampling rate and length of each trial
sessind = 0;
for i = 1:length(filelist)
    fprintf('loading %s\n',filelist{i});
     load(filelist{i});
    n_runs = length(runs);
    
        
    for j = 1:n_runs
        ntrials = size(runs{j}.x,3);
        for k = 1:ntrials
            % imf bandpower
            t_modes = eegmodes{sessind+1}.array{k}.modes;
            
            % construct the filtered signal
            sig = emdfilter(t_modes,fs);
            
%%
           % downsample and package it into appropriate run
            sig = sig(1:64:end);
            runs{j}.x(32,:,k) = sig;
        end
        sessind = sessind+1;
    end
    %save packed runs into filelist
    save(filelist{i},'runs');
    clear runs;
end
fprintf('\n Packing done\n');
end

% function to calculate filter
function filt_sig = emdfilter(t_modes,fs)

imf_bandpower = zeros(size(t_modes,1),1);
            imf_entropy = zeros(size(t_modes,1),1);
            for z = 1:size(imf_bandpower)
                
                imf_bandpower(z) = bandpower(t_modes(z,:),fs,[1 12]);
                imf_bandpower(z) =  imf_bandpower(z)/bandpower(...
                    t_modes(z,:),fs,[0 fs/2]) ;
                %entropy calculated to check information content
                imf_entropy(z) = wentropy(t_modes(z,:),'shannon');
                
            end
            
            
            nmod = imf_bandpower>0.7;
            
            filt_sig = sum(t_modes(nmod,:),1);
end




