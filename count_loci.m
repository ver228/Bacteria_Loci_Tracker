load('Data_MME_T4T130_310517_scan0.mat')
load('cellShapeInfo_T4T130_310517_scan0_PhC.mat')

%Create a table containing the number of loci per cell per video
ind_lociN = [shapeIndCell.videoID; shapeIndCell.cellID; shapeIndCell.lociN]';
ind_lociN = unique(ind_lociN, 'rows');

%I do not want nan values (I do not remember what they are there but i am sure they are bad
good = ~isnan(ind_lociN(:,1));
ind_lociN = ind_lociN(good,:);

% This is only to make the search of index easier
loci_n = ind_lociN(:, 3);
key_ii = cell(size(loci_n));
for ii = 1:size(ind_lociN, 1)
    key_ii{ii} = sprintf('%i_%i', ind_lociN(ii, 1), ind_lociN(ii, 2));
end
loci_n_map = containers.Map(key_ii,loci_n);

%% Now I get the number of loci per cell using the seg_*_PhC.mat method
dd = [shapeAll.videoID; shapeAll.cellID]';
loci_n_per_msd = nan(size(dd, 1), 1);
for ii = 1:size(dd,1)
    row = dd(ii,:);
    if ~any(isnan(row))
        key = sprintf('%i_%i', row(1), row(2));
        loci_n_per_msd(ii) = loci_n_map(key);
    end
end
%here there is something weird since some cells where I assigned the msd,
%are not supose to have any loci (loci_n_per_msd == 0), but hopefully it
%is a small error, but that will require me to work on the original code.

%% Plot 
msd = timeAv.MSD;
figure(), hold on
for nn = 1:2
    msd_mean = mean(msd(:, loci_n_per_msd==nn), 2);
    plot(msd_mean)
end
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')
legend({'1', '2'})
xlim([1,20])






