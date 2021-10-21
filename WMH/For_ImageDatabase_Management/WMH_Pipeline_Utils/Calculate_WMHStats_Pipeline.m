
PVD_WMHFolder = '/media/wmhdb_mnt/4A_PVD_WMH';
PVD_WMHFiles = dir(fullfile(PVD_WMHFolder, 'PVD_clean_WMH_*.img'));
numPVDFiles = length(PVD_WMHFiles);

JVPVD_WMHFolder = '/media/wmhdb_mnt/4B_JVPVD_WMH';
JVPVD_WMHFiles = dir(fullfile(JVPVD_WMHFolder, 'JVPVD_clean_WMH_*.img'));
numJVPVDFiles = length(JVPVD_WMHFiles);

Subjects_PVD = cell(numPVDFiles,1);
Subjects_JVPVD = cell(numJVPVDFiles,1);

for idx = 1:numPVDFiles
   
    Subjects_PVD{idx,1} = PVD_WMHFiles(idx).name(16:30);
    
    PVD_WMHMask = load_untouch_nii(strcat(PVD_WMHFolder, '/', PVD_WMHFiles(idx).name));
        
    total_wmh_labels = length(find(PVD_WMHMask.img>0));
    pd_p_labels = length(find(PVD_WMHMask.img==1));
    pd_d_labels = length(find(PVD_WMHMask.img==2));
    
    WMHVoxelSize = PVD_WMHMask.hdr.dime.pixdim(2) * PVD_WMHMask.hdr.dime.pixdim(3) * PVD_WMHMask.hdr.dime.pixdim(4);
    
    PD_PVWMHLabels(idx,1) = pd_p_labels;
    PD_DWMHLabels(idx,1)  = pd_d_labels;
    
    PD_TotalWMH_Volume(idx,1) = total_wmh_labels * WMHVoxelSize;
    PD_PVWMH_Volume(idx,1) = pd_p_labels * WMHVoxelSize;
    PD_DWMH_Volume(idx,1)  = pd_d_labels * WMHVoxelSize;
  
end

for idx = 1:numJVPVDFiles
   
    Subjects_JVPVD{idx,1} = JVPVD_WMHFiles(idx).name(18:32);
    
    JVPVD_WMHMask = load_untouch_nii(strcat(JVPVD_WMHFolder, '/', JVPVD_WMHFiles(idx).name));
        
    total_wmh_labels = length(find(JVPVD_WMHMask.img>0));
    jpd_j_labels = length(find(JVPVD_WMHMask.img==1));
    jpd_p_labels = length(find(JVPVD_WMHMask.img==2));
    jpd_d_labels = length(find(JVPVD_WMHMask.img==3));
    
    WMHVoxelSize = JVPVD_WMHMask.hdr.dime.pixdim(2) * JVPVD_WMHMask.hdr.dime.pixdim(3) * JVPVD_WMHMask.hdr.dime.pixdim(4);
    
    JPD_JVWMHLabels(idx,1) = jpd_j_labels;
    JPD_PVWMHLabels(idx,1) = jpd_p_labels;
    JPD_DWMHLabels(idx,1)  = jpd_d_labels;
    
    JPD_TotalWMH_Volume(idx,1) = total_wmh_labels * WMHVoxelSize;
    JPD_JVWMH_Volume(idx,1) = jpd_j_labels * WMHVoxelSize;
    JPD_PVWMH_Volume(idx,1) = jpd_p_labels * WMHVoxelSize;
    JPD_DWMH_Volume(idx,1)  = jpd_d_labels * WMHVoxelSize;
  
end

FinalWMHlabelstats_PVD   = table(PD_PVWMHLabels, PD_DWMHLabels);
FinalWMHlabelstats_JVPVD = table(JPD_JVWMHLabels, JPD_PVWMHLabels, JPD_DWMHLabels);

FinalWMHStats_PVD   = table(Subjects_PVD, PD_TotalWMH_Volume, PD_PVWMH_Volume, PD_DWMH_Volume);
FinalWMHStats_JVPVD = table(Subjects_JVPVD, JPD_TotalWMH_Volume, JPD_JVWMH_Volume, JPD_PVWMH_Volume, JPD_DWMH_Volume);
                  
                  