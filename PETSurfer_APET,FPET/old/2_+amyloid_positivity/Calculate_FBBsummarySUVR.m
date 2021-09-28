% Calculates Cortical Summary ROI SUVR as described by Landau in ADNI document.
%   - 'Florbetapir processing methods'
%   - 'Florbetaben processing and positivity threshold derivation'
% Use this SUVR to determine amyloid-positive vs amyloid-negative subjects.
%   - For AV45, threshold is 1.11
%   - For FBB, threshold is 1.20
% To index table-variables, code used {} bracket instead of the [] bracket.
%
% * NUMBER OF SUBJECTS IN GTMSTATS AND ASEG/APARCSTATS MUST BE SAME.
% * ONLY RAW CSV FILES MUST BE INPUT.
% * MUST BE FROM FREESURFER V.6.
% * MAKE SURE SUBJECTS IN GTMSTATS AND ASEG/APARCSTATS ARE IN SAME ORDER***
%   - to make sure, input gtmpvclist that is a csv file.

% ========================= ROI Column Dictionary =========================
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

% =========================================================================

% Adjust settings as needed 
% (should all be unedited .csv files! .xls files usually result in errors):
filename_gtmpvclist = 'K:\7_TextureABAD\200908_676ppl_gtmpvclist.csv'; 
filename_gtmstats = 'K:\7_TextureABAD\200908_676ppl_gtmstats_norescale.csv'; 
filename_aseg = 'K:\7_TextureABAD\200909_676ppl_asegstats.csv';
filename_aparc_lh = 'K:\7_TextureABAD\200909_676ppl_lh_volume.csv';
filename_aparc_rh = 'K:\7_TextureABAD\200909_676ppl_rh_volume.csv';


%-------------------------------------------------------------------------------------------------------------------------------------------------------
% 000 . 
% Codified version of:
% 'Import Data --> select csv file --> Table --> Import Selection'
gtmpvclist = import_gtmpvclist_csv(filename_gtmpvclist);
orig_gtmstats = import_gtmstats_csv(filename_gtmstats);

orig_aseg = import_aseg_csv(filename_aseg);
orig_aparc_lh = import_aparc_lh_csv(filename_aparc_lh);
orig_aparc_rh = import_aparc_rh_csv(filename_aparc_rh);

% 00.
% Collect first columns (subject) of each table, for easy reference:
Subjects_matrix = [gtmpvclist orig_aseg(:,1) orig_aparc_lh(:,1) orig_aparc_rh(:,1) ];
    
    % CHECK if hospnum of gtmstats and aseg/aparcstats match.
    hospnum_gtmpvclist = char(table2cell(gtmpvclist));
    hospnum_aseg = char(table2cell(orig_aseg(:,1)));
    hospnum_aparc_lh = char(table2cell(orig_aparc_lh(:,1)));
    hospnum_aparc_rh = char(table2cell(orig_aparc_rh(:,1)));
    
    hospnum_gtmpvclist = cellstr(hospnum_gtmpvclist(:,13:20)); % 'gtmpvc_flip_11111111_yymmdd~' = 13:20th characters
    hospnum_aseg = cellstr(hospnum_aseg(:,2:9));               %'r11111111_yymmdd~' = 2:9th characters
    hospnum_aparc_lh = cellstr(hospnum_aparc_lh(:,2:9));
    hospnum_aparc_rh = cellstr(hospnum_aparc_rh(:,2:9));
       
    Subjects_matrix_hospnumonly = [hospnum_gtmpvclist hospnum_aseg hospnum_aparc_lh hospnum_aparc_rh];

    if min(strcmp(Subjects_matrix_hospnumonly(:,1), Subjects_matrix_hospnumonly(:,2)))==1 ...
            && min(strcmp(Subjects_matrix_hospnumonly(:,1), Subjects_matrix_hospnumonly(:,3)))==1 ...
            && min(strcmp(Subjects_matrix_hospnumonly(:,2), Subjects_matrix_hospnumonly(:,3)))==1 ...
            && min(strcmp(Subjects_matrix_hospnumonly(:,3), Subjects_matrix_hospnumonly(:,4)))==1
        a='good';
    else
        error('Subject hospnum of gtmstats, aseg, lhrhaparc DO NOT MATCH. Check Subjects_matrix_hospnumonly')
    end
    
% 0.
% Rearrange column order:
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
suv_x_volume_frontsubrois = 	 roi_gtmstats{:, 2:19} .* roi_aparc{:, 2:19};
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






