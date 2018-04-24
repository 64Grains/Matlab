%% ��NURBS���߷ָ�Ϊû���ؽڵ��NURBS���߶�
% NURBS������Ϣ���£�
%   nurbs.nDegree ------ ����
%   nurbs.vecKnots ----- �ڵ�ʸ��
%   nurbs.vecPoles ----- ���Ƶ�
%   nurbs.vecWeights --- ���Ƶ��Ӧ��Ȩֵ��
%   nurbs.bRational ---- �Ƿ�Ϊ����B��������
function vecNurbs = DivideNurbs(nurbs)
    % ������
    nurbs = CheckNurbs(nurbs);
    % �����ؽڵ㴦����ڵ㣬ʹ���ؽڵ���ظ���Ϊnurbs.nDegree+1��Ȼ��NURBS���߷ָ�Ϊû���ؽڵ��NURBS���߶�
    global g_nCompareError;
    nStartIndex = 1;
    while true
        if nurbs.vecKnots(nStartIndex) - nurbs.vecKnots(nurbs.nDegree+1) > g_nCompareError
            break;
        end
        nStartIndex = nStartIndex + 1;
    end
    nEndIndex = length(nurbs.vecKnots);
    while true
        if nurbs.vecKnots(nEndIndex) - nurbs.vecKnots(length(nurbs.vecKnots)-nurbs.nDegree) < -g_nCompareError
            break;
        end
        nEndIndex = nEndIndex - 1;
    end
    % ͳ����Ҫ����Ľڵ�ֵ
    vecInsertKnot = nurbs.vecKnots;
    nIndex = 0;
    nFlagKnot = nurbs.vecKnots(nStartIndex);
    nRepeatCount = 1;
    for i = nStartIndex+1:nEndIndex+1
        if abs(nurbs.vecKnots(i) - nFlagKnot) < g_nCompareError
            nRepeatCount = nRepeatCount + 1;
            continue;
        end
        if nRepeatCount > 1
            nInsertCount = nurbs.nDegree + 1 - nRepeatCount;
            for j = 1:nInsertCount
                nIndex = nIndex + 1;
                vecInsertKnot(nIndex) = nFlagKnot;
            end
        end
        nFlagKnot = nurbs.vecKnots(i);
        nRepeatCount = 1;
    end
    vecInsertKnot = vecInsertKnot(1:nIndex);
    % �ڵ�ϸ��
    nurbs = RefineNurbs(nurbs, vecInsertKnot);
    % ��NURBS���߽��л���
    vecNurbs = SectionNurbs(nurbs);
end

%%% NURBS���ߣ��ڵ�ϸ��
function nurbsNew = RefineNurbs(nurbs, vecInsertKnot)
    if isempty(vecInsertKnot)
        nurbsNew = nurbs;
        return;
    end
    % ������B��������
    if ~nurbs.bRational
        nurbsNew = RefineBSpline(nurbs, vecInsertKnot);
        return;
    end
    % ����B�������ߣ�������ת��Ϊ��ά���������
    vecTempPoles = nurbs.vecPoles;
    [nRow, nColumn] = size(vecTempPoles);
    nurbs.vecPoles = zeros(nRow, nColumn+1);
    for i = 1:nRow
        nurbs.vecPoles(i,1:nColumn) = vecTempPoles(i,:) * nurbs.vecWeights(i);
        nurbs.vecPoles(i,nColumn+1) = nurbs.vecWeights(i);
    end
    nurbsNew = RefineBSpline(nurbs, vecInsertKnot);
    % ת���������
    vecTempPoles = nurbsNew.vecPoles;
    [nRow, nColumn] = size(vecTempPoles);
    nurbsNew.vecPoles = zeros(nRow, nColumn-1);
    for i = 1:nRow
        nurbsNew.vecPoles(i,:) = vecTempPoles(i,1:nColumn-1) / vecTempPoles(i,nColumn);
    end
    nurbsNew.vecWeights = vecTempPoles(:,nColumn);
end

%%% BSpline���ߣ��ڵ�ϸ��
% NURBS������Ϣ���£�
%   nurbs.nDegree ------ ����
%   nurbs.vecKnots ----- �ڵ�ʸ��
%   nurbs.vecPoles ----- ���Ƶ�
%   nurbs.vecWeights --- ���Ƶ��Ӧ��Ȩֵ��
%   nurbs.bRational ---- �Ƿ�Ϊ����B��������
function nurbsNew = RefineBSpline(nurbs, vecInsertKnot)
    nLength = length(vecInsertKnot);
    % B�������ߵ��ݴ�
    nurbsNew.nDegree = nurbs.nDegree;
    % �ڵ������
    nMinIndex = FindSpan(nurbs.nDegree, nurbs.vecKnots, vecInsertKnot(1));
    nMaxIndex = FindSpan(nurbs.nDegree, nurbs.vecKnots, vecInsertKnot(nLength)) + 1;
    % ���Ʋ���Ľڵ�ʸ��
    nurbsNew.vecKnots = zeros(length(nurbs.vecKnots)+nLength,1);
    nurbsNew.vecKnots(1:nMinIndex) = nurbs.vecKnots(1:nMinIndex);
    nurbsNew.vecKnots(nMaxIndex+nLength:end) = nurbs.vecKnots(nMaxIndex:end);
    % ���Ʋ���Ŀ��Ƶ�
    [nRow, nColumn] = size(nurbs.vecPoles);
    nurbsNew.vecPoles = zeros(nRow+nLength,nColumn);
    nurbsNew.vecPoles(1:nMinIndex-nurbs.nDegree,:) = nurbs.vecPoles(1:nMinIndex-nurbs.nDegree,:);
    nurbsNew.vecPoles(nMaxIndex-1+nLength:end,:) = nurbs.vecPoles(nMaxIndex-1:end,:);
    
    nIndex = nMaxIndex + nurbs.nDegree;
    nFlag = nMaxIndex + nurbs.nDegree + nLength;
    % �¿��Ƶ�ͽڵ�ʸ��
    for j = nLength:-1:1
        while vecInsertKnot(j) <= nurbs.vecKnots(nIndex) && nIndex > nMinIndex
            nurbsNew.vecPoles(nFlag-nurbs.nDegree-1,:) = nurbs.vecPoles(nIndex-nurbs.nDegree-1,:);
            nurbsNew.vecKnots(nFlag) = nurbs.vecKnots(nIndex);
            nFlag = nFlag - 1;
            nIndex = nIndex - 1;
        end
        nurbsNew.vecPoles(nFlag-nurbs.nDegree-1,:) = nurbsNew.vecPoles(nFlag-nurbs.nDegree,:);
        for k = 1:nurbs.nDegree
            nTemp = nFlag - nurbs.nDegree + k;
            nAlpha = nurbsNew.vecKnots(nFlag+k) - vecInsertKnot(j);
            if nAlpha ~= 0
                nAlpha = nAlpha / (nurbsNew.vecKnots(nFlag+k) - nurbs.vecKnots(nIndex-nurbs.nDegree+k));
                nurbsNew.vecPoles(nTemp-1,:) = nAlpha * nurbsNew.vecPoles(nTemp-1,:) + (1 - nAlpha) * nurbsNew.vecPoles(nTemp,:);
            else
                nurbsNew.vecPoles(nTemp-1,:) = nurbsNew.vecPoles(nTemp,:);
            end
        end
        nurbsNew.vecKnots(nFlag) = vecInsertKnot(j);
        nFlag = nFlag - 1;
    end
    % ���Ƶ��Ȩֵ
    nurbsNew.vecWeights = [];
end

%%% ��NURBS���߽��л���
function vecNurbs = SectionNurbs(nurbs)
    vecNurbs = cell(size(nurbs.vecPoles,1),1);
    nIndex = 0;
    % ��һ��NURBS���߶�
    nKnotIndex = nurbs.nDegree + 1;
    nPointIndex = 0;
    nurbsNew.nDegree = nurbs.nDegree;
    nurbsNew.vecKnots = nurbs.vecKnots(1:nKnotIndex);
    nurbsNew.vecWeights = [];
    nRepeatCount = 1;
    nFlagKnot = nurbs.vecKnots(nKnotIndex+1);
    global g_nCompareError;
    for i = nKnotIndex+2:length(nurbs.vecKnots)-nurbs.nDegree
        % �ؽڵ�
        if abs(nurbs.vecKnots(i) - nFlagKnot) < g_nCompareError
            nRepeatCount = nRepeatCount + 1;
            continue;
        end
        % �ڽڵ㲻�ظ�
        if nRepeatCount == 1
            nurbsNew.vecKnots = [nurbsNew.vecKnots; nFlagKnot];
            nFlagKnot = nurbs.vecKnots(i);
            continue;
        end
        % �ڽڵ��ظ����ظ���Ϊnurbs.nDegree + 1
        if nRepeatCount < nurbs.nDegree + 1
            error('����Ĳ������ڵ��ظ���Ϊ%d\n', nRepeatCount);
        end
        nurbsNew.vecKnots = [nurbsNew.vecKnots; ones(nRepeatCount,1) * nFlagKnot];
        nPointCount = length(nurbsNew.vecKnots) - nurbsNew.nDegree - 1;
        nurbsNew.vecPoles = nurbs.vecPoles(nPointIndex+1:nPointIndex+nPointCount,:);
        if ~isempty(nurbs.vecWeights)
            nurbsNew.vecWeights = nurbs.vecWeights(nPointIndex+1:nPointIndex+nPointCount,:);
        end
        nPointIndex = nPointIndex + nPointCount;
        nIndex = nIndex + 1; 
        vecNurbs{nIndex} = nurbsNew;
        % ���ñ�ʶֵ
        nurbsNew.vecKnots = ones(nRepeatCount,1) * nFlagKnot;
        nFlagKnot = nurbs.vecKnots(i);
        nRepeatCount = 1;
    end
    % ���һ��NURBS���߶�
    nurbsNew.vecKnots = [nurbsNew.vecKnots; ones(nRepeatCount,1) * nFlagKnot];
    nurbsNew.vecKnots = [nurbsNew.vecKnots; nurbs.vecKnots(length(nurbs.vecKnots)-nurbs.nDegree+1:end)];
    if nPointIndex ~= size(nurbs.vecPoles,1)
        nPointCount = length(nurbsNew.vecKnots) - nurbsNew.nDegree - 1;
        nurbsNew.vecPoles = nurbs.vecPoles(nPointIndex+1:nPointIndex+nPointCount,:);
        if ~isempty(nurbs.vecWeights)
            nurbsNew.vecWeights = nurbs.vecWeights(nPointIndex+1:nPointIndex+nPointCount,:);
        end
        nPointIndex = nPointIndex + nPointCount;
        nIndex = nIndex + 1; 
        vecNurbs{nIndex} = nurbsNew;
    end
    vecNurbs = vecNurbs(1:nIndex);
    if nPointIndex ~= size(nurbs.vecPoles,1)
        error('����Ľ�������Ƶ������©��\n');
    end
end