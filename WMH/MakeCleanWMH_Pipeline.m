function MakeCleanWMH_Pipeline(OrigWMHMask, OrigFSMask, SIDEFolder, DestFolder)

    % 0. Load/Scan/Create files
    WMHMask = load_untouch_nii(OrigWMHMask);
    FSMask = load_untouch_nii(OrigFSMask);
    
    [pathstr, wmhname, wmhext] = fileparts(OrigWMHMask);
    [pathstr, fsname, fsext] = fileparts(OrigFSMask);
    
    Clean_WMHMask = WMHMask; 
    Clean_WMHMask.img = zeros(size(WMHMask));
    
    
%     % 1. Extract ventricle, wm parts only from FS mask. <- This results in removal of some valid WMH.
%     VentricleLabels = [4 5 14 15 43 44 72];
%     WMLabels = [2 7 41 46 3000:3035 4000:4035 5001 5002];
%     
%     VentricleIdx = ismember(FSMask.img, VentricleLabels);
%     WMIdx= ismember(FSMask.img, WMLabels);
% 
%     FSMask.img(VentricleIdx==0|WMIdx==0) = 0; FSMask.img(VentricleIdx==1|WMIdx==1) = 1;


    % 1. Remove cortical ribbon from FS mask (leaving only ventricle, wm, and some subcortical gm)
    %    Better to do this way than as above, because some WMH are included in
    %    areas segmented as subcortical GM, such as thalamus, caudate, etc.
    CorticalLabels = [0 1000:1035 2000:2035];
    CorticalIdx = ismember(FSMask.img, CorticalLabels);
    FSMask.img(CorticalIdx==0) = 1;         % Convert non-cortexlabel voxels to 1.
    FSMask.img(CorticalIdx==1) = 0;         % Convert cortexlabel voxels to 0
    FSMask.img(isnan(FSMask.img)==1) = 0;   % Some voxels in background are NaN. Also convert these to 0.
   
    save_untouch_nii(FSMask, strcat(SIDEFolder,'/noctx_fsmasks/noctx_',fsname,fsext)); % Just to doublecheck (noctx = no neocortex)
   
    % 1-2. Change class of FSMask to int16, to match class of WMHMask.
    %      FSMask class was single, but since its only values are 0 and 1, ok to switch it to integer class. 
    %      "Integers can only be combined with integers of the same class,
    %      or scalar doubles."
    %      Sometimes, both WMH and FSMASK are already class single. 
    if strcmp(class(WMHMask.img),'int16')==1
        FSMask.img = int16(FSMask.img);
    else
    end

       
    % 2. Multiply to remove parts of WMH mask that are in cortical areas or beyond
    Clean_WMHMask.img = WMHMask.img .* FSMask.img;    
    save_untouch_nii(Clean_WMHMask, strcat(DestFolder,'/clean_',wmhname,wmhext));
    
end
