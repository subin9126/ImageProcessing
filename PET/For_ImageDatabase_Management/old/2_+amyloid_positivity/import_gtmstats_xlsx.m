function data = import_gtmstats(workbookFile, sheetName, range)
%IMPORTFILE ���������Ʈ���� ������ ��������
%   DATA = IMPORTFILE(FILE) FILE�̶�� Microsoft Excel ���������Ʈ ������ ù ��° ��ũ��Ʈ����
%   �����͸� �а� �����͸� ���� �迭�� ��ȯ�մϴ�.
%
%   DATA = IMPORTFILE(FILE,SHEET) ������ ��ũ��Ʈ���� �о� ���Դϴ�.
%
%   DATA = IMPORTFILE(FILE,SHEET,RANGE) ������ ��ũ��Ʈ�� �������� �о� ���Դϴ�. ���� 'C1:C2'��
%   ����Ͽ� ������ �����մϴ�. ���⼭ C1�� C2�� �ش� ������ ó���� �� ������ ��Ÿ���ϴ�.%
% ��:
%   gtmstats2020researchapetnorescale = importfile('gtmstats_2020research_apet_norescale.xlsx','Sheet1','A2:CY59');
%
%   XLSREAD�� �����Ͻʽÿ�.

% MATLAB���� ���� ��¥�� �ڵ� ������: 2020/05/13 12:24:55

%% �Է� ó��

% ��Ʈ�� �������� ���� ��� ù ��° ��Ʈ �б�
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% ������ �������� ���� ��� ��� ������ �б�
if nargin <= 2 || isempty(range)
    range = '';
end

%% ������ ��������
[~, ~, data] = xlsread(workbookFile, sheetName, range);
data(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),data)) = {''};

