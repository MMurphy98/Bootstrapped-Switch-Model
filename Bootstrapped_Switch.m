function [result, Size_Array, Capacitor_Array] = Bootstrapped_Switch(fmax, CL, V0, THD, varargin)
%Bootstrapped_Switch: calculated the transistor size and bootstrapped
%capacitor
%Input Variable:
%   fmax: the frequency of the input signal;
%   V0: input voltage;
%   CL: load caps;
%   THD: target thd;
%Output:
%   result: the calculated results
%   Size_Array: the sweep results of W
%   Capacitor_Array: the sweep results of Cb
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   
%% Input ParameterS parse
% create inputParser object
    p = inputParser;

% optional parameters
    addOptional(p,'VDD',1.8,@isnumeric);        % supply voltage
    addOptional(p,'VTH0',0.52,@isnumeric);      % threshold voltage
    addOptional(p,'alpha',-1.15,@isnumeric);    % the fitting coefficient
    addOptional(p,'Kn',270E-6,@isnumeric);      % miun*Cox
    parse(p, varargin{:});

    VDD = p.Results.VDD;
    VTH0 = p.Results.VTH0;
    alpha = p.Results.alpha;
    Kn = p.Results.Kn;

    
% defalut parameter
    VOD = VDD - VTH0;
    L = 0.2;                                    % um

    if THD < 0 
        THD_Target = THD - 4;
    else
        THD_Target = -1*THD - 4;
    end
    HD3_SD = db2mag(THD_Target);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Calculate the size of the switching transistor
    K_SD = 4*pi/3*V0*fmax^2*CL^2*abs(alpha-1)/VOD;
    Ron0 = sqrt(HD3_SD / K_SD);
    
    size = 1/(Kn*VOD*Ron0);
    W_des = size*L;                              % um
    
    Ron0_des = 1/(Kn*VOD*(W_des/L));
    HD3_SD = getHD3_SDExchange(Ron0_des, V0, CL, fmax);
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Calculate the bootstrapped capacitor Cb
    Cp1 = 1.5E-14;              % Cp from gate to ground (F)
    CovW = 1.8E-16;             % the overlap capcacitors coefficient (F/um)
    Cp2 = CovW * W_des;         % Cp from gate to input terminal (F)    
    Cp3 = CovW * W_des;         % Cp from gate to ouput terminal (F)
    Cp_array = [Cp1, Cp2, Cp3];  

    % bisection_method to find the cb from [Cp1, CL]
    cb0_upper = CL;
    cb0_lower = Cp1;
    cb0_tol = 0.01E-12;
    while (cb0_upper - cb0_lower) / 2 > cb0_tol
        cb0_mid = mean([cb0_lower, cb0_upper]);
        hd3_mid = getHD3_Cap_Switch_para(W_des/L,V0,CL,fmax, ...
            cb0_mid,Cp_array);
        if (hd3_mid == THD_Target)
            cb0_root = cb0_mid;
            return;
        else
            hd3_uppder = getHD3_Cap_Switch_para(W_des/L,V0,CL,fmax, ...
                cb0_upper,Cp_array);
            if (hd3_mid-THD_Target) * (hd3_uppder-THD_Target) < 0
                cb0_lower = cb0_mid;
            else
                cb0_upper = cb0_mid;
            end
        end
    end
    cb0_root = mean([cb0_lower, cb0_upper]);
    HD3_cap_switch = getHD3_Cap_Switch_para(W_des/L,V0,CL,fmax, ...
        cb0_root,Cp_array);

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Check the capacitive division
    Cgs0 = 0.90E-15; % parasitic coefficient capacitors in triode region (F/um)
    Cgs = Cgs0 * W_des;
    Cgd = Cgs0 * W_des;
    HD3_cap_track = getHD_Cap_Track(W_des/L,V0,CL,fmax, ...
        cb0_root,[Cp1, Cgs, Cgd]);
    if (HD3_cap_track > THD_Target)
        warning("Capacitive Division Failed!");
    end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Sweep Size and bootstrapped capacitor 
    Sweep_Length = 50;
    Sweep_Range = linspace(0.1, 2, Sweep_Length);
    Sweep_W = W_des*Sweep_Range;
    Sweep_Cb = cb0_root*Sweep_Range;
    HD3_Sweep_W = zeros(1,Sweep_Length);
    HD3_Sweep_Cb = zeros(1,Sweep_Length);
    for i = 1:Sweep_Length
        HD3_Sweep_W(i) = getHD3_SDExchange(1/(Kn*VOD*(Sweep_W(i)/L)), ...
            V0, CL, fmax);
        HD3_Sweep_Cb(i) = getHD3_Cap_Switch_para(W_des/L,V0,CL,fmax,...
            Sweep_Cb(i),Cp_array);
    end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%% Output results
    Size_Array.Size_i = Sweep_W;
    Size_Array.HD3_i = HD3_Sweep_W;
    Capacitor_Array.Cb_i = Sweep_Cb;
    Capacitor_Array.HD3_i = HD3_Sweep_Cb;
    
    result.W = W_des;                       % unit: um
    result.Cb = cb0_root;                   % unit: F
    result.HD3_tot = mag2db(sum([HD3_SD, ...% unit: dB
        HD3_cap_switch,HD3_cap_track].^2));
    result.HD3_SD = HD3_SD;                 % unit: dB
    result.HD3_cap_switch = HD3_cap_switch; % unit: dB
    result.HD3_cap_track = HD3_cap_track;   % unit: dB
    
end