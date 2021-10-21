
% Code for converting dicom files using SPM12.

%++++++++Specify accordingly++++++++++++++++++++++++++++++++++++++++++++++++++++
% Parent directory of folders that contain dicom files for each subject
main_dir = 'Z:\Personal_Folder\Subin\KUH\APET\DICOM\HY_PET data';

% Voxel resolution of converted files
voxelSize = [1.0157 1.0157 2];

% Image modality that is being converted (included at filename)
mod = 'APET'

% Output directory containing converted, processed nii files
out_dir = 'Z:\Personal_Folder\Subin\KUH\APET\0_converted_files'



%++++++++Do not change below++++++++++++++++++++++++++++++++++++++++++++++++++++
folders = dir(main_dir); 
folders = folders(3:end);
numsubjects = length(folders);

before_after = cell(1,1);

for s = 1:numsubjects
    subjdir = [main_dir '\' folders(s).name];
    
    dir_contents = dir(subjdir);
    dir_contents = dir_contents(3:end);
    numfiles = length(dir_contents);
    
    
    dcmlist = {};
    for n = 1:numfiles
        dcmlist = [dcmlist; [subjdir '\' dir_contents(n).name]];
    end  
    
    % Convert dicom to nii
    matlabbatch{1}.spm.util.import.dicom.data =   dcmlist ;
    matlabbatch{1}.spm.util.import.dicom.root = 'flat';
    matlabbatch{1}.spm.util.import.dicom.outdir = {subjdir};
    matlabbatch{1}.spm.util.import.dicom.protfilter = '.*';
    matlabbatch{1}.spm.util.import.dicom.convopts.format = 'nii';
    matlabbatch{1}.spm.util.import.dicom.convopts.meta = 0;
    matlabbatch{1}.spm.util.import.dicom.convopts.icedims = 0;    
    spm_jobman('run', matlabbatch)
    
    % Rename converted files
    output_fname = [subjdir '\' dir(fullfile(subjdir, '*.nii')).name];
    apet_fname = [out_dir '\'  folders(s).name '_' mod '.nii'];
    
    before_after{s,1} = output_fname;
    before_after{s,2} = apet_fname;
    movefile(output_fname, apet_fname)
    
    % Resave as origin-set version.
    pet = load_untouch_nii(apet_fname);
    origLoc = [(size(pet.img,1)/2) (size(pet.img,2)/2) (size(pet.img,3)/2)];
    save_nii(make_nii(pet.img, voxelSize, origLoc), [out_dir '\'  folders(s).name '_' mod '.nii'])

    
end