function Make_JVPVD_WMHMASK_Pipeline(cleanWMHMask, flairregFSMask, DestFolder, VFolder, ROItype)

    % Scan/Create/Load files
    [pathstr, wmhname, wmhext] = fileparts(cleanWMHMask);
    [pathstr, fsname, fsext] = fileparts(flairregFSMask);
    
    WMHMask = load_untouch_nii(cleanWMHMask); 
    FSMask = load_untouch_nii(flairregFSMask);
    
    JVPVD_WMHMASK = WMHMask; 
    JVPVD_WMHMASK.img = zeros(size(WMHMask.img));
    
    
    % Make Ventricle Mask if does not exist:
    flairreg_ventricle_subj = [VFolder '/flairreg_ventricle_' fsname fsext];
    if ~exist(flairreg_ventricle_subj, 'file')
        VentricleLabels = [4 5 14 15 43 44 72];
        VentricleIdx = ismember(FSMask.img, VentricleLabels);
        FSMask.img(VentricleIdx==1) = 1; FSMask.img(VentricleIdx==0) = 0;
        VentricleMask = FSMask;
        save_untouch_nii(VentricleMask, flairreg_ventricle_subj);
    elseif exist(flairreg_ventricle_subj, 'file')
        VentricleMask = load_untouch_nii(flairreg_ventricle_subj);
    end
    
    WMHMask.img = double(WMHMask.img);      
    
    JVPVD_WMHMASK.img = MaskSubWMHwithVentricle_Pipeline(WMHMask.img, VentricleMask, ROItype); 
    
    save_untouch_nii(JVPVD_WMHMASK, strcat(DestFolder,'/JVPVD_',wmhname,wmhext));
    
end
