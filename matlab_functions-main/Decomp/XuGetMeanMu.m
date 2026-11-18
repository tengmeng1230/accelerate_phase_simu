function mu_mean = XuGetMeanMu(s_material,density,spec_simu,en_simu,detector_type)
if nargin == 4
    detector_type = 1;
end
mu = XuGetAtten(s_material,density,en_simu)/10;
if detector_type == 1
    spec_simu = spec_simu/sum(spec_simu);
    mu_mean = sum(spec_simu.*mu);
else
     mu_mean = sum(spec_simu.*en_simu.*mu)/sum(spec_simu.*en_simu);
end