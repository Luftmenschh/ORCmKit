function alpha = VoidFraction_Hughmark(q, rho_v, rho_l, mu_v, mu_l, D, G)
alpha = NaN*ones(size(q));

for i = 1:length(q)
    
    q1 = max(0.001, min(0.99,q(i)));
    beta = VoidFraction_homogenous(q1, rho_v, rho_l);
    f = @(x) residualVoidFraction_Hughmark(x,q1, beta, rho_v, mu_v, mu_l, D, G);
    alpha(i) = zeroBrent (0, 1, 1e-8, 1e-8, f );
    res_alpha = f(alpha(i));
    if abs(res_alpha) > 5e-2
        alpha(i) = 1;
        display(['Error in Hughmark void fraction model, residual : ' num2str(res_alpha)])
        disp(['q1 = ' num2str(q1)]);
        disp(['beta = ' num2str(beta)]);
        disp(['rho_v = ' num2str(rho_v)]);
        disp(['mu_v = ' num2str(mu_v)]);
        disp(['mu_l = ' num2str(mu_l)]);
        disp(['D = ' num2str(D)]);
        disp(['G = ' num2str(G)]);
    end
end
end

function res = residualVoidFraction_Hughmark(x,q1, beta, rho_v, mu_v, mu_l, D, G)
Z = (((D*G)/(mu_l+x*(mu_v-mu_l)))^(1/6))*(((1/9.81/D)*(G*q1/(rho_v*beta*(1-beta)))^2)^(1/8));
ln_Z = log(Z);
p1 = -0.010060658854755;
p2 = 0.155594796014726;
p3 = -0.870912508715887;
p4 = 2.167004115373165;
p5 = -2.224608445535130;
ln_Kh = p1*ln_Z^4 + p2*ln_Z^3 + p3*ln_Z^2 + p4*ln_Z + p5;
Kh = exp(ln_Kh);
alpha_new = Kh*beta;
res= (x-alpha_new);
end

