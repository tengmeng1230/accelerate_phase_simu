function coefs = XuGetWaterCorrectionCoefs(en_simu,spec_simu,vec_length_water,order_cell)
%function coefs = XuGetWaterCorrectionCoefs(en_simu,spec_simu,vec_length_water,order_cell)
spec_simu = spec_simu/sum(spec_simu);
mu_water = XuGetAtten('water',1,en_simu)/10;
mu_water_mean = sum(spec_simu.*mu_water);

postlog_simu_truth = vec_length_water*mu_water_mean;
postlog_val = zeros(1,length(vec_length_water));
for length_idx = 1:length(vec_length_water)
    
    atten_simu = sum(spec_simu.*exp(-vec_length_water(length_idx)*mu_water));
    postlog_val(length_idx)= log(1/atten_simu);
end
coefs = XuPolyFitForOneInput(postlog_val,postlog_simu_truth,order_cell);
