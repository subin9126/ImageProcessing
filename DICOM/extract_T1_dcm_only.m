%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Original name: 'Extract_T1_DICOM_only_190123.m'
% Code for extracting DICOM of T1 only from each subject.
% Reads modality of DICOM files of each subject (has T1,T2,FLAIR,DTI), and brings if T1.
%
% Note.
% 1. Most subjects will have either 175 or 324(?) dicom files
%    Subjects with 199 files are likely those who also have T1_GD files.
%    These should be collectively removed manually later.
%
% 2018.09.14. SB MODI (for efficiency)
% * Original code takes a long time because it scans all dicom files (esp DTI)
%
% * Usually, subjects have dicom files in this order:
%   (A) DTI-T2-FLAIR-T1
%   (B) T1 - ~~~
%
% * In the case of A (first file is DTI), we assume that DTI dicom files
%   will be at least 1200+ files, so we skip immediately to the 1200th file
%   and start scanning from there
%
% * In the case of B (first file is T1), we start scanning from the first
%   file.
%
% * In both cases, once we have at least 175 T1 dicom files and the next
%   dicom file is NOT a T1, we exit the loop and move onto the next subject.
%
% * These help avoid unnecessarily scanning all files and speeds up the
%   process.
%  
% ** This code also saves folder name of subject who had less than 100
%   dicom files into 'Less_than_100_files_subj' variable. 
%    MUST LOOK AT THIS VARIABLE EACH TIME I RUN THIS CODE
%
% 2019.01.23. SB MODI (for convenience)
% ** Copy of the code 'code_SAVE_only_T1_ws1_ver2_1.m'. Renamed to 'Extract_T1_DICOM_only_190123.m'
% ** Also, changed input method so that I copypaste the subjects'
%    cerad_mridate and folder to a pre-saved .mat file that will be loaded.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

%%%%%%%%Change Accordingly%%%%%%%%

DATA_DIR = '/media/mri_dicom_mnt';
SV_DIR = '/media/ws1/DATA/NIPA2018/SNUBH_DATA_Year2/190807_NEW_for_700-700SET'; 
startidx = 3; %In case want to start running list again from certain subject

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('/home/ws1/matlab/NIPA_matlab/Subjects_for_DCM_Extraction.mat');

% cerad_in and folder_in are initially 1x1 cell array variables, into which
% I will copypaste directly from excel sheets (paste as tabular data).
%       To reset after each use, type as below and save the .mat file again.
%       cerad_in = cell(1,1); folder_in = cell(1,1);
% Check if mridates of both cerad_in and folder_in are equal (to double-check):
for check = 1:length(cerad_in)
    if strcmp(cerad_in{check}(end-5:end),folder_in{check}(end-5:end)) == 0
        fprintf('**Dates of cerad_in and folder_in in line %i do not match. Re-check inputs** \n', check)
        return;
    else
        
    end
end     
        
CERADMRIDATE_DB = cerad_in;  
FOLDER_DB = folder_in;

LNG_DB = length(CERADMRIDATE_DB);
Less_than_100_files_subj = {};


for idx = startidx:LNG_DB
    
    fprintf('=====Doing Subject %d of %d ===== \n',idx, LNG_DB)
    
    FOLDER = []; FOLDER = FOLDER_DB{idx};
    SUBJ_DIR = []; SUBJ_DIR = CERADMRIDATE_DB{idx};
    
    make_dir_1 = []; make_dir_1 = [SV_DIR, '/', SUBJ_DIR];
    eval(sprintf('mkdir(make_dir_1)'))
    
    HOSPNUM_START = []; HOSPNUM_START = FOLDER(1:2);
    BRING_PTH = []; BRING_PTH = [DATA_DIR, '/', HOSPNUM_START, 'XXXXXX/', FOLDER ];
    %BRING_PTH = [DATA_DIR, '/',*,'/', FOLDER ];
    
    
    ALL_DCM = []; ALL_DCM = dir([BRING_PTH,'/IM*']);
    if isempty(ALL_DCM)
        ALL_DCM = dir([BRING_PTH, '/im*']);
        if isempty(ALL_DCM)
            ALL_DCM = dir([BRING_PTH, '/FILE*']);
            if isempty(ALL_DCM)
               ALL_DCM = dir([BRING_PTH, '/*.DCM']); 
            end
        end
    end
    
    eval(sprintf('cd %s', SV_DIR))
    num_ALL_DCM = []; num_ALL_DCM = length(ALL_DCM);
    count = 0;
    
    
    if num_ALL_DCM < 100
        fprintf('====Subject %s has less than 100 dcm files==== \n', SUBJ_DIR)
        Less_than_100_files_subj = [Less_than_100_files_subj; SUBJ_DIR];      
    else
        % File information
        first_file = []; first_file = [BRING_PTH '/' ALL_DCM(1).name];
        firstinfo = []; firstinfo = dicominfo(first_file);
        IsDTI = ~isempty(strfind(firstinfo.ProtocolName,'DTI'));
        
        % A. If first file is DTI, skip to about 1200th file
        if IsDTI == 1
            for idx2 = 1250:num_ALL_DCM %In some cases, will have to run with from 1st!
                % Scan for protocol (and display)
                file_name = []; file_name = [BRING_PTH '/' ALL_DCM(idx2).name];
                info = []; info = dicominfo(file_name);
                            
                fprintf('file %d of %d is ', idx2, num_ALL_DCM); display(info.ProtocolName)
                
                % If T1 DICOM, bring
                IsT1 = ~isempty(strfind(info.ProtocolName,'T1'));
                if IsT1 == 1
                    count = count+1;
                    SAVE_NAME = []; SAVE_NAME = sprintf('%s//IM%05d.dcm', make_dir_1, count);
                    copyfile(file_name, SAVE_NAME);
                    fprintf('current count %d \n', count)
                    
                end
                
                % If no more T1 DICOM appears, get out of loop,
                % and move to next subject
                if count >=175 && ~isempty(strfind(info.ProtocolName,'T1'))==0
                    break
                end 
            end
            clear idx2
            
        % B. If first file is not DTI, just start scanning from the first file    
        elseif IsDTI == 0 
            for idx3 = 1:num_ALL_DCM
                % Scan for protocol (and display)
                file_name = []; file_name = [BRING_PTH '/' ALL_DCM(idx3).name];
                info = []; info = dicominfo(file_name);
                
                fprintf('file %d of %d is ', idx3, num_ALL_DCM); display(info.ProtocolName)            
                
                % If T1 DICOM, bring
                IsT1 = ~isempty(strfind(info.ProtocolName,'T1'));
                if IsT1 ==1
                    count = count+1;
                    SAVE_NAME = []; SAVE_NAME = sprintf('%s//IM%05d.dcm', make_dir_1, count);
                    copyfile(file_name, SAVE_NAME);
                    fprintf('current count %d \n', count)
                end
                  
                % If no more T1 DICOM appears, get out of loop, 
                % and move to next subject
                if count >=175 && ~isempty(strfind(info.ProtocolName,'T1'))==0
                    break
                end
            end
            clear idx3
        end
        
 
        
    end %end subject
end %end current batch of subjects

% lessthan100listname = strcat( num2str(min(idx)))
% save(Less_than_100_files_subj, lessthan100listname)

