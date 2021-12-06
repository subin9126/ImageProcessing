% Code for removing subject's information in DICOM files
% 2019.01.04. Subin Lee
%             - Edited some variable names.
%             - Removed for loop regarding ttype (t1,flair)
%             - Edited so that: 
%               1. We **MANUALLY COPY THE ORIG DCM files into a new folder (specified by 'origdcm_copy_dir' below), 
%                  and then RUN CODE ON the manually copied dcm**
%               2. Code will write new dcm files (without info), as filenames according to specified modality 
%                  (T1_00001.dcm, FL_00001.dcm, etc).
%               3. Once all the new dcm files are written, the original copy dcm files (IM_00001.dcm) 
%                  that contain info will be deleted.
%
% 2019.01.24. - For ws1 environment.
% 2021.02.03. - Final version.

clear all
close all
clc
tStart = tic; 

% ------CHANGE ACCORDINGLY----------------
mod = 'T1';       % 'T1' or 'FL'
fileext = '.dcm'; % '.dcm' or '.IMA'
origdcm_copy_dir = '/media/wmhdb_mnt/VUNO/NIPA2018/UPGRADED_VALIDATIONSET_copy';
startidx = 1; 
% ----------------------------------------

cd(origdcm_copy_dir)
subject = dir('./*'); 
subject(1:2) = []; %remove . and .. 
num_subj = length(subject);

if num_subj > 0,
    for idx = startidx:num_subj 
        
        subj_folder = []; subj_dcm_files = []; num_dcm_files = 0;     
       
        subj_folder = [origdcm_copy_dir '/' subject(idx).name];
        subj_dcm_files = dir(strcat(subj_folder,'/*',fileext)); 
        num_dcm_files = length(subj_dcm_files);
        
        if num_dcm_files == 0
            fprintf('No files of specified file ext in folder %s \n', subj_folder)
            continue;
        else
        
            cd(subj_folder);

            fprintf('Writing new noinfo dcm file, subject %d \n', idx)
            for fidx = 1:num_dcm_files
                % Specify content of new dcm files
                dinfo_pth = []; dinfo_mod = []; dicom_X = [];
                dinfo_pth = [subj_folder, '/' subj_dcm_files(fidx).name];
                dinfo_mod = dicominfo(dinfo_pth);
                dicom_X = dicomread(dinfo_pth);

                dinfo_mod.Filename = [subject(idx).name];

                dinfo_mod.AccessionNumber = [];
                dinfo_mod.PatientName = [];
                dinfo_mod.PatientID = [];
                dinfo_mod.PatientBirthDate = [];

                dinfo_mod.ReferringPhysicianName = [];

                % Write new dcm files (with 'IM_' filename)
                dicom_fname = [];
                dicom_fname = [mod '_', sprintf('%05d', fidx), '.dcm'];
                dicomwrite(dicom_X, dicom_fname, dinfo_mod)  
            end

            % Check if all orig copy dcm files have been remade
            % If so, delete orig copy dcm files
            modname = [mod '*'];
            if length(dir(fullfile(subj_folder, modname))) == num_dcm_files
                fprintf('Rewriting done; Deleting orig copy dcm files\n')
                for fidx = 1:num_dcm_files
                    delete([subj_folder, '/' subj_dcm_files(fidx).name]);
                end
            else
                error('Number of orig copy dcm files and new noinfo dcm files different')
            end


            fprintf('Subject %s done. \n', subject(idx).name)
        end
        
    end
end

tElapsed = toc(tStart);
fprintf('Processing time: %.3f min\n', tElapsed / 60);



