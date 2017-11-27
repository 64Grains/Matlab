%% 解析出有效的文件路径
function vecValidFilePaths = ParseValidFilePath(vecOrigFilePaths)
    nLength = length(vecOrigFilePaths);
    vecValidFilePaths = cell(nLength,1);
    nIndex = 1;
    for i = 1:nLength
        if ~isempty(vecOrigFilePaths{i})
            vecValidFilePaths{nIndex} = vecOrigFilePaths{i};
            nIndex = nIndex + 1;
        end
    end
    if 1 == nIndex
        vecValidFilePaths = [];
    else
        vecValidFilePaths = vecValidFilePaths(1:nIndex-1);
    end
end