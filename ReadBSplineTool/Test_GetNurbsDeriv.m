%% test
clear all;clc;close all;
% 添加上级目录到搜索路径
strPath = pwd;
vecIndexs = strfind(strPath, '\');
strPath = strPath(1:vecIndexs(end)-1);
addpath(strPath);
% 椭圆
nurbs1.nLevel = 2;
nurbs1.vecKnots = [0 0 0 0.33 0.67 0.67 1 1 1];
nurbs1.vecControlPoints = [200 0; 200 -100; -200 -100; -200 0; -200 100; 0 100];
nurbs1.vecWeights = [1 0.5 0.5 1.0 0.707 1.0];
% 圆
nurbs2.nLevel = 2;
nurbs2.vecKnots = [0 0 0 0.25 0.5 0.5 0.75 1 1 1];
nurbs2.vecControlPoints = [100 0; 100 100; -100 100; -100 0; -100 -100; 100 -100; 100 0];
nurbs2.vecWeights = [1 0.5 0.5 1 0.5 0.5 1];
% 螺旋线
nurbs3.nLevel = 3;
nurbs3.vecKnots = [0 0 0 0 0.21075 0.24052 0.28945 0.38099 0.45393 0.52747 0.61779 0.75841 1 1 1 1];
nurbs3.vecControlPoints = [-180 -200 -40; -80 -80 -40; 0 40 30; 0 80 50; 50 100 100; 100 180 200;...
    200 200 160; 290 250 120; 350 230 240; 500 180 100; 600 150 210; 700 0 100];
nurbs3.vecWeights = [1 0.85 0.4 0.3 0.45 0.4 0.6 0.7 0.8 0.8 0.9 1];
% Bezier
nurbs4.nLevel = 4;
nurbs4.vecKnots = [0 0 0 0 0 1 1 1 1 1];
nurbs4.vecControlPoints = [10.021763 81.915572; 10.171763 81.882850; 10.271763 81.861036; 10.321763 81.844675; 10.321763 81.828314];
nurbs4.vecWeights = [];
% 星星
nurbs5.nLevel = 2;
nurbs5.vecKnots = [0 0 0 0.111 0.222 0.333 0.444 0.555 0.666 0.777 0.888 1 1 1];
nurbs5.vecControlPoints = [80 120; 50 80; 0 80; 40 40; 30 0; 80 30; 130 0; 120 40; 160 80; 110 80; 80 120];
nurbs5.vecWeights = [];
% 计算导矢数值
nurbs = nurbs1;
nCount = 200;
vecNewDeriv = zeros(nCount+1,9);
for i = 0:nCount
    nKnot = nurbs.vecKnots(1) + (nurbs.vecKnots(end) - nurbs.vecKnots(1)) * i / nCount;
    if size(nurbs.vecControlPoints,2) == 2
        [vecNewDeriv(i+1,1:2), vecNewDeriv(i+1,4:5), vecNewDeriv(i+1,7:8)] = GetNurbsDeriv(nurbs, nKnot);
    elseif size(nurbs.vecControlPoints,2) == 3
        [vecNewDeriv(i+1,1:3), vecNewDeriv(i+1,4:6), vecNewDeriv(i+1,7:9)] = GetNurbsDeriv(nurbs, nKnot);
    end
end
nStepKnot = (nurbs.vecKnots(end) - nurbs.vecKnots(1)) / nCount;
vecOrigDeriv = vecNewDeriv;
vecOrigDeriv(2:end,4:6) = diff(vecOrigDeriv(:,1:3)) / nStepKnot;
vecOrigDeriv(3:end,7:9) = diff(vecOrigDeriv(2:end,4:6)) / nStepKnot;
% 画图比较
vecTitles = {'轨迹图', '一阶导矢图', '二阶导矢图'};
for i = 1:min(nurbs.nLevel+1,3)
    figure(i);
    hold on;
    if isequal(vecNewDeriv(:,i*3), zeros(size(vecNewDeriv,1),1))
        plot(vecOrigDeriv(i:end,i*3-2), vecOrigDeriv(i:end,i*3-1), '.-b');
        plot(vecNewDeriv(:,i*3-2), vecNewDeriv(:,i*3-1), '.-g');
        if i == 1
            plot(nurbs.vecControlPoints(:,1), nurbs.vecControlPoints(:,2), '*-r');
        end
    else
        plot3(vecOrigDeriv(i:end,i*3-2), vecOrigDeriv(i:end,i*3-1), vecOrigDeriv(i:end,i*3), '.-b');
        plot3(vecNewDeriv(:,i*3-2), vecNewDeriv(:,i*3-1), vecNewDeriv(:,i*3), '.-g');
        if i == 1
            plot3(nurbs.vecControlPoints(:,1), nurbs.vecControlPoints(:,2), nurbs.vecControlPoints(:,3), '*-r');
        end
        view([1 1 1]);
    end
    legend('微分法作图', '计算法作图');
    title(vecTitles{i});
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
title('曲率图');
legend('微分法作图', '计算法作图');