clear all
addpath util/
addpath data/
addpath data/MNIST/
addpath minFunc/
addpath ParforProgress2/

inputSize = 32*32;      % number of input units
hiddenSizes = [800];    % number of hidden units
outputSize = 10;
lambda = 0.0001;        % weight decay parameter

% load training images and labels
images_orig = loadMNISTImages('train-images.idx3-ubyte');
labels = loadMNISTLabels('train-labels.idx1-ubyte');
idx = find(labels==0);
labels(idx) = 10;
display_network(images_orig(:,1:100)); % Show the first 100 images
disp(labels(1:30));
labelData = zeros(10, size(images_orig, 2));
for i = 1 : length(labels)
    labelData(labels(i), i) = 1;
end
% load test images and labels
testImages = loadMNISTImages('t10k-images.idx3-ubyte');
testLabels = loadMNISTLabels('t10k-labels.idx1-ubyte');
idx = find(testLabels==0);
testLabels(idx) = 10;

paraVector = initParams(inputSize, hiddenSizes, outputSize);

% pad training set
images = reshape(images_orig, 28, 28, size(images_orig, 2));
images_padded = zeros(32, 32, size(images, 3));
for i = 1 : size(images, 3)
    images_padded(:,:,i) = padarray(images(:,:,i), [2, 2], 0);
end
% reshape back
images_padded = reshape(images_padded, 32*32, size(images_padded, 3));
fprintf('Training image padding done!\n');

% pad test set
testImagesSquare = reshape(testImages, 28, 28, size(testImages, 2));
testImages_padded = zeros(32, 32, size(testImagesSquare, 3));
for i = 1 : size(testImagesSquare, 3)
    testImages_padded(:,:,i) = padarray(testImagesSquare(:,:,i), [2, 2], 0);
end
% reshape back
testImages_padded = reshape(testImages_padded, 32*32, size(testImages_padded, 3));
fprintf('Test image padding done!\n');

% gradient checking
%[cost, grad] = coreActions(paraVector, inputSize, hiddenSizes, outputSize, lambda, ...
%                            images_padded(:,1:3), labelData);
                        
%fprintf('Gradient Checking! Begin \n');


   
%numgrad = computeNumericalGradient(paraVector, inputSize, hiddenSizes, outputSize, lambda, ...
%                                   images_padded(:,1:3), labelData, grad);
                               
%fprintf('End Gradient Checking! ');

options.Method = 'lbfgs'; % Here, we use L-BFGS to optimize our cost
                          % function. Generally, for minFunc to work, you
                          % need a function pointer with two outputs: the
                          % function value and the gradient. In our problem,
                          % sparseAutoencoderCost.m satisfies this.
options.maxIter = 50;	  % Maximum number of iterations of L-BFGS to run 
options.display = 'on';
batchsize = 10000;
% randomly generate indices
perm = randperm(size(images_orig, 2));




loopNo = size(images_orig, 2) / batchsize;
for loop = 1 : loopNo
    fprintf('loop: %d/%d\n', loop, loopNo);   
    
    startIdx = (loop - 1) * batchsize + 1;
    endIdx = startIdx + batchsize - 1;
    batchdata = images_padded(:, perm(startIdx:endIdx));
    batchLabel = labelData(:, perm(startIdx:endIdx));
    
    fprintf('with index: %d to %d\n', startIdx, endIdx);
    
    
    % optimization
    [paraVector, cost] = minFunc(@(p) coreActions(p, ...
                                       inputSize, hiddenSizes, outputSize, lambda, ... 
                                       batchdata, batchLabel), paraVector, options);
	
    % testing    
    % compute test accuracy
    fprintf('computing test accuracy...\n');
    estimatedOutputs = zeros(10, size(testImages_padded, 2));
    parfor i = 1 : size(testImages_padded, 2)
        output = computeOutput(paraVector, inputSize, hiddenSizes, outputSize, lambda, testImages_padded(:,i));
        estimatedOutputs(:,i) = output;
    end
    [maxVal, estimatedLabels] = max(estimatedOutputs);
    estimatedLabels = estimatedLabels';
    correctCount = length(find(estimatedLabels == testLabels));
    acc = correctCount / size(testImages, 2);
    err = 1 - acc;
    fprintf('testing acc: %f%%, \n', acc*100);
    fprintf('testing err: %f%% \n', err*100);
    
    fid = fopen('result.txt', 'at');
    %fprintf(fid, 'loop: %d, \n', loop);
    fprintf(fid, 'acc: %f%%, \n', acc*100);
    fprintf(fid, 'err: %f%% \n', err*100);
    %fprintf(fid, 'cost: %f, \n', cost);
    fprintf(fid, '----------------------------\n');
    fclose(fid);
end


                                
                                
                                
                                



