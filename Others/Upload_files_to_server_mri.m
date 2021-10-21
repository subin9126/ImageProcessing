clear
%%%%% Change accordingly %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SRC_FOLDER = 'C:\Users\ReCODe_GAAIN\Desktop\MRI related files\MRI Image Day\13XXXXXX';
SERVER = 'Z:\VOL1\MRI_DICOM\1.5T';
hospnum_start_vector = 10:33; 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%0. SCANNING Folders to upload:
cd(SRC_FOLDER)
Folders_to_upload = dir('.');
Folders_to_upload = Folders_to_upload(3:end); % to get rid of . and ..
numFolders = length(Folders_to_upload);

%0. EXTRACTING first two numbers of hospnum of subjects_to_upload into a vector
folder_hospnum_start_vector = zeros(numFolders,1);
for idx = 1:numFolders
    folder_hospnum_start_vector(idx,1) = str2num(Folders_to_upload(idx).name(1:2));
end


Folders_uploaded = [];
Folders_not_uploaded = [];

while exist(SERVER, 'dir') && (length(Folders_not_uploaded)+length(Folders_uploaded)) < numFolders
    for hospnum_start = hospnum_start_vector
        
        HOSPNUM_FOLDER = [num2str(hospnum_start) 'XXXXXX'];
        
        % Find which of current folderts-to-upload correspond to the current hospnum
        % e.g. If current HOSPNUM_FOLDER is 10XXXXXX, find indexes of subjects
        %      from folders_to_upload who also start with 10.
        [hospnum_idx] = find(folder_hospnum_start_vector == hospnum_start);
        
        if isempty(hospnum_idx)==1
            continue
        elseif isempty(hospnum_idx)==0
            fprintf('==== Copying folders that start with %i ====\n', hospnum_start)
            for ii = hospnum_idx'
                src_dir = [SRC_FOLDER '\'  Folders_to_upload(ii).name];
                dest_dir = [SERVER '\' HOSPNUM_FOLDER '\' Folders_to_upload(ii).name];
                
                % IN CASE SERVER CONNECTION IS LOST during upload.
                if ~exist(SERVER, 'dir')
                    fprintf('*** Server not accessible. Check connection *** \n')
                    fprintf('*** Last fully uploaded folder was %s *** \n', Folders_to_upload(ii-1).name)
                    input('*** When ready to resume, press enter *** \n')
                % CHECK if dest_dir already exists,
                % because the files in there and the current files may be different,
                % so this needs to be checked manually.
                elseif exist(dest_dir, 'dir') ~= 0
                    fprintf('-- Folder %s already exists on server. Skipping uploading this folder for now --\n', dest_dir)
                    Folders_not_uploaded = [Folders_not_uploaded; dest_dir];
                    continue
                elseif ~exist(dest_dir, 'dir')
                    copyfile(src_dir, dest_dir)
                    Folders_uploaded = [Folders_uploaded; dest_dir];
                end
            end
        end
    end
end
    fprintf('=== %i folders uploaded, %i folders not uploaded === \n', size(Folders_uploaded,1), size(Folders_not_uploaded,1))
