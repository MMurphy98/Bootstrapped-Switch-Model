function HD3 = getHD3_Cap_Track(size, V0, CL, Fmax, Cb, Cp_array, varargin)
%getHD_Cap_Track: calculated HD3 based based on capacitive division;
%Input Variable:
%   size: W/L
%   V0: input voltage;
%   CL: load caps;
%   Fmax: input frequency;
%   Cb: bootstrapped capacitor;
%   Cp_array: the parasitic capacitors array, [Cg-G, Cg-s, Cg-d]
%Output:
%   HD3: 3-rd harmonic component [dB];
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
%% Input Parameters parse
% create inputParser object
    p = inputParser;

% optional parameters
    addOptional(p,'VDD',1.8,@isnumeric);        % supply voltage
    addOptional(p,'VTH0',0.52,@isnumeric);      % threshold voltage
    addOptional(p,'Kn',270E-6,@isnumeric);
    parse(p, varargin{:});
    VDD = p.Results.VDD;
    VTH0 = p.Results.VTH0;
    Kn = p.Results.Kn;
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% calculate Vgs
    C_tot = Cb + sum(Cp_array);
    Vgs1 = Cp_array(1) ./ C_tot * V0 ;          % AC value
    Vgs0 = VDD;                                 % DC value
    KV = Vgs1 ./ (Vgs0 - VTH0);

    ron0 = 1/(Kn*size*(Vgs0-VTH0));
    R2 = (KV.^2) .* ron0 ./ 2;
    HD3 = mag2db(R2*CL*Fmax*pi);
end
