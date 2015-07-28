function [finalTable] = featureExtractionTrain(varargin)
    
    %Step 1: Import data from files into four tables: one for each of x, y,
    %z and classification
    
    table_x1 = [];
    table_y1 = [];
    table_z1 = [];
    table_c1 = [];
    
    for i = 1:nargin
        
        t = readtable(varargin{i});
        table_x1 = [table_x1; t.X_mG_];
        table_y1 = [table_y1; t.Y_mG_];
        table_z1 = [table_z1; t.Z_mG_];
        table_c1 = [table_c1; t.Classification];
        
    end
    
    %Step 2a: Implement sliding window of width 128 and 50% overlap (x)
    
    table_x2(1, 1:128) = rot90(table_x1(1:128, 1));
    sRow = 129;
    tRow = 2;
    [rows,~] = size(table_x1);
    
    while sRow + 64 <= rows
        table_x2(tRow, 1:64) = table_x2(tRow - 1, 65:128);
        table_x2(tRow, 65:128) = rot90(table_x1(sRow:(sRow + 63)));
        tRow = tRow + 1;
        sRow = sRow + 64;
    end
    
    %Step 2b: Implement sliding window of width 128 and 50% overlap (y)
    
    table_y2(1, 1:128) = rot90(table_y1(1:128, 1));
    sRow = 129;
    tRow = 2;
    [rows,~] = size(table_y1);
    
    while sRow + 64 <= rows
        table_y2(tRow, 1:64) = table_y2(tRow - 1, 65:128);
        table_y2(tRow, 65:128) = rot90(table_y1(sRow:(sRow + 63)));
        tRow = tRow + 1;
        sRow = sRow + 64;
    end
    
    %Step 2c: Implement sliding window of width 128 and 50% overlap (z)
    
    table_z2(1, 1:128) = rot90(table_z1(1:128, 1));
    sRow = 129;
    tRow = 2;
    [rows,~] = size(table_z1);
    
    while sRow + 64 <= rows
        table_z2(tRow, 1:64) = table_z2(tRow - 1, 65:128);
        table_z2(tRow, 65:128) = rot90(table_z1(sRow:(sRow + 63)));
        tRow = tRow + 1;
        sRow = sRow + 64;
    end
    
    %Step 2d: Make new classification table to align with the 3 new tables
    %for x, y and z.
    
    table_c2(1, 1) = rot90(table_c1(128, 1));
    sRow = 129;
    tRow = 2;
    [rows,~] = size(table_c1);
    
    while sRow + 64 <= rows
        table_c2(tRow, 1) = table_c1(sRow, 1);
        tRow = tRow + 1;
        sRow = sRow + 64;
    end
    
    %Step 3: Combine the x, y, and z tables
    
    combinedData = table(table_x2, table_y2, table_z2);
    
    %Step 4: Feature extraction
    
    dataMean = varfun(@calcHorizontalMean, combinedData);
    dataStdv = varfun(@calcHorizontalStdv, combinedData);
    
    finalTable = [dataMean, dataStdv];
    finalTable.activity = table_c2;
end
    
function Y = calcHorizontalMean(X)
    Y = mean(X,2);
end

function Y = calcHorizontalStdv(X)
    Y = std(X,[],2);
end