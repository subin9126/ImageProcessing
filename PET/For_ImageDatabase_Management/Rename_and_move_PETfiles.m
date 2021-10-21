clear
%%%%% Change accordingly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Folder where the converted PET files are located:
Current_volumefiles_folder = 'C:\Users\SUBIN\Desktop\MRIConvert_Outputs';

% Folder where the converted PET files should be moved to
% (Folder containing subject folders):
Subject_dcmfolders_folder  = 'D:\APET_backup\tmp_181104\ResearchAPET';

% Set to 1 the first time
% Set to 0 when rerunning the code to manage folders that were skipped because they do not exist
DO_RENAME_FILES = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%0. SCANNING Volume Files:
cd(Current_volumefiles_folder)
Volumefiles_hdr = dir(fullfile(Current_volumefiles_folder, '*.hdr'));
Volumefiles_img = dir(fullfile(Current_volumefiles_folder, '*.img'));
if length(Volumefiles_hdr) ~= length(Volumefiles_img)
    disp('Number of .hdr and .img files not equal \n')
    return
else
    numVolumefiles = length(Volumefiles_img);
end

%1. RENAMING
% Rename files to get rid of '20' part in date:
% Only rename if DO_RENAME_FILES set to 1, because sometimes we may be
% re-running the code after renaming the files.
% Save parts of new filename for deriving subj foldernames:
subj_foldernames = cell(numVolumefiles,1);
for idx = 1:numVolumefiles
    old_filename_hdr = Volumefiles_hdr(idx).name;
    new_filename_hdr = strrep(old_filename_hdr, '_20', '_');
    old_filename_img = Volumefiles_img(idx).name;
    new_filename_img = strrep(old_filename_img, '_20', '_');
    
    if DO_RENAME_FILES==1
        movefile(old_filename_hdr, new_filename_hdr);
        movefile(old_filename_img, new_filename_img);
    end
    
    subj_foldernames{idx,1} = new_filename_img(1:15);
    subj_hospnum{idx,1} = new_filename_img(1:8);
    subj_underscore{idx,1} = new_filename_img(9);
    subj_petdate{idx,1} = new_filename_img(10:15);
end


%2. MOVE FILES
% Derive subject foldernames from volumefiles (only leave unique cases):
[~,uniqueidx,~]= unique(strcat(subj_hospnum, subj_underscore, subj_petdate));
subj_foldernames_unique = subj_foldernames(uniqueidx,:);


% Move volumefiles to each subject's folder:
Volumefiles_renamed = dir(fullfile(Current_volumefiles_folder, '*'));
Volumefiles_renamed = Volumefiles_renamed(3:end); % get rid of . and ..
numVolumefiles_renamed = length(Volumefiles_renamed);
for ii = 1:length(subj_foldernames_unique)
    
    current_subject_folder = subj_foldernames_unique{ii};
    current_subject_dir = strcat(Subject_dcmfolders_folder,'\',subj_foldernames_unique{ii});
    
    %   Because I derive the foldernames from the volumefiles,
    %   such foldername MAY NOT ACTUALLY EXIST (e.g. has '_minipacs' or '_2' at the end of the foldername, or entered date wrong).
    %   In these cases, SKIP for now, so that I manually change the foldername later.
    if ~exist(current_subject_dir, 'dir')
        fprintf('--Folder %s does not exist, Skipping scanning this folder for now.--\n', current_subject_dir)
        continue
    end
    
    
    for idx2 = 1:numVolumefiles_renamed
        %   If EXISTING current subject folder name and the first 15 characters of current filename match,
        %   move current file into current folder:
        if strcmp(current_subject_folder,Volumefiles_renamed(idx2).name(1:15)) == 1
            movefile(Volumefiles_renamed(idx2).name, current_subject_dir)
        else
            continue
        end
    end
end



