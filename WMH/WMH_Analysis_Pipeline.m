function [log] = WMH_Analysis_Pipeline(DO_BIAS_CORRECTION, DO_WMH_SEGMENT, DO_CLEAN_WMH, DO_PVD_WMHMASK, DO_JVPVD_WMHMASK)
%% WMH Pipeline for IMAGE DAY 

% 0. Execution Settings (change accordingly. 0 to deactivate, 1 to activate): 
% DO_BIAS_CORRECTION = 0;
% DO_WMH_SEGMENT = 0;
% DO_CLEAN_WMH = 0;
% DO_PVD_WMHMASK = 1;
% DO_JVPVD_WMHMASK = 1;

% 0. Directory Settings:
ORIGFLAIRFolder = '/media/ws2/DATA/IMAGE_DAY/WMH/0_flair'; 
BCFLAIRFolder   = '/media/ws2/DATA/IMAGE_DAY/WMH/1_bcflair';
WMHFolder       = '/media/ws2/DATA/IMAGE_DAY/WMH/2_orig_wmh';
CLEANWMHFolder  = '/media/ws2/DATA/IMAGE_DAY/WMH/3_clean_wmh';
PVDWMHFolder    = '/media/ws2/DATA/IMAGE_DAY/WMH/4a_pvd_wmh';
JVPVDWMHFolder  = '/media/ws2/DATA/IMAGE_DAY/WMH/4b_jvpvd_wmh';
SIDEFolder      = '/media/ws2/DATA/IMAGE_DAY/WMH/99_sideproducts';

ISOT1Folder     = '/media/ws2/DATA/IMAGE_DAY/WMH/3_isot1';
FSMASKFolder    = '/media/ws2/DATA/IMAGE_DAY/WMH/3_fsmasks';

SPMDir = '/home/ws2/spm8/spm8';
TemplatesDir = '/media/ws2/DATA/IMAGE_DAY/WMH/SCRIPTS/Templates';

startidx = 1;

tStart = tic
%%

ORIGFLAIRFiles = dir(fullfile(ORIGFLAIRFolder, '*.img')); % do not input *.nii files. NEVER input *.hdr bc won't work on spm input
    numORIGFLAIRFiles = size(ORIGFLAIRFiles,1);



FSMaskFiles = dir(fullfile(FSMASKFolder, '*_wmparc.nii'));
    numFSMaskFiles = size(FSMaskFiles,1);
    
ISOT1Files = dir(fullfile(ISOT1Folder, 'r*.nii')); 
    numISOT1Files = size(ISOT1Files,1);
 

 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1. Bias Correction of FLAIR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DO_BIAS_CORRECTION == 1
    
    for idx = startidx:numORIGFLAIRFiles
        fprintf('===BiasCorrection of Subject %d of %d=== \n', idx, numORIGFLAIRFiles)
        matlabbatch{1}.spm.spatial.preproc.data = {strcat(ORIGFLAIRFolder,'/',ORIGFLAIRFiles(idx).name,',1')};
        matlabbatch{1}.spm.spatial.preproc.output.GM = [0 0 0];
        matlabbatch{1}.spm.spatial.preproc.output.WM = [0 0 0];
        matlabbatch{1}.spm.spatial.preproc.output.CSF = [0 0 0];
        matlabbatch{1}.spm.spatial.preproc.output.biascor = 1;
        matlabbatch{1}.spm.spatial.preproc.output.cleanup = 0;
        matlabbatch{1}.spm.spatial.preproc.opts.tpm = {
            strcat(SPMDir,'/tpm/grey.nii')
            strcat(SPMDir,'/tpm/white.nii')
            strcat(SPMDir,'/tpm/csf.nii')
            };
        matlabbatch{1}.spm.spatial.preproc.opts.ngaus = [2
            2
            2
            4];
        matlabbatch{1}.spm.spatial.preproc.opts.regtype = 'mni';
        matlabbatch{1}.spm.spatial.preproc.opts.warpreg = 1;
        matlabbatch{1}.spm.spatial.preproc.opts.warpco = 25;
        matlabbatch{1}.spm.spatial.preproc.opts.biasreg = 0.0001;
        matlabbatch{1}.spm.spatial.preproc.opts.biasfwhm = 60;
        matlabbatch{1}.spm.spatial.preproc.opts.samp = 3;
        matlabbatch{1}.spm.spatial.preproc.opts.msk = {''};
        spm_jobman('run', matlabbatch);
        clear matlabbatch;
       
        [hsts, message] = movefile(strcat(ORIGFLAIRFolder,'/m*.hdr'),BCFLAIRFolder);
        [ists, message] = movefile(strcat(ORIGFLAIRFolder,'/m*.img'),BCFLAIRFolder);
        if hsts == 0 || ists == 0
            error('Error. Moving BCFLAIR of subject %d unsuccessful\n', idx)
        end
     
    end
    delete(strcat(ORIGFLAIRFolder,'/*.mat')); %delete .mat files produced from biascorrection
    clear idx
    INFLAIRFolder = BCFLAIRFolder;        
    
elseif DO_BIAS_CORRECTION == 0            
    INFLAIRFolder = BCFLAIRFolder; % if already have bcflair, skip to next step
        INFLAIRFiles = dir(fullfile(BCFLAIRFolder, 'm*.img'));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2. Run WMH Segmentation on INFLAIR (FLAIR input)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DO_WMH_SEGMENT == 1
    
    % Use templates from TemplatesDir
    % Segment files from INFLAIRFolder
    % Create WMH files in WMHFolder
    % Save sideproducts in SIDEFolder/outputs folder
    % Start for-loop from nth subject
    SegmentWMH_Pipeline(TemplatesDir,INFLAIRFolder,WMHFolder, SIDEFolder, 1);    

    delete(strcat(INFLAIRFolder,'/*.mat'));

end

WMHFiles = dir(fullfile(WMHFolder, 'WMH_*.img')); 
    numWMHFiles = size(WMHFiles,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Clean up FLAIR-space WMH  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
if DO_CLEAN_WMH == 1
    
    flairreg_t1Folder = [SIDEFolder '/flairreg_t1'];
    flairreg_FSFolder = [SIDEFolder '/flairreg_fsmasks'];
    
        % Check for errors in input:    
        if numWMHFiles ~= numFSMaskFiles || numISOT1Files ~= numWMHFiles || numISOT1Files ~= numFSMaskFiles
            error('Error during CLEANWMH.\n Number of WMH, isoT1 or FSMask files do not match \n WMH:%i, isoT1:%i, FSMask:%i\n',...
                  numWMHFiles, numISOT1Files, numFSMaskFiles)
        end
        for checkidx = 1:numWMHFiles
            % Extract subjectname from 'WMH_m*.hdr/img' and 'r*_wmparc.nii'
            wmh_subj = WMHFiles(checkidx).name(6:20);       
            fsmask_subj = FSMaskFiles(checkidx).name(2:16); 
            if isempty(strfind(wmh_subj, fsmask_subj))==1 
                error('Error during CLEANWMH.\n Subjects in wmh and fsmask not in order\n Unordered subjects are %s and %s \n', wmh_subj, fsmask_subj)
            end
        end
        clear checkidx

    for idx = startidx:numFSMaskFiles
        
        % Coregister(nn) fsmask to orig flair-space
        matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {strcat(INFLAIRFolder,'/',INFLAIRFiles(idx).name,',1')};
        matlabbatch{1}.spm.spatial.coreg.estwrite.source = {strcat(ISOT1Folder,'/',ISOT1Files(idx).name,',1')};
        matlabbatch{1}.spm.spatial.coreg.estwrite.other = {strcat(FSMASKFolder,'/',FSMaskFiles(idx).name,',1')};
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2 1];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
        matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 0;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
        matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'flairreg_';
        spm_jobman('run', matlabbatch);
        clear matlabbatch;
        
        movefile([ISOT1Folder '/flairreg_r*.nii'], flairreg_t1Folder); 
        movefile([FSMASKFolder '/flairreg_*wmparc.nii'], flairreg_FSFolder);
        
        fprintf('===Cleaning FLAIR-space WMH of Subject %d of %d=== \n',idx,numFSMaskFiles)
        
        % Clean WMH from WMHFolder
        % Overlap with flairreg_fsmask from flairreg_fsmasks folder
        % Creates noctx_fsmasks as sideproduct
        % Creates clean WMH in CLEANWMHFolder
        MakeCleanWMH_Pipeline([WMHFolder '/' WMHFiles(idx).name], ...
                              [SIDEFolder '/flairreg_fsmasks/' 'flairreg_' FSMaskFiles(idx).name], ...
                              SIDEFolder, ...
                              CLEANWMHFolder);  
    end
    clear idx
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%4. Create JVWMH, PVWMH, DWMH Masks (flair-space)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if DO_PVD_WMHMASK == 1 || DO_JVPVD_WMHMASK == 1

    
    CLEANWMHFiles = dir(fullfile(CLEANWMHFolder, 'clean_WMH_*.img'));
    numCLEANWMHFiles = size(CLEANWMHFiles,1);
    

    flairreg_fsmaskfiles = dir(fullfile(flairreg_FSFolder, 'flairreg_r*wmparc.nii'));
    
    flairreg_FS_VENTRICLEFolder = [SIDEFolder '/flairreg_ventricle_masks'];
    
        % Check for errors in input:    
        if numCLEANWMHFiles ~= length(flairreg_fsmaskfiles)
            error('Error during PVD_WMH.\n Number of CLEANWMH and flairreg_FSMask files do not match \n')
        end
        for checkidx = 1:numCLEANWMHFiles
            % Extract subjectname from 'clean_WMH_m*.hdr/img' and 'flairreg_r*_wmparc.nii'
            cleanwmh_subj = CLEANWMHFiles(checkidx).name(12:26);
            flairreg_fsmask_subj = flairreg_fsmaskfiles(checkidx).name(11:25);  
            if isempty(strfind(flairreg_fsmask_subj, cleanwmh_subj))==1
                error('Error during PVD_WMH.\n Subjects in cleanwmh and flairreg_fsmask not in order\n Unordered subjects are %s and %s \n', ...
                      cleanwmh_subj, flairreg_fsmask_subj)
            end
        end
        clear checkidx
end
if DO_PVD_WMHMASK == 1 
    for idx = startidx:numCLEANWMHFiles
        
        fprintf('===Making PVD WMH of Subjects %d of %d=== \n',idx,numCLEANWMHFiles)
        
        % Input cleanWMH from CLEANWMHFolder
        % Use flairreg_fsmask to create flairreg_ventricle mask (if does not exist yet)
        % Create PVD WMH mask in PVDWMHFolder
        Make_PVD_WMHMASK_Pipeline([CLEANWMHFolder '/' CLEANWMHFiles(idx).name], ...
                                  [flairreg_FSFolder '/' flairreg_fsmaskfiles(idx).name], ...
                                  PVDWMHFolder, ...
                                  flairreg_FS_VENTRICLEFolder, ... 
                                  'PVvsD');            
    end
    clear idx
end
if DO_JVPVD_WMHMASK == 1
    for idx = startidx:numCLEANWMHFiles
        
        fprintf('===Making JVPVD WMH of Subjects %d of %d=== \n',idx,numCLEANWMHFiles)
        
        % Input cleanWMH from CLEANWMHFolder
        % Use flairreg_fsmask to create flairreg_ventricle mask (if does not exist yet)
        % Create JVPVD WMH mask in JVPVDWMHFolder
        Make_JVPVD_WMHMASK_Pipeline([CLEANWMHFolder '/' CLEANWMHFiles(idx).name], ...
                                    [flairreg_FSFolder '/' flairreg_fsmaskfiles(idx).name], ...
                                    JVPVDWMHFolder, ...
                                    flairreg_FS_VENTRICLEFolder, ...
                                   'JVvsPVvsD');            
    end
    clear idx
end





tElapsed = toc(tStart)/60;
fprintf('Total runtime: %d min \n',tElapsed)


log.Folders.ORIGFLAIRFolder = '/media/ws2/DATA/IMAGE_DAY/WMH/0_flair'; 
log.Folders.BCFLAIRFolder   = '/media/ws2/DATA/IMAGE_DAY/WMH/1_bcflair';
log.Folders.INFLAIRFolder = INFLAIRFolder; 
log.Folders.WMHFolder       = '/media/ws2/DATA/IMAGE_DAY/WMH/2_orig_wmh';
log.Folders.CLEANWMHFolder  = '/media/ws2/DATA/IMAGE_DAY/WMH/3_clean_wmh';
log.Folders.PVDWMHFolder    = '/media/ws2/DATA/IMAGE_DAY/WMH/4a_pvd_wmh';
log.Folders.JVPVDWMHFolder  = '/media/ws2/DATA/IMAGE_DAY/WMH/4b_jvpvd_wmh';
log.Folders.SIDEFolder      = '/media/ws2/DATA/IMAGE_DAY/WMH/99_sideproducts';
log.Folders.ISOT1Folder     = '/media/ws2/DATA/IMAGE_DAY/WMH/3_isot1';
log.Folders.FSMASKFolder    = '/media/ws2/DATA/IMAGE_DAY/WMH/3_fsmasks';
log.Folders.SPMDir = '/home/ws2/spm8/spm8';
log.Folders.TemplatesDir = '/media/ws2/DATA/IMAGE_DAY/WMH/SCRIPTS/Templates';
log.Folders.flairreg_t1Folder = [SIDEFolder '/flairreg_t1'];
log.Folders.flairreg_FSFolder = [SIDEFolder '/flairreg_fsmasks'];
log.Folders.flairreg_FS_VENTRICLEFolder = [SIDEFolder '/flairreg_ventricle_masks'];

log.Files.ORIGFLAIRFiles = dir(fullfile(ORIGFLAIRFolder, '*.img')); % do not input *.nii files. NEVER input *.hdr bc won't work on spm input
log.Files.INFLAIRFiles = dir(fullfile(BCFLAIRFolder, 'm*.img'));
log.Files.FSMaskFiles = dir(fullfile(FSMASKFolder, '*_wmparc.nii'));
log.Files.ISOT1Files = dir(fullfile(ISOT1Folder, 'r*.nii')); 
log.Files.CLEANWMHFiles = dir(fullfile(CLEANWMHFolder, 'clean_WMH_*.img'));
log.Files.flairreg_fsmaskfiles = dir(fullfile(flairreg_FSFolder, 'flairreg_r*wmparc.nii'));   


log.numFiles.numORIGFLAIRFiles = size(ORIGFLAIRFiles,1);
log.numFiles.numFSMaskFiles = size(FSMaskFiles,1); 
log.numFiles.numISOT1Files = size(ISOT1Files,1);
log.numFiles.numCLEANWMHFiles = size(CLEANWMHFiles,1);


