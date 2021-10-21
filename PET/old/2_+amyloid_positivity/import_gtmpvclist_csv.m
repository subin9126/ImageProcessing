function [gtmpvclist] = import_gtmpvclist_csv(filename)
%% �ؽ�Ʈ ���Ͽ��� �����͸� �����ɴϴ�.
% ���� �ؽ�Ʈ ���Ͽ��� �����͸� �������� ���� ��ũ��Ʈ:
%
%    K:\7_TextureABAD\200901_addmci_204ppl_gtmpvclist.csv
%
% ������ �ٸ� �����ͳ� �ؽ�Ʈ ���Ϸ� �ڵ带 Ȯ���Ϸ��� ��ũ��Ʈ ��� �Լ��� �����Ͻʽÿ�.

% MATLAB���� ���� ��¥�� �ڵ� ������: 2020/09/02 15:02:56

%% ������ �ʱ�ȭ�մϴ�.
% filename = 'K:\7_TextureABAD\200901_addmci_204ppl_gtmpvclist.csv';
delimiter = '';

%% �� �ؽ�Ʈ ���ο� ���� ���� ���ڿ�:
%   ��1: �ؽ�Ʈ (%s)
% �ڼ��� ������ ���� �������� TEXTSCAN�� �����Ͻʽÿ�.
formatSpec = '%s%[^\n\r]';

%% �ؽ�Ʈ ������ ���ϴ�.
fileID = fopen(filename,'r');

%% ���� ���ڿ��� ���� ������ ���� �н��ϴ�.
% �� ȣ���� �� �ڵ带 �����ϴ� �� ���Ǵ� ������ ����ü�� ������� �մϴ�. �ٸ� ���Ͽ� ���� ������ �߻��ϴ� ��� �������� ������
% �ڵ带 �ٽ� �����Ͻʽÿ�.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter,  'ReturnOnError', false);

%% �ؽ�Ʈ ������ �ݽ��ϴ�.
fclose(fileID);

%% ������ �� ���� �����Ϳ� ���� ���� ó�� ���Դϴ�.
% �������� �������� ������ �� ���� �����Ϳ� ��Ģ�� ������� �ʾ����Ƿ� ���� ó�� �ڵ尡 ���Ե��� �ʾҽ��ϴ�. ������ �� ����
% �����Ϳ� ����� �ڵ带 �����Ϸ��� ���Ͽ��� ������ �� ���� ���� �����ϰ� ��ũ��Ʈ�� �ٽ� �����Ͻʽÿ�.

%% ��� ���� �����
gtmpvclist = table(dataArray{1:end-1}, 'VariableNames', {'gtmpvclist_subject'});

%% �ӽ� ���� �����
clearvars filename delimiter formatSpec fileID dataArray ans;