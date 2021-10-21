function SegmentWMH_Pipeline(TemplatesDir, SrcFolder, DestFolder, SIDEFolder, startidx)
%
%0. Execution/Directory Settings
%
spm_defaults;

oldDir = pwd;

MAKE_SNU_FLAIR_POSITIVE_DATA = 1;
DO_COREGISTER_AND_SEGMENTATION = 1;
    templateForCoregistration = strcat(TemplatesDir,'/ICBM152_2009a_T1_1mm.nii');
    templateGMForSegmentation = strcat(TemplatesDir, '/ICBM152_2009a_GM_1mm.nii');
    templateWMForSegmentation = strcat(TemplatesDir,'/ICBM152_2009a_WM_1mm.nii');
    templateCSFForSegmentation = strcat(TemplatesDir,'/ICBM152_2009a_CSF_1mm.nii');
    useBrainMask = 1;
    templateBrainMaskForSegmentation = strcat(TemplatesDir,'/ICBM152_2009a_Brain_1mm.nii');

% Step for removing septum related regions
DO_REMOVE_SEPTUM = 1;
CoregSeptum = 1;
    
MAKE_INPUT_SEGMENT_FILES = 1;                                         
MAKE_BRAIN_MASK = 1;
    togetherWithCSF = 0;
    % 0: GM+WM, 1: GM+WM+CSF, 2:GM+WM-CSF, 3:(GM>th & GM>CSF) | (WM>th & WM>CSF)
	threshold_MFMIFSF = 0.1;
	threshold_MFMIFSF_CSFcut = 0.99;    
    doErodeAndFill = 1;
    erodeVoxel = 3;  erodeRepeat = 1;
    fillVoxel  = 1;  fillRepeat  = 1;                                                                                          
MAKE_CEREBRUM_MASK = 1;
    templateCereInMNISpace = strcat(TemplatesDir,'/MNI152_cerebrum_1mm.nii');
    templateCereWMInMNISpace = strcat(TemplatesDir,'/MNI152_cerebrumWM_1mm.nii');
    templateSeptumMask = strcat(TemplatesDir,'/KNE96_Septum_medium.nii'); % DW modi 180918
    thresholdBinaryCereMask = 0.9;
    thresholdBinaryCereWMMask = 0.9;
    thresholdBinarySeptumWMMask = 20;
DO_SKULL_STRIPPING_USING_MASK = 1;    
DO_MAIN_ROUTINE_FOR_WMH = 1;    
    optionSearchingStartingPointForDAUC = 3;
	lengthForDecidingSign = 3;
	thresholdForDecidingNegativeInterval = -5;  
    thresholdCerebrumInMainWMH = 0.5;
    normalizingBrainVolume = 0;    
    AVERAGE_CERE_VOL = 1150 * 1.0e+03;                        
    PLOT_HISTOGRAM_DO_MAIN_ROUTINE_FOR_WMH = 0;
    PLOT_DAUC_DO_MAIN_ROUTINE_FOR_WMH = 0;
    methodForDeterminingZo = 201105;
    if methodForDeterminingZo == 1,                                                   
        coeffZE = 16.0570;                
        expCoeffZE = -0.0000774;          
        convergingLine = 2.6498;                                         
    elseif methodForDeterminingZo == 0,
        coeffZE = 8.1666;                 
        expCoeffZE = -0.0000582;       
        convergingLine = 2.6074;                                        
    elseif methodForDeterminingZo == 24,
        coeffZE = 9.8302;                
        expCoeffZE =-0.0000626 ;          
        convergingLine = 2.5963;                                                
    elseif methodForDeterminingZo == 31, 
        coeffZE =1.7959;                 
        expCoeffZE =  -0.0000646 ;       
        convergingLine = 2.6504;               
    elseif methodForDeterminingZo == 41, 
        coeffZE = -0.9497;               
        expCoeffZE =  -0.0000476;         
        convergingLine = 3.8584;             
    elseif methodForDeterminingZo == 42, 
        coeffZE = -0.8905;               
        expCoeffZE =  -0.0000500;         
        convergingLine = 3.8310;                
    elseif methodForDeterminingZo == 100, 
        coeffZE = 1.5009;                 
        expCoeffZE =  -0.0000642;         
        convergingLine = 2.1025;               
    elseif methodForDeterminingZo == 101, 
        coeffZE = 0.8583;                 
        expCoeffZE =  -0.0000706;         
        convergingLine = 2.1345;               
    elseif methodForDeterminingZo == -1, 
        coeffZE = 0.000001;               
        expCoeffZE =  -0.000001;          
        convergingLine = 1.0;                                                      
    elseif methodForDeterminingZo == 201008; % 5th regression linear model 20100817
        coeffZE = 0.000001; 
        expCoeffZE = -0.0000067;                                                    
        convergingLine = 2.7202;
    elseif methodForDeterminingZo == 200911,
        coeffZE = 2.014;                 
        expCoeffZE = -0.0000534;         
        convergingLine = 2.636;          
    elseif methodForDeterminingZo == 201103,
        coeffZE = 0.9747;                 
        expCoeffZE = -0.0000414;          
        convergingLine = 1.8333;          
    elseif methodForDeterminingZo == 201104,
        coeffZE = 0.7904;                 
        expCoeffZE = -0.0000293;          
        convergingLine = 1.7072;          
    elseif methodForDeterminingZo == 201105,
        coeffZE = 0.9827;               
        expCoeffZE = -0.0000397;         
        convergingLine = 1.7050;      
    elseif methodForDeterminingZo == 201106, % ZestO = phi(1)+sqrt(phi(2)+ phi(3)*log(DaucRange./(1000-DaucRange)));
        BayesianCoeff1 = -13.2449;         
        BayesianCoeff2 = 203.9397;
        BayesianCoeff3 = -8.4877;
        coeffZE = 0.1;           
        expCoeffZE = 0.1;      
        convergingLine = 0.1;                                                     
    else                                 % DEFAULT[ORIGINAL] ALGORITHM   
        coeffZE = 1.173;     
        expCoeffZE = -0.00004252;  
        convergingLine = 2.612;                                               
    end
DO_CEREBRUM_WM_MASKING_WMH = 1;
    thresholdForMask = 0.5;
    thresholdForWMMask = 0.05;
REMOVE_ISOLATED_SMALL_WMH = 1;    
    thresholdForSmallWMH = 100;
HDR_CORRECTION = 1;

%%
%
% PROCESS Step: Select input (FLAIR) images
% 
INFLAIRFiles = dir(fullfile(SrcFolder, '*.img'));  % EDITED BY LSB 181218
numOfSubjects = size(INFLAIRFiles,1);              % EDITED BY LSB 180610 

%mkdir(strcat(SIDEFolder,'/outputs'))                 % EDITED BY LSB 180612

%
% PROCESS Step: Set processing list
%
plist = [];
for subjectNum = startidx:numOfSubjects 
    [scanPath, fname, fext] = fileparts(strcat(SrcFolder,'/',INFLAIRFiles(subjectNum).name)); %EDITED BY LSB 181218
    fname_F_removed = fname;       
    fname_F_removed(:,end-1:end) = [];
    plist(subjectNum).imageID = fname_F_removed;    
    plist(subjectNum).scanPath = scanPath;
    plist(subjectNum).scanInputFile = strcat(fname,fext);
    plist(subjectNum).positiveFlairImageFile = fullfile(strcat(SIDEFolder, '/outputs/p_', fname, '.img'));
    plist(subjectNum).reslicedFlairImageFile = fullfile(strcat(SIDEFolder,'/outputs/rp_', fname, '.img'));
    plist(subjectNum).parametersSnMatFile    = fullfile(strcat(SIDEFolder,'/outputs/rp_', fname, '_seg_sn.mat'));
    plist(subjectNum).parametersInvSnMatFile = fullfile(strcat(SIDEFolder,'/outputs/rp_', fname, '_seg_inv_sn.mat'));
    plist(subjectNum).MNIFlairImageFile      = fullfile(strcat(SIDEFolder,'/outputs/MNIrp_', fname, '.img'));
    plist(subjectNum).GM_spm_segFile         = fullfile(strcat(SIDEFolder,'/outputs/c1rp_', fname, '.img'));
    plist(subjectNum).WM_spm_segFile         = fullfile(strcat(SIDEFolder,'/outputs/c2rp_', fname, '.img'));
    plist(subjectNum).CSF_spm_segFile        = fullfile(strcat(SIDEFolder,'/outputs/c3rp_', fname, '.img'));
    plist(subjectNum).WMMaskFile             = fullfile(strcat(SIDEFolder,'/outputs/p_c2rp_', fname, '.img'));    
    plist(subjectNum).MNIBrainMaskFile       = fullfile(strcat(SIDEFolder,'/outputs/bMask_rp_', fname, '.img'));
    plist(subjectNum).brainMaskFile          = fullfile(strcat(SIDEFolder,'/outputs/p_bMask_rp_', fname, '.img'));
    plist(subjectNum).skullStrippedFile      = fullfile(strcat(SIDEFolder,'/outputs/sfcrp_', fname, '.img'));
    plist(subjectNum).MNICereMaskFile        = fullfile(strcat(SIDEFolder,'/outputs/cereMask_rp_', fname, '.img'));    
    plist(subjectNum).MNICereWMMaskFile      = fullfile(strcat(SIDEFolder,'/outputs/cereWMMask_rp_', fname, '.img'));
    plist(subjectNum).KNESeptumMaskFile      = fullfile(strcat(SIDEFolder,'/outputs/septumMask_rp_', fname, '.img'));   % Added by DW 18SEP07
    plist(subjectNum).cereMaskFile           = fullfile(strcat(SIDEFolder,'/outputs/p_cereMask_rp_', fname, '.img'));  
    plist(subjectNum).cereWMMaskFile         = fullfile(strcat(SIDEFolder,'/outputs/p_cereWMMask_rp_', fname, '.img'));
    plist(subjectNum).KNECereSeptumMaskFile  = fullfile(strcat(SIDEFolder,'/outputs/p_septumMask_rp_', fname, '.img')); % Edited by DW 180906
    plist(subjectNum).premainWMHFile         = fullfile(strcat(SIDEFolder,'/outputs/preWMHmain_', fname, '.img'));      %EDITED BY LSB 180612 ****
    plist(subjectNum).mainWMHFile            = fullfile(strcat(SIDEFolder,'/outputs/WMHmain_', fname, '.img'));         %EDITED BY LSB 180612 ****
    plist(subjectNum).mainWMHZscoreFile      = fullfile(strcat(SIDEFolder,'/outputs/Zscore_', fname, '.img'));
    plist(subjectNum).cereWMHFile            = fullfile(strcat(SIDEFolder,'/outputs/WMHcere_', fname, '.img'));         %EDITED BY LSB 180612 ****
    plist(subjectNum).maskedWMHFile          = fullfile(strcat(SIDEFolder,'/outputs/WMHWM_', fname, '.img'));           %EDITED BY LSB 180612 ****
    plist(subjectNum).cleanWMHFile           = fullfile(strcat(DestFolder,'/WMH_', fname, '.img'));                    %EDITED BY LSB 181220 ****
    plist(subjectNum).diaryFile              = fullfile(strcat(SIDEFolder,'/outputs/diary_', fname, '.txt')); 
end

%
% PROCESS Step: SegmentWMH main loop start
%
dateNtime = datestr(clock,30);
fprintf('SegmentWMH main loop start at %s \n',dateNtime);
for subjectNum = startidx:numOfSubjects 
    fprintf('*** Starting SegmentWMH main loop (%d/%d) ***\n', subjectNum, numOfSubjects);

    %
    % PROCESS Step: Make SNU FLAIR positive data
    %
    if MAKE_SNU_FLAIR_POSITIVE_DATA == 1,
        fprintf('Step 1: Make SNU FLAIR positive data\n');
        cd(oldDir);
        MakeFLAIRPositiveData(plist(subjectNum).scanPath, plist(subjectNum).scanInputFile, plist(subjectNum).positiveFlairImageFile);
    end
    
    %
    % PROCESS Step: Coregister FLAIR positive data to T1 template & Segment coregistered FLAIR positive data
    %    
    if DO_COREGISTER_AND_SEGMENTATION == 1,
        fprintf('Step 2: Coregister FLAIR positive data to T1 template & Segment coregistered FLAIR positive data\n');
        cd(char(plist(subjectNum).scanPath));
        
        coregOptionFlags     = struct('sep',[4 2],'params',[0 0 0  0 0 0], 'cost_fun','nmi','fwhm',[7 7],...
                                'tol',[0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001],'graphics',1);
        resliceOptionFlags   = struct('interp',1,'mask',1,'mean',0,'which',1,'wrap',[0 0 0]','prefix','r');
        jobForCoreg.ref      = cellstr(templateForCoregistration);
        jobForCoreg.source   = cellstr(plist(subjectNum).positiveFlairImageFile);
        jobForCoreg.other    = cellstr('');
        jobForCoreg.eoptions = coregOptionFlags;
        jobForCoreg.roptions = resliceOptionFlags;
        coregOutput          = spm_run_coreg_estwrite(jobForCoreg);
        clear coregOptionFlags resliceOptionFlags jobForCoreg coregOutput; 
        
        segOption.tpm      = cellstr(char(templateGMForSegmentation, templateWMForSegmentation, templateCSFForSegmentation)); % Prior probability maps      
        segOption.ngaus    = [2 2 2 4]; % default[2 2 2 4]: number of Gaussians used to represent the intensity distribution for each tissue
        segOption.warpreg  = 3;         % default 1 : warping regularisation (increase for decreasing distortion of ...)
        segOption.warpco   = 25;        % default 25: warp frequency cutoff (smaller cutoff freq. allow more detailed deformations to be modelled)
        segOption.biasreg  = 0.0001;    % default 0.0001:  0:no regularisation, 0.00001:extremely light, 0.0001:very light, ..., 10:extremely heavy
        segOption.biasfwhm = 75;        % default 75:  30; %50; % 30~150mm or No correction (0)
        segOption.regtype  = 'none';    % default = 'mni'; % regularisation type 
                                        % 'mni'   - registration of European brains with MNI space
                                        % 'eastern' - registration of East Asian brains with MNI space
                                        % 'rigid' - rigid(ish)-body registration
                                        % 'subj'  - inter-subject registration
                                        % 'none'  - no regularisation
        segOption.fudge    = 5;
        segOption.samp     = 3; % default 3 : sampling distance (smaller values use more of the data)
        segOption.msk      = cellstr(char(''));
        if useBrainMask == 1,
            segOption.msk  = cellstr(char(templateBrainMaskForSegmentation)); %masking image => do not use????
        end
        outputOption = struct('biascor',1,'GM',[1 1 1],'WM',[1 1 1],'CSF',[1 1 1],'cleanup',0);
                       % Bias corrected 1:save, 0:dont,
                       % seg_img_save_option [native_space  modulated_normalised  unmodulated_normalised],  
                       % clean up any partitions 0:dont, 1:light clean, 2:thorough clean
        
        jobForSegment.data   = cellstr(plist(subjectNum).reslicedFlairImageFile);
        jobForSegment.opts   = segOption;
        jobForSegment.output = outputOption;
        segOut               = spm_run_preproc(jobForSegment);
        clear segOption outputOption jobForSegment segOut;
        
        sn_flags = struct('interp',1, 'wrap', [0 0 0], 'vox', [1 1 1], 'bb', [NaN NaN NaN; NaN NaN NaN], 'preserve', 1,  'prefix','ST_');
        V        = spm_vol(plist(subjectNum).reslicedFlairImageFile);     
        VO       = spm_write_sn(V, plist(subjectNum).parametersSnMatFile, sn_flags);
        VO.fname = plist(subjectNum).MNIFlairImageFile;      
        VO       = spm_write_vol(VO,VO.dat);
        clear V VO;
    end
    
    %
    % PROCESS Step: Reslice segmented files (GM/WM/CSF) in input subject coordinate
    %  
    if MAKE_INPUT_SEGMENT_FILES == 1,
        fprintf('Step 3: Reslice segmented files (GM/WM/CSF) in input subject coordinate\n');
        cd(char(plist(subjectNum).scanPath));
        
        % Load WM segmentation image & reslice 1.0 WMImage to 0.5 
        jobForCoreg.ref     = cellstr(plist(subjectNum).positiveFlairImageFile);
        resliceOptionFlags  = struct('interp',1,'mask',1,'mean',0,'which',1,'wrap',[0 0 0]','prefix','p_');

        jobForCoreg.source  = cellstr(plist(subjectNum).GM_spm_segFile);
        jobForCoreg.roptions= resliceOptionFlags; 
        coregOutput         = spm_run_coreg_reslice(jobForCoreg); 

        jobForCoreg.source  = cellstr(plist(subjectNum).WM_spm_segFile);
        jobForCoreg.roptions= resliceOptionFlags; 
        coregOutput         = spm_run_coreg_reslice(jobForCoreg); 

        jobForCoreg.source  = cellstr(plist(subjectNum).CSF_spm_segFile);
        jobForCoreg.roptions= resliceOptionFlags; 
        coregOutput         = spm_run_coreg_reslice(jobForCoreg); 
        clear jobForCoreg coregOutput ;
    end
    
    %
    % PROCESS Step: Make brain mask in both of MNI template and input subject coordinates
    % 
    if MAKE_BRAIN_MASK == 1,
        fprintf('Step 4: Make brain mask in both of MNI template and input subject coordinates\n');
        cd(char(plist(subjectNum).scanPath));
        
        % Make brain mask in both of MNI template
        [H,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).GM_spm_segFile);
        I1 = load_nii_img(H,filetype,fileprefix,machine);    
        I1 = H.dime.scl_slope * double(I1);
        H.dime.scl_slope = 1;  
   
        [H,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).WM_spm_segFile);
        I2 = load_nii_img(H,filetype,fileprefix,machine);     
        I2 = H.dime.scl_slope * double(I2);
        H.dime.scl_slope = 1;
        
        if togetherWithCSF == 1,
            [H,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).CSF_spm_segFile);
            I3 = load_nii_img(H,filetype,fileprefix,machine);      
            I3 = H.dime.scl_slope * double(I3);
            H.dime.scl_slope = 1;             
            tmpImg = I1 + I2 + I3;
            clear I3;
        elseif togetherWithCSF == 2,
            [H,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).CSF_spm_segFile);
            I3 = load_nii_img(H,filetype,fileprefix,machine);    
            tmpImg = (((I1>threshold_MFMIFSF) | (I2>threshold_MFMIFSF)) & (I3<threshold_MFMIFSF_CSFcut));
            clear I3;
        elseif togetherWithCSF == 3,
            [H,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).CSF_spm_segFile);
            I3 = load_nii_img(H,filetype,fileprefix,machine);    
            tmpImg = ( (I1 > threshold_MFMIFSF & I1 > I3) | (I2 > threshold_MFMIFSF & I2 > I3) );
            clear I3;
        else
            tmpImg = (I1>threshold_MFMIFSF) | (I2>threshold_MFMIFSF);
        end
        targetImg = tmpImg > 0;  
        H.dime.scl_slope = 1;
        
        b_out_nii.hdr = H;
        b_out_nii.img = targetImg;
        save_nii(b_out_nii, char(plist(subjectNum).MNIBrainMaskFile));
            
        clear H I1 I2 tmpImg b_out_nii targetImg;
        
        if doErodeAndFill == 1,
            [H,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).MNIBrainMaskFile);
            Is = load_nii_img(H,filetype,fileprefix,machine); 
            
            for erodeNum = 1:erodeRepeat,   % Erode 
                STRUCT_ELEM = uint8(ones(erodeVoxel,erodeVoxel,erodeVoxel)); % 3,3,3 % 2,2,2
                Is = imerode(Is, STRUCT_ELEM);
            end    
            
            for fillNum = 1:fillRepeat,     % Fill 
                STRUCT_ELEM = uint8(ones(fillVoxel,fillVoxel,fillVoxel)); % 6,6,6 % 5,5,5
                Is = fillImage(Is, STRUCT_ELEM);               
            end     
            
            b_out_nii.hdr = H;
            b_out_nii.img = Is;
            save_nii(b_out_nii, plist(subjectNum).MNIBrainMaskFile);
            clear H Is b_out_nii STRUCT_ELEM;
        end

        % Make brain mask in input subject coordinate
        resliceOptionFlags = struct('interp',1,'mask',1,'mean',0,'which',1,'wrap',[0 0 0]','prefix','p_');
        jobForCoreg.ref = cellstr(plist(subjectNum).positiveFlairImageFile);
        jobForCoreg.source = cellstr(plist(subjectNum).MNIBrainMaskFile); 
        jobForCoreg.other = cellstr(''); 
        jobForCoreg.roptions = resliceOptionFlags;
        
        coregOutput = spm_run_coreg_reslice(jobForCoreg);
        
        clear coregOptionFlags resliceOptionFlags jobForCoreg coregOutput;
    end 
    
    %
    % PROCESS Step: Make cerebrum and cerebrum WM mask images in input subject coordinate
    %
    if MAKE_CEREBRUM_MASK == 1,  
        fprintf('Step 5: Make cerebrum and cerebrum WM mask images in input subject coordinate\n');   
        cd(char(plist(subjectNum).scanPath));

        sn_flags = struct('interp',1, 'wrap', [0 0 0], 'vox', [1 1 1], 'bb', [NaN NaN NaN; NaN NaN NaN], 'preserve', 1,  'prefix','STC_');
        V = spm_vol(templateCereInMNISpace);
        VO = spm_write_sn(V, plist(subjectNum).parametersInvSnMatFile, sn_flags);
        VO.dat = VO.dat > thresholdBinaryCereMask;            
        VO.fname = plist(subjectNum).MNICereMaskFile;      
        VO = spm_write_vol(VO,VO.dat);

        resliceOptionFlags = struct('interp',1,'mask',1,'mean',0,'which',1,'wrap',[0 0 0]','prefix','p_');
        jobForCoreg.ref = cellstr(plist(subjectNum).positiveFlairImageFile);
        jobForCoreg.source = cellstr(plist(subjectNum).MNICereMaskFile);  
        jobForCoreg.other = cellstr(''); 
        jobForCoreg.roptions = resliceOptionFlags;
        coregOutput = spm_run_coreg_reslice(jobForCoreg);
        
        clear sn_flags V VO coregOptionFlags resliceOptionFlags jobForCoreg coregOutput;        
        
        sn_flags = struct('interp',1, 'wrap', [0 0 0], 'vox', [1 1 1], 'bb', [NaN NaN NaN; NaN NaN NaN], 'preserve', 1,  'prefix','STW_');
        V = spm_vol(templateCereWMInMNISpace);
        VO = spm_write_sn(V, plist(subjectNum).parametersInvSnMatFile, sn_flags);
        VO.dat = VO.dat > thresholdBinaryCereWMMask;            
        VO.fname = plist(subjectNum).MNICereWMMaskFile;
        VO = spm_write_vol(VO,VO.dat);
        
        resliceOptionFlags = struct('interp',1,'mask',1,'mean',0,'which',1,'wrap',[0 0 0]','prefix','p_');                          
        jobForCoreg.ref = cellstr(plist(subjectNum).positiveFlairImageFile);
        jobForCoreg.source = cellstr(plist(subjectNum).MNICereWMMaskFile);
        jobForCoreg.other = cellstr(''); 
        jobForCoreg.roptions = resliceOptionFlags;
        coregOutput = spm_run_coreg_reslice(jobForCoreg);
        
        clear sn_flags V VO coregOptionFlags resliceOptionFlags jobForCoreg coregOutput;
        
        % Septum
        sn_flags = struct('interp',1, 'wrap', [0 0 0], 'vox', [1 1 1], 'bb', [NaN NaN NaN; NaN NaN NaN], 'preserve', 1,  'prefix','STW_');
        V = spm_vol(templateSeptumMask);
        VO = spm_write_sn(V, plist(subjectNum).parametersInvSnMatFile, sn_flags);
        VO.dat = VO.dat >= thresholdBinarySeptumWMMask;            
        VO.fname = plist(subjectNum).KNESeptumMaskFile;
        VO = spm_write_vol(VO,VO.dat);
        
        resliceOptionFlags = struct('interp',1,'mask',1,'mean',0,'which',1,'wrap',[0 0 0]','prefix','p_');                          
        jobForCoreg.ref = cellstr(plist(subjectNum).positiveFlairImageFile);
        jobForCoreg.source = cellstr(plist(subjectNum).KNESeptumMaskFile);
        jobForCoreg.other = cellstr(''); 
        jobForCoreg.roptions = resliceOptionFlags;
        coregOutput = spm_run_coreg_reslice(jobForCoreg);
        
        clear sn_flags V VO coregOptionFlags resliceOptionFlags jobForCoreg coregOutput;
    end
    
    %
    % PROCESS Step: Skull stripping using subject mask
    %     
    if DO_SKULL_STRIPPING_USING_MASK == 1,       
        fprintf('Step 6: Skull stripping using subject mask\n');   
        cd(char(plist(subjectNum).scanPath));

        [Hi,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).positiveFlairImageFile);
        I = load_nii_img(Hi,filetype,fileprefix,machine);   
        [Hm,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).brainMaskFile);
        Im = load_nii_img(Hm,filetype,fileprefix,machine);   

        if size(I,1)~=size(Im,1)||size(I,2)~=size(Im,2)||size(I,3)~=size(Im,3),
            fprintf('Error: Check data & mask file dimension\n');
            return;
        end
        targetImage = double(I) .* double(Im);
        
        b_out_nii.hdr = Hi;
        b_out_nii.img = targetImage;
        save_nii(b_out_nii, plist(subjectNum).skullStrippedFile);
        
        clear Hi Hm I Im targetImage b_out_nii;            
    end 
    
%     %
%     % PROCESS Step: Make subject base Septum related region
%     %
%     
%     if CoregSeptum == 1,
%         % Septum
%         sn_flags = struct('interp',1, 'wrap', [0 0 0], 'vox', [1 1 1], 'bb', [NaN NaN NaN; NaN NaN NaN], 'preserve', 1,  'prefix','STW_');
%         V = spm_vol(templateSeptumMask);
%         VO = spm_write_sn(V, plist(subjectNum).parametersInvSnMatFile, sn_flags);
%         VO.dat = VO.dat >= thresholdBinarySeptumWMMask;            
%         VO.fname = plist(subjectNum).KNESeptumMaskFile;
%         VO = spm_write_vol(VO,VO.dat);
%         
%         resliceOptionFlags = struct('interp',1,'mask',1,'mean',0,'which',1,'wrap',[0 0 0]','prefix','p_');                          
%         jobForCoreg.ref = cellstr(plist(subjectNum).positiveFlairImageFile);
%         jobForCoreg.source = cellstr(plist(subjectNum).KNESeptumMaskFile);
%         jobForCoreg.other = cellstr(''); 
%         jobForCoreg.roptions = resliceOptionFlags;
%         coregOutput = spm_run_coreg_reslice(jobForCoreg);
%         
%         clear sn_flags V VO coregOptionFlags resliceOptionFlags jobForCoreg coregOutput;
%         
%         imageName = plist(subjectNum).skullStrippedFile;
%         [H,filetype,fileprefix,machine] = load_nii_hdr(imageName);
%         I = load_nii_img(H,filetype,fileprefix,machine);
%         
%         SeptNm = plist(subjectNum).pKNECereSeptumMaskFile;
%         [Hs,filetype,fileprefix,machine] = load_nii_hdr(SeptNm);
%         Is = load_nii_img(Hs,filetype,fileprefix,machine);
%         
%         [tempd, tempf] = fileparts(plist(subjectNum).KNECereSeptumMaskFile);
%         p = fullfile(tempd,[tempf '.img']);
%         
%         H.dime.datatype = 4; 
%         H.dime.scl_slope = 1;
%         b_out_nii.hdr = H;
%         b_out_nii.img = Is;
%         save_nii(b_out_nii, p);
%         
%         clear imageName H I SeptNm Hs Is p tempd tempf b_out_nii filetype fileprefix machine
%     end
    %
    % PROCESS Step: Main routine for WMH
    %       
    if DO_MAIN_ROUTINE_FOR_WMH == 1,
        fprintf('Step 7: Main routine for WMH\n');
        cd(char(plist(subjectNum).scanPath));
        
        imageName = plist(subjectNum).skullStrippedFile;
        outName = plist(subjectNum).premainWMHFile;
        outNameZscore = plist(subjectNum).mainWMHZscoreFile;
        
        [H,filetype,fileprefix,machine] = load_nii_hdr(imageName);
        I = load_nii_img(H,filetype,fileprefix,machine);   
        fid = fopen(plist(subjectNum).diaryFile,'a+');
        fid2 = fopen('Dauc_Ze_BrainVol.xls','a+');
        
        J = double(I(I>0));
        
        % Making histogram
        maxi = max(J);    mini = min(J);    binrange = (maxi - mini);     binCount = binrange;
        [S, x] = hist(J, binCount);
        Sorg = S;
        SforGaussfit = S;
        [PeakValue, PeakMode] = max(SforGaussfit);
        PeakMode = x(PeakMode);
        
        % Gaussian fitting   
        fit_result=fit(x',SforGaussfit','gauss1');
        MeanGF=fit_result.b1;
        SDGF=fit_result.c1/sqrt(2);
        a=fit_result.a1;
        
        % Calculating AUC of histogram and Gaussian fitted curve at x>MeanGF
        gaussian_data_point=a*exp(-((x-MeanGF).^2/(2*SDGF^2)));
        [temp, index_mean]=min(abs(x - MeanGF));
        Len=length(x);
        DUC = zeros(1,Len);
        DUC(index_mean:Len) = S(index_mean:Len)-gaussian_data_point(index_mean:Len);        
        
        startingIndex = index_mean;
        if optionSearchingStartingPointForDAUC == 1,
            startingIndex = index_mean + round(1.2815*SDGF); %startingIndex = mena + sigma(90%)
            GFSgm5 = index_mean + round(5*SDGF);
            for tmpIndex = startingIndex:GFSgm5,
                if S(tmpIndex) > gaussian_data_point(tmpIndex),
                    startingIndex = tmpIndex;
                    break;
                end
            end
             startingIndex = tmpIndex;
        elseif optionSearchingStartingPointForDAUC == 2,
            lowerBoundStartingIndex = index_mean + round(1.2815*SDGF);
            upperBoundStartingIndex = index_mean + round(5*SDGF);
            for tmpIndex = upperBoundStartingIndex:-1:lowerBoundStartingIndex,
                if DUC(tmpIndex) < thresholdForDecidingNegativeInterval,
                    if sum(DUC(tmpIndex-lengthForDecidingSign:tmpIndex)) < thresholdForDecidingNegativeInterval*lengthForDecidingSign,
                        startingIndex = tmpIndex;
                        break;
                    end
                end           
            end
            startingIndex = tmpIndex;
        elseif optionSearchingStartingPointForDAUC == 3,
            lowerBoundStartingIndex = index_mean + round(3.0*SDGF);
            upperBoundStartingIndex = index_mean + round(10*SDGF);
            if upperBoundStartingIndex > Len,
                upperBoundStartingIndex = Len;
            end
            
            for tmpIndex = upperBoundStartingIndex:-1:lowerBoundStartingIndex,
                if DUC(tmpIndex) < thresholdForDecidingNegativeInterval,
                    if sum(DUC(tmpIndex-lengthForDecidingSign:tmpIndex)) < thresholdForDecidingNegativeInterval*lengthForDecidingSign,
                        startingIndex = tmpIndex;
                        break;
                    end
                end           
            end
            startingIndex = tmpIndex;
        elseif optionSearchingStartingPointForDAUC == 5,
            lowerBoundStartingIndex = index_mean + round(5.5*SDGF);
            upperBoundStartingIndex = index_mean + round(10*SDGF);
            if upperBoundStartingIndex > Len,
                upperBoundStartingIndex = Len;
            end
            
            for tmpIndex = upperBoundStartingIndex:-1:lowerBoundStartingIndex,
                if DUC(tmpIndex) < thresholdForDecidingNegativeInterval,
                    if sum(DUC(tmpIndex-lengthForDecidingSign:tmpIndex)) < thresholdForDecidingNegativeInterval*lengthForDecidingSign,
                        startingIndex = tmpIndex;
                        break;
                    end
                end           
            end
            startingIndex = tmpIndex;
        end
         
        AUC_H = sum(S(startingIndex:Len));
        AUC_GF = sum(gaussian_data_point(startingIndex:Len));
        DAUC = abs(AUC_H - AUC_GF);
        DUC = zeros(1,Len);
        DUC(startingIndex:Len) = S(startingIndex:Len)-gaussian_data_point(startingIndex:Len);
        voxelVol = H.dime.pixdim(2) * H.dime.pixdim(3) * H.dime.pixdim(4);
        AUC_H = AUC_H * voxelVol;
        AUC_GF = AUC_GF * voxelVol;
        DAUC = DAUC * voxelVol;

        % Plotting results  
        if PLOT_HISTOGRAM_DO_MAIN_ROUTINE_FOR_WMH == 1,
            figure;
            plot(x,S,'b-');
            hold on;
            plot(x,gaussian_data_point,'r-');
            legend(sprintf('AUC_H = %d',round(AUC_H)),sprintf('AUC_G = %d', round(AUC_GF)));
            Y=plot(x,S,'b-');
            hold off;
        end
    
        % Calculate Cerebrum Volume
        [S2H,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).cereMaskFile);        
        S2I = load_nii_img(S2H,filetype,fileprefix,machine); 
        voxelVol2 = S2H.dime.pixdim(2) * S2H.dime.pixdim(3) * S2H.dime.pixdim(4);
        OrigImage2 = reshape(S2I,S2H.dime.dim(2)*S2H.dime.dim(3)*S2H.dime.dim(4),1);
        J2 = double(S2I(S2I>thresholdCerebrumInMainWMH));
        
        % Making histogram
        [S2, x2] = hist(J2, 2);
        Vol2 = S2(2)*voxelVol2;
        PARAMETERS_FOR_SEQUENTIAL_STEPS.CereVol(subjectNum) = Vol2;
         
        clear S2H S2I OrigImage2 J2 S2 x2 ;
         
        if normalizingBrainVolume == 1,   
            DAUC = DAUC/Vol2*AVERAGE_CERE_VOL;
        end         
    
        ZE = coeffZE*exp(expCoeffZE*DAUC)+convergingLine;
        if methodForDeterminingZo == 20100817,             
            ZE = coeffZE*DAUC+convergingLine; 
        elseif methodForDeterminingZo == 201106,
            ZE = BayesianCoeff1+sqrt(BayesianCoeff2+BayesianCoeff3*log(DAUC/(1000000-DAUC)));             
        end
        TE = MeanGF + ZE*SDGF;
        
        PARAMETERS_FOR_SEQUENTIAL_STEPS.ZE0(subjectNum) = ZE;
        PARAMETERS_FOR_SEQUENTIAL_STEPS.MeanGF(subjectNum) = MeanGF;
        PARAMETERS_FOR_SEQUENTIAL_STEPS.PeakMode(subjectNum) = PeakMode;
        PARAMETERS_FOR_SEQUENTIAL_STEPS.SDGF(subjectNum) = SDGF;
        PARAMETERS_FOR_SEQUENTIAL_STEPS.DAUC(subjectNum) = DAUC;
        PARAMETERS_FOR_SEQUENTIAL_STEPS.TE(subjectNum) = TE;
    
        % Making WML mask
        OrigImage = reshape(I,H.dime.dim(2)*H.dime.dim(3)*H.dime.dim(4),1);
        BinImage = zeros(H.dime.dim(2)*H.dime.dim(3)*H.dime.dim(4),1);
        ind = find(OrigImage > TE);
        for nn=1:length(ind)
             BinImage(ind(nn)) = 1;
        end
        PARAMETERS_FOR_SEQUENTIAL_STEPS.WMLVol(subjectNum) = sum(sum(sum(BinImage)));
        
        [tempd, tempf] = fileparts(outName);
        p = fullfile(tempd,[tempf '.img']);
        
        H.dime.datatype = 4; 
        H.dime.scl_slope = 1;
        b_out_nii.hdr = H;
        b_out_nii.img = BinImage;
        save_nii(b_out_nii, p);
        
        [piH,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).positiveFlairImageFile);
        piI = load_nii_img(piH,filetype,fileprefix,machine);   
        [tempd, tempf] = fileparts(outNameZscore);
        p = fullfile(tempd,[tempf '.img']);
        ZscoreImage = (double(piI) - MeanGF)/SDGF;
                          
        piH.dime.datatype = 16; % Floating point 32bit;  
        piH.dime.scl_slope = 1;
        b_out_nii.hdr = piH;
        b_out_nii.img = ZscoreImage;
        save_nii(b_out_nii, p);
        
        clear piI piH;
        
        % Save the results
        [pathstr, name, ext] = fileparts(imageName); 
        Output_Results = fullfile(pathstr, [name '_result' '.xls']);
        ImageID = strtok(name,'_');
        temp = num2cell([mini, maxi, binrange, MeanGF, SDGF, AUC_H, AUC_GF, DAUC, ZE, TE]);
        RESULT = cat(2,cellstr(ImageID),temp);
         
        ImageID2 = plist(subjectNum).imageID;    
        dateNtime = datestr(clock,30);
        CereVolume = PARAMETERS_FOR_SEQUENTIAL_STEPS.CereVol(subjectNum);
         
        fprintf(fid, '%s \t %s \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \n',plist(subjectNum).imageID, datestr(clock,30), [mini, maxi, binrange, MeanGF, SDGF, AUC_H, AUC_GF, DAUC, ZE, TE], PARAMETERS_FOR_SEQUENTIAL_STEPS.ZE0(subjectNum));
        fclose(fid);

        
        if PLOT_DAUC_DO_MAIN_ROUTINE_FOR_WMH == 1,
            figure('Name', plist(subjectNum).scanInputFile);
            hold on;
            orgY = plot(x,Sorg,'g-');
            Y=plot(x,S,'b-');
            plot(x,gaussian_data_point,'r-');
            plot(x, DUC,'k', 'LineWidth',1);
            plot([TE TE],[max(S)/2 0],'k--');
            plot([startingIndex startingIndex],[max(S)/2 0],'k:');
            legend('Original Histogram', 'Modified Histogram', 'Gaussian fit', sprintf('DAUC = %f',DAUC/1000),sprintf('TE(ZE) = %f(%f)\n', TE, ZE),sprintf('lower bound of DUC =%f\n', startingIndex));
            xlabel('Intensity');
            ylabel('# Voxels');
            axis([0 MeanGF*3 min(DUC) max(S)]);
            [scanPath, fname, fext] = fileparts(char(inImageFile(subjectNum,:)));
            print('-djpeg', strcat('Gaussian_fit_',num2str(int32(subjectNum)),'_',fname));
            [scanPath, fname, fext] = fileparts(char(inImageFile(subjectNum,:)));
            tmpSaveFile1 = strcat('hist_',num2str(int32(subjectNum)),'_',fname);
            save(tmpSaveFile1, 'S', 'Sorg');                
            hold off;
            close;
        end
        clear H I J x S BinImage OrigImage b_out_nii gaussian_data_point;   
    end 
    
    %
    % PROCESS Step: Do removing septum related regions
    %
    if DO_REMOVE_SEPTUM == 1,
        fprintf('Step 8: Do removing Septum related regions\n');
        
        % To remove septum related regions
        [Hs,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).KNECereSeptumMaskFile);
        Is = load_nii_img(Hs,filetype,fileprefix,machine); % Call subject's Septum box
        [Hwmh,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).premainWMHFile);
        Iwmh = load_nii_img(Hwmh,filetype,fileprefix,machine); % Call subject's preWMH from step 7
        
        tmpSeptumIdx = ones(size(Is));
        tmpSeptumIdx(find(Is >= thresholdBinarySeptumWMMask)) = 0;
        
        targetImage = double(Iwmh) .* double(tmpSeptumIdx);
        
        b_out_nii.hdr = Hwmh;
        b_out_nii.img = targetImage;
        save_nii(b_out_nii, plist(subjectNum).mainWMHFile);
           
        clear Hi Hm I Im targetImage b_out_nii;   
    end
    
    %
    % PROCESS Step: Do cerebrum WM masking into WMH
    %       
    if DO_CEREBRUM_WM_MASKING_WMH == 1,
        fprintf('Step 9: Do cerebrum WM masking into WMH\n');
        cd(char(plist(subjectNum).scanPath));

        [Hi,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).mainWMHFile);
        I = load_nii_img(Hi,filetype,fileprefix,machine);   
        [Hm,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).cereWMMaskFile);
        Im = load_nii_img(Hm,filetype,fileprefix,machine); 

        % To make mask
        Im = Im > thresholdForMask; 
        if size(I,1)~=size(Im,1)||size(I,2)~=size(Im,2)||size(I,3)~=size(Im,3),
            fprintf('Error: Check data & mask file dimension \n');
            size(I)
            size(Im)
            return;
        end
        targetImage = double(I) .* double(Im);
        if Hi.dime.datatype == 2, % It must be fixed !!! % temporarily, if it's pittsburgh binary data [0 ~ 255]
            Hi.dime.glmax = 1;
            Hi.dime.glmin = 0;
            Hi.hk.extens = 0;
            Hi.hist.originator = [fix(Hi.dime.dim(2)*0.5) fix(Hi.dime.dim(3)*0.5) fix(Hi.dime.dim(4)*0.5) 0 0];
            targetImage = targetImage>0;
            targetImage = uint8(targetImage);
        end
        b_out_nii.hdr = Hi;
        b_out_nii.img = targetImage;     
        save_nii(b_out_nii, plist(subjectNum).cereWMHFile);
            
        clear Hi Hm I Im targetImage J x S b_out_nii Hi;   
                           
        [Hi,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).cereWMHFile);
        I = load_nii_img(Hi,filetype,fileprefix,machine);   
        [Hwm,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).WMMaskFile);
        Iwm = load_nii_img(Hwm,filetype,fileprefix,machine);    
        Iwm = Hwm.dime.scl_slope * double(Iwm);
        Hwm.dime.scl_slope = 1;
        Iwm = Iwm > thresholdForWMMask;        
        
        I = I .* int16(Iwm); 
        b_out_nii.hdr = Hi;
        b_out_nii.img = I;     
        save_nii(b_out_nii, plist(subjectNum).maskedWMHFile);
            
        clear Hi Hwm I Iwm b_out_nii ;                    
    end
    
    %
    % PROCESS Step: Remove isolated small WMH
    %        
    if REMOVE_ISOLATED_SMALL_WMH == 1,
        fprintf('Step 10: Remove isolated small WMH \n');
        cd(char(plist(subjectNum).scanPath));
        
        [Hi,filetype,fileprefix,machine] = load_nii_hdr(plist(subjectNum).maskedWMHFile);
        I = load_nii_img(Hi,filetype,fileprefix,machine); 
        
        I = imfill(I,'holes');
        I = bwareaopen(I, thresholdForSmallWMH);
        b_out_nii.hdr = Hi;
        b_out_nii.img = I;     
        save_nii(b_out_nii, plist(subjectNum).cleanWMHFile);
            
        clear Hi I  b_out_nii ;            
    end   
    
    %
    % PROCESS Step: Correction of .hdr file
    %        
    if HDR_CORRECTION == 1,
        fprintf('Step 11: Correction of .hdr file\n');
        cd(char(plist(subjectNum).scanPath));
        
        FLAIRFileInfo = dir(plist(subjectNum).scanInputFile);
        WMHFileInfo = dir(plist(subjectNum).cleanWMHFile);
        FLAIRHdrFile = strrep(plist(subjectNum).scanInputFile, 'img', 'hdr');
        WMHHdrFile = strrep(plist(subjectNum).cleanWMHFile, 'img', 'hdr');
        
        if FLAIRFileInfo.bytes == WMHFileInfo.bytes
            delete(WMHHdrFile);
            copyfile(FLAIRHdrFile, WMHHdrFile);
        elseif FLAIRFileInfo.bytes == WMHFileInfo.bytes * 2
            cd(oldDir);
            MakeFLAIRPositiveData(plist(subjectNum).scanPath, plist(subjectNum).cleanWMHFile, plist(subjectNum).cleanWMHFile);
            delete(WMHHdrFile);
            copyfile(FLAIRHdrFile, WMHHdrFile);
        end
    end   
    
end   % SegmentWMH main loop end


cd(oldDir);

%----------------------------------------
% fillImage
%----------------------------------------
function F = fillImage(I,STRUCT_ELEM )
dim1 = size(I,1);
dim2 = size(I,2);
dim3 = size(I,3);
F = imclose(I, STRUCT_ELEM);

for n=1:dim3    % xy fill
    slice = reshape(F(:,:,n), dim1, dim2);
    F(:,:,n) = imfill(slice);
end

for n=1:dim2    % xz fill
    slice = reshape(F(:,n,:), dim1, dim3);
    F(:,n,:) = imfill(slice);
end

for n=1:dim1    % yz fill
    slice = reshape(F(n,:,:), dim2, dim3);
    F(n,:,:) = imfill(slice);
end
end   % Function fillImage end

end   % Function SegmentWMH end