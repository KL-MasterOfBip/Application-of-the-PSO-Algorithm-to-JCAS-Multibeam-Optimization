function [gBest, gBestCost] = APSO_swarm_core(iter, alpha, Aq, amp, Pd, minn)
% Thêm đầu vào 'minn': số vòng lặp tối đa cho phép đứng yên
M = length(amp);
V = Aq(:, alpha);
nParticles = 15;
c1 = 2; c2 = 2;

phi = -pi + 2*pi*rand(M, nParticles);
vel = zeros(M, nParticles);
pBest = phi;
pBestCost = inf(1,nParticles);
gBestCost = inf;
gBest = phi(:,1);

% Biến kiểm soát hội tụ
cnt = 0;
old_gBestCost = inf;

for it = 1:iter
    % ===== 1. Adaptive Inertia Weight (APSO) =====
    phi_mean = mean(phi,2);
    D = mean(vecnorm(phi - phi_mean,2,1));
    if D > pi*sqrt(M)*0.6
        w = 0.9;
    elseif D < pi*sqrt(M)*0.2
        w = 0.4;
    else
        w = 0.6;
    end
    
    % ===== 2. Fitness Evaluation =====
    for p = 1:nParticles
        W = amp .* exp(1j*phi(:,p));
        PMp = abs(W' * V);
        cost = sum((PMp - Pd).^2, 'all');
        
        if cost < pBestCost(p)
            pBestCost(p) = cost;
            pBest(:,p) = phi(:,p);
        end
    end
    
    [minCost, idx] = min(pBestCost);
    if minCost < gBestCost
        gBestCost = minCost;
        gBest = pBest(:,idx);
    end

    % ===== 3. Kiểm tra dừng sớm tại phân đàn =====
    if abs(gBestCost - old_gBestCost) < 1e-12
        cnt = cnt + 1;
    else
        cnt = 0; % Reset nếu có cải thiện
    end
    
    if cnt >= minn
        % Nếu trong 1 giai đoạn giao tiếp (swarmIters) mà đứng yên quá lâu thì dừng
        break; 
    end
    old_gBestCost = gBestCost;

    % ===== 4. Update Velocity & Position =====
    for p = 1:nParticles
        vel(:,p) = w*vel(:,p) ...
            + c1*rand*(pBest(:,p)-phi(:,p)) ...
            + c2*rand*(gBest-phi(:,p));
        phi(:,p) = mod(phi(:,p)+vel(:,p)+pi,2*pi)-pi;
    end
end
end