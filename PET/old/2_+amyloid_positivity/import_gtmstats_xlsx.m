function data = import_gtmstats(workbookFile, sheetName, range)
%IMPORTFILE 스프레드시트에서 데이터 가져오기
%   DATA = IMPORTFILE(FILE) FILE이라는 Microsoft Excel 스프레드시트 파일의 첫 번째 워크시트에서
%   데이터를 읽고 데이터를 셀형 배열로 반환합니다.
%
%   DATA = IMPORTFILE(FILE,SHEET) 지정된 워크시트에서 읽어 들입니다.
%
%   DATA = IMPORTFILE(FILE,SHEET,RANGE) 지정된 워크시트와 범위에서 읽어 들입니다. 구문 'C1:C2'를
%   사용하여 범위를 지정합니다. 여기서 C1과 C2는 해당 영역의 처음과 끝 지점을 나타냅니다.%
% 예:
%   gtmstats2020researchapetnorescale = importfile('gtmstats_2020research_apet_norescale.xlsx','Sheet1','A2:CY59');
%
%   XLSREAD도 참조하십시오.

% MATLAB에서 다음 날짜에 자동 생성됨: 2020/05/13 12:24:55

%% 입력 처리

% 시트가 지정되지 않은 경우 첫 번째 시트 읽기
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% 범위가 지정되지 않은 경우 모든 데이터 읽기
if nargin <= 2 || isempty(range)
    range = '';
end

%% 데이터 가져오기
[~, ~, data] = xlsread(workbookFile, sheetName, range);
data(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),data)) = {''};

