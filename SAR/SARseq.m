function SAR_seq = SARseq(p,X,omega,year)
%% Seasonal autoregressive model simulation
    % input:
    %   p is the order of SAR model
    %   X is the original sequence
    %   omega is the total season count
    %   length is the required sequence length
    % output:
    %   SAR_seq is the simulated sequence
    %---------------------------------
    % author: Yujia Cheng @ Ocean University of China, Master of OE
    % complete: May 13th, 2016  

%% assumed initial value
t = 1;
tau = p;
x = zeros(year,omega);
z = zeros(year,omega);
z = z(:);
rho = paraEst(X);

%% iterative generation of sequence
while t ~= year
    while tau <= omega
        xi = normalDSS();
        [phi,sigma_eps] = autoCorrFun(p,tau+(t-1)*omega,rho);
        epsilon = sqrt(sigma_eps) * xi;
        if t == 1 && tau == p
            z_zero = [0,z(1:p-1)];
            z_new = z_zero * flipud(phi) + epsilon;
        else
            z = z((t-1)*omega+tau-p+1:(t-1)*omega+tau);
            z_new = z * flipud(phi) + epsilon;
        end
        x_new = mean(X(:,tau)) + sqrt(var(X(:,tau)))*z_new;
        z(t,tau) = z_new;
        x(t,tau) = x_new;
        tau = tau + 1;
    end
    tau = 1;
    t = t + 1;
end
        
