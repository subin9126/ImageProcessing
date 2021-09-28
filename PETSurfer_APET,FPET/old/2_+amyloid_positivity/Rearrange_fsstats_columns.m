
filename_aseg = 'asegstats_NIPA_191202_before.csv';
filename_aparc_lh = '';
filename_aparc_rh = '';

aseg_rearrange = [1 2 3 5 5 6 7 8 9 13 14 16 17 18 19 36 39 50 53 64 20 21 22 23 24 25 26 27 28 29 30 31 32 33 37 40 51 54 65 10 11 12 15 34 35 38 41 42 43 45 45 46 47 48 49 52 55 56 57 58 59 60 61 62 63 66 67 ];
aparc_rearrange = [1 6 16 7 33 30 15 9 34 2 28 27 4 18 19 20 12 14 32 24 17 22 31 29 8 25 26 3 23 10 13 21 5 11 35 ];

%--------------------------------------------------------------------

% Codified versions of:
% 'Import Data --> select csv file --> Table --> Import Selection'
orig_aseg = import_aseg(filename_aseg);
orig_aparc_lh = import_aparc_lh(filename_aparc_lh);
orig_aparc_rh = import_aparc_rh(filename_aparc_rh);

% Rearrange column order:
new_aseg = orig_aseg(:, aseg_rearrange);
new_aparc_lh = orig_aparc_lh(:, aparc_rearrange);
new_aparc_rh = orig_aparc_rh(:, aparc_rearrange);

% Save new tables: