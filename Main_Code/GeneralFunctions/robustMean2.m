function [finalMean, stdSample] = robustMean2(data)
%%% MODIFY TO WORK ONLY WITH VECTORS (FASTER) AEJ

%ROBUSTMEAN calculates mean and standard deviation discarding outliers
%
% SYNOPSIS [finalMean, stdSample, inlierIdx, outlierIdx] = robustMean(data)
%
% INPUT    data : input data
%          dim  : (opt) dimension along which the mean is taken
%          k    : (opt) #of sigmas at which to place cut-off
%
% OUTPUT   finalMean : robust mean
%          stdSample : std of the data (divide by sqrt(n) to get std of the
%                      mean)
%          inlierIdx : index into data with the inliers 
%          outlierIdx: index into data with the outliers
%
% REMARKS  The code is based on (linear)LeastMedianSquares. It could be changed to
%          include weights 
%This file is part of u-track.
%
%    u-track is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%    u-track is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with u-track.  If not, see <http://www.gnu.org/licenses/>.
%
% Copyright: jonas, 04/04
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%========================
% LEAST MEDIAN SQUARES
%========================

% define magic numbers:
k=3; %cut-off is roughly at 3 sigma, see Danuser, 1992 or Rousseeuw & Leroy, 1987
magicNumber2=1.4826^2; %see same publications

medianData = median(data);

% calculate statistics
res2 = (data-medianData).^2;
medRes2 = max(median(res2),eps);

%testvalue to calculate weights
testValue=res2./(magicNumber2*medRes2);

%goodRows: weight 1, badRows: weight 0
in = testValue<=k^2;
stdSample=sqrt(sum(res2(in))/(sum(in)-4));

%====END LMS=========

%======
% MEAN
%======
finalMean = mean(data(in));

