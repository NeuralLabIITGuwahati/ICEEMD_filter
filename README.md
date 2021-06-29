# ICEEMD_filter
An ICEEMD implementation as a filter for single channel P300 data.

**Requisites**

1.	Hoffmans Subject data, utilities and codes [1]
2.	Improved Complete Ensemble EMD codes [2]
3.	Following Matlab codes (Algorithm_test,  ICEEMD_wn, extracttrials_raw, emd, crossvalidate_modified, testclassification_modified,  raweeg_iceemdmodes, sigfrommodes)


**Folder placement**

The MATLAB files (including Hoffmans codes) needs to be place in the same folder as shown below.
Make sure the codes are in directory “\” , Subject data is in format “\subject\sessions\runs”.

**Important Matlab codes** 
(Note: For original Hoffman’s code info refer their readme document)

<ins>ICEEMD_wn</ins> : Modified ICEEMD code [2] with the white_noise modes being fed directly to the function to reduce redundancy and processing time
	
<ins>emd</ins> :  Function for calculating the IMF components in the ICEEMD_wn function
	
<ins>extracttrials_raw</ins> : Modified ‘extracttrials’ code from Hoffman’s, which extracts the EEG data from a session (as indicated by subject) and packages it into 1s long trials cell array in the native 2048 sampling frequency
	
<ins>raweeg_iceemdmodes</ins>: Function to take the packed 2048Hz EEG trials (created by extracttrials_hari) and calculates (IMF) ̅ modes of the trials and saves them to a cellarray whose name is given as input. [Note: This function is time consuming and takes 5-6 hours per subject (1-1.5 hours per session) to calculate the IMFs so please run them before hand if possible]
	 
<ins>sigfrommodes</ins> : Function to repack filtered signals, made by selectively merging 2 or more (IMF) ̅ modes into 32hz trial array. This selection is made by choosing IMFs that contains >70% of their power spectral density, within the desired bandwidth of 1-12 Hz
	
<ins>testclassification_modified</ins> : Modified testclassification codes of Hoffman’s [1], which returns a confusion chart of predictions, for a set of training files and test file.

<ins>crossvalidate_modified</ins> : Modified ‘crossvalidate’ file which returns the blockwise correct number of predictions made by the Bayesian-LDA in the trial file list provided as well as accuracies.
	
<ins>Algorithm_test:</ins> Test file to run and test the implementation of the IMF filtering for the EEG data.
  
**Example of usage**

	%% Trials with IMF filter (by hari) 

	imf_channels = [32]; % EEG channels for analysis


	setpath %set path to folder to access utility functions
	%% Extract raw 2048 Hz signal into trials

	sample_sublist = [4]; % subject to analyse


	for j = 1:4
	      trialfilelist{j} = "s" + num2str(sample_sublist)+num2str(j); %File list to store sessions

	end

	for j = 1:4
	      rawfilelist{j} = "d" + num2str(sample_sublist)+num2str(j); %File list to store raw sessions

	end


	%% Package filtered signal into trial run matrix

	for t = 1:4
	    extracttrials("subject"+num2str(i)+"\session"+num2str(t)+"\",trialfilelist{t})
	end

	%% Calculate performance of original Butterworth Filter for comparison

	[accuracy_12hz,x]=crossvalidate_modified(trialfilelist); %crossvalidate and store accuracies

	%% Package unfiltered raw signal into trial run matrix

	for t = 1:4
	    extracttrials_raw("subject"+num2str(i)+"\session"+num2str(t)+"\",trialfilelist{t})
	end


	%% Calculate the IMF modes for the trials and store to a .mat file
	raweeg_iceemdmodes (rawfilelist,'modes_sub8raw.mat');


	%% Packages filtered signal from IMFs into the trial signals
	sigfrommodes(trialfilelist,'modes_sub8raw'); % Pack signal

	%% Calculate performance of IMF Filter and store accuracies
	[accuracy_imf,x]=crossvalidate_modified(trialfilelist); 

References

[1]	U. Hoffmann, J. M. Vesin, T. Ebrahimi, and K. Diserens, “An efficient P300-based brain-computer interface for disabled subjects,” J. Neurosci. Methods, vol. 167, no. 1, pp. 115–125, 2008, doi: 10.1016/j.jneumeth.2007.03.005.
[2]	M. A. Colominas, G. Schlotthauer, and M. E. Torres, “Improved complete ensemble EMD: A suitable tool for biomedical signal processing,” Biomed. Signal Process. Control, vol. 14, no. 1, pp. 19–29, 2014, doi: 10.1016/j.bspc.2014.06.009.



