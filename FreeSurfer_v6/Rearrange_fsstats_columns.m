
% For extracting specified ROI stats from fsstats files

%---------Specify accoringly-------------------------------------------
Folder = 'K:\7_TextureABAD';

filename_aseg = '200902_textureprd_addmci_205ppl_asegstats.csv';
filename_aparc_lh = '200902_textureprd_addmci_205ppl_lh_volume.csv';
filename_aparc_rh = '200902_textureprd_addmci_205ppl_rh_volume.csv';
filename_aparc_thick_lh = '200902_textureprd_addmci_205ppl_lh_thickness.csv';
filename_aparc_thick_rh = '200902_textureprd_addmci_205ppl_rh_thickness.csv';

% Input column indices of desired ROIs:
aseg_rearrange = [1 67 13 28];
aparc_rearrange = [1 10 25 ];

%---------Do not change below------------------------------------------
filename_aseg = [Folder '\' filename_aseg];
filename_aparc_lh = [Folder '\' filename_aparc_lh];
filename_aparc_rh = [Folder '\' filename_aparc_rh];
filename_aparc_thick_lh = [Folder '\' filename_aparc_thick_lh];
filename_aparc_thick_rh = [Folder '\' filename_aparc_thick_rh];


% Codified versions of:
% 'Import Data --> select csv file --> Table --> Import Selection'
orig_aseg = import_aseg_csv(filename_aseg);
orig_aparc_lh = import_aparc_lh_csv(filename_aparc_lh);
orig_aparc_rh = import_aparc_rh_csv(filename_aparc_rh);
orig_aparc_thick_lh = import_aparc_lh_csv(filename_aparc_thick_lh);
orig_aparc_thick_rh = import_aparc_lh_csv(filename_aparc_thick_rh);


% Rearrange column order:
new_aseg = orig_aseg(:, aseg_rearrange);
new_aparc_lh = orig_aparc_lh(:, aparc_rearrange);
new_aparc_rh = orig_aparc_rh(:, aparc_rearrange);
new_aparc_thick_lh = orig_aparc_thick_lh(:, aparc_rearrange);
new_aparc_thick_rh = orig_aparc_thick_rh(:, aparc_rearrange);


