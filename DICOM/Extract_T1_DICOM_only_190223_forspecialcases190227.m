%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Code for save only T1 and T2-FLAIR DICOM file
% 2018.06.18. DW
% 2018.08.29. DW MODI
% 2018.09.12. SB MODI (for WS1 environment)
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
%
% 2019.01.24. SB MODI (for cases where T1 dicoms are in another subfolder!)
% ** CHANGE subfolder variable ACCORDINGLY (depending on 00000001 folder, myelin, or T1 folder***
% ** Only does step B (does not skip to 1000th file if first file is DTI),
%    because in the case of these subfolders if there are DTIs there are
%    usually only partly (less than 1000 of them).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

%%%%%%%%Change Accordingly%%%%%%%%

DATA_DIR = '/media/mri_dicom_mnt';
SV_DIR = '/media/ws1/DATA/NIPA2018/SNUBH_DATA_Year2/190807_NEW_for_700-700SET';
% subfolder = 'T1_'; %'00000001' or '1' or 'T1_*' % ADDED 190124
startidx = 1; %In case want to start running list again from certain subject

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
    BRING_PTH1 = [];
    %%%%%%%%%%%%%%%%%%%%%%%%EDITED 190227%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    BRING_PTH1 = [DATA_DIR, '/', HOSPNUM_START, 'XXXXXX/', FOLDER];
    eval(sprintf('cd %s', BRING_PTH1))
    
    % Automatically extracts subfolder name in current subject folder.
    % If more than one subfolder, prompt user to choose which one
    subfolder_search = dir(BRING_PTH1);
    subfolder_search = subfolder_search(3:end);
    dirflags = find([subfolder_search.isdir]==1);
    if length(dirflags) == 1
        subfolder = subfolder_search(dirflags).name;
    elseif length(dirflags) >1
        subfolder_many = [];
        for s = 1:length(dirflags)
            subfolder_many{s,1} = subfolder_search(dirflags(s)).name;
        end
        IsT1dir = (strfind(subfolder_many, 'T1'))
        if ~isempty(find(~cellfun(@isempty,IsT11dir)))
            ss = find(~cellfun(@isempty,IsT1dir));
            subfolder = subfolder_many{ss,1};
        else
            display(FOLDER_DB{idx})
            display(subfolder_many)
            subfolder = input('Choose subfolder name: ','s')
        end
    else
        continue % do personally later.gonna go home now.
    end
    BRING_PTH = [BRING_PTH1 '/' subfolder ];

    
    
    ALL_DCM = []; ALL_DCM = dir([BRING_PTH,'/IM*']);
    if isempty(ALL_DCM)
        ALL_DCM = dir([BRING_PTH, '/im*']);
        if isempty(ALL_DCM)
            ALL_DCM = dir([BRING_PTH, '/FILE*']);
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    eval(sprintf('cd %s', SV_DIR))
    num_ALL_DCM = []; num_ALL_DCM = length(ALL_DCM);
    count = 0;
    
    
    
    % File information
    first_file = []; first_file = [BRING_PTH '/' ALL_DCM(1).name];
    if strcmp(first_file, '.mat')==1
        first_file = [];
        first_file = [BRING_PTH '/' ALL_DCM(2).name];
    end
    firstinfo = []; firstinfo = dicominfo(first_file);
    IsDTI = ~isempty(strfind(firstinfo.ProtocolName,'DTI'));
           
    if IsDTI == 1
        startsearch = 500;
    else
        startsearch = 1;
    end
    
    for idx3 = startsearch:num_ALL_DCM
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
        if count >=175 && ~isempty(strfind(info.ProtocolName,'T1'))==0
            break
        end

        
        clear idx3
        
        
        
        
    end %end subject
end %end current batch of subjects

% lessthan100listname = strcat( num2str(min(idx)))
% save(Less_than_100_files_subj, lessthan100listname)

