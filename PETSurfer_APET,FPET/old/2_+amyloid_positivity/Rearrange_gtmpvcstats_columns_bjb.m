
% ========= ROI Column Dictionary =========
REF_default_columns = [1 3 4 17 18]; % whole cerebellum
ROI_default_columns = [1 5 19 6 20 7 21 8 22 10 23 11 24 34 68 35 69 36 70 37 71 38 72 39 73 40 74 41 75 42 76 43 77 44 78 45 79 46 80 47 81 48 82 49 83 50 84 51 85 52 86 53 87 54 88 55 89 56 90 57 91 58 92 59 93 60 94 61 95 62 96 63 97 64 98 65 99 66 100 67 101];
ROI_subin2020_columns = [1 36 70 59 93 50 84 52 86 41 75 47 81 40 74 63 97 57 91 42 76];
% =========================================

% Adjust settings as needed:
filename_gtmstats = 'K:\7_NewTopic\gtmstats_2020research_apet_norescale.csv'; % should be csv! xls file usually results in errors
REF_columns = REF_default_columns;
ROI_columns = ROI_default_columns;
% option_supply_subject_columns = 0; % optional; 0 = no, 1 = yes
option = 'bilateral'; % bilateral - calculates average SUV of lh and rh of each region 

%--------------------------------------------------------------------
% 0 . 
% Codified version of:
% 'Import Data --> select csv file --> Table --> Import Selection'
orig_gtmstats = import_gtmstats_as_table(filename_gtmstats);
%     % If subjectnames are supplied, modify first column of orig_gtmstats table now:
%     if option_supply_subject_columns == 1
%         subject_columns = input('Copy subjectnames from excel into the subject_columns variable, \n then click enter to move on')
%         orig_gtmstats{:,1} = subject_columns;
%     end

% Rearrange column order:
ref_gtmstats = orig_gtmstats(:, REF_columns);
roi_gtmstats = orig_gtmstats(:, ROI_columns); 

% 1. 
% Calculate Ref SUV:
suv_ref = mean(ref_gtmstats{:,2:end}, 2); 
                                % returns ref suv for each subject 

% Calculate ROI SUV:
if strfind(option, 'bilateral') == 1
    numroi_lhrh = size(roi_gtmstats,2) - 1; 
                                % exclude subjects column (first) from counting
    % Initialize:  
    suv_roi_bilateral = zeros(size(roi_gtmstats));
    suv_roi_bilateral_table = array2table( zeros( size(roi_gtmstats,1),(numroi_lhrh/2)+1) );
                                % create table of size: (numsubjects) x (subject column + num bilateral roi columns)
    i = 0;
    
    % Calculate bilateral ROI SUV (average the lh and rh)
    for n = 2:2:(numroi_lhrh) 
                        % 2: to start from first roi rather than from subject column
                        % 2: to for-loop by 2;
                        % *** ASSUMES that lh and rh of same ROI occur consecutively (next to each other) ***
        lh_roiname = char(roi_gtmstats.Properties.VariableNames(n));
        rh_roiname = char(roi_gtmstats.Properties.VariableNames(n+1));
       
        % Start_indexes for extracting ROI names from column headers:
        % Subcortical ROIs:
        if ~isempty(find(isstrprop(lh_roiname,'upper')))
            start_idx = find(isstrprop(lh_roiname,'upper'));
            start_idx = start_idx(2); 
                          % find indices where uppercase letters, and
                          % skip to next uppercase after 'Left' or 'Right'
                          % name examples: 'LeftThalamusProper', 'RightHippocampus'..etc.
        % Cortical ROIs:
        elseif isempty(find(isstrprop(lh_roiname,'upper')))
            start_idx = 6; 
                          % skip to next string after 'ctxlh' or 'ctxrh'
                          % name examples: 'ctxlhcaudalmiddlefrontal','ctxrhrostralmiddlefrontal' ,..etc
        else
            disp('ROI is neither subcortical nor cortical region ')
            return
        end
        
        % Compare extracted ROI names of the lh and rh roi columns to make sure they are same regions:
        if strfind(lh_roiname(start_idx:end), rh_roiname(start_idx:end)) == 1
            nn = n - 2*i;
                % Record average of lh and rh of current ROI (matrix version; might not need):
                suv_roi_bilateral(:,nn) = mean(roi_gtmstats{:,n:n+1}, 2);
                
                % Record average of lh and rh of current ROI (table version):
                % Create column name for suv table:
                suv_roi_bilateral_table.Properties.VariableNames(nn) = cellstr(strcat('suv_',lh_roiname(start_idx:end)));
                suv_roi_bilateral_table{:,nn} = (mean(roi_gtmstats{:,n:n+1}, 2));
                
                % Pre-make column names for SUVR table:
                roinames{1,nn} = strcat('SUVR_',lh_roiname(start_idx:end));
                
           i = i +0.5;
                    % nn and i are set so that averages of consecutive columns on gtmstats_roi 
                    % are rightly placed into the new suv_roi_bilateral_table.
                    % ex) gtmstats_roi(n,n+1) ------------- suv_roi_bilateral_table (nn)
                    %         column 2,3      ---average-->     column 2
                    %         column 4,5      ---average-->     column 3
                    %         column 6,7      ---average-->     column 4
                    %         column 8,9      ---average-->     column 5
                    % Results in equation of nn = n - 2*i, 
                    % where n starts from 2 and increases by 2 each time,
                    % and i starts from 0 and increases by 0.5 each time.
        else
            disp('Column names of subcortical rois (lh and rh) do not match')
            return
        end
        
    end

end

% 2. 
% Make SUVR table:
SUVR_roi_bilateral_table = array2table( zeros(size(roi_gtmstats,1),(numroi_lhrh/2)+1) );
SUVR_roi_bilateral_table.Properties.VariableNames(2:end) = roinames(2:end);
SUVR_roi_bilateral_table.Properties.VariableNames(1) = {'Subjects'};
propertiers = SUVR_roi_bilateral_table.Properties; %for easy access when copypasting to excel

% Calculate SUVR:
for s = 1:size(suv_roi_bilateral_table,1)
    SUVR_roi_bilateral_table{s,:} = suv_roi_bilateral_table{s,:} ./ suv_ref(s,1);
                    % Was hard to do column-by-column division with table
                    % So, divided ref suv from every roi suv, one subject at a time
end





