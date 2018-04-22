%% ���NURBS���ߵĲ���
% NURBS������Ϣ���£�
%   nurbs.nDegree ------ ����
%   nurbs.vecKnots ----- �ڵ�ʸ��
%   nurbs.vecPoles ----- ���Ƶ�
%   nurbs.vecWeights --- ���Ƶ��Ӧ��Ȩֵ��
%   nurbs.bRational ---- �Ƿ�Ϊ����B��������
function nurbsNew = CheckNurbs(nurbs)
    % ����Ƿ�ΪNURBS����
    if nurbs.nDegree <= 0 || length(nurbs.vecKnots) < 1 || size(nurbs.vecPoles,1) < 1 ...
            || length(nurbs.vecKnots) ~= size(nurbs.vecPoles,1) + nurbs.nDegree + 1
        error('����Ĳ�����NURBS���ߴ���Ϊ%d���ڵ�ʸ����Ϊ%d�����Ƶ���Ϊ%d\n',...
            nurbs.nDegree, length(nurbs.vecKnots), size(nurbs.vecPoles,1));
    end
    if length(nurbs.vecWeights) > 1 && length(nurbs.vecWeights) ~= size(nurbs.vecPoles,1)
        error('����Ĳ�����NURBS���߿��Ƶ���Ϊ%d�����Ƶ��Ӧ��Ȩֵ��Ϊ%d\n',...
            size(nurbs.vecPoles,1), length(nurbs.vecWeights));
    end
    % ��ֵ�ȽϾ���
    global g_nCompareError;
    g_nCompareError = 1e-9;
    % ����Ƿ�Ϊ����B��������
    nurbsNew = nurbs;
    nurbsNew.bRational = false;
    for i = 2:length(nurbsNew.vecWeights)
        if abs(nurbsNew.vecWeights(i) - nurbsNew.vecWeights(1)) > g_nCompareError
            nurbsNew.bRational = true;
            break;
        end
    end
end