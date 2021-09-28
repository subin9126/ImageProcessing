function [orig_gtmstats] = import_gtmstats_csv(filename)
%% 텍스트 파일에서 데이터를 가져옵니다.
% 다음 텍스트 파일에서 데이터를 가져오기 위한 스크립트:
%
%    K:\7_TextureABAD\200808_474ppl_gtmstats_norescale.csv
%
% 선택한 다른 데이터나 텍스트 파일로 코드를 확장하려면 스크립트 대신 함수를 생성하십시오.

% MATLAB에서 다음 날짜에 자동 생성됨: 2020/08/08 18:00:16

%% 변수를 초기화합니다.
% filename = 'K:\7_TextureABAD\200808_474ppl_gtmstats_norescale.csv';
delimiter = ' ';
startRow = 2;

%% 각 텍스트 라인에 대한 형식 문자열:
%   열1: double (%f)
%	열2: double (%f)
%   열3: double (%f)
%	열4: double (%f)
%   열5: double (%f)
%	열6: double (%f)
%   열7: double (%f)
%	열8: double (%f)
%   열9: double (%f)
%	열10: double (%f)
%   열11: double (%f)
%	열12: double (%f)
%   열13: double (%f)
%	열14: double (%f)
%   열15: double (%f)
%	열16: double (%f)
%   열17: double (%f)
%	열18: double (%f)
%   열19: double (%f)
%	열20: double (%f)
%   열21: double (%f)
%	열22: double (%f)
%   열23: double (%f)
%	열24: double (%f)
%   열25: double (%f)
%	열26: double (%f)
%   열27: double (%f)
%	열28: double (%f)
%   열29: double (%f)
%	열30: double (%f)
%   열31: double (%f)
%	열32: double (%f)
%   열33: double (%f)
%	열34: double (%f)
%   열35: double (%f)
%	열36: double (%f)
%   열37: double (%f)
%	열38: double (%f)
%   열39: double (%f)
%	열40: double (%f)
%   열41: double (%f)
%	열42: double (%f)
%   열43: double (%f)
%	열44: double (%f)
%   열45: double (%f)
%	열46: double (%f)
%   열47: double (%f)
%	열48: double (%f)
%   열49: double (%f)
%	열50: double (%f)
%   열51: double (%f)
%	열52: double (%f)
%   열53: double (%f)
%	열54: double (%f)
%   열55: double (%f)
%	열56: double (%f)
%   열57: double (%f)
%	열58: double (%f)
%   열59: double (%f)
%	열60: double (%f)
%   열61: double (%f)
%	열62: double (%f)
%   열63: double (%f)
%	열64: double (%f)
%   열65: double (%f)
%	열66: double (%f)
%   열67: double (%f)
%	열68: double (%f)
%   열69: double (%f)
%	열70: double (%f)
%   열71: double (%f)
%	열72: double (%f)
%   열73: double (%f)
%	열74: double (%f)
%   열75: double (%f)
%	열76: double (%f)
%   열77: double (%f)
%	열78: double (%f)
%   열79: double (%f)
%	열80: double (%f)
%   열81: double (%f)
%	열82: double (%f)
%   열83: double (%f)
%	열84: double (%f)
%   열85: double (%f)
%	열86: double (%f)
%   열87: double (%f)
%	열88: double (%f)
%   열89: double (%f)
%	열90: double (%f)
%   열91: double (%f)
%	열92: double (%f)
%   열93: double (%f)
%	열94: double (%f)
%   열95: double (%f)
%	열96: double (%f)
%   열97: double (%f)
%	열98: double (%f)
%   열99: double (%f)
%	열100: double (%f)
%   열101: double (%f)
% 자세한 내용은 도움말 문서에서 TEXTSCAN을 참조하십시오.
formatSpec = '%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%% 텍스트 파일을 엽니다.
fileID = fopen(filename,'r');

%% 형식 문자열에 따라 데이터 열을 읽습니다.
% 이 호출은 이 코드를 생성하는 데 사용되는 파일의 구조체를 기반으로 합니다. 다른 파일에 대한 오류가 발생하는 경우 가져오기 툴에서
% 코드를 다시 생성하십시오.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'EmptyValue' ,NaN,'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%% 텍스트 파일을 닫습니다.
fclose(fileID);

%% 가져올 수 없는 데이터에 대한 사후 처리 중입니다.
% 가져오기 과정에서 가져올 수 없는 데이터에 규칙이 적용되지 않았으므로 사후 처리 코드가 포함되지 않았습니다. 가져올 수 없는
% 데이터에 사용할 코드를 생성하려면 파일에서 가져올 수 없는 셀을 선택하고 스크립트를 다시 생성하십시오.

%% 출력 변수 만들기
orig_gtmstats = table(dataArray{1:end-1}, 'VariableNames', {'GTM','LeftCerebralWhiteMatter','LeftCerebellumWhiteMatter','LeftCerebellumCortex','LeftThalamusProper','LeftCaudate','LeftPutamen','LeftPallidum','BrainStem','LeftHippocampus','LeftAmygdala','CSF','LeftAccumbensarea','LeftVentralDC','Leftchoroidplexus','RightCerebralWhiteMatter','RightCerebellumWhiteMatter','RightCerebellumCortex','RightThalamusProper','RightCaudate','RightPutamen','RightPallidum','RightHippocampus','RightAmygdala','RightAccumbensarea','RightVentralDC','Rightchoroidplexus','Air','Skull','Vermis','Pons','CSFExtraCerebral','HeadExtraCerebral','ctxlhbankssts','ctxlhcaudalanteriorcingulate','ctxlhcaudalmiddlefrontal','ctxlhcuneus','ctxlhentorhinal','ctxlhfusiform','ctxlhinferiorparietal','ctxlhinferiortemporal','ctxlhisthmuscingulate','ctxlhlateraloccipital','ctxlhlateralorbitofrontal','ctxlhlingual','ctxlhmedialorbitofrontal','ctxlhmiddletemporal','ctxlhparahippocampal','ctxlhparacentral','ctxlhparsopercularis','ctxlhparsorbitalis','ctxlhparstriangularis','ctxlhpericalcarine','ctxlhpostcentral','ctxlhposteriorcingulate','ctxlhprecentral','ctxlhprecuneus','ctxlhrostralanteriorcingulate','ctxlhrostralmiddlefrontal','ctxlhsuperiorfrontal','ctxlhsuperiorparietal','ctxlhsuperiortemporal','ctxlhsupramarginal','ctxlhfrontalpole','ctxlhtemporalpole','ctxlhtransversetemporal','ctxlhinsula','ctxrhbankssts','ctxrhcaudalanteriorcingulate','ctxrhcaudalmiddlefrontal','ctxrhcuneus','ctxrhentorhinal','ctxrhfusiform','ctxrhinferiorparietal','ctxrhinferiortemporal','ctxrhisthmuscingulate','ctxrhlateraloccipital','ctxrhlateralorbitofrontal','ctxrhlingual','ctxrhmedialorbitofrontal','ctxrhmiddletemporal','ctxrhparahippocampal','ctxrhparacentral','ctxrhparsopercularis','ctxrhparsorbitalis','ctxrhparstriangularis','ctxrhpericalcarine','ctxrhpostcentral','ctxrhposteriorcingulate','ctxrhprecentral','ctxrhprecuneus','ctxrhrostralanteriorcingulate','ctxrhrostralmiddlefrontal','ctxrhsuperiorfrontal','ctxrhsuperiorparietal','ctxrhsuperiortemporal','ctxrhsupramarginal','ctxrhfrontalpole','ctxrhtemporalpole','ctxrhtransversetemporal','ctxrhinsula'});

%% 임시 변수 지우기
clearvars filename delimiter startRow formatSpec fileID dataArray ans;