function [hists, image_path]=flickr30k_feature_extractor(input_dir, outputFile)
% Author: Andrea Vedaldi
% Stripped to my requierments by me on 28 sep
% Copyright (C) 2011-2013 Andrea Vedaldi
% All rights reserved.
%
% This file is part of the VLFeat library and is made available under
% the terms of the BSD license (see the COPYING file).
run([getenv('VLFEATROOT') '/toolbox/vl_setup']);
numdescr=1e5; % The number of descriptors in btw the code
numWords=600; % The number of KNN clusters in the VBOW model
resizeDim = 100; % The dimension to which the images are resized to.
standardizeImage = @(im) imresize(im2single(im), [resizeDim NaN]);
randSeed = 1;
randn('state',randSeed) ;
rand('state',randSeed) ;
vl_twister('state',randSeed) ;

%% Get PHOW descriptors to train the dictionary
model.phowOpts={'Step', 3};
image_path=dir(fullfile(input_dir, '*.jpg'));
image_path=cellfun(@(e) fullfile(input_dir, e), {image_path.name}, ...
                   'UniformOutput', false);
descrs = {};
parfor ii = 1:length(image_path)
    fprintf('Phowing %d image\n', ii);
    im = standardizeImage(imread(image_path{ii})) ;
    [~, descrs{ii}] = vl_phow(im, model.phowOpts{:}) ;
end
descrs = single(vl_colsubset(cat(2, descrs{:}), numdescr));

%% Quantize descriptors to get visual words
model.vocab = vl_kmeans(descrs, numWords, 'verbose', 'algorithm', 'elkan', 'MaxNumIterations', 50);
model.kdtree = vl_kdtreebuild(model.vocab);
model.quantizer = 'kdtree';
model.numSpatialX = 2;
model.numSpatialY = 2;

%% Compute Histograms
hists = {};
parfor ii = 1:length(image_path)
    fprintf('Processing %d image\n', ii);
    hists{ii} = getImageDescriptor(model, imread(image_path{ii}), standardizeImage)';
end
hists = cat(1, hists{:});