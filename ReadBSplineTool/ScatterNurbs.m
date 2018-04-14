%% ��ָ�������ɢNURBS����
% NURBS������Ϣ���£�
%   nurbs.nLevel -------------- ����
%   nurbs.vecKnots ------------ �ڵ�ʸ��
%   nurbs.vecControlPoints ---- ���Ƶ�
%   nurbs.vecWeights ---------- ���Ƶ��Ӧ��Ȩֵ��
%   nurbs.bRational ----------- �Ƿ�Ϊ����B��������
function vecPoints = ScatterNurbs(nurbs, nDeflection)
    % ������
    nurbs = CheckNurbs(nurbs);
    % �ռ��ڵ�ʸ���з��ظ��ڵ�ֵ
    global g_nCompareError;
    vecDispKnots = nurbs.vecKnots;
    nIndex = 1;
    for i = 2:length(nurbs.vecKnots)
        if abs(vecDispKnots(nIndex) - nurbs.vecKnots(i)) > g_nCompareError / 2
            nIndex = nIndex + 1;
            vecDispKnots(nIndex) = nurbs.vecKnots(i);
        end
    end
    vecDispKnots = vecDispKnots(1:nIndex);
    % ��ÿ�������ظ��ڵ�ֵ����Ϊ�����֣��ݹ����NURBS���ߵ���ɢ��
    vecPoints = nurbs.vecControlPoints(1,:);
    for i = 2:length(vecDispKnots)
        nMidKnot = 0.5 * (vecDispKnots(i-1) + vecDispKnots(i));
        vecFrontPoints = PerformNurbs(nurbs, nDeflection, vecDispKnots(i-1), nMidKnot);
        vecBackPoints = PerformNurbs(nurbs, nDeflection, nMidKnot, vecDispKnots(i));
        vecPoints = [vecPoints(1:end-1,:); vecFrontPoints(1:end-1,:); vecBackPoints];
    end
end

%% ��ָ��������ɢָ�������NURBS����
function vecPoints = PerformNurbs(nurbs, nDeflection, nStartKnot, nEndKnot)
    vecPoints = [];
    nPointMin = 2;
    knotInfoStart.nKnot = nStartKnot;
    knotInfoEnd.nKnot = nEndKnot;
    [knotInfoStart.nxDeriv0, knotInfoStart.nxDeriv1, knotInfoStart.nxDeriv2] = GetNurbsDeriv(nurbs, knotInfoStart.nKnot);
    [knotInfoEnd.nxDeriv0, knotInfoEnd.nxDeriv1, knotInfoEnd.nxDeriv2] = GetNurbsDeriv(nurbs, knotInfoEnd.nKnot);
    vecPoints = [vecPoints; knotInfoStart.nxDeriv0];
    % �ݹ����
    global g_nCompareError;
    nEps = g_nCompareError * g_nCompareError;
    vecPoints = QuasiFleche(nurbs, nDeflection * nDeflection, knotInfoStart, knotInfoEnd, nPointMin, nEps, vecPoints);
end

%% ��ָ�����ȵݹ������ɢ��NURBS����
function vecPointsNew = QuasiFleche(nurbs, nDeflection2, knotInfoStart, knotInfoEnd, nPointMin, nEps, vecPoints)
    vecPointsNew = vecPoints;
    nPointSize = size(vecPointsNew,1);
    nDeltaKnot = knotInfoEnd.nKnot - knotInfoStart.nKnot;
    knotInfoNext = knotInfoEnd;
    if nPointMin > 2
        nDeltaKnot = nDeltaKnot / (nPointMin - 1);
        knotInfoNext.nKnot = knotInfoStart.nKnot + nDeltaKnot;
        [knotInfoNext.nxDeriv0, knotInfoNext.nxDeriv1, knotInfoNext.nxDeriv2] = GetNurbsDeriv(nurbs, knotInfoNext.nKnot);
    end
    
    nNorme = (norm(knotInfoNext.nxDeriv0 - knotInfoStart.nxDeriv0))^2;
    nTheFleche = 0;
    bFlecheOk = false;
    if nNorme > nEps
        nNorme1 = (norm(knotInfoStart.nxDeriv1))^2;
        nNorme2 = (norm(knotInfoNext.nxDeriv1))^2;
        if nNorme1 > nEps && nNorme2 > nEps
            nxStartNormalized = knotInfoStart.nxDeriv1 / norm(knotInfoStart.nxDeriv1);
            nxNextNormalized = knotInfoNext.nxDeriv1 / norm(knotInfoNext.nxDeriv1);
            nNormeDiff = (norm(nxStartNormalized - nxNextNormalized))^2;
            if nNormeDiff > nEps
                nTheFleche = nNormeDiff * nNorme / 64;
                bFlecheOk = true;
            end
        end
    end
    
    if ~bFlecheOk
        nxMid = 0.5 * (knotInfoNext.nxDeriv0 + knotInfoStart.nxDeriv0);
        [nxVerif, ~, ~] = GetNurbsDeriv(nurbs, knotInfoStart.nKnot + 0.5 * nDeltaKnot);
        nTheFleche = (norm(nxMid - nxVerif))^2;
    end
    
    if nTheFleche < nDeflection2
        if norm(vecPointsNew(end,:) - knotInfoNext.nxDeriv0) > 0
            vecPointsNew = [vecPointsNew; knotInfoNext.nxDeriv0];
        end
    else
        vecPointsNew = QuasiFleche(nurbs, nDeflection2, knotInfoStart, knotInfoNext, 3, nEps, vecPointsNew);
    end
    
    if nPointMin > 2
        nPointMin = nPointMin - (size(vecPointsNew,1) - nPointSize);
        vecPointsNew = QuasiFleche(nurbs, nDeflection2, knotInfoNext, knotInfoEnd, nPointMin, nEps, vecPointsNew);
    end
end