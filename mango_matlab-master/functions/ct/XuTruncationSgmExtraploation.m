function sgm_corr = XuTruncationSgmExtraploation(sgm, detEleSize, mu, idxLeft, idxRight)
% Do extrapolation for truncated sinogram.
% sgm: truncated sinogram [rows x cols x slices]
% detEleSize: detector element size (mm).
% mu: linear attenuation of object (/mm) (e.g. 0.020 for soft tissue)
% idxLeft: index of left side for slope calculation (e.g. 196:210, then 1:195 will be extrapolated).
% idxRight: idex of right side for slope calculation.
% sgm_corr: sinogram after extraploation.

if nargin < 2
    mu = 0.017;
end

% detector element size [mm]
dx = detEleSize;

[M, N, S] = size(sgm);


for slice = 1:S
    % start interp
    for row = 1:M
        %-----------------------------------
        % left
        %-----------------------------------
        p = sgm(row, idxLeft(1), slice);
        % calculate slope
        x_left = idxLeft * detEleSize;
        s = polyfit(x_left, sgm(row, idxLeft, slice), 1);
        s = s(1);
        % position x_0
        x_0 = x_left(1) + p*s/(4*mu^2);
        % radius R
        R = sqrt(p^2/(4*mu^2) + (x_left(1) - x_0)^2);

        x_to_be_extraplate = (1:(idxLeft(1))) * detEleSize;
        val_extraplate = real(2*mu*sqrt(R^2  - (x_to_be_extraplate - x_0).^2));
        ratio = val_extraplate(end)/p;
        sgm(row, 1:(idxLeft(1)-1), slice) = val_extraplate(1:end-1) /ratio;

        p = sgm(row, idxRight(end), slice);
        % calculate slope
        x_right = idxRight * detEleSize;
        s = polyfit(x_right, sgm(row, idxRight, slice), 1);
        s = s(1);
        % position x_0
        x_0 = x_right(end) + p*s/(4*mu^2);
        % radius R
        R = sqrt(p^2/(4*mu^2) + (x_right(1) - x_0)^2);

        x_to_be_extraplate = (idxRight(end):N) * detEleSize;
        val_extraplate = real(2*mu*sqrt(R^2  - (x_to_be_extraplate - x_0).^2));
        ratio = val_extraplate(1)/p;
        sgm(row, (idxRight(end)+1) :N, slice) = val_extraplate(2:end) /ratio;


    end
end
sgm_corr = sgm;
sgm_corr(find(isnan(sgm_corr))) = 0;

