function [SAR_seq,normSAR] = SARlgnseq(p,X,omega,year)
%% SAR lognormal distribution sequence simulation
    % input:
    %   p is the order of SAR model
    %   X is the original lognormal distribution sequence
    %   omega is the total season count
    %   length is the required sequence length
    % output:
    %   SAR_seq is the simulated sequence
    %---------------------------------
    % author: Yujia Cheng @ Ocean University of China, Master of OE
    % complete: May 16th, 2016  

%% assumed initial value
t = 1;
tau = p;
x = zeros(year,omega);
y = zeros(year,omega);
z = zeros(year,omega);
z = z(:);
rho = paraEst(X);

%% iterative generation of normal sequence
while t <= year
    while tau <= omega
        xi = normalDSS();
        if tau < p
            [phi,sigma_eps] = autoCorrFun(p,tau-p+omega,rho);
        else
            [phi,sigma_eps] = autoCorrFun(p,tau,rho);
        end
        epsilon = sqrt(sigma_eps) * xi;
        if t == 1 && tau == p
            z_zero = [0,z(1:p-1)'];
            z_new = z_zero * flipud(phi) + epsilon;
        else
            z_nonzero = z((t-1)*omega+tau-p+1:(t-1)*omega+tau);
            z_new = z_nonzero' * flipud(phi) + epsilon;
        end
        y_new = mean(X(:,tau)) + sqrt(var(X(:,tau)))*z_new;
        z((t-1)*omega+tau) = z_new;
        y(t,tau) = y_new;
        tau = tau + 1;
    end
    tau = 1;
    t = t + 1;
end

%% transformated from normal to lognormal
Cs_x = zeros(1,omega);
for i = 1:omega
    Cs_x(i) = skewness(X(:,i));
end
eta = arrayfun(@(x)((sqrt(x^2+4)+x)/2)^(1/3)-...
    ((sqrt(x^2+4)-x)/2)^(1/3),Cs_x);
a = mean(X)-var(X)./eta;
for j = 1:omega
    x(:,j) = a(j)+exp(y(:,j));
end

%% return sequence
SAR_seq = x;
normSAR = y;
