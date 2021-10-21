function [gtmpvclist] = import_gtmpvclist_csv(filename)
%% 텍스트 파일에서 데이터를 가져옵니다.
% 다음 텍스트 파일에서 데이터를 가져오기 위한 스크립트:
%
%    K:\7_TextureABAD\200901_addmci_204ppl_gtmpvclist.csv
%
% 선택한 다른 데이터나 텍스트 파일로 코드를 확장하려면 스크립트 대신 함수를 생성하십시오.

% MATLAB에서 다음 날짜에 자동 생성됨: 2020/09/02 15:02:56

%% 변수를 초기화합니다.
% filename = 'K:\7_TextureABAD\200901_addmci_204ppl_gtmpvclist.csv';
delimiter = '';

%% 각 텍스트 라인에 대한 형식 문자열:
%   열1: 텍스트 (%s)
% 자세한 내용은 도움말 문서에서 TEXTSCAN을 참조하십시오.
formatSpec = '%s%[^\n\r]';

%% 텍스트 파일을 엽니다.
fileID = fopen(filename,'r');

%% 형식 문자열에 따라 데이터 열을 읽습니다.
% 이 호출은 이 코드를 생성하는 데 사용되는 파일의 구조체를 기반으로 합니다. 다른 파일에 대한 오류가 발생하는 경우 가져오기 툴에서
% 코드를 다시 생성하십시오.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% 텍스트 파일을 닫습니다.
fclose(fileID);

%% 가져올 수 없는 데이터에 대한 사후 처리 중입니다.
% 가져오기 과정에서 가져올 수 없는 데이터에 규칙이 적용되지 않았으므로 사후 처리 코드가 포함되지 않았습니다. 가져올 수 없는
% 데이터에 사용할 코드를 생성하려면 파일에서 가져올 수 없는 셀을 선택하고 스크립트를 다시 생성하십시오.

%% 출력 변수 만들기
gtmpvclist = table(dataArray{1:end-1}, 'VariableNames', {'gtmpvclist_subject'});

%% 임시 변수 지우기
clearvars filename delimiter formatSpec fileID dataArray ans;