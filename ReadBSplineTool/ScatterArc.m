%% 将圆弧按照规定的精度离散为小线段
% 参数strG17：坐标平面
% 参数strCurGId：G指令(G2或G3)
% 参数nxLastPos：圆弧的起点坐标
% 参数nxCurPos：圆弧的终点坐标
% 参数nxCurParam：圆弧的参数
% 返回值vecPoints：圆弧离散后的数据点
function vecPoints = ScatterArc(strG17, strCurGId, nxLastPos, nxCurPos, nxCurParam, nDeflection)
    %%% 圆弧指令G02、G03（G02/G03 X_Y_Z_R_(I_J_K_)）
    % G02指定以顺时针方式插补，G03为逆时针
    % R的值为负时表明圆弧段大于半圆，而为正时则表明圆弧段小于或等于半圆
    % G17设定X-Y工作平面，G18设定Z-X工作平面，G19设定Y-Z工作平面
    % 参数检查
    if ~strcmp(strCurGId, 'G2') && ~strcmp(strCurGId, 'G3')
        error('错误的参数值：%s，该指令不是圆弧指令！', strCurGId);
    end
    % 参数默认值
    if isempty(strG17)
        strG17 = 'G17';
    end
    % 将坐标转化为平面坐标
    [nxLastTwoAxis, nLastThreeAxis] = GetTwoAxisByPlane(strG17, nxLastPos);
    [nxCurTwoAxis, nCurThreeAxis] = GetTwoAxisByPlane(strG17, nxCurPos);
    if nLastThreeAxis ~= nCurThreeAxis
        error('圆弧的起点和终点不在同一坐标平面内！');
    end
    % 圆心
    [nxArcCenter, ~] = GetTwoAxisByPlane(strG17, nxCurParam(1:3));
    global g_IJLIncrementalMode;
    if g_IJLIncrementalMode
        nxArcCenter = nxArcCenter + nxLastTwoAxis;
    end
    % 将半径编程统一为圆心编程
    if ~isinf(nxCurParam(4))
        nxArcCenter = TransRadiusToArcCenter(strCurGId, nxLastTwoAxis, nxCurTwoAxis, nxCurParam(4));
    end
    % 计算夹角
    nxStartVec = (nxLastTwoAxis - nxArcCenter) / norm(nxLastTwoAxis - nxArcCenter);
    nxEndVec = (nxCurTwoAxis - nxArcCenter) / norm(nxCurTwoAxis - nxArcCenter);
    nCosValue = nxStartVec(1) * nxEndVec(1) + nxStartVec(2) * nxEndVec(2);
    nSinValue = nxStartVec(1) * nxEndVec(2) - nxStartVec(2) * nxEndVec(1);
    if strcmp(strCurGId, 'G2')
        nSinValue = -nSinValue;
    end
    nAngle = acos(nCosValue);
    if nSinValue < 0
        nAngle = 2 * pi - nAngle;
    end
    % 是否为整圆
    if 0 == nAngle && isinf(nxCurParam(4))
        nAngle = 2 * pi;
    end
    % 根据精度离散圆弧
    nRadius = norm(nxLastTwoAxis - nxArcCenter);
    nStepAngle = 2 * acos(1 - min(nDeflection, nRadius) / nRadius);
    nCount = ceil(nAngle / nStepAngle) + 1;
    nStepAngle = nAngle / nCount;
    if strcmp(strCurGId, 'G2')
        nStepAngle = -nStepAngle;
    end
    % 计算离散的点
    vecPoints = zeros(nCount+1,3);
    nxTempAxis = zeros(1,2);
    for i = 0:nCount
        nStartAngle = i * nStepAngle;
        nxTempAxis(1) = nxArcCenter(1) + nRadius * (nxStartVec(1) * cos(nStartAngle) - nxStartVec(2) * sin(nStartAngle));
        nxTempAxis(2) = nxArcCenter(2) + nRadius * (nxStartVec(1) * sin(nStartAngle) + nxStartVec(2) * cos(nStartAngle));
        vecPoints(i+1,:) = GetThreeAxisByPlane(strG17, nxTempAxis, nLastThreeAxis);
    end
end

%% 将半径编程统一为圆心编程
% 参数strCurGId：G指令(G2或G3)
% 参数nxLastPos：圆弧的起点坐标
% 参数nxCurPos：圆弧的终点坐标
% 参数nRadius：圆弧的半径
% 返回值nxArcCenter：圆弧的圆心
function nxArcCenter = TransRadiusToArcCenter(strCurGId, nxLastPos, nxCurPos, nRadius)
    % 计算弦长
    nChordLength = norm(nxCurPos - nxLastPos);
    % 计算旋转角度
    nCosAngle = nChordLength * 0.5 / abs(nRadius);
    nSinAngle = sqrt(1 - nCosAngle * nCosAngle);
    % 计算旋转方向
    if strcmp('G2', strCurGId) && nRadius > 0
        nSinAngle = -nSinAngle;
    end
    if strcmp('G3', strCurGId) && nRadius < 0
        nSinAngle = -nSinAngle;
    end
    % 计算圆心
    nAlpha = abs(nRadius) / nChordLength;
    nxArcCenter = zeros(1,2);
    nxArcCenter(1) = nxLastPos(1) + nAlpha * ((nxCurPos(1) - nxLastPos(1)) * nCosAngle...
        - (nxCurPos(2) - nxLastPos(2)) * nSinAngle);
    nxArcCenter(2) = nxLastPos(2) + nAlpha * ((nxCurPos(1) - nxLastPos(1)) * nSinAngle...
        + (nxCurPos(2) - nxLastPos(2)) * nCosAngle);
end

%% 根据坐标平面将三维坐标转换为二维坐标
% 参数strG17：坐标平面
% 参数nxThreeAxis：三维空间中的坐标
% 返回值nxTwoAxis：二维空间中的坐标
% 返回值nThreeAxis：第三维空间的坐标值
function [nxTwoAxis, nThreeAxis] = GetTwoAxisByPlane(strG17, nxThreeAxis)
    % 初始化
    nxTwoAxis = zeros(1,2);
    switch strG17
        case 'G17'
            nxTwoAxis(1) = nxThreeAxis(1);
            nxTwoAxis(2) = nxThreeAxis(2);
            nThreeAxis = nxThreeAxis(3);
        case 'G18'
            nxTwoAxis(1) = nxThreeAxis(3);
            nxTwoAxis(2) = nxThreeAxis(1);
            nThreeAxis = nxThreeAxis(2);
        case 'G19'
            nxTwoAxis(1) = nxThreeAxis(2);
            nxTwoAxis(2) = nxThreeAxis(3);
            nThreeAxis = nxThreeAxis(1);
        otherwise
            error('错误的G指令：%s', strG17);
    end
end

%% 根据坐标平面将二维坐标转换为三维坐标
% 参数strG17：坐标平面
% 参数nxTwoAxis：二维空间中的坐标
% 参数nThreeAxis：第三维空间的坐标
% 返回值nxThreeAxis：三维空间中的坐标
function nxThreeAxis = GetThreeAxisByPlane(strG17, nxTwoAxis, nThreeAxis)
    % 初始化
    nxThreeAxis = zeros(1,3);
    switch strG17
        case 'G17'
            nxThreeAxis(1) = nxTwoAxis(1);
            nxThreeAxis(2) = nxTwoAxis(2);
            nxThreeAxis(3) = nThreeAxis;
        case 'G18'
            nxThreeAxis(3) = nxTwoAxis(1);
            nxThreeAxis(1) = nxTwoAxis(2);
            nxThreeAxis(2) = nThreeAxis;
        case 'G19'
            nxThreeAxis(2) = nxTwoAxis(1);
            nxThreeAxis(3) = nxTwoAxis(2);
            nxThreeAxis(1) = nThreeAxis;
        otherwise
            error('错误的G指令：%s', strG17);
    end
end