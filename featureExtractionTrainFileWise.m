function [finalTable] = featureExtractionTrainFileWise(varargin)

finalTable = [];

%Step 4: Combine data from different files.
for masterVariable=1:nargin;%Goes over all the files
    
    
    %Step 1: Load the data for one file into tables

    windowWidth=64;%vary this to vary the size of the window
    windowOverlap=0.5;
    windowStep=windowWidth*windowOverlap;
    sampling_rate=25; %based on experimentation
    table_x1 = [];
    table_y1 = [];
    table_z1 = [];
    table_class1 = [];
    table_accel1 = [];
    %table_dir1 = [];

    t = readtable(varargin{masterVariable});
    table_x1 =  t.X_mG_;
    table_y1 =  t.Y_mG_;
    table_z1 =  t.Z_mG_;
    table_class1 =  t.Classification;

    [rows,~] = size(table_x1);
    
    timeSpentExcercisingInSeconds = rows / samplingRate;
    
    %Step 1a: Calculate acceleration for the data
    table_accel1=zeros(rows,1); %Pre-allocate an array of all zeroes to save compilation time.
    for i=1:rows
        vector = [table_x1(i,1) table_y1(i,1) table_z1(i,1)];
        table_accel1(i,1) = norm(vector);
    end

    %Step 1b: Calculate unit direction for the data
    %table_dir1=zeroes(rows,3);
    %for i=1:rows
    %    table_dir1(i,1) = varfun(@calculateUnitVectorInThatDirection,table_x1(i),table_accel1(i));
    %    table_dir1(i,2) = varfun(@calculateUnitVectorInThatDirection,table_y1(i),table_accel1(i));
    %    table_dir1(i,3) = varfun(@calculateUnitVectorInThatDirection,table_z1(i),table_accel1(i));
    %    %dir1 = [x_unit y_unit z_unit] -->sample row
    %end

    
    %Step 2: Slide a window down the columns and calculate the mean and
    %standard deviation of each window (for each column)
    intermediate = rows-windowWidth-1;
    numWindows = ceil(intermediate/windowStep);%num windows is the number of windows we will have, based on 
    %the number of rows we have, the amoun      t of overlap, etc.
    %derivation of this formula is in derivation_of_numWindows.txt

    table_xMean = zeros(numWindows,1);
    table_xStDev = zeros(numWindows,1);
    table_yMean = zeros(numWindows,1);
    table_yStDev = zeros(numWindows,1);
    table_zMean = zeros(numWindows,1);
    table_zStDev = zeros(numWindows,1);
    table_accelMean = zeros(numWindows,1);
    table_accelStDev = zeros(numWindows,1);
    %table_dirMean = zeros(numWindows,3);
    %table_dirStDev = zeros(numWindows,3);

    windowStart=1;
    windowEnd=windowStart+windowWidth;
    while windowEnd<=rows;
        currentRow = floor(windowStart/windowStep) + 1; %Returns 1 the first pass through the loop, 2 the second pass, 3 the third,etc.
        table_xMean(currentRow,1) = mean(table_x1(windowStart:windowEnd,1),1); %average accel_x for the window
        table_xStDev(currentRow,1) = std(table_x1(windowStart:windowEnd,1),[],1); %standard deviation of accel_x for the window
        table_yMean(currentRow,1) = mean(table_y1(windowStart:windowEnd,1),1);%average accel_y for the window
        table_yStDev(currentRow,1) = std(table_y1(windowStart:windowEnd,1),[],1);%standard deviation of accel_y for the window
        table_zMean(currentRow,1) = mean(table_z1(windowStart:windowEnd,1),1);%average accel_z for the window
        table_zStDev(currentRow,1) = std(table_z1(windowStart:windowEnd,1),[],1);%standard deviation of accel_z for the window
        table_accelMean(currentRow,1) = mean(table_accel1(windowStart:windowEnd,1),1);%average accelartion for the window
        table_accelStDev(currentRow,1) = std(table_accel1(windowStart:windowEnd,1),[],1);%standard dev. of accel for the window
        %table_dirMean(currentRow,1) = mean(table_dir(i:i+windowWidth),1);%average direction of accel for the window
        %table_dirStDev(currentRow,1) = std(table_dir(i:i+windowWidth),[],1);%stand. dev. of dir. of accel for the window
        windowStart = windowStart + windowStep;
        windowEnd=windowStart+windowWidth;
    end
    

    %Step3: make modified class table to attach to our other tables
    [lastRowToKeep,~]=size(table_xMean);
    [finalRow,~]=size(table_class1);
    table_class1(lastRowToKeep+1:finalRow,:)=[];

    finalTable1=table(table_xMean,table_xStDev,table_yMean,table_yStDev,table_zMean,table_zStDev,table_accelMean,table_accelStDev,table_class1);
    finalTable=[finalTable;finalTable1];

end
end


%function Q = calculateUnitVectorInThatDirection(vector,accel)
%    Q = vector / accel;
%end
