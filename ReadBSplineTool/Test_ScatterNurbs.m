%% test
clear all;clc;close all;
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
% 计算曲线上的点
nurbs = nurbs1;
nCount = 200;
vecPointsByFormula = zeros(nCount+1,3);
for i = 0:nCount
    nKnot = nurbs.vecKnots(1) + (nurbs.vecKnots(end) - nurbs.vecKnots(1)) * i / nCount;
    if size(nurbs.vecControlPoints,2) == 2
        [vecPointsByFormula(i+1,1:2), ~, ~] = GetNurbsDeriv(nurbs, nKnot);
    elseif size(nurbs.vecControlPoints,2) == 3
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
    plot(nurbs.vecControlPoints(:,1), nurbs.vecControlPoints(:,2), '*-r');
else
    plot3(vecPointsByFormula(:,1), vecPointsByFormula(:,2), vecPointsByFormula(:,3), '.-b');
    plot3(vecPointsByDeflection(:,1), vecPointsByDeflection(:,2), vecPointsByDeflection(:,3), '.-g');
    plot3(nurbs.vecControlPoints(:,1), nurbs.vecControlPoints(:,2), nurbs.vecControlPoints(:,3), '*-r');
    view([1 1 1]);
end
legend('按节点矢量离散作图', '按弓高误差离散作图');
title('轨迹图');
axis equal;