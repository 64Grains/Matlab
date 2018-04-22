%% test
% NURBS曲线信息如下：
%   nurbs.nDegree ------ 次数
%   nurbs.vecKnots ----- 节点矢量
%   nurbs.vecPoles ----- 控制点
%   nurbs.vecWeights --- 控制点对应的权值点
function Test_Nurbs()
    clear all;clc;close all;
    % 读取NURBS曲线
    nurbs = ReadNurbsFromFile('test\circle.nc');
    if isempty(nurbs)
        return;
    end
    % 测试离散方式
    Test_NurbsScatter(nurbs);
    % 测试导矢
    Test_NurbsDeriv(nurbs);
end

%%% 读取NURBS曲线
function nurbs = ReadNurbsFromFile(strFilePath)
    nurbs = [];
    % 检查文件是否存在
    bFileExist = exist(strFilePath, 'file');
    if 0 == bFileExist || 7 == bFileExist
        fprintf('文件(%s)不存在!\n', strFilePath);
        return;
    end
    % NURBS曲线信息
    nurbs.nDegree = 0;
    nurbs.vecKnots = [];
    nurbs.vecPoles = [];
    nurbs.vecWeights = [];
    % 读取文件
    fidRead = fopen(strFilePath, 'r');
    while ~feof(fidRead)
        % 一次性读取多行
        fAll = textscan(fidRead, '%s', 1000, 'Delimiter', '\n');
        fCell = fAll{1};
        nMaxLines = size(fCell,1);
        for i = 1:nMaxLines
            % 获取并处理每一行字符串
            strOrig = fCell{i};
            if isempty(strOrig)
                continue;
            end
            nurbs = GetNurbsFlags(nurbs, strOrig);
        end
    end
    fclose(fidRead);
    % 检查NURBS曲线是否合法
    CheckNurbs(nurbs);
end

%%% 获取NURBS曲线标识符的值
function nurbsNew = GetNurbsFlags(nurbs, strOrig)
    nurbsNew = nurbs;
    % 坐标值
    nxPole = [0, 0, 0];
    bHasPole = false;
    % 解析标识符及对应值
    vecResult = textscan(strOrig, '%c%f');
    vecFlags = vecResult{1};
    vecValues = vecResult{2};
    for i = 1:length(vecFlags)
        switch vecFlags(i)
            case 'G'
                if vecValues(i) ~= 6.2
                    error('错误的参数：G代码标识为%f\n', vecValues(i));
                end
            case 'P'
                if nurbsNew.nDegree ~= 0
                    error('只支持单段NURBS曲线的解析!\n');
                end
                nurbsNew.nDegree = vecValues(i);
            case 'K'
                nurbsNew.vecKnots = [nurbsNew.vecKnots; vecValues(i)];
            case 'X'
                nxPole(1) = vecValues(i);
                bHasPole = true;
            case 'Y'
                nxPole(2) = vecValues(i);
                bHasPole = true;
            case 'Z'
                nxPole(3) = vecValues(i);
                bHasPole = true;
            case 'R'
                nurbsNew.vecWeights = [nurbsNew.vecWeights; vecValues(i)];
            otherwise
                error('错误的标识符:%c\n', vecFlags(i));
        end
    end
    if bHasPole
        nurbsNew.vecPoles = [nurbsNew.vecPoles; nxPole];
    end
end

%%% 测试离散方式
function Test_NurbsScatter(nurbs)
    % 计算曲线上的点
    nCount = 200;
    vecPointsByFormula = zeros(nCount+1,3);
    nStartKnot = nurbs.vecKnots(nurbs.nDegree+1);
    nEndKnot = nurbs.vecKnots(length(nurbs.vecKnots)-nurbs.nDegree);
    for i = 0:nCount
        nKnot = nStartKnot + (nEndKnot - nStartKnot) * i / nCount;
        if size(nurbs.vecPoles,2) == 2
            [vecPointsByFormula(i+1,1:2), ~, ~] = GetNurbsDeriv(nurbs, nKnot);
        elseif size(nurbs.vecPoles,2) == 3
            [vecPointsByFormula(i+1,:), ~, ~] = GetNurbsDeriv(nurbs, nKnot);
        end
    end
    nDeflection = 1e-2;
    vecPointsByDeflection = ScatterNurbs(nurbs, nDeflection);
    % 画图比较
    figure();
    hold on;
    if isequal(vecPointsByFormula(:,3), zeros(size(vecPointsByFormula,1),1))
        plot(vecPointsByFormula(:,1), vecPointsByFormula(:,2), '.-b');
        plot(vecPointsByDeflection(:,1), vecPointsByDeflection(:,2), '.-g');
        plot(nurbs.vecPoles(:,1), nurbs.vecPoles(:,2), '*-r');
    else
        plot3(vecPointsByFormula(:,1), vecPointsByFormula(:,2), vecPointsByFormula(:,3), '.-b');
        plot3(vecPointsByDeflection(:,1), vecPointsByDeflection(:,2), vecPointsByDeflection(:,3), '.-g');
        plot3(nurbs.vecPoles(:,1), nurbs.vecPoles(:,2), nurbs.vecPoles(:,3), '*-r');
        view([1 1 1]);
    end
    legend('按节点矢量离散作图', '按弓高误差离散作图', 'NURBS曲线控制点');
    title('轨迹图');
    axis equal;
end

%%% 测试导矢
function Test_NurbsDeriv(nurbs)
    % 计算导矢数值
    nCount = 200;
    vecNewDeriv = zeros(nCount+1,9);
    nStartKnot = nurbs.vecKnots(nurbs.nDegree+1);
    nEndKnot = nurbs.vecKnots(length(nurbs.vecKnots)-nurbs.nDegree);
    for i = 0:nCount
        nKnot = nStartKnot + (nEndKnot - nStartKnot) * i / nCount;
        if size(nurbs.vecPoles,2) == 2
            [vecNewDeriv(i+1,1:2), vecNewDeriv(i+1,4:5), vecNewDeriv(i+1,7:8)] = GetNurbsDeriv(nurbs, nKnot);
        elseif size(nurbs.vecPoles,2) == 3
            [vecNewDeriv(i+1,1:3), vecNewDeriv(i+1,4:6), vecNewDeriv(i+1,7:9)] = GetNurbsDeriv(nurbs, nKnot);
        end
    end
    nStepKnot = (nEndKnot - nStartKnot) / nCount;
    vecOrigDeriv = vecNewDeriv;
    vecOrigDeriv(2:end,4:6) = diff(vecOrigDeriv(:,1:3)) / nStepKnot;
    vecOrigDeriv(3:end,7:9) = diff(vecOrigDeriv(2:end,4:6)) / nStepKnot;
    % 画图比较
    vecTitles = {'一阶导矢图', '二阶导矢图'};
    for i = 2:min(nurbs.nDegree+1,3)
        figure();
        hold on;
        if isequal(vecNewDeriv(:,i*3), zeros(size(vecNewDeriv,1),1))
            plot(vecOrigDeriv(i:end,i*3-2), vecOrigDeriv(i:end,i*3-1), '.-b');
            plot(vecNewDeriv(:,i*3-2), vecNewDeriv(:,i*3-1), '.-g');
        else
            plot3(vecOrigDeriv(i:end,i*3-2), vecOrigDeriv(i:end,i*3-1), vecOrigDeriv(i:end,i*3), '.-b');
            plot3(vecNewDeriv(:,i*3-2), vecNewDeriv(:,i*3-1), vecNewDeriv(:,i*3), '.-g');
            view([1 1 1]);
        end
        legend('微分法作图', '计算法作图');
        title(vecTitles{i-1});
        axis equal;
    end
    % 计算曲率
    vecNewCurvature = zeros(size(vecNewDeriv,1),1);
    vecOldCurvature = zeros(size(vecOrigDeriv,1),1);
    for i = 1:length(vecNewCurvature)
        nxNumerator = zeros(1,3);
        nxNumerator(1) = vecNewDeriv(i,5) * vecNewDeriv(i,9) - vecNewDeriv(i,8) * vecNewDeriv(i,6);
        nxNumerator(2) = vecNewDeriv(i,6) * vecNewDeriv(i,7) - vecNewDeriv(i,9) * vecNewDeriv(i,4);
        nxNumerator(3) = vecNewDeriv(i,4) * vecNewDeriv(i,8) - vecNewDeriv(i,7) * vecNewDeriv(i,5);
        vecNewCurvature(i) = norm(nxNumerator) / (norm(vecNewDeriv(i,4:6)))^3;
    end
    for i = 1:length(vecOldCurvature)
        nxNumerator = zeros(1,3);
        nxNumerator(1) = vecOrigDeriv(i,5) * vecOrigDeriv(i,9) - vecOrigDeriv(i,8) * vecOrigDeriv(i,6);
        nxNumerator(2) = vecOrigDeriv(i,6) * vecOrigDeriv(i,7) - vecOrigDeriv(i,9) * vecOrigDeriv(i,4);
        nxNumerator(3) = vecOrigDeriv(i,4) * vecOrigDeriv(i,8) - vecOrigDeriv(i,7) * vecOrigDeriv(i,5);
        vecOldCurvature(i) = norm(nxNumerator) / (norm(vecOrigDeriv(i,4:6)))^3;
    end
    % 画图
    figure();
    hold on;
    plot(1:length(vecOldCurvature), vecOldCurvature, '.-b');
    plot(1:length(vecNewCurvature), vecNewCurvature, '.-g');
    legend('微分法作图', '计算法作图');
    title('曲率图');
end