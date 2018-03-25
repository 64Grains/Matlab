%% 检查NURBS曲线的参数
% NURBS曲线信息如下：
%   nurbs.nLevel -------------- 次数
%   nurbs.vecKnots ------------ 节点矢量
%   nurbs.vecControlPoints ---- 控制点
%   nurbs.vecWeights ---------- 控制点对应的权值点
%   nurbs.bRational ----------- 是否为有理B样条曲线
function nurbsNew = CheckNurbs(nurbs)
    % 检查是否为NURBS曲线
    if nurbs.nLevel <= 0 || length(nurbs.vecKnots) < 1 || size(nurbs.vecControlPoints,1) < 1 ...
            || length(nurbs.vecKnots) ~= size(nurbs.vecControlPoints,1) + nurbs.nLevel + 1
        error('错误的参数：NURBS曲线次数为%d，节点矢量数为%d，控制点数为%d\n',...
            nurbs.nLevel, length(nurbs.vecKnots), size(nurbs.vecControlPoints,1));
    end
    if length(nurbs.vecWeights) > 1 && length(nurbs.vecWeights) ~= size(nurbs.vecControlPoints,1)
        error('错误的参数：NURBS曲线控制点数为%d，控制点对应的权值数为%d\n',...
            size(nurbs.vecControlPoints,1), length(nurbs.vecWeights));
    end
    % 数值比较精度
    global g_nCompareError;
    g_nCompareError = 1e-9;
    % 检查是否为有理B样条曲线
    nurbsNew = nurbs;
    nurbsNew.bRational = false;
    for i = 2:length(nurbsNew.vecWeights)
        if abs(nurbsNew.vecWeights(i) - nurbsNew.vecWeights(1)) > g_nCompareError
            nurbsNew.bRational = true;
            break;
        end
    end
end