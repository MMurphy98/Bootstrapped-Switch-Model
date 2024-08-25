%% Parameters Settings
V0 = 0.89;                     % input swing
C1 = 38.72E-12;                 % load cap
Fs = 2E6;                       % sample rate
Fin0 = 499/1024*Fs;             % input frequency (Hz)

%% Run Calculation
Target_THD = 90;
[r, size_array, cb_array] = Bootstrapped_Switch(Fin0, C1, V0, Target_THD)