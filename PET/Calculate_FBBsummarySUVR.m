% About:
% - Calculates Cortical Summary ROI SUVR as described by Landau in ADNI document.
%   - 'Florbetapir processing methods'
%   - 'Florbetaben processing and positivity threshold derivation'
% - Use this SUVR to determine amyloid-positive vs amyloid-negative subjects.
%   - For AV45, threshold is 1.11
%   - For FBB, threshold is 1.20
%
% Input:
% CSV files as defined in the 'Specify Accordinly' section. 
%
% Output:
% FINAL - a nxm table where n is number of subjects and m columns are:
%           - first column is subjectname
%           - second column is Cortical Summary SUVR
%           - third to last columns are SUVR of ROIs
%
% * NUMBER OF SUBJECTS IN GTMSTATS AND ASEG/APARCSTATS MUST BE SAME.
% * ONLY RAW CSV FILES MUST BE INPUT.
% * MUST BE FROM FREESURFER V.6.
% * MAKE SURE SUBJECTS IN GTMSTATS AND ASEG/APARCSTATS ARE IN SAME ORDER***
%   - to make sure, input gtmpvclist that is a csv file.



clear 

% ++++++++++++++++++++Specify Accordingly+++++++++++++++++++++++++++++++++++++++++++++++++++++
% Fill in path to specified files.
% (should all be unedited .csv files! .xls files usually result in errors):
filename_gtmpvclist = <path to .csv file version of gtmpvclist from '5_extract_PVCvalues'> 
filename_gtmstats = <path to .csv file output of gtmstats from '5_extract_PVCvalues'>  
filename_aseg = <path to .csv file asegstats2table output of '5_Extract_FS_stats'>
filename_aparc_lh = <path to .csv file lh aparcstats2table output of '5_Extract_FS_stats'>
filename_aparc_rh = <path to .csv file rh aparcstats2table output of '5_Extract_FS_stats'>

%++++++++++++++++++++Do Not Change Below++++++++++++++++++++++++++++++++++++++++++++++++++++
%------------------------------------------------------------------------------------------
% ROI Column Dictionary.
% gtmpvc stats:
idx_reference = [1 3 4 17 18]; % whole cerebellum
idx_frontsubroi = [36 44 46 50 51 52 59 60 64 70 78 80 84 85 86 93 94 98];
idx_cingsubroi = [35 42 55 58 69 76 89 92];
idx_latparietsubroi = [40 57 61 63 74 91 95 97];
idx_lattempsubroi = [47 62 81 96];

idx_FBBsummaryROI = [1 idx_frontsubroi idx_cingsubroi idx_latparietsubroi idx_lattempsubroi];
REF_columns_gtmpvc = idx_reference;
ROI_columns_gtmpvc = idx_FBBsummaryROI;

% aseg stats:
idx_reference_vol = [1 4 5 22 23]; % whole cerebellum
% aparc stats (***Must be from FreeSurfer v6!! Has 37 columns total***):
idx_frontsubroi_vol = [4 12 14 18 19 20 27 28 32];
idx_cingsubroi_vol = [3 10 23 26];
idx_latparietsubroi_vol = [8 25 29 31];
idx_lattempsubroi_vol = [15 30];

%------------------------------------------------------------------------------------------
% 000 . 
% Load files (codified version of 'Import Data --> select csv file --> Table --> Import Selection'):
gtmpvclist = import_gtmpvclist_csv(filename_gtmpvclist);
orig_gtmstats = import_gtmstats_csv(filename_gtmstats);

orig_aseg = import_aseg_csv(filename_aseg);
orig_aparc_lh = import_aparc_lh_csv(filename_aparc_lh);
orig_aparc_rh = import_aparc_rh_csv(filename_aparc_rh);

% 00.
% Collect first columns (subject) of each table, for easy reference:
Subjects_matrix = [gtmpvclist orig_aseg(:,1) orig_aparc_lh(:,1) orig_aparc_rh(:,1) ];
    
% 0.
% Rearrange column order by lobe:
ref_gtmstats = orig_gtmstats(:, REF_columns_gtmpvc);
roi_gtmstats = orig_gtmstats(:, ROI_columns_gtmpvc); 
               % 1: subject column / 2~19: lhrh_front / 20~27: lhrh_cing / 28~35: lhrh_latpariet / 36~39: lhrh_lattemp
               
ref_aseg = orig_aseg(:, idx_reference_vol);
roi_aparc = [orig_aparc_lh(:,1) ...
             orig_aparc_lh(:,idx_frontsubroi_vol) orig_aparc_rh(:,idx_frontsubroi_vol) ...
             orig_aparc_lh(:,idx_cingsubroi_vol) orig_aparc_rh(:,idx_cingsubroi_vol) ...
             orig_aparc_lh(:,idx_latparietsubroi_vol) orig_aparc_rh(:,idx_latparietsubroi_vol) ...
             orig_aparc_lh(:,idx_lattempsubroi_vol) orig_aparc_rh(:,idx_lattempsubroi_vol)]; 
             % 1: subject column / 2~19: lhrh_front / 20~27: lhrh_cing / 28~35: lhrh_latpariet / 36~39: lhrh_lattemp
             
if size(roi_gtmstats,1) ~= size(roi_aparc,1) ...
        || size(roi_gtmstats,2) ~= size(roi_aparc,2) ...
        || size(roi_gtmstats,3) ~= size(roi_aparc,3) 
    error('Matrix size of roi_gtmstats and roi_aparc are different')
end
             
%------------------------------------------------------------------------------------------
% Calculate Cortical Summary SUVR and Amyloid Positivity
% 1. 
% Calculate Reference Region's SUV:
suv_ref = mean(ref_gtmstats{:, 2:end}, 2); 
                                % returns ref suv for each subject 
 
% Section 2 does the following calculation for each of the 4 main cortical regions:
% Formula for weighted average SUV of each main cortical region:
%    ((subregion1_FBBmean x subregion1_volume) + (subregion2_FBBmean x subregion2_volume) + ... + (subregionN_FBBmean x subregionN_volume))
%     / (subregion1_volume + subregion2_volume + ... + subregionN_volume)
%
% 2-1.
% Calculate total volume of each main cortical area, for each subject:
totalvolume_front =     sum( [orig_aparc_lh{:,idx_frontsubroi_vol} orig_aparc_rh{:,idx_frontsubroi_vol}] ,2);
totalvolume_cing =      sum( [orig_aparc_lh{:,idx_cingsubroi_vol} orig_aparc_rh{:,idx_cingsubroi_vol}] ,2);
totalvolume_latpariet = sum( [orig_aparc_lh{:,idx_latparietsubroi_vol} orig_aparc_rh{:,idx_latparietsubroi_vol}] ,2);
totalvolume_lattemp =   sum( [orig_aparc_lh{:,idx_lattempsubroi_vol} orig_aparc_rh{:,idx_lattempsubroi_vol}] ,2);

% 2-2.
% SUVxVOLUME of each SUBROI of each of 4 main cortical regions.
% Multiply roi_gtmstats and roi_aparc for each main cortical area:
suv_x_volume_frontsubrois =   roi_gtmstats{:, 2:19} .* roi_aparc{:, 2:19};
suv_x_volume_cingsubrois =       roi_gtmstats{:,20:27} .* roi_aparc{:,20:27};
suv_x_volume_latparietsubrois =  roi_gtmstats{:,28:35} .* roi_aparc{:,28:35};
suv_x_volume_lattempsubrois =    roi_gtmstats{:,36:39} .* roi_aparc{:,36:39};

% 2-3.
% WEIGHTED MEAN SUV of each of 4 main cortical regions.
% Sum each main cortical area SUVxVOLUME matrix across subregions
% Divide that by the main cortical area total volume:
weighted_avg_suv_front =      sum(suv_x_volume_frontsubrois,2) ./totalvolume_front;
weighted_avg_suv_cing =       sum(suv_x_volume_cingsubrois,2) ./totalvolume_cing;
weighted_avg_suv_latpariet =  sum(suv_x_volume_latparietsubrois,2) ./totalvolume_latpariet;
weighted_avg_suv_lattemp =    sum(suv_x_volume_lattempsubrois,2) ./totalvolume_lattemp;


% 3.
% CORTICAL SUMMARY ROI SUV:
CorticalSummaryROISUV = (weighted_avg_suv_front + weighted_avg_suv_cing + weighted_avg_suv_latpariet + weighted_avg_suv_lattemp) / 4;

% 4.
% CORTICAL SUMMARY ROI SUVR:
CorticalSummaryROISUVR = CorticalSummaryROISUV ./ suv_ref;


%------------------------------------------------------------------------------------------
% Organize raw data into bilateral ROI SUVR with cortical summary score
% Output: 'FINAL' table

% 5. Rearrange suv values of ROI in following order:
lh_roinames = {'LeftThalamusProper','LeftCaudate','LeftPutamen','LeftPallidum','LeftHippocampus','LeftAmygdala','LeftAccumbensarea','LeftVentralDC','Leftchoroidplexus','ctxlhbankssts','ctxlhcaudalanteriorcingulate','ctxlhcaudalmiddlefrontal','ctxlhcuneus','ctxlhentorhinal','ctxlhfrontalpole','ctxlhfusiform','ctxlhinferiorparietal','ctxlhinferiortemporal','ctxlhinsula','ctxlhisthmuscingulate','ctxlhlateraloccipital','ctxlhlateralorbitofrontal','ctxlhlingual','ctxlhmedialorbitofrontal','ctxlhmiddletemporal','ctxlhparacentral','ctxlhparahippocampal','ctxlhparsopercularis','ctxlhparsorbitalis','ctxlhparstriangularis','ctxlhpericalcarine','ctxlhpostcentral','ctxlhposteriorcingulate','ctxlhprecentral','ctxlhprecuneus','ctxlhrostralanteriorcingulate','ctxlhrostralmiddlefrontal','ctxlhsuperiorfrontal','ctxlhsuperiorparietal','ctxlhsuperiortemporal','ctxlhsupramarginal','ctxlhtemporalpole','ctxlhtransversetemporal'};
rh_roinames = {'RightThalamusProper','RightCaudate','RightPutamen','RightPallidum','RightHippocampus','RightAmygdala','RightAccumbensarea','RightVentralDC','Rightchoroidplexus','ctxrhbankssts','ctxrhcaudalanteriorcingulate','ctxrhcaudalmiddlefrontal','ctxrhcuneus','ctxrhentorhinal','ctxrhfrontalpole','ctxrhfusiform','ctxrhinferiorparietal','ctxrhinferiortemporal','ctxrhinsula','ctxrhisthmuscingulate','ctxrhlateraloccipital','ctxrhlateralorbitofrontal','ctxrhlingual','ctxrhmedialorbitofrontal','ctxrhmiddletemporal','ctxrhparacentral','ctxrhparahippocampal','ctxrhparsopercularis','ctxrhparsorbitalis','ctxrhparstriangularis','ctxrhpericalcarine','ctxrhpostcentral','ctxrhposteriorcingulate','ctxrhprecentral','ctxrhprecuneus','ctxrhrostralanteriorcingulate','ctxrhrostralmiddlefrontal','ctxrhsuperiorfrontal','ctxrhsuperiorparietal','ctxrhsuperiortemporal','ctxrhsupramarginal','ctxrhtemporalpole','ctxrhtransversetemporal'};

rearrange_lh_asegaparc_idx = [5 6 7 8 10 11 13 14 15 34 35 36 37 38 64 39 40 41 67 42 43 44 45 46 47 49 48 50 51 52 53 54 55 56 57 58 59 60 61 62 63 65 66];
rearrange_rh_asegaparc_idx = [19 20 21 22 23 24 25 26 27 68 69 70 71 72 98 73 74 75 101 76 77 78 79 80 81 83 82 84 85 86 87 88 89 90 91 92 93 94 95 96 97 99 100];
rearranged_suv_lh_asegaparc = table2array(orig_gtmstats(:,rearrange_lh_asegaparc_idx));
rearranged_suv_rh_asegaparc = table2array(orig_gtmstats(:,rearrange_rh_asegaparc_idx));


% 6. Sum lh and rh of each roi:
bilateral_roinames = {'Cerebellum','ThalamusProper','Caudate','Putamen','Pallidum','Hippocampus','Amygdala','Accumbensarea','VentralDC','choroidplexus','bankssts','caudalanteriorcingulate','caudalmiddlefrontal','cuneus','entorhinal','frontalpole','fusiform','inferiorparietal','inferiortemporal','insula','isthmuscingulate','lateraloccipital','lateralorbitofrontal','lingual','medialorbitofrontal','middletemporal','paracentral','parahippocampal','parsopercularis','parsorbitalis','parstriangularis','pericalcarine','postcentral','posteriorcingulate','precentral','precuneus','rostralanteriorcingulate','rostralmiddlefrontal','superiorfrontal','superiorparietal','superiortemporal','supramarginal','temporalpole','transversetemporal'};

rearranged_suv_bilateral_ref_and_asegaparc = [suv_ref (rearranged_suv_lh_asegaparc + rearranged_suv_rh_asegaparc)];
T_Rearranged_suv_ref_and_bilateral = array2table( rearranged_suv_bilateral_ref_and_asegaparc, 'VariableNames', append('suv_', bilateral_roinames));


% 7. Calculate suvr from the rearranged.
Rearranged_SUVR = rearranged_suv_bilateral_ref_and_asegaparc(:,2:end) ./ suv_ref;
T_Rearranged_SUVR = array2table( Rearranged_SUVR, 'VariableNames', append('suvr_', bilateral_roinames(2:end)) );


% 8. Combine all into one (FINAL):
FINAL = [Subjects_matrix(:,end) array2table(CorticalSummaryROISUVR, 'VariableNames', {'CorticalSummarySUVR'}) T_Rearranged_SUVR];
FINAL.Properties.VariableNames

%------------------------------------------------------------------------------------------
