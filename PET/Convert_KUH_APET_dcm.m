
folders = dir('Z:\Personal_Folder\Subin\KUH\APET\DICOM\HY_PET data'); 
folders = folders(3:end);
numsubjects = length(folders);

before_after = cell(1,1);

for s = 1:numsubjects
    subjdir = ['Z:\Personal_Folder\Subin\KUH\APET\DICOM\HY_PET data\' folders(s).name];
    
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
    apet_fname = ['Z:\Personal_Folder\Subin\KUH\APET\0_converted_files\'  folders(s).name '_APET.nii'];
    
    before_after{s,1} = output_fname;
    before_after{s,2} = apet_fname;
    movefile(output_fname, apet_fname)
    
    % Resave as origin-set version.
    pet = load_untouch_nii(apet_fname);
%     save_nii(make_nii(pet.img, [2 2 2], [64 64 45]), ['Z:\Personal_Folder\Subin\KUH\APET\1_origin_set_files\'  folders(s).name '_APET.nii'])
    save_nii(make_nii(pet.img, [1.0157 1.0157 2], [168 168 41]), ['Z:\Personal_Folder\Subin\KUH\APET\1_origin_set_files\'  folders(s).name '_APET.nii'])

    
end