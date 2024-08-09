function HD3 = getHD3_Cap_Switch_para(size, V0, CL, Fmax, Cb, Cp_array,varargin)
%getHD_Cap_Switch: calculated HD3 based on the analysis of Cap Switching;
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
%% Calculate the Kv = Vgs1 / (Vgs0-VTH0)     
    C_tot = Cb + sum(Cp_array);
    Cp_tot = sum(Cp_array);
    Vgs0 = (Cb*VDD - (Cp_tot)*VDD/2) ./ C_tot;      % DC value
    Vgs1 =  Cp_tot ./ C_tot * V0 ;                  % AC value
    KV = Vgs1 ./ (Vgs0-VTH0);
    
    ron0 = 1/(Kn*size*(Vgs0-VTH0));
    R2 = (KV.^2).* ron0 / 2;
    HD3 = mag2db(R2.*CL*Fmax*pi);

end
