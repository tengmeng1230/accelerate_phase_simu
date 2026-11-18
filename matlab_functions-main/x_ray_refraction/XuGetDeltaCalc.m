function delta=XuGetDeltaCalc(energy,A,Z,rho)
%delta=XuGetDeltaCalc(s,energy,A,Z,rho)
%enegy is in keV
%A is molar mass (e.g. in g/mol)
%Z is atomic number
%rho is density (g/cm^3)


r_e = 2.81e-15;
h = 1.0545e-34 * 2 * pi;
c = 3e8;
energy_in_j = 1.6022e-16 * energy;

rho_e = 6.02e23 / A * Z * rho * 1e6;

delta = r_e * (h^2) *(c^2) ./(2*pi*(energy_in_j.^2)) * rho_e;