clear
LOCATION = '\\Recodeimage\mri_dicom';
Result_Loc = '\\Recodeimage\mri_dicom\List\NAS_DICOMSNU\20210326_RECODEIMAGE';
a=1;
for i = 10:34
    
    if i == 34
        i = 'C1';
    else
    end
    
    HOSP_FOLDER = [num2str(i) 'XXXXXX'];
    SRC_FOLDER = [LOCATION '/' HOSP_FOLDER];
    
    cd(SRC_FOLDER);
    
    subjfolders = dir(SRC_FOLDER);
    
    b = 1;
    while length(subjfolders(b).name) < 15
        b = b+1;
    end
    
    subjfolders = subjfolders(b:end, :);
    
    for idx = 1:length(subjfolders)
        
        cd([SRC_FOLDER '/' subjfolders(idx).name]);
        TXT_IF = dir('**/*.txt');
        
        for ii = 1:length(TXT_IF)
            matrix_e{a,:} = strcat(string(TXT_IF(ii).folder),'\',string(TXT_IF(ii).name));
%             matrix_E(a,:) = [matrix_e{a,:}]
            a=a+1;
        end
    end
end

writecell(matrix_e,fullfile(Result_Loc,'error.txt'))
