function [out,TS] = HexModel(fluid_h, P_h_su, in_h_su, m_dot_h, fluid_c, P_c_su, in_c_su, m_dot_c, param)

%% CODE DESCRIPTION
% ORCmKit - an open-source modelling library for ORC systems
% Remi Dickes - 27/04/2016 (University of Liege, Thermodynamics Laboratory)
% rdickes @ulg.ac.be
%
% HexModel is a single matlab code implementing six different modelling
% approaches to simulate counter-flow heat exchangers (see the Documentation/HexModel_MatlabDoc)
%
% The model inputs are:
%       - fluid_h: nature of the hot fluid                        	[-]
%       - P_h_su: inlet pressure of the hot fluid                   [Pa]
%       - in_h_su: inlet temperature or enthalpy of the hot fluid   [K or J/kg]
%       - m_dot_h: mass flow rate of the hot fluid                  [kg/s]
%       - fluid_c: nature of the cold fluid                        	[-]
%       - P_c_su: inlet pressure of the cold fluid                  [Pa]
%       - in_c_su: inlet temperature or enthalpy of the cold fluid  [K or J/kg]
%       - m_dot_c: mass flow rate of the cold fluid                 [kg/s]
%       - param: structure variable containing the model parameters
%
% The model paramters provided in 'param' depends of the type of model selected:
%
%       - if param.modelType = 'CstPinch':
%           param.pinch = pinch point value in the temperature profile [K]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'CstEff':
%           param.epsilon_th = effective thermal efficiency of the heat exchanger [-]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'PolEff':
%           param.CoeffPolEff = polynomial coefficients for calculating the effective thermal efficiency of the heat exchanger
%           param.m_dot_h_n = nominal hot fluid mass flow rate [kg/sec]
%           param.m_dot_c_n = nominal cold fluid mass flow rate [kg/sec]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'hConvCst':
%           param.hConv_h_liq = HF convective heat transfer coeff for liquid phase [W/m^2.K]
%           param.hConv_h_tp = HF convective heat transfer coeff for two-phase [W/m^2.K]
%           param.hConv_h_vap = HF convective heat transfer coeff for vapour phase [W/m^2.K]
%           param.hConv_c_liq = CF convective heat transfer coeff for liquid phase [W/m^2.K]
%           param.hConv_c_tp = CF convective heat transfer coeff for two-phase [W/m^2.K]
%           param.hConv_c_vap = CF convective heat transfer coeff for vapour phase [W/m^2.K]
%           param.A_tot (or param.A_h_tot && param.A_c_tot) = total surfac area of HEX [m^2]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'hConvVar':
%           param.m_dot_h_n = HF nominal mass flow rate [kg/s]
%           param.hConv_h_liq_n = HF nominal convective heat transfer coeff for liquid phase [W/m^2.K]
%           param.hConv_h_tp_n = HF nominal convective heat transfer coeff for two-phase [W/m^2.K]
%           param.hConv_h_vap_n = HF nominal convective heat transfer coeff for vapour phase [W/m^2.K]
%           param.m_dot_c_n = CF nominal mass flow rate [kg/s]
%           param.hConv_c_liq_n = CF nominal convective heat transfer coeff for liquid phase [W/m^2.K]
%           param.hConv_c_tp_n = CF nominal convective heat transfer coeff for two-phase [W/m^2.K]
%           param.hConv_c_vap_n = CF nominal convective heat transfer coeff for vapour phase [W/m^2.K]
%           param.A_tot (or param.A_h_tot && param.A_c_tot) = total surfac area of HEX [m^2]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
%       - if param.modelType = 'hConvCor':
%           param.correlation_h.type_1phase = type of correlation for the hot side (single phase)
%           param.correlation_h.type_2phase = type of correlation for the hot side (two phase)
%           param.correlation_c.type_1phase = type of correlation for the cold side (single phase)
%           param.correlation_c.type_1phase = type of correlation for the cold side (two phase)
%           param.CS_h / param.Dh_h = cross-section and hydraulic diameter of the hot fluid
%           param.CS_c / param.Dh_c = cross-section and hydraulic diameter of the cold fluid
%           param.A_tot (or param.A_h_tot && param.A_c_tot) = total surfac area of HEX [m^2]
%           param.type_h = type of input for hot fluid ('H' for enthalpy,'T' for temperature)
%           param.type_c = type of input for cold fluid ('H' for enthalpy,'T' for temperature)
%           param.V_h_tot = HEX volume for the hot fluid side [m^3]
%           param.V_c_tot = HEX volume for the cold fluid side [m^3]
%           param.displayResults = flag to display the results or not [1/0]
%           param.displayTS = flag to display the temperature profiles or not [1/0]
%
% The model outputs are:
%       - out: a structure variable which includes at miniumum the following information:
%               - x_vec =  vector of power fraction in each zone
%               - Qdot_vec =  vector of heat power in each zone [W]
%               - H_h_vec = HF enthalpy vector                  [J/kg]
%               - H_c_vec = CF enthalpy vector                  [J/kg]
%               - T_h_vec = HF temperature vector               [K]
%               - T_c_vec = CF temperature vector               [K]
%               - s_h_vec = HF entropy vector                   [J/kg.K]
%               - s_c_vec = HF entropy vector                   [J/kg.K]
%               - DT_vec = Temperature difference vector        [K]
%               - pinch =  pinch point value                  	[K]
%               - h_h_ex =  HF exhaust enthalpy                 [J/kg]
%               - T_h_ex =  HF exhaust temperature              [K]
%               - h_c_ex =  CF exhaust enthalpy                 [J/kg]
%               - T_c_ex =  CF exhaust temperature              [K]
%               - V_h_vec = HF volume vector                    [m^3]
%               - V_c_vec = CF volume vector                    [m^3]
%               - M_h_vec = HF mass vector                      [kg]
%               - M_c_vec = CF mass vector                      [kg]
%               - M_h = Mass of hot fluid in the HEX            [kg]
%               - M_c = Mass of hot fluid in the HEX            [kg]
%               - time = the code computational time          	[sec]
%               - flag = simulation flag                      	
%
%       - TS : a stucture variable which contains the vectors of temperature
%              and entropy of the fluid (useful to generate a Ts diagram
%              when modelling the entire ORC system
%
% Further details, contact rdickes@ulg.ac.be
% NOTE: the comments might not be up to date


%% DEMONSTRATION CASE

if nargin == 0    
    % Define a demonstration case if HexModel.mat is not executed externally  
    
    fluid_h = 'PiroblocBasic';                                               % Nature of the hot fluid           [-]
    m_dot_h = 0.05;                                                          % Mass flow rat of the hot fluid    [kg/s]
    P_h_su =  2e5;                                                          % Supply pressure of the hot fluid  [Pa]
    in_h_su = 370.5;% CoolProp.PropsSI('H','P',P_h_su,'T',70+273.15, fluid_h);      % Supply h or T of the hot fluid  	[J/kg pr K]
    fluid_c = 'R245fa';                                                     % Nature of the cold fluid        	[-]
    m_dot_c = 0.0349;                                                      % Mass flow rat of the cold fluid  	[kg/s]
    P_c_su = 8.67e5;                                                           % Supply pressure of the cold fluid	[Pa]
    in_c_su = 2.5073e+05; %CoolProp.PropsSI('H','P',P_c_su,'T',20+273.15, fluid_c);      % Supply h or T of the cold fluid  	[J/kg pr K]
    
    % Example of impletenation in the case of a correlation-based model for a plate heat exchanger
%     param.n_tp_disc = 10;
%     param.modelType = 'hConvCor';
%     param.correlation_h.type_1phase = 'Martin';
%     param.correlation_h.type_2phase = 'Han_condensation';
%     param.correlation_h.void_fraction = 'Homogenous';
% 
%     param.correlation_c.type_1phase = 'Martin';
%     param.correlation_c.type_2phase = 'Han_boiling';
%     param.type_h = 'T';   
%     param.type_c = 'H';   
    
    L_phex_ev = 0.519-0.06;
    W_phex_ev = 0.191;
    pitch_p_ev = 0.0022;
    th_p_ev = 0.0004;
    b_p_ev = pitch_p_ev-th_p_ev;
    Np_phex_ev = 100;
    Nc_wf_ev = ceil((Np_phex_ev-1)/2);
    Nc_sf_ev = floor((Np_phex_ev-1)/2);
    CS_ev = W_phex_ev*b_p_ev;
%     A_tot_ev = (Np_phex_ev-2)*L_phex_ev*W_phex_ev;
    A_eff_ev = 9.8;
    Np_eff_ev = Np_phex_ev-2;
    phi_ev = (A_eff_ev/Np_eff_ev)/(W_phex_ev*L_phex_ev);
    
    pitch_co_ev = 0.007213; %computed based on phi_ev and b_phex_ev
    Dh_ev = 2*b_p_ev/phi_ev;
    param.theta = 30*pi/180;
    param.type_h = 'T';
    param.type_c = 'H';
    param.A_h_tot = A_eff_ev;
    param.A_c_tot = A_eff_ev;
    param.V_h_tot = 0.009;
    param.V_c_tot = 0.009;
    param.L_hex = L_phex_ev;
    param.pitch_co = pitch_co_ev;
    param.phi =  phi_ev;
    param.Dh_c = Dh_ev;
    param.Dh_h = Dh_ev;
    param.CS_c = CS_ev;
    param.CS_h = CS_ev;
    param.n_canals_c = Nc_wf_ev;
    param.n_canals_h = Nc_sf_ev;
    param.n_tp_disc = 10;
    param.modelType = 'hConvCor';
    param.correlation_h.type_1phase = 'Wanniarachchi';
    param.correlation_h.type_2phase = 'Han_condensation';
    param.correlation_c.type_1phase = 'Wanniarachchi';
    param.correlation_c.type_2phase = 'Almalfi_boiling';
    param.correlation_h.void_fraction = 'Homogenous';
    param.correlation_c.void_fraction = 'Homogenous';%'Hughmark';
    
%     L_phex = 0.313;
%     W_phex = 0.1128;
%     pitch_pl_phex = 0.001;
%     pitch_co_phex = 0.005;
%     th_phex = 0.0003;
%     b_phex = pitch_pl_phex-th_phex;
%     Np_phex = 45;
%     Nc_h = ceil((Np_phex-1)/2);
%     Nc_c = floor((Np_phex-1)/2);
%     Dh = 2*b_phex;
%     CS = W_phex*b_phex;
%     A_tot = (Np_phex-2)*L_phex*W_phex;
%     param.L_hex = L_phex;
%     param.A_h_tot = A_tot;
%     param.A_c_tot = A_tot;  
%     param.V_h_tot = 0.001;
%     param.V_c_tot = 0.001;  
%     param.pitch_co = pitch_co_phex;
%     param.phi = 1.1;
%     param.n_canals_h = Nc_h;
%     param.n_canals_c = Nc_c;   
%     param.CS_h = CS;
%     param.CS_c = CS;
%     param.Dh_h = Dh;
%     param.Dh_c = Dh;
%     param.theta = 60*pi/180;

%     fluid_h = 'R245fa';                                               % Nature of the hot fluid           [-]
%     m_dot_h = 0.0269;                                                          % Mass flow rat of the hot fluid    [kg/s]
%     in_h_su =  4.3973e+05;                                                          % Supply pressure of the hot fluid  [Pa]
%     P_h_su = 3.1811e+05;% CoolProp.PropsSI('H','P',P_h_su,'T',70+273.15, fluid_h);      % Supply h or T of the hot fluid  	[J/kg pr K]
%     fluid_c = 'air';                                                     % Nature of the cold fluid        	[-]
%     m_dot_c = 0.2222;                                                      % Mass flow rat of the cold fluid  	[kg/s]
%     P_c_su = 100000;                                                           % Supply pressure of the cold fluid	[Pa]
%     in_c_su = 4.1975e+05; %CoolProp.PropsSI('H','P',P_c_su,'T',20+273.15, fluid_c);      % Supply h or T of the cold fluid  	[J/kg pr K]
% 
% 
% Rt_in =  8.5/2/1000;    % internal radius of the tube [m] 8.5
% Rt_ex = 9.5/2/1000;     % external radius of the tube [m] 9.5
% Lt = 1120/1000;         % length of the tube [m]
% N_pass = 12;            % Number of pass for each pipe [-]
% N_pipes = 13;           % Number of pipes [-]
% N_raw = 4;           % Number of pipes [-]
% pitch_fin = 3.5/1000;   % space between the fins [m]
% N_fin = floor(Lt/pitch_fin);% Number of fins [-]
% W_fin = 980/1000;       % Width of the fins [m]
% L_fin = 130/1000;       % Heigh of the fins [m]
% th_fin = 0.5/1000;      % Thickness of the fins [m]
% X_f_l = 26.5/1000;      % Longitudinal distance between the tubes [m]
% X_f_t = 26.3/1000;      % Transversal distance between the tubes [m]
% X_f_d = sqrt((0.5*X_f_t)^2+X_f_l^2); % Diagonal distance between the tubes [m]
% N_row_1line = N_pass*N_pipes/N_raw;          % Number of tubes in one raw
% CS_wf = pi*Rt_in^2;
% Dh_wf = 2*Rt_in;
% A_wf = 2*pi*Rt_in*Lt*N_pipes*N_pass;
% CS_sf = min((X_f_t - 2*Rt_ex), 2*(X_f_d - 2*Rt_ex))*N_row_1line*Lt -(W_fin*th_fin*N_fin) ;
% Dh_sf = 2*Rt_ex;
% A_fin = 2*N_fin*W_fin*L_fin;
% A_sf = A_fin+2*pi*Rt_ex*(Lt-N_fin*th_fin)*N_pipes*N_pass;
% B_fin = X_f_t/2;
% H_fin = 0.5*sqrt((0.5*X_f_t)^2 + X_f_l^2);
% omega_A = A_sf/A_wf;
% omega_f = A_fin/A_sf;
% omega_t = A_sf/(2*pi*Rt_ex*Lt*N_pipes*N_pass);
% k_fin = 205;
%     
param.displayResults = 0;
param.displayTS = 1;
param.generateTS = 1;
% 
% param.type_h = 'H';
% param.type_c = 'H';
% param.A_h_tot = A_wf;
% param.A_c_tot = A_sf;
% param.V_h_tot = 0.014;
% param.V_c_tot = 0.7585;
% param.fin_h = 'none';
% param.fin_c.k = k_fin;
% param.fin_c.th = th_fin;
% param.fin_c.r = Rt_ex;
% param.fin_c.B = B_fin;
% param.fin_c.H = H_fin;
% param.fin_c.omega_f = omega_f;
% param.fin_c.omega_t = omega_t;
% param.Dh_c = Dh_sf;
% param.Dh_h = Dh_wf;
% param.CS_c = CS_sf;
% param.CS_h = CS_wf;
% param.n_canals_c = N_pipes;
% param.n_canals_h = 1;
% param.n_tp_disc = 10;
% param.modelType = 'hConvCor';
% param.correlation_h.type_1phase = 'Gnielinski';
% param.correlation_h.type_2phase = 'Cavallini_condensation';
% param.correlation_c.type_1phase = 'VDI_finned_tubes_staggered';
% param.correlation_c.type_2phase = 'VDI_finned_tubes_staggered';
% param.correlation_h.void_fraction = 'Homogenous';
% param.correlation_c.void_fraction = 'Homogenous';


    % For another example of implementation, please load the .mat file
    % "HEX_param_examples" and select the desired modelling approach
%     load('HEX_param_examples.mat')
%     param = Example_HEX_hConvVar;
end

tstart_hex = tic;

%% HEAT EXCHANGER MODELLING
% Modelling section of the code

if not(isfield(param,'displayResults'))
    param.displayResults = 0;
    param.displayTS = 0;
    %if nothing specified by the user, the results are not displayed by
    %default.
end

if not(isfield(param,'V_h_tot'))
    param.V_h_tot = 0;
end
if not(isfield(param,'V_c_tot'))
    param.V_c_tot = 0;
end
if not(isfield(param,'generateTS'))
    param.generateTS = 1;
end
if not(isfield(param,'n_tp_disc'))
    param.n_tp_disc = 2;
end

% Evaluation of the hot fluid (HF) supply temperature
if strcmp(param.type_h,'H')
    T_h_su = CoolProp.PropsSI('T','P',P_h_su,'H',in_h_su, fluid_h);
elseif strcmp(param.type_h,'T')
    T_h_su = in_h_su;
end
% Evaluation of the cold fluid (CF) supply temperature
if strcmp(param.type_c,'H')
    T_c_su = CoolProp.PropsSI('T','P',P_c_su,'H',in_c_su, fluid_c);
elseif strcmp(param.type_c,'T')
    T_c_su = in_c_su;
end

flag_reverse = 0;
if T_h_su<T_c_su  
    if strcmp(param.modelType, 'CstEff')
        [fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, type_h_int,  V_h_int_tot ] = deal(fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.type_h, param.V_h_tot);
        [fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.type_h,  param.V_h_tot] = deal(fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.type_c, param.V_c_tot);
        [fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.type_c,  param.V_c_tot] = deal(fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, type_h_int,V_h_int_tot);
        flag_reverse = 1;
        
    elseif strcmp(param.modelType, 'PolEff')
        [fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, type_h_int,  V_h_int_tot] = deal(fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.type_h, param.V_h_tot);
        [fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.type_h, param.V_h_tot] = deal(fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.type_c,  param.V_c_tot);
        [fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.type_c, param.V_c_tot] = deal(fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, type_h_int, V_h_int_tot);
        param.CoeffPolEff = param.CoeffPolEff([1 3 2 6 5 4]);
        flag_reverse = 1;
        
    elseif strcmp(param.modelType, 'hConvVar')
        [fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, hConv_h_int_liq_n, hConv_h_int_tp_n, hConv_h_int_vap_n, type_h_int, A_h_int_tot, V_h_int_tot, alpha_mass_h_int] = deal(fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.hConv_h_liq_n, param.hConv_h_tp_n, param.hConv_h_vap_n, param.type_h, param.A_h_tot, param.V_h_tot, param.alpha_mass_h);
        [fluid_h, P_h_su, in_h_su, m_dot_h, T_h_su, param.m_dot_h_n, param.hConv_h_liq_n, param.hConv_h_tp_n, param.hConv_h_vap_n, param.type_h, param.A_h_tot, param.V_h_tot, param.alpha_mass_h] = deal(fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.hConv_c_liq_n, param.hConv_c_tp_n, param.hConv_c_vap_n, param.type_c, param.A_c_tot, param.V_c_tot, param.alpha_mass_c);
        [fluid_c, P_c_su, in_c_su, m_dot_c, T_c_su, param.m_dot_c_n, param.hConv_c_liq_n, param.hConv_c_tp_n, param.hConv_c_vap_n, param.type_c, param.A_c_tot, param.V_c_tot, param.alpha_mass_c] = deal(fluid_h_int, P_h_int_su, in_h_int_su, m_dot_h_int, T_h_int_su, m_dot_h_int_n, hConv_h_int_liq_n, hConv_h_int_tp_n, hConv_h_int_vap_n, type_h_int, A_h_int_tot, V_h_int_tot, alpha_mass_h_int);
        flag_reverse = 1;
    end
end

if (T_h_su-T_c_su)>1e-2  && m_dot_h  > 0 && m_dot_c > 0;
    % Check if the operating conditions permit a viable heat transfer
    
    switch param.modelType
        %If yes, select the proper model paradigm chosen by the user
        
        case 'CstPinch' % Model which imposes a constant pinch
            if T_h_su-T_c_su > param.pinch
                
                % Power and enthalpy vectors calculation
                lb = 0; % Minimum heat power that can be transferred between the two media
                ub = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute maximum heat power that can be transferred between the two media
                f = @(Q_dot) HEX_CstPinch_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param.pinch, Q_dot, param); % function to solve in order to find Q_dot_eff in the heat exchanger
                Q_dot_eff = zeroBrent ( lb, ub, 1e-6, 1e-6, f ); % Solver driving residuals of HEX_CstPinch_res to zero
                out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
                out.Q_dot_tot = Q_dot_eff;
                out.h_h_ex = out.H_h_vec(1);
                out.h_c_ex = out.H_c_vec(end);
                out.T_h_ex = out.T_h_vec(1);
                out.T_c_ex = out.T_c_vec(end);
                out.resPinch = abs(1-out.pinch/param.pinch);
                
                % Entropy vector calculation
                [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
                if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_h_vec)
                        out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                    end
                end
                if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_c_vec)
                        out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                    end
                end
                
                % Mass calculation
                out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
                out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
                for i = 1: length(out.V_h_vec)
                    if strcmp(param.type_h,'H')
                        out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                    else
                        out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                    end
                    if strcmp(param.type_c,'H')
                        out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                    else
                        out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                    end
                end
                out.M_h = sum(out.M_h_vec);
                out.M_c = sum(out.M_c_vec);
                
                % Flag evaluation
                if out.resPinch <1e-4
                    out.flag = 1;
                else
                    out.flag = -1;
                end
                
            else
                
                % Power and enthalpy vectors calculation
                Q_dot_eff = 0;
                out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
                out.h_h_ex = out.H_h_vec(1);
                out.h_c_ex = out.H_c_vec(end);
                out.T_h_ex = out.T_h_vec(1);
                out.T_c_ex = out.T_c_vec(end);
                out.Q_dot_tot = Q_dot_eff;
                
                % Entropy vector calculation
                [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
                if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_h_vec)
                        out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                    end
                end
                if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_c_vec)
                        out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                    end
                end
                
                % Mass calculation
                out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
                out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
                for i = 1: length(out.V_h_vec)
                    if strcmp(param.type_h,'H')
                        out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                    else
                        out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                    end
                    if strcmp(param.type_c,'H')
                        out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                    else
                        out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                    end
                end
                out.M_h = sum(out.M_h_vec);
                out.M_c = sum(out.M_c_vec);
                
                % Flag evaluation                
                out.flag = 2;
            end
            
        case 'CstEff'   % Model which imposes a constant thermal efficiency
                        
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max
            Q_dot_eff = param.epsilon_th*Q_dot_max; %Effective heat transfer
            out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = Q_dot_eff;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);

            % Entropy vector calculation            
            [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
            if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_h_vec)
                    out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                end
            end
            if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_c_vec)
                    out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
            out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
            for i = 1: length(out.V_h_vec)
                if strcmp(param.type_h,'H')
                    out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                else
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end
                if strcmp(param.type_c,'H')
                    out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                else
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
            
            % Flag evaluation             
            if abs(out_max.pinch) < 1e-2 % Check that Q_dot_max correspond to the situation where the pinch is equal to zero
                out.flag = 1;
            else
                out.flag = -2;
            end        
            
        case 'PolEff'   % Model which computes the thermal efficiency  with a polynomial regressions
            
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max
            Q_dot_eff = Q_dot_max*max(1e-5,min(1, param.CoeffPolEff(1) + param.CoeffPolEff(2)*(m_dot_h/param.m_dot_h_n) + param.CoeffPolEff(3)*(m_dot_c/param.m_dot_c_n) + param.CoeffPolEff(4)*(m_dot_h/param.m_dot_h_n)^2 + param.CoeffPolEff(5)*(m_dot_h/param.m_dot_h_n)*(m_dot_c/param.m_dot_c_n) + param.CoeffPolEff(6)*(m_dot_c/param.m_dot_c_n)^2));
            out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = Q_dot_eff;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);
            
            % Entropy vector calculation            
            [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
            if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_h_vec)
                    out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                end
            end
            if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_c_vec)
                    out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
            out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
            for i = 1: length(out.V_h_vec)
                if strcmp(param.type_h,'H')
                    out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                else
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end
                if strcmp(param.type_c,'H')
                    out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                else
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
            
            % Flag evaluation 
            if abs(out_max.pinch) < 1e-2 % Check that Q_dot_max correspond to the situation where the pinch is equal to zero
                out.flag = 1;
            else
                out.flag = -2;
            end
            
        case 'hConvCst' % 3-zone moving-boundary model with constant convective heat transfer coefficients
            if isfield(param, 'A_tot')
                % if only one surface area is specified, then it is the
                % same for the hot and the cold fluid (ex: CPHEX)
                param.A_h_tot = param.A_tot;
                param.A_c_tot = param.A_tot;
            end
            
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max
            lb = 0; % Minimum heat power that can be transferred between the two media
            ub = Q_dot_max;
            f = @(Q_dot) HEX_hConvCst_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su,  Q_dot, param); % function to solve in order to find Q_dot_eff in the heat exchanger
            if f(ub) > 0
                Q_dot_eff = ub; % HEX so oversized that the effective heat power is equal to Q_dot_max
            else
                Q_dot_eff = zeroBrent ( lb, ub, 1e-6, 1e-6, f); % Solver driving residuals of HEX_hConvCst_res to zero
            end
            out = HEX_hConvCst(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = Q_dot_eff;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);
            
            % Entropy vector calculation
            [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
            if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_h_vec)
                    out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                end
            end
            if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                for i = 1: length(out.H_c_vec)
                    out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.A_h./param.A_h_tot);
            out.V_c_vec = param.V_c_tot*(out.A_h./param.A_h_tot);
            for i = 1: length(out.V_h_vec)
                if strcmp(param.type_h,'H')
                    out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                else
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end
                if strcmp(param.type_c,'H')
                    out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                else
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D',out. T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
            
            % Flag evaluation              
            if out.resA <1e-4
                out.flag = 1;
            else
                if abs(out_max.pinch) < 1e-2
                    if Q_dot_eff == Q_dot_max
                        out.flag = 2;
                    else
                        out.flag = -1;
                    end
                else
                    out.flag = -2;
                end
            end
            
        case 'hConvVar' % 3-zone moving-boundary model with mass-flow dependent convective heat transfer coefficients
            if isfield(param, 'A_tot')
                % if only one surface area is specified, then it is the
                % same for the hot and the cold fluid (ex: CPHEX)
                param.A_h_tot = param.A_tot;
                param.A_c_tot = param.A_tot;
            end
            
            if isfield(param,'n')
                param.n_h_liq = param.n;
                param.n_c_liq = param.n;
                param.n_h_tp = param.n;
                param.n_c_tp = param.n;
                param.n_h_vap = param.n;
                param.n_c_vap = param.n;
            end
            
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max
            lb = 0; % Minimum heat power that can be transferred between the two media
            ub = Q_dot_max; % Maximum heat power that can be transferred between the two media
            f = @(Q_dot) HEX_hConvVar_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su,  Q_dot, param); % function to solve in order to find Q_dot_eff in the heat exchanger
            if f(ub) > 0
                Q_dot_eff = ub; % HEX so oversized that the effective heat power is equal to Q_dot_max
            else
                Q_dot_eff = zeroBrent ( lb, ub, 1e-8, 1e-8, f ); % Solver driving residuals of HEX_hConvVar_res to zero
            end
            out = HEX_hConvVar(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = Q_dot_eff;
            out.epsilon_th = Q_dot_eff/Q_dot_max;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);           
            out.hConv_h_liq_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'liq')));
            out.hConv_h_tp_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'tp')));
            out.hConv_h_vap_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'vap')));
            out.hConv_c_liq_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'liq')));
            out.hConv_c_tp_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'tp')));
            out.hConv_c_vap_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'vap')));
            
            % Entropy vector calculation
            [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
            if param.generateTS
                if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_h_vec)
                        out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                    end
                end
                if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_c_vec)
                        out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                    end
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.A_h./sum(out.A_h));
            out.V_c_vec = param.V_c_tot*(out.A_h./sum(out.A_h));

            for i = 1: length(out.V_h_vec)
                
                if strcmp(param.type_h,'H')
                    if strcmp(out.type_zone_h{i},  'tp') 
                        if strcmp(param.type_mass,'Sivi_integrated')
                            rho_h_vap = CoolProp.PropsSI('D','P',P_h_su,'Q',1,fluid_h);
                            rho_h_liq = CoolProp.PropsSI('D','P',P_h_su,'Q',0,fluid_h);
                            x2 = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h);
                            x1 = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                            S =  (rho_h_vap/rho_h_liq)^(-1/3);
                            K = rho_h_vap/rho_h_liq*S;
                            alpha_mass_h = -1*((K*(log(((x2-1)*K-x2)/((x1-1)*K-x1))+x2-x1))+(x1-x2))/(((x2-x1)*K^2)+(2*K*(x1-x2))+(x2-x1));
                            out.M_h_vec(i) = out.V_h_vec(i)*(alpha_mass_h*rho_h_vap+ (1-alpha_mass_h)*rho_h_liq);
                        elseif strcmp(param.type_mass,'Personnal')
                            alpha_mass_h = param.alpha_mass_h;
                            out.M_h_vec(i) = out.V_h_vec(i)*(alpha_mass_h*CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h)+(1-alpha_mass_h)*CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h));
                        end                        
                    else
                        out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                    end
                else
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end
                
                if strcmp(param.type_c,'H')
                    if strcmp(out.type_zone_c{i},  'tp')
                        if strcmp(param.type_mass,'Sivi_integrated')
                            rho_c_vap = CoolProp.PropsSI('D','P',P_c_su,'Q',1,fluid_c);
                            rho_c_liq = CoolProp.PropsSI('D','P',P_c_su,'Q',0,fluid_c);
                            x2 = CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c);
                            x1 = CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                            S =  (rho_c_vap/rho_c_liq)^(-1/3);
                            K = rho_c_vap/rho_c_liq*S;
                            alpha_mass_c = -1*((K*(log(((x2-1)*K-x2)/((x1-1)*K-x1))+x2-x1))+(x1-x2))/(((x2-x1)*K^2)+(2*K*(x1-x2))+(x2-x1));
                            out.M_c_vec(i) = out.V_c_vec(i)*(alpha_mass_c*rho_c_vap+ (1-alpha_mass_c)*rho_c_liq);
                        elseif strcmp(param.type_mass,'Personnal')
                            alpha_mass_c = param.alpha_mass_c;
                            out.M_c_vec(i) = out.V_c_vec(i)*(alpha_mass_c*CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c)+(1-alpha_mass_c)*CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c));
                        end
                    else
                        out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                    end
                else
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
            
            % Flag evaluation 
            if out.resA <1e-4
                out.flag = 1;
            else
                if abs(out_max.pinch) < 1e-2
                    if Q_dot_eff == Q_dot_max
                        out.flag = 2;
                    else
                        %fluid_h, P_h_su, in_h_su, m_dot_h, fluid_c, P_c_su, in_c_su, m_dot_c, param
                        out.flag = -1;
                    end
                    
                else
                    out.flag = -2;
                end
            end
            
        case 'hConvCor' % 3-zone moving-boundary model with empirical correlations from the litterature 
            if isfield(param, 'A_tot')
                % if only one surface area is specified, then it is the
                % same for the hot and the cold fluid (ex: CPHEX)
                param.A_h_tot = param.A_tot;
                param.A_c_tot = param.A_tot;
            end
            if not(isfield(param, 'fact_corr_sp'))                
                param.fact_corr_sp = 1;
            end
            if not(isfield(param, 'fact_corr_2p'))                
                param.fact_corr_2p = 1;
            end            
            
            % Power and enthalpy vectors calculation
            Q_dot_max = HEX_Qdotmax(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, param); %Compute the maximum heat power that can be transferred between the two media
            out_max = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_max, param); %Evaluate temperature profile based on Q_dot_max
            lb = 0; % Minimum heat power that can be transferred between the two media
            ub = Q_dot_max; % Maximum heat power that can be transferred between the two media
            f = @(Q_dot) HEX_hConvCor_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su,  Q_dot, param); % function to solve in order to find Q_dot_eff in the heat exchanger
            if f(ub) > 0
                Q_dot_eff = ub; % HEX so oversized that the effective heat power is equal to Q_dot_max
            else
                Q_dot_eff = zeroBrent ( lb, ub, 1e-8, 1e-8, f ); % Solver driving residuals of HEX_hConvVar_res to zero
            end
            out = HEX_hConvCor(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, real(Q_dot_eff), param); %Evaluate temperature profile based on Q_dot_eff
            out.Q_dot_tot = real(Q_dot_eff);
            out.epsilon_th = real(Q_dot_eff)/Q_dot_max;
            out.h_h_ex = out.H_h_vec(1);
            out.h_c_ex = out.H_c_vec(end);
            out.T_h_ex = out.T_h_vec(1);
            out.T_c_ex = out.T_c_vec(end);
            
            out.hConv_h_liq_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'liq')));
            out.hConv_h_tp_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'tp')));
            out.hConv_h_vap_mean = mean(out.hConv_h(strcmp(out.type_zone_h, 'vap')));
            out.hConv_c_liq_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'liq')));
            out.hConv_c_tp_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'tp')));
            out.hConv_c_vap_mean = mean(out.hConv_c(strcmp(out.type_zone_c, 'vap'))); 

            
            % Entropy vector calculation
            [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
            if param.generateTS
                if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_h_vec)
                        out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                        out.q_h_vec(i) = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                    end
                end
                if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
                    for i = 1: length(out.H_c_vec)
                        out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                        out.q_c_vec(i) = CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                    end
                end
            end
            
            % Mass calculation
            out.V_h_vec = param.V_h_tot*(out.A_h./sum(out.A_h));
            out.V_c_vec = param.V_c_tot*(out.A_h./sum(out.A_h));
            
            for i = 1: length(out.V_h_vec)
                if strcmp(param.type_h,'H')
                    if strcmp(out.type_zone_h{i},  'tp')
                             
                        q_h_1iq = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
                        q_h_vap = CoolProp.PropsSI('Q','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h);
                        rho_h_liq = CoolProp.PropsSI('D','P',P_h_su,'Q',0,fluid_h);
                        rho_h_vap = CoolProp.PropsSI('D','P',P_h_su,'Q',1,fluid_h);
                        switch param.correlation_h.void_fraction
                            case 'Homogenous'
                                f_void = @(q) VoidFraction_homogenous(q, rho_h_vap,  rho_h_liq);
                                Weight_h = integral(f_void, q_h_1iq, q_h_vap);
                                
                            case 'Sivi'
                                f_void = @(q) VoidFraction_Sivi(q, rho_h_vap,  rho_h_liq);
                                Weight_h = integral(f_void, q_h_1iq, q_h_vap);
                                
                            case 'Hughmark'
                                mu_h_liq = CoolProp.PropsSI('V','P',P_h_su,'Q',0,fluid_h);
                                mu_h_vap = CoolProp.PropsSI('V','P',P_h_su,'Q',1,fluid_h);
                                f_void = @(q) VoidFraction_Hughmark(q, rho_h_vap,  rho_h_liq, mu_h_vap, mu_h_liq, param.Dh_h,  m_dot_h/param.n_canals_h/param.CS_h);
                                Weight_h = integral(f_void, q_h_1iq, q_h_vap);                                
                        end

                        out.M_h_vec(i) = out.V_h_vec(i)/(q_h_vap-q_h_1iq)*(rho_h_liq*Weight_h+ rho_h_vap*(1-Weight_h));
                  
                    else
                        out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
                    end
                else
                    out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
                end

                if strcmp(param.type_c,'H')
                    if strcmp(out.type_zone_c{i},  'tp')
                        
                        q_c_1iq = CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
                        q_c_vap = CoolProp.PropsSI('Q','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c);
                        rho_c_liq = CoolProp.PropsSI('D','P',P_c_su,'Q',0,fluid_c);
                        rho_c_vap = CoolProp.PropsSI('D','P',P_c_su,'Q',1,fluid_c);
                        switch param.correlation_c.void_fraction
                            case 'Homogenous'
                                f_void = @(q) VoidFraction_homogenous(q, rho_c_vap,  rho_c_liq);
                                Weight_c = integral(f_void, q_c_1iq, q_c_vap);
                                
                            case 'Sivi'
                                f_void = @(q) VoidFraction_Sivi(q, rho_c_vap,  rho_c_liq);
                                Weight_c = integral(f_void, q_c_1iq, q_c_vap);
                                
                            case 'Hughmark'
                                mu_c_liq = CoolProp.PropsSI('V','P',P_c_su,'Q',0,fluid_c);
                                mu_c_vap = CoolProp.PropsSI('V','P',P_c_su,'Q',1,fluid_c);
                                f_void = @(q) VoidFraction_Hughmark(q, rho_c_vap,  rho_c_liq, mu_c_vap, mu_c_liq, param.Dh_c,  m_dot_c/param.n_canals_c/param.CS_c);
                                Weight_c = integral(f_void, q_c_1iq, q_c_vap);

                        end
                        
                        out.M_c_vec(i) = out.V_c_vec(i)/(q_c_vap-q_c_1iq)*(rho_c_liq*Weight_c+ rho_c_vap*(1-Weight_c));
                        
                    else
                        out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
                    end
                else
                    out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', out.T_c_vec(i),  out.T_c_vec(i+1), P_c_su, fluid_c);
                end
            end
               
            out.M_h = sum(out.M_h_vec);
            out.M_c = sum(out.M_c_vec);
             
            % Flag evaluation 
            if out.resA <1e-4
                out.flag = 1;
            else
                if abs(out_max.pinch) < 1e-2
                    if Q_dot_eff == Q_dot_max
                        out.flag = 2;
                    else
                        %fluid_h, P_h_su, in_h_su, m_dot_h, fluid_c, P_c_su, in_c_su, m_dot_c, param
                        out.flag = -1;
                    end
                    
                else
                    out.flag = -2;
                end
            end
            
        otherwise
            disp('Wrong type of model input')
    end
    
else
    %If no, there is not any heat power transfered
    Q_dot_eff = 0;
    out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot_eff, param);
    out.h_h_ex = out.H_h_vec(1);
    out.h_c_ex = out.H_c_vec(end);
    out.T_h_ex = out.T_h_vec(1);
    out.T_c_ex = out.T_c_vec(end);
    out.Q_dot_tot = Q_dot_eff;
    
    % Entropy calculation
    [out.s_h_vec, out.s_c_vec] = deal(NaN*ones(1, length(out.H_h_vec)));
    if param.generateTS
        if strcmp(param.type_h,'H') %if not an incompressible fluid, calculate entropy vector
            for i = 1: length(out.H_h_vec)
                out.s_h_vec(i) = CoolProp.PropsSI('S','P',P_h_su,'H',out.H_h_vec(i),fluid_h);
            end
        end
        if strcmp(param.type_c,'H') %if not an incompressible fluid, calculate entropy vector
            for i = 1: length(out.H_c_vec)
                out.s_c_vec(i) = CoolProp.PropsSI('S','P',P_c_su,'H',out.H_c_vec(i),fluid_c);
            end
        end
    end
    % Mass calculation
    out.V_h_vec = param.V_h_tot*(out.Qdot_vec./out.Q_dot_tot);
    out.V_c_vec = param.V_c_tot*(out.Qdot_vec./out.Q_dot_tot);
    for i = 1: length(out.V_h_vec)
        if strcmp(param.type_h,'H')
            out.M_h_vec(i) = out.V_h_vec(i)*(CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i),fluid_h)+CoolProp.PropsSI('D','P',P_h_su,'H',out.H_h_vec(i+1),fluid_h))/2;
        else
            out.M_h_vec(i) = out.V_h_vec(i)*sf_PropsSI_bar('D', out.T_h_vec(i),  out.T_h_vec(i+1), P_h_su, fluid_h);
        end
        if strcmp(param.type_c,'H')
            out.M_c_vec(i) = out.V_c_vec(i)*(CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i),fluid_c)+CoolProp.PropsSI('D','P',P_c_su,'H',out.H_c_vec(i+1),fluid_c))/2;
        else
            out.M_c_vec(i) = out.V_c_vec(i)*sf_PropsSI_bar('D', T_c_vec(i),  T_c_vec(i+1), P_c_su, fluid_c);
        end
    end
    out.M_h = sum(out.M_h_vec);
    out.M_c = sum(out.M_c_vec);
    
    if (T_h_su-T_c_su)<1e-2  && (T_h_su-T_c_su >0)  && m_dot_h  > 0 && m_dot_c > 0
        out.flag = 3;
    else
        out.flag = -3;
    end
end
out.flag_reverse = flag_reverse;

if flag_reverse
    out.Qdot_vec = flip(out.Qdot_vec);
    [out.H_h_vec, out.H_c_vec] = deal(flip(out.H_c_vec), flip(out.H_h_vec));
    [out.T_h_vec, out.T_c_vec] = deal(flip(out.T_c_vec), flip(out.T_h_vec));    
    out.DT_vec = flip(out.DT_vec);


    [out.h_h_ex, out.h_c_ex] = deal(out.h_c_ex, out.h_h_ex);    
    [out.T_h_ex, out.T_c_ex] = deal(out.T_c_ex, out.T_h_ex);    
    [out.s_h_vec, out.s_c_vec] = deal(flip(out.s_c_vec), flip(out.s_h_vec));
    [out.V_h_vec, out.V_c_vec] = deal(flip(out.V_c_vec), flip(out.V_h_vec));
    [out.M_h_vec, out.M_c_vec] = deal(flip(out.M_c_vec), flip(out.M_h_vec));   
    [out.M_h, out.M_c] = deal(out.M_c, out.M_h);          
    out.x_vec = (out.H_h_vec-out.H_h_vec(1))./(out.H_h_vec(end)-out.H_h_vec(1));
    if strcmp(param.modelType, 'hConvVar') && out.flag ~= 3 &&  out.flag ~= -3
        [out.hConv_h, out.hConv_c] = deal(flip(out.hConv_c), flip(out.hConv_h));
        out.DTlog = flip(out.DTlog);
        [out.eff_h, out.eff_c] = deal(flip(out.eff_c), flip(out.eff_h));
        [out.A_h, out.A_c] = deal(flip(out.A_c), flip(out.A_h));
        out.U = flip(out.U);
        [out.type_zone_h, out.type_zone_c] = deal(flip(out.type_zone_c), flip(out.type_zone_h));
    end
end

out.time = toc(tstart_hex);

%% TS DIAGRAM and DISPLAY

% Generate the output variable TS
TS.T_h = out.T_h_vec;
TS.T_c = out.T_c_vec;
TS.s_h = out.s_h_vec;
TS.s_c = out.s_c_vec;
TS.x = out.x_vec;
TS.x_geom = [0 cumsum(out.V_h_vec)./param.V_h_tot];

% If the param.displayTS flag is activated (=1), the temperature profile is
% plotted in a new figure
if param.displayTS == 1
    figure
    hold on
    plot(TS.x, TS.T_c-273.15,'s-' ,'linewidth',2)
    plot(TS.x, TS.T_h-273.15,'o-' ,'linewidth',2)
    grid on
    xlabel('Heat power fraction [-]','fontsize',14,'fontweight','bold')
    ylabel('Temperature [�C]','fontsize',14,'fontweight','bold')
    set(gca,'fontsize',14,'fontweight','bold')
end

% If the param.displayResults flag is activated (=1), the results are displayed on the
% command window
if param.displayResults ==1
    in.fluid_h = fluid_h;
    in.m_dot_h = m_dot_h;
    in.in_h_su = in_h_su;
    in.type_h = param.type_h;
    in.P_h_su = P_h_su;
    in.fluid_c = fluid_c;
    in.m_dot_c = m_dot_c;
    in.in_c_su = in_c_su;
    in.type_c = param.type_c;
    in.P_c_su = P_c_su;
    in.modelType= param.modelType;
    
    if nargin ==0
        fprintf ( 1, '\n' );
        disp('-------------------------------------------------------')
        disp('--------------------   Demo Code   --------------------')
        disp('-------------------------------------------------------')
        fprintf ( 1, '\n' );
    end
    disp('Working conditions:')
    fprintf ( 1, '\n' );
    disp(in)
    disp('Results')
    disp(out)
    
end

end


function res = HEX_CstPinch_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, pinch, Q_dot, info)
% function giving the residual committed on the pinch for a given Q_dot
out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
res = pinch - out.pinch;
end

function res = HEX_hConvCst_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info)
% function giving the residual committed on the HEX surface area for a given Q_dot
out = HEX_hConvCst(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info);
res = out.resA;
end

function out = HEX_hConvCst(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info)
out = HEX_profile(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
[out.hConv_h, out.hConv_c, out.DTlog, out.eff_h, out.eff_c, out.A_h, out.A_c, out.U] = deal(NaN*ones(1,length(out.T_h_vec)-1));
for j = 1:length(out.T_h_vec)-1
    % Hot side heat transfer coefficient
    if strcmp(info.type_h, 'H')
        if isempty(strfind(fluid_h, 'INCOMP:'))
            if (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) < CoolProp.PropsSI('H','P',P_h_su,'Q',0,fluid_h)
                out.hConv_h(j) = info.hConv_h_liq;
            elseif (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) > CoolProp.PropsSI('H','P',P_h_su,'Q',1,fluid_h)
                out.hConv_h(j) = info.hConv_h_vap;
            else
                out.hConv_h(j) = info.hConv_h_tp;
            end
        else
            out.hConv_h(j) = info.hConv_h_liq;
        end
    elseif strcmp(info.type_h, 'T')
        out.hConv_h(j) = info.hConv_h_liq;
    end
    % Cold side heat transfer coefficient
    if strcmp(info.type_c, 'H')
        if isempty(strfind(fluid_c, 'INCOMP:'))
            if (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) < CoolProp.PropsSI('H','P',P_c_su,'Q',0,fluid_c)
                out.hConv_c(j) = info.hConv_c_liq;
            elseif (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) > CoolProp.PropsSI('H','P',P_c_su,'Q',1,fluid_c)
                out.hConv_c(j) = info.hConv_c_vap;
            else
                out.hConv_c(j) = info.hConv_c_tp;
            end
            out.hConv_c(j) = info.hConv_c_liq;
        else
            out.hConv_c(j) = info.hConv_c_liq;
        end
    elseif strcmp(info.type_c, 'T')
        out.hConv_c(j) = info.hConv_c_liq;
    end
    out.DTlog(j) = deltaT_log(out.T_h_vec(j+1), out.T_h_vec(j),out.T_c_vec(j), out.T_c_vec(j+1));
    
    % Hot side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_h'))
        out.eff_h(j) = 1;
    elseif strcmp(info.fin_h, 'none')
        out.eff_h(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_h(j),info.fin_h.k, info.fin_h.th, info.fin_h.r, info.fin_h.B, info.fin_h.H);
        out.eff_h(j) = 1-info.fin_h.omega_f*(1-eta_eff);
    end
    
    % Cold side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_c'))
        out.eff_c(j) = 1;
    elseif strcmp(info.fin_c, 'none')
        out.eff_c(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_c(j), info.fin_c.k, info.fin_c.th, info.fin_c.r, info.fin_c.B, info.fin_c.H);
        out.eff_c(j) = 1-info.fin_c.omega_f*(1-eta_eff);
    end
    
    % Global heat transfer coefficient and zone surface area
    out.U(j) = (1/out.hConv_h(j)/out.eff_h(j) + 1/out.hConv_c(j)/out.eff_c(j)/(info.A_c_tot/info.A_h_tot))^-1;
    out.A_h(j) = out.Qdot_vec(j)/out.DTlog(j)/out.U(j);
    out.A_c(j) = out.A_h(j)*info.A_c_tot/info.A_h_tot;
end
out.A_h_tot = sum(out.A_h);
out.resA = 1 - out.A_h_tot/info.A_h_tot;
end

function res = HEX_hConvVar_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info)
% function giving the residual committed on the HEX surface area for a given Q_dot
out = HEX_hConvVar(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info);
res = out.resA;
end

function out = HEX_hConvVar(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info)
out = HEX_profile_3(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
[out.hConv_h, out.hConv_c, out.DTlog, out.eff_h, out.eff_c, out.A_h, out.A_c, out.U] = deal(NaN*ones(1,length(out.H_h_vec)-1));
for j = 1:length(out.T_h_vec)-1
    % Hot side heat transfer coefficient
    if strcmp(info.type_h, 'H')
        if isempty(strfind(fluid_h, 'INCOMP:'))
            if (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) < CoolProp.PropsSI('H','P',P_h_su,'Q',0,fluid_h)
                out.hConv_h(j) = info.hConv_h_liq_n*(m_dot_h/info.m_dot_h_n)^info.n_h_liq;
                out.type_zone_h{j} = 'liq';
            elseif (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) > CoolProp.PropsSI('H','P',P_h_su,'Q',1,fluid_h)
                out.hConv_h(j) = info.hConv_h_vap_n*(m_dot_h/info.m_dot_h_n)^info.n_h_vap;
                out.type_zone_h{j} = 'vap';
            else
                out.hConv_h(j) = info.hConv_h_tp_n*(m_dot_h/info.m_dot_h_n)^info.n_h_tp;
                out.type_zone_h{j} = 'tp';
            end
        else
            out.hConv_h(j) = info.hConv_h_liq_n*(m_dot_h/info.m_dot_h_n)^info.n_h_liq;
            out.type_zone_h{j} = 'liq';
        end
    elseif strcmp(info.type_h, 'T')
        out.hConv_h(j) = info.hConv_h_liq_n*(m_dot_h/info.m_dot_h_n)^info.n_h_liq;
        out.type_zone_h{j} = 'liq';
    end
    
    % Cold side heat transfer coefficient
    if strcmp(info.type_c, 'H')
        if isempty(strfind(fluid_c, 'INCOMP:'))
            if (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) < CoolProp.PropsSI('H','P',P_c_su,'Q',0,fluid_c)
                out.hConv_c(j) = info.hConv_c_liq_n*(m_dot_c/info.m_dot_c_n)^info.n_c_liq;
                out.type_zone_c{j} = 'liq';
            elseif (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) > CoolProp.PropsSI('H','P',P_c_su,'Q',1,fluid_c)
                out.hConv_c(j) = info.hConv_c_vap_n*(m_dot_c/info.m_dot_c_n)^info.n_c_vap;
                out.type_zone_c{j} = 'vap';
            else
                out.hConv_c(j) = info.hConv_c_tp_n*(m_dot_c/info.m_dot_c_n)^info.n_c_tp;
                out.type_zone_c{j} = 'tp';
            end
        else
            out.hConv_c(j) = info.hConv_c_liq_n*(m_dot_c/info.m_dot_c_n)^info.n_c_liq;
            out.type_zone_c{j} = 'liq';
        end
    elseif strcmp(info.type_c, 'T')
        out.hConv_c(j) = info.hConv_c_liq_n*(m_dot_c/info.m_dot_c_n)^info.n_c_liq;
        out.type_zone_c{j} = 'liq';
    end
    out.DTlog(j) = deltaT_log(out.T_h_vec(j+1), out.T_h_vec(j),out.T_c_vec(j), out.T_c_vec(j+1));
    
    % Hot side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_h'))
        out.eff_h(j) = 1;
    elseif strcmp(info.fin_h, 'none')
        out.eff_h(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_h(j), info.fin_h.k, info.fin_h.th, info.fin_h.r, info.fin_h.B, info.fin_h.H);
        out.eff_h(j) = 1-info.fin_h.omega_f*(1-eta_eff);
    end
    
    % Cold side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_c'))
        out.eff_c(j) = 1;
    elseif strcmp(info.fin_c, 'none')
        out.eff_c(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_c(j), info.fin_c.k, info.fin_c.th, info.fin_c.r, info.fin_c.B, info.fin_c.H);
        out.eff_c(j) = 1-info.fin_c.omega_f*(1-eta_eff);
    end
    
    % Global heat transfer coefficient and zone surface area
    out.U(j) = (1/out.hConv_h(j)/out.eff_h(j) + 1/out.hConv_c(j)/out.eff_c(j)/(info.A_c_tot/info.A_h_tot))^-1;
    out.A_h(j) = out.Qdot_vec(j)/out.DTlog(j)/out.U(j);
    out.A_c(j) = out.A_h(j)*info.A_c_tot/info.A_h_tot;
end
out.A_h_tot = sum(out.A_h);
out.resA = 1 - out.A_h_tot/info.A_h_tot;
end

function res = HEX_hConvCor_res(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info)
% function giving the residual committed on the HEX surface area for a given Q_dot
out = HEX_hConvCor(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, real(Q_dot), info);

res = out.resA;

end

function out = HEX_hConvCor(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info)

out = HEX_profile_3(fluid_h, m_dot_h, P_h_su, in_h_su, fluid_c, m_dot_c, P_c_su, in_c_su, Q_dot, info); %evaluate the temperature profile for a given heat power, cfr documentation of HEX_profile
[out.A_h, out.A_c, out.hConv_h, out.hConv_c, out.DTlog] = deal(NaN*ones(1,length(out.H_h_vec)-1));

for j = 1:length(out.T_h_vec)-1

    % LMTD for the current cell
    out.DTlog(j) = deltaT_log(out.T_h_vec(j+1), out.T_h_vec(j),out.T_c_vec(j), out.T_c_vec(j+1));
    
    % What type of cells for hot side (1phase or 2phase?)    
    if strcmp(info.type_h, 'H')
        if isempty(strfind(fluid_h, 'INCOMP:'))
            if (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) < CoolProp.PropsSI('H','P',P_h_su,'Q',0,fluid_h)
                out.type_zone_h{j} = 'liq';
            elseif (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)) > CoolProp.PropsSI('H','P',P_h_su,'Q',1,fluid_h)
                out.type_zone_h{j} = 'vap';
            else
                out.type_zone_h{j} = 'tp';
            end
        else
            out.type_zone_h{j} = 'liq';
        end
    elseif strcmp(info.type_h, 'T')
        out.type_zone_h{j} = 'liq';
    end
        
    % What type of cells for cold side (1phase or 2phase?)
    if strcmp(info.type_c, 'H')
        if isempty(strfind(fluid_c, 'INCOMP:'))
            if (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) < CoolProp.PropsSI('H','P',P_c_su,'Q',0,fluid_c)
                out.type_zone_c{j} = 'liq';
            elseif (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)) > CoolProp.PropsSI('H','P',P_c_su,'Q',1,fluid_c)
                out.type_zone_c{j} = 'vap';
            else
                out.type_zone_c{j} = 'tp';
            end
        else
            out.type_zone_c{j} = 'liq';
        end
    elseif strcmp(info.type_c, 'T')
        out.type_zone_c{j} = 'liq';
    end
    
    % Hot-side convective heat transfer coefficient
    if strcmp(out.type_zone_h{j}, 'liq') || strcmp(out.type_zone_h{j}, 'vap')
        
        switch info.correlation_h.type_1phase
            case 'Martin'
                if strcmp(info.type_h, 'H')
                    mu_h = CoolProp.PropsSI('V', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    Pr_h = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    k_h = CoolProp.PropsSI('L', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                elseif strcmp(info.type_h, 'T')
                    cp_h = sf_PropsSI_bar('C', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    k_h = sf_PropsSI_bar('L', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    mu_h = sf_PropsSI_bar('V', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    Pr_h = cp_h*mu_h/k_h;
                end
                G_h = m_dot_h/info.n_canals_h/info.CS_h;
                Re_h = G_h*info.Dh_h/mu_h;
                if Re_h < 2000
                    f_0 = 16/Re_h;
                    f_90 = 149.25/Re_h+0.9625;
                else
                    f_0 = (1.56*log(Re_h)-3)^-2;
                    f_90 = 9.75/Re_h^0.289;
                end               
                f_h = (((cos(info.theta))/sqrt(0.045*tan(info.theta) + 0.09*sin(info.theta) + f_0/cos(info.theta)))+((1-cos(info.theta))/(sqrt(3.8*f_90))))^(-0.5);
                Nu_h = info.fact_corr_sp*0.205*(Pr_h^0.33333333)*(f_h*Re_h^2*sin(2*info.theta))^0.374;
                out.hConv_h(j) = Nu_h*k_h/info.Dh_h;
                
            case 'Wanniarachchi'
                if strcmp(info.type_h, 'H')
                    mu_h = CoolProp.PropsSI('V', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    Pr_h = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    k_h = CoolProp.PropsSI('L', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                elseif strcmp(info.type_h, 'T')
                    cp_h = sf_PropsSI_bar('C', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    k_h = sf_PropsSI_bar('L', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    mu_h = sf_PropsSI_bar('V', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    Pr_h = cp_h*mu_h/k_h;
                end
                G_h = m_dot_h/info.n_canals_h/info.CS_h;
                Re_h = G_h*info.Dh_h/mu_h;
                j_Nu_h_t = 12.6*(90-info.theta*180/pi)^(-1.142)*Re_h^(0.646+0.00111*(90-info.theta*180/pi));                
                j_Nu_h_l = 3.65*(90-info.theta*180/pi)^(-0.455)*Re_h^-0.339;
                Nu_h = info.fact_corr_sp*(j_Nu_h_l^3 + j_Nu_h_t^3)^(1/3)*Pr_h^(1/3);
                out.hConv_h(j) = Nu_h*k_h/info.Dh_h;
                
            case 'Thonon'
                if strcmp(info.type_h, 'H')
                    mu_h = CoolProp.PropsSI('V', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    Pr_h = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    k_h = CoolProp.PropsSI('L', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                elseif strcmp(info.type_h, 'T')
                    cp_h = sf_PropsSI_bar('C', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    k_h = sf_PropsSI_bar('L', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    mu_h = sf_PropsSI_bar('V', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    Pr_h = cp_h*mu_h/k_h;
                end
                G_h = m_dot_h/info.n_canals_h/info.CS_h;
                Re_h = G_h*info.Dh_h/mu_h;
                if info.theta <= 15*pi/180
                    C = 0.1;
                    m = 0.687;
                elseif info.theta > 15*pi/180 && info.theta <= 30*pi/180
                    C = 0.2267;
                    m = 0.631;
                elseif  info.theta > 30*pi/180 && info.theta <= 45*pi/180
                    C = 0.2998;
                    m = 0.645;
                elseif info.theta > 45*pi/180 && info.theta <= 60*pi/180
                    C = 0.2946;
                    m = 0.7;
                end
                Nu_h = info.fact_corr_sp*C*Re_h^m*Pr_h^0.33333333;
                out.hConv_h(j) = Nu_h*k_h/info.Dh_h;
                
            case 'Gnielinski_and_Sha'
                if strcmp(info.type_h, 'H')
                    mu_h = CoolProp.PropsSI('V', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    Pr_h = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                    k_h = CoolProp.PropsSI('L', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                elseif strcmp(info.type_h, 'T')
                    cp_h = sf_PropsSI_bar('C', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    k_h = sf_PropsSI_bar('L', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    mu_h = sf_PropsSI_bar('V', out.T_h_vec(j), out.T_h_vec(j+1), P_h_su, fluid_h);
                    Pr_h = cp_h*mu_h/k_h;
                end
                G_h = m_dot_h/info.n_canals_h/info.CS_h;
                
                Re_h = G_h*info.Dh_h/mu_h;
                if Re_h > 2300
                    f_h = (1.8*log10(Re_h)-1.5)^-2; %Konakov correlation 
                    Nu_h = ((f_h/8)*(Re_h-1000)*Pr_h)/(1+12.7*sqrt(f_h/8)*(Pr_h^(2/3)-1)); % Gnielinski
                else
                    Nu_1 = 4.364;
                    Nu_2 = 1.953*(Re_h*Pr_h*info.Dh_h/info.Lt_h)^0.33333333333333333333333333333;
                    Nu_h = (Nu_1^3 + 0.6^3 + (Nu_2-0.6)^3)^0.3333333333333333333333;
                end
                out.hConv_h(j) = Nu_h*k_h/info.Dh_h;
        end
        
    elseif strcmp(out.type_zone_h{j}, 'tp') 
        
        switch info.correlation_h.type_2phase
            case 'Han_condensation'
                mu_h_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_h_su, fluid_h);
                k_h_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_h_su, fluid_h);
                x_h = CoolProp.PropsSI('Q', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                Pr_h_l = CoolProp.PropsSI('Prandtl', 'Q', 0, 'P', P_h_su, fluid_h);
                rho_h_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_h_su, fluid_h);
                rho_h_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_h_su, fluid_h);
                G_h = (m_dot_h/info.n_canals_h)/info.CS_h;
                G_h_eq = G_h * ( (1 - x_h) + x_h * (rho_h_l/rho_h_v)^0.5);
                Re_h_eq = G_h_eq*info.Dh_h/mu_h_l;                
                Ge1 = 11.22*(info.pitch_co/info.Dh_h)^-2.83*(info.theta)^(-4.5);
                Ge2 = 0.35*(info.pitch_co/info.Dh_h)^0.23*(info.theta)^(1.48);
                Nu_h = Ge1*Re_h_eq^Ge2*Pr_h_l^0.33333333;
                out.hConv_h(j) = Nu_h*k_h_l/info.Dh_h;
            
            case 'Longo_condensation'
                mu_h_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_h_su, fluid_h);
                k_h_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_h_su, fluid_h);
                Pr_h_l = CoolProp.PropsSI('Prandtl', 'Q', 0, 'P', P_h_su, fluid_h);
                x_h = CoolProp.PropsSI('Q', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                rho_h_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_h_su, fluid_h);
                rho_h_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_h_su, fluid_h);
                G_h = (m_dot_h/info.n_canals_h)/info.CS_h;
                G_h_eq = G_h * ( (1 - x_h) + x_h * (rho_h_l/rho_h_v)^0.5);
                Re_h_eq = G_h_eq*info.Dh_h/mu_h_l;
                i_fg_h = CoolProp.PropsSI('H', 'Q', 1, 'P', P_h_su, fluid_h) - CoolProp.PropsSI('H', 'Q', 0, 'P', P_h_su, fluid_h);
                g = 9.81;               
                if Re_h_eq < 1600
                    T_sat = (0.5*out.T_h_vec(j)+0.5*out.T_h_vec(j+1));
                    T_wall = (0.25*out.T_h_vec(j)+0.25*out.T_h_vec(j+1) + 0.25*out.T_c_vec(j)+0.25*out.T_c_vec(j+1));
                    out.hConv_h(j) = info.phi*0.943*((k_h_l^3*rho_h_l^2*g*i_fg_h)/(mu_h_l*(T_sat-T_wall)*info.L_hex))^0.25;
                else
                    out.hConv_h(j) = 1.875*info.phi*k_h_l/info.Dh_h*Re_h_eq^0.445*Pr_h_l^0.3333333;
                end
                
            case 'Cavallini_condensation'
                mu_h_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_h_su, fluid_h);
                mu_h_v = CoolProp.PropsSI('V', 'Q', 1, 'P', P_h_su, fluid_h);
                rho_h_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_h_su, fluid_h);
                rho_h_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_h_su, fluid_h);
                Pr_h_l = CoolProp.PropsSI('Prandtl', 'Q', 0, 'P', P_h_su, fluid_h);
                x_h = CoolProp.PropsSI('Q', 'H', (0.5*out.H_h_vec(j)+0.5*out.H_h_vec(j+1)), 'P', P_h_su, fluid_h);
                k_h_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_h_su, fluid_h);                
                d_i = info.Dh_h;
                g = 9.81;
                C_T = 2.6; %1.6 for HC or 2.6 for other refrigerant
                X_tt = ((mu_h_l/mu_h_v)^0.1)*((rho_h_v/rho_h_l)^0.5)*((1-x_h)/x_h)^0.9; %Martinelli factor
                             
                G_h = (m_dot_h/info.n_canals_h)/info.CS_h;
                Re_h_l = G_h*info.Dh_h/mu_h_l;              
                J_v = x_h*G_h/sqrt(g*d_i*rho_h_v*(rho_h_l-rho_h_v)); 
                J_v_T = (((7.5/(4.3*X_tt^1.111 + 1))^-3) + ((C_T)^-3) )^-0.333333333333333333;
                h_h_lo = 0.023*Re_h_l^0.8*Pr_h_l^0.4*k_h_l/d_i;
                h_h_a = h_h_lo*(1 + (1.128*x_h^0.817)*((rho_h_l/rho_h_v)^0.3685)*((mu_h_l/mu_h_v)^0.2363)*((1-mu_h_v/mu_h_l)^2.144)*(Pr_h_l^-0.1));                
                
                if J_v > J_v_T %delta_T-independent flow regime
                    out.hConv_h(j) = h_h_a;
                elseif J_v <= J_v_T %delta_T-dependent flow regime
                    i_fg_h = CoolProp.PropsSI('H', 'Q', 1, 'P', P_h_su, fluid_h) - CoolProp.PropsSI('H', 'Q', 0, 'P', P_h_su, fluid_h);
                    T_sat = (0.5*out.T_h_vec(j)+0.5*out.T_h_vec(j+1));
                    T_wall = (0.25*out.T_h_vec(j)+0.25*out.T_h_vec(j+1) + 0.25*out.T_c_vec(j)+0.25*out.T_c_vec(j+1));
                    h_strat = 0.725*((1+0.741*((1-x_h)/x_h)^0.3321)^-1)*(((k_h_l^3*rho_h_l*(rho_h_l-rho_h_v)*g*i_fg_h)/(mu_h_l*d_i*(T_sat-T_wall)))^0.25)+((1-x_h^0.087)*h_h_lo);
                    h_h_d = J_v/J_v_T*(h_h_a*(J_v_T/J_v)^0.8 - h_strat) + h_strat;
                    out.hConv_h(j) = h_h_d;
                end
                                            
        end
        
    end
    
    % Cold-side convective heat transfer coefficient
    if strcmp(out.type_zone_c{j}, 'liq') || strcmp(out.type_zone_c{j}, 'vap')
        
        switch info.correlation_c.type_1phase
            case 'Martin'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c;
                Re_c = G_c*info.Dh_c/mu_c;               
                if Re_c < 2000
                    f_0 = 16/Re_c;
                    f_90 = 149.25/Re_c+0.9625;
                else
                    f_0 = (1.56*log(Re_c)-3)^-2;
                    f_90 = 9.75/Re_c^0.289;
                end
                f_c = (((cos(info.theta))/sqrt(0.045*tan(info.theta) + 0.09*sin(info.theta) + f_0/cos(info.theta)))+((1-cos(info.theta))/(sqrt(3.8*f_90))))^(-0.5);
                Nu_c = info.fact_corr_sp*0.205*(Pr_c^0.33333333)*(f_c*Re_c^2*sin(2*info.theta))^0.374;
                out.hConv_c(j) = Nu_c*k_c/info.Dh_c;
                out.Re_c(j) = Re_c;
                out.Nu_c(j) = Nu_c;
                out.Pr_c(j) = Pr_c;
                out.k_c(j) = k_c;
                
                
            case 'Wanniarachchi'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c;
                Re_c = G_c*info.Dh_c/mu_c;
                j_Nu_c_t = 12.6*(90-info.theta*180/pi)^(-1.142)*Re_c^(0.646+0.00111*(90-info.theta*180/pi));
                j_Nu_c_l = 3.65*(90-info.theta*180/pi)^(-0.455)*Re_c^-0.339;
                Nu_c = info.fact_corr_sp*(j_Nu_c_l^3 + j_Nu_c_t^3)^(1/3)*Pr_c^(1/3);
                out.hConv_c(j) = Nu_c*k_c/info.Dh_c;
                out.Re_c(j) = Re_c;
                out.Nu_c(j) = Nu_c;
                out.Pr_c(j) = Pr_c;
                out.k_c(j) = k_c;
                
            case 'Thonon'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c;
                Re_c = G_c*info.Dh_c/mu_c;
                if info.theta <= 15*pi/180
                    C = 0.1;
                    m = 0.687;
                elseif info.theta > 15*pi/180 && info.theta <= 30*pi/180
                    C = 0.2267;
                    m = 0.631;
                elseif  info.theta > 30*pi/180 && info.theta <= 45*pi/180
                    C = 0.2998;
                    m = 0.645;
                elseif info.theta > 45*pi/180 && info.theta <= 60*pi/180
                    C = 0.2946;
                    m = 0.7;
                end
                Nu_c = info.fact_corr_sp*C*Re_c^m*Pr_c^0.33333333;
                out.hConv_c(j) = Nu_c*k_c/info.Dh_c;
                out.Re_c(j) = Re_c;
                out.Nu_c(j) = Nu_c;
                out.Pr_c(j) = Pr_c;
                out.k_c(j) = k_c;                
            case 'Gnielinski'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c;
                Re_c = G_c*info.Dh_c/mu_c;
                if Re > 2300
                    f_c = (1.8*log10(Re_c)-1.5)^-2; %Konakov correlation
                    Nu_c = ((f_c/8)*(Re_c-1000)*Pr_c)/(1+12.7*sqrt(f_c/8)*(Pr_c^(2/3)-1));
                else
                    Nu_c = 3.66;
                end
                out.hConv_c(j) = Nu_c*k_c/info.Dh_c;
                
            case 'VDI_finned_tubes_staggered'
                if strcmp(info.type_c, 'H')
                    mu_c = CoolProp.PropsSI('V', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    Pr_c = CoolProp.PropsSI('Prandtl', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                    k_c = CoolProp.PropsSI('L', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                elseif strcmp(info.type_c, 'T')
                    cp_c = sf_PropsSI_bar('C', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    k_c = sf_PropsSI_bar('L', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    mu_c = sf_PropsSI_bar('V', out.T_c_vec(j), out.T_c_vec(j+1), P_c_su, fluid_c);
                    Pr_c = cp_c*mu_c/k_c;
                end
                G_c = m_dot_c/info.n_canals_c/info.CS_c; % Warning, CS_c is the minimum free flow surface area and n_canals_c is taken equal to 1               
                Re_c = G_c*info.Dh_c/mu_c; % Warning, Dh_c is the externel diameter of the tubes forming the bank
                Nu_c = 0.38*Re_c^0.6*Pr_c^0.33333333*info.fin_c.omega_t^-0.15;
                out.hConv_c(j) = Nu_c*k_c/info.Dh_c;
        end
        
        
    elseif strcmp(out.type_zone_c{j}, 'tp')
        switch info.correlation_c.type_2phase
            case 'Han_boiling'
                mu_c_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_c_su, fluid_c);
                k_c_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_c_su, fluid_c);
                x_c = CoolProp.PropsSI('Q', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                Pr_c_l = CoolProp.PropsSI('Prandtl', 'Q', 0, 'P', P_c_su, fluid_c);
                rho_c_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_c_su, fluid_c);
                rho_c_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_c_su, fluid_c);
                i_fg_c = CoolProp.PropsSI('H', 'Q', 1, 'P', P_c_su, fluid_c) - CoolProp.PropsSI('H', 'Q', 0, 'P', P_c_su, fluid_c);
                G_c = (m_dot_c/info.n_canals_c)/info.CS_c;
                G_c_eq = G_c * ( (1 - x_c) + x_c * (rho_c_l/rho_c_v)^0.5);
                Re_c_eq = G_c_eq*info.Dh_c/mu_c_l;
                AU_tp = out.Qdot_vec(j)/out.DTlog(j);
                Ge1 = 2.81*(info.pitch_co/info.Dh_c)^-0.041*(info.theta)^(-2.83);
                Ge2 = 0.746*(info.pitch_co/info.Dh_c)^-0.082*(info.theta)^(0.61);
                Bo = 1;
                k = 0;
                err_Bo = 1;
                while k <= 10 && err_Bo > 5e-2 %iterate for boiling number
                    Nu = Ge1*Re_c_eq^Ge2*Bo^0.3*Pr_c_l^0.4;
                    h = Nu*k_c_l/info.Dh_c;
                    U = (1/h +  1/out.hConv_h(j))^-1;
                    A_tp = AU_tp/U;
                    q = out.Qdot_vec(j)/A_tp;
                    Bo_new = q/(G_c_eq*i_fg_c);
                    err_Bo = abs(Bo_new-Bo)/Bo;
                    Bo = Bo_new;
                end
                
                out.hConv_c(j) = h;
                
                
            case 'Almalfi_boiling'
                g = 9.81;
                rho_c_l = CoolProp.PropsSI('D', 'Q', 0, 'P', P_c_su, fluid_c);
                rho_c_v = CoolProp.PropsSI('D', 'Q', 1, 'P', P_c_su, fluid_c);
                rho_c = CoolProp.PropsSI('D', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                sigma_c = CoolProp.PropsSI('I', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                x_c = CoolProp.PropsSI('Q', 'H', (0.5*out.H_c_vec(j)+0.5*out.H_c_vec(j+1)), 'P', P_c_su, fluid_c);
                k_c_l = CoolProp.PropsSI('L', 'Q', 0, 'P', P_c_su, fluid_c);
                G_c = (m_dot_c/info.n_canals_c)/info.CS_c;
                G_c_eq = G_c * ( (1 - x_c) + x_c * (rho_c_l/rho_c_v)^0.5);
                i_fg_c = CoolProp.PropsSI('H', 'Q', 1, 'P', P_c_su, fluid_c) - CoolProp.PropsSI('H', 'Q', 0, 'P', P_c_su, fluid_c);               
                Bd = (rho_c_l-rho_c_v)*g*info.Dh_c^2/sigma_c;
                beta_star = info.theta/(70*pi/180);
                rho_star = rho_c_l/rho_c_v;
                AU_tp = out.Qdot_vec(j)/out.DTlog(j);

                if Bd < 4
                    We = (G_c^2*info.Dh_c)/(rho_c*sigma_c);
                    Bo = 1;
                    k = 0;
                    err_Bo = 1;
                    while k <= 10 && err_Bo > 5e-2 %iterate for boiling number
                        k = k+1;
                        Nu_c = info.fact_corr_2p*982*beta_star^1.101*We^0.315*Bo^0.32*rho_star^-0.224;
                        h = Nu_c*k_c_l/info.Dh_c;
                        U = (1/h +  1/out.hConv_h(j))^-1;
                        A_tp = AU_tp/U;
                        q = out.Qdot_vec(j)/A_tp;
                        Bo_new = q/(G_c_eq*i_fg_c);
                        err_Bo = abs(Bo_new-Bo)/Bo;
                        Bo = Bo_new;
                    end
                    out.hConv_c(j) = h;
                else
                    mu_c_v = CoolProp.PropsSI('V', 'Q', 1, 'P', P_c_su, fluid_c);
                    mu_c_l = CoolProp.PropsSI('V', 'Q', 0, 'P', P_c_su, fluid_c);
                    Re_c_v = G_c*x_c*info.Dh_c/mu_c_v;
                    Re_c_lo = G_c*info.Dh_c/mu_c_l;
                    Bo = 1;
                    k = 0;
                    err_Bo = 1;
                    while k <= 10 && err_Bo > 5e-2 %iterate for boiling number
                        k = k+1;       
                        Nu_c = info.fact_corr_2p*18.495*beta_star^0.248*Re_c_v^0.135*Re_c_lo^0.351*Bd^0.235*Bo^0.198*rho_star^-0.223;
                        h = Nu_c*k_c_l/info.Dh_c;
                        U = (1/h +  1/out.hConv_h(j))^-1;
                        A_tp = AU_tp/U;
                        q = out.Qdot_vec(j)/A_tp;
                        Bo_new = q/(G_c_eq*i_fg_c);
                        err_Bo = abs(Bo_new-Bo)/Bo;
                        Bo = Bo_new;
                    end
                    out.hConv_c(j) = h;
                end
                
        end  
        
    end
    
    
    % Hot side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_h'))
        out.eff_h(j) = 1;
    elseif strcmp(info.fin_h, 'none')
        out.eff_h(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_h(j), info.fin_h.k, info.fin_h.th, info.fin_h.r, info.fin_h.B, info.fin_h.H);
        out.eff_h(j) = 1-info.fin_h.omega_f*(1-eta_eff);
    end
    
    % Cold side heat transfer efficiency (in case of fins)
    if not(isfield(info, 'fin_c'))
        out.eff_c(j) = 1;
    elseif strcmp(info.fin_c, 'none')
        out.eff_c(j) = 1;
    else
        eta_eff = FinSchmidt(out.hConv_c(j), info.fin_c.k, info.fin_c.th, info.fin_c.r, info.fin_c.B, info.fin_c.H);
        out.eff_c(j) = 1-info.fin_c.omega_f*(1-eta_eff);
    end
    
    % Global heat transfer coefficient and zone surface area
    out.U(j) = (1/out.hConv_h(j)/out.eff_h(j) + 1/out.hConv_c(j)/out.eff_c(j)/(info.A_c_tot/info.A_h_tot))^-1;
    out.A_h(j) = out.Qdot_vec(j)/out.DTlog(j)/out.U(j);
    out.A_c(j) = out.A_h(j)*info.A_c_tot/info.A_h_tot;
end

out.A_h_tot = sum(out.A_h);
out.resA = 1 - out.A_h_tot/info.A_h_tot;

end

function [DT_log, DTh, DTc ]= deltaT_log(Th_su, Th_ex, Tc_su, Tc_ex)
% function that provides the mean logarithm temperature difference between two fluids
DTh = max(Th_su-Tc_ex,1e-2);
DTc = max(Th_ex-Tc_su,1e-2);
if DTh ~= DTc;
    DT_log = (DTh-DTc)/log(DTh/DTc);
else
    DT_log = DTh;
end
end

function eta_fin = FinSchmidt(hConv, k, th, r, B, H)
% functions that compute the fin efficiency based on Schmidt's theory and geometrical data of the HEX
m = sqrt(2*hConv/k/th);
phi_f = B/r;
beta_f = H/B;
R_e = r*1.27*phi_f*(beta_f-0.3)^0.5;
phi = (R_e/r - 1)*(1+0.35*log(R_e/r));
eta_fin = tanh(m*R_e*phi)/(m*R_e*phi);
end

function one_alpha = VoidFraction_Hughmark(q, rho_v, rho_l, mu_v, mu_l, D, G)
one_alpha = NaN*ones(size(q));
for i = 1:length(q)
    q1 = q(i);
    beta = 1./(1+(((1-q1)./q1).*(rho_v/rho_l)));
    alpha = beta;
    res_alpha = 1;
    k = 0;
    while res_alpha > 1e-2 && k <= 10
        k = k + 1;
        Z = (((D*G)./(mu_l+alpha.*(mu_v-mu_l))).^(1/6)).*(((1/9.81/D)*(G.*q1./(rho_v.*beta.*(1-beta))).^2).^(1/8));
        ln_Z = log(Z);
        p1 = -0.010060658854755;
        p2 = 0.155594796014726;
        p3 = -0.870912508715887;
        p4 = 2.167004115373165;
        p5 = -2.224608445535130;
        ln_Kh = p1.*ln_Z.^4 + p2.*ln_Z.^3 + p3.*ln_Z.^2 + p4.*ln_Z + p5;
        Kh = exp(ln_Kh);
        alpha_new = Kh.*beta;
        res_alpha= norm(abs(alpha-alpha_new)./alpha_new);
        alpha = alpha_new;
    end
    one_alpha(i) = 1-alpha;
end
end

function one_alpha = VoidFraction_Sivi(q, rho_v, rho_l)
S_zivi = (rho_v/rho_l)^(-1/3);
alpha = 1./(1+(((1-q)./q).*(rho_v/rho_l)*S_zivi));
one_alpha = 1-alpha;
end

function one_alpha = VoidFraction_homogenous(q, rho_v, rho_l)
alpha = 1./(1+((1-q)./q).*(rho_v/rho_l));
one_alpha = 1-alpha;
end