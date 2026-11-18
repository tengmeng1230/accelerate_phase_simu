function delta=XuGetDelta(s,energy,indicated_density)
%delta=XuGetAtten(s,energy,indicated_density)
%s is the string of the atten file
%energy is in keV
%indicated_density(optional) the indicated density for this material (g/cm^3)
%delta includes the density

if nargin == 2
    density_ratio = 1;
else
    density_rec = MgGetMaterialDensity(s);
    density_ratio = indicated_density / density_rec;
end


data=importdata([s,'_delta.txt']);
energy_eV=energy*1000;
if min(energy_eV)<min(data(:,1)) || max(energy_eV)>max(data(:,1))
    fprintf('Warning: Energy out of range!\n');
end
data_log=log(data);
energy_log=log(energy_eV);
delta_log=interp1(data_log(:,1),data_log(:,2),energy_log,'linear','extrap');
delta=exp(delta_log);

delta = delta * density_ratio;