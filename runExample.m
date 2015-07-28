%Navigate to folder where the data is located. Copy and past each statement
%into the command window and run them one at a time.

tableTrain = featureExtractionTrain(...
    'Edited Jumping Jacks NON_DOMINATE_WRIST Jul 26, 2015 63120 PM.csv', ...
    'Edited Pushups NON_DOMINATE_WRIST Jul 26, 2015 55445 PM.csv', ...
    'Edited Situps NON_DOMINATE_WRIST Jul 26, 2015 55725 PM.csv');

%Import tableTrain, train a model, name your model 'trainedClassifier'
classificationLearner;

tableTest = featureExtractionTest('Test Sophia Situps Data.csv');

tablePredict = predict(trainedClassifier, tableTest{:,trainedClassifier.PredictorNames});

tableEvaluate = [tableTest tablePredict];

