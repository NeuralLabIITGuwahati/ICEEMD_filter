function extracttrials_raw(indir, outfile,imf_channels)
%
% extracttrials(indir, outfile)
%
% Extracts single trials from the files in *indir* and writes them to 
% *outfile*.
%
% Example: extracttrials('subject1\session1','s1')

% Author: Ulrich Hoffmann - EPFL, 2006
% Copyright: Ulrich Hoffmann - EPFL


%% scan indir for input files
d = dir(indir);
filelist = {};
for i = 1:length(d)
   if(d(i).isdir == 0)
       filename = sprintf('%s\\%s',indir,d(i).name);
       filelist = cat(2,filelist,{filename});
   end
end
fprintf('found %i files ...\n',length(filelist));


%% initialize variables
runs = cell(1,length(filelist));
srate = 2048;% sampling rate of raw data in Hz
fs = 2048; % target sampling rate

reference = [7 24]; %1:32;         % indices of channels used as reference

decimation = srate/fs;                   % downsampling factor
n_samples  = fs;                   % number of (temporal) samples in a trial
n_targets = 0;                     % keeps track of number of target trials 
n_nontargets = 0;                  % keeps track of nontarget trials 


%% extract features from files in filelist
for i = 1:length(filelist)
    
    % load data
    f = load(filelist{i});
    fprintf('processing %s\n',filelist{i});
    
    % rereference the data
    n_channels = size(f.data,1);
    ref = repmat(mean(f.data(reference,:),1),n_channels,1);
    f.data = f.data - ref;

    % drop the mastoid channels
    f.data = f.data(1:32,:);
    n_channels = size(f.data,1);
    
    % downsample the data (from 2048 Hz to 64 Hz)
    f.data = f.data(:,1:decimation:end);
    
    % extract trials 
    % compute class labels
    % put everything in the cell-array runs
    n_trials = size(f.events,1);
    runs{i}.x = zeros(n_channels,n_samples,n_trials);
    for j = 1:n_trials
        pos = round(etime(f.events(j,:), ...
                         f.events(1,:))*(srate/decimation) ...
                         + 1 + 0.4*srate/decimation) ;
        runs{i}.x(:,:,j) = f.data(:,pos:pos+n_samples-1);
    end
    runs{i}.y = zeros(1,n_trials);
    runs{i}.y(f.stimuli == f.target) =  1;
    runs{i}.y(f.stimuli ~= f.target) = -1;
    runs{i}.stimuli = f.stimuli;
    runs{i}.target  = f.target;

    % update counters
    n_targets = n_targets + sum(runs{i}.y == 1);
    n_nontargets = n_nontargets + sum(runs{i}.y == -1);    

end


%% save results in outfile
fprintf('total target trials: %i\n',n_targets);
fprintf('total nontarget trials %i\n',n_nontargets);
save(outfile,'runs');