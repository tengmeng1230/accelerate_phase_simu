function sgm_noisy = XuGenSgmNoisyGauss(sgm,N)
%sgm_noisy = XuGenSgmNoisy(sgm,N)
%sgm is postlog

sgm_prelog=exp(-sgm);

sgm_prelog_N = N.*sgm_prelog;

sgm_prelog_N_smaller_than_20_map = sgm_prelog_N<20;

sgm_prelog_N_smaller_than_20 = sgm_prelog_N.*sgm_prelog_N_smaller_than_20_map;%set regions larger than 20 to zero
sgm_prelog_N_smaller_than_20 = sgm_prelog_N_smaller_than_20 + (1 - sgm_prelog_N_smaller_than_20_map);%set regions larger than 20 to 1


sgm_prelog_N_smaller_than_20_noisy = poissrnd(sgm_prelog_N_smaller_than_20);
sgm_prelog_N_noisy = sqrt(sgm_prelog_N).*randn(size(sgm))+sgm_prelog_N;
sgm_prelog_N_noisy = sgm_prelog_N_noisy.*(1-sgm_prelog_N_smaller_than_20_map) + sgm_prelog_N_smaller_than_20_noisy.*sgm_prelog_N_smaller_than_20_map;
sgm_noisy = log(N./(sgm_prelog_N_noisy+eps));