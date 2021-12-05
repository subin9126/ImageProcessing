clear
LOCATION = '';
Result_Loc = 'C:\Users\ReCODe_GAAIN\Desktop\Result';
a=1;
for i = 10:34
    
    if i == 34
        i = 'C1';
    else
    end
    
    HOSP_FOLDER = [num2str(i) 'XXXXXX'];
    SRC_FOLDER = [LOCATION '/' HOSP_FOLDER];
    SRC_FOLDER_2 = [Result_Loc '/' HOSP_FOLDER];
    cd(SRC_FOLDER);
    
    subjfolders = dir(SRC_FOLDER);
    
    b = 1;
    while length(subjfolders(b).name) < 15
        b = b+1;
    end
    
    subjfolders = subjfolders(b:end, :);

    for idx = 1:length(subjfolders)
        mkdir(SRC_FOLDER_2, subjfolders(idx).name);
        cd([SRC_FOLDER '/' subjfolders(idx).name]);
        hdr_IF = dir('**/*.hdr');
        img_IF = dir('**/*.img');
        for iii = 1:size(hdr_IF)
            copyfile(append(hdr_IF(iii).folder,'\',hdr_IF(iii).name), append(SRC_FOLDER_2,'\',subjfolders(idx).name));
            copyfile(append(img_IF(iii).folder,'\',img_IF(iii).name), append(SRC_FOLDER_2,'\',subjfolders(idx).name));
        end
    end
end
