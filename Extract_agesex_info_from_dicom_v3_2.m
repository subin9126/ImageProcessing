clear

Search_Dir = '/media/mri_dicom_mnt/20200709';
cd(Search_Dir)
contents_pre = dir('./*'); 

contents = contents_pre(3:end); % delete the . and ./

numSubjects = length(contents); 
Matrix = cell(numSubjects,9);

for i = 1:numSubjects
    
    subject = contents(i).name;
    cd([Search_Dir '/' subject ])%'/T1'])
        
    % Scan for all files and bring the first dcm file
    % If subjectfolder empty, record subjectname only and skip to next
    % If subjectfolder not empty, record age and sex info also.
    dcmfiles = dir('./IM_*'); %dir('./*.dcm');
%     dcmfiles = dcmfiles(3:end);
    
    if isempty(dcmfiles)==1
        Matrix{i,1} = subject;

    elseif isempty(dcmfiles)==0
        try
        d = dicominfo(dcmfiles(1).name);
        Matrix{i,1} = subject;
        Matrix{i,2} = d.PatientID;
        Matrix{i,3} = d.PatientBirthDate;
        Matrix{i,4} = d.AcquisitionDate;
        Matrix{i,5} = d.PatientSex;
        Matrix{i,6} = d.Manufacturer;
        Matrix{i,7} = d.InstitutionName;
        Matrix{i,8} = d.ManufacturerModelName;
        Matrix{i,9} = d.StudyDescription;
        catch ME
            disp('unavailable');disp(subject);
            unavail_subj{i,1} = subject;
        end
        
        
        clear d
        
        %Age(i,1) = str2num(Matrix{i,6}(2:3));
        
       
    end
    
end

if exist('unavail_subj','var') == 1
    unavail_subj = unavail_subj(~cellfun('isempty',unavail_subj));
    % avail_sub = Matrix(~cellfun('isempty',Matrix));
end
