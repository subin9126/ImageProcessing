function [] = Preprocess_PETimages_workflow(Folder, pettype,output_1_1_nii_folder,output_1_2_flip_nii_folder)

% Written 19/07/16 by LSB for MRIDay workflow.
% This script uses SPM function and code from NIfTI_20140122

Files = dir(fullfile(Folder, strcat('*',pettype, '.img')));

for i=1:length(Files)
    
    %1-1. Convert from hdrimg to nii
    input_fullname = strcat(Folder,'/',Files(i).name);
	[pathstr,fname,ext] = fileparts(input_fullname);
    output_fullname = strcat(output_1_1_nii_folder,'/',fname,'.nii');
    
    V = spm_vol(input_fullname);
    ima = spm_read_vols(V);
    V.fname = output_fullname;
    spm_write_vol(V,ima);
    
    %1-2. Left-right flip:
    old_fullname = output_fullname;
    new_fullname = strcat(output_1_2_flip_nii_folder,'/flip_',fname,'.nii');
    flip_lr(old_fullname, new_fullname);
    
    
end






