function [HD3] = getHD3_SDExchange(Ron, V0,CL,Fmax,varargin)
%getHD3_SDExchange calculated HD3 based on the analysis of S/D Exchange;
%Input Variable:
%   Ron: resistor in On State;
%   V0: the amplitude of the input signal;
%   CL: load caps;
%   Fmax: input frequency;
%   alpha: the coefficient representing length of MOSFET;
%Output:
%   HD3: 3-rd harmonic component [dB];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Original Calculation method
%     K1 = V0*C1/(VDD-VTH)*(alpha) .*Ron .*win;
%     K2 = V0*C1/(VDD-VTH)*(1) .*Ron .*win;
%     P = K1 - K2;
%     Q = K1 + K2;
    
%     R2_num = 30*pi*(-16.*P.^2 + 48*pi.*P + 9*pi^2.*Q.^2) .* Ron;
%     R2_den = -512.*P.^3 + 2688*pi.*P.^2 + 2160*pi^3 + ...
%         9*pi^2.*P.*(-464+5.*Q.^2);
%     R2 = R2_num ./ R2_den;
    
%     HD3 = C1 .*win .* R2 / 2;
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Simplifed method    
%     R2 = 10.*P ./ (-29.*P+15*pi)*Ron
% More
%     R2 = 2.*P ./ (3*pi)*Ron
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    % create inputParser object
    p = inputParser;

    % optional parameters
    addOptional(p,'VDD',1.8,@isnumeric);        % supply voltage
    addOptional(p,'VTH0',0.52,@isnumeric);       % threshold voltage
    addOptional(p,'alpha',-1.15,@isnumeric);    % the fitting coefficient
    addOptional(p,'Kn',270E-6,@isnumeric);      % mun*Cox
    parse(p, varargin{:});

    VDD = p.Results.VDD;
    VTH0 = p.Results.VTH0;
    alpha = p.Results.alpha;
    Kn = p.Results.Kn;

    % calculate HD3
    % Ron0 = 1/(Kn*(VDD-VTH0));
    wmax = 2*pi.*Fmax;

    K1 = V0*CL/(VDD-VTH0)*(alpha) .*Ron .*wmax;
    K2 = V0*CL/(VDD-VTH0)*(1) .*Ron .*wmax;
    
    R2 = (K1-K2)*2/(3*pi).*Ron;
    HD3 = (CL .* wmax .* R2 / 2);
    HD3 = mag2db(abs(HD3));

end