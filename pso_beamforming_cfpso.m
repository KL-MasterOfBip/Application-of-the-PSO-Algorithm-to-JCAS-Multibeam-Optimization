function W_cf = pso_beamforming_cfpso(iter_pso, alpha, Aq, W0, PdM, minn)
% Thêm tham số đầu vào 'minn' để dừng sớm

M = length(W0);
V = Aq(:, alpha);
Pd = PdM(:, alpha);
amp = abs(W0);

nParticles = 30;

% Clerc–Kennedy parameters (Hệ số thu hẹp)
c1 = 2.05;
c2 = 2.05;
phi_sum = c1 + c2;
chi = 2 / abs(2 - phi_sum - sqrt(phi_sum^2 - 4*phi_sum));

phi_p = -pi + 2*pi*rand(M, nParticles);   % particle position (phase)
vel = zeros(M, nParticles);

pBest = phi_p;
pBestCost = inf(1, nParticles);
gBestCost = inf;
gBest = phi_p(:,1);

% Biến hỗ trợ dừng sớm
cnt = 0;
old_gBestCost = inf;

for it = 1:iter_pso
    % ===== 1. Fitness evaluation =====
    for p = 1:nParticles
        W = amp .* exp(1j * phi_p(:,p));
        PMp = abs(W' * V);
        cost = sum((PMp - Pd).^2, 'all');

        if cost < pBestCost(p)
            pBestCost(p) = cost;
            pBest(:,p) = phi_p(:,p);
        end
    end

    [minCost, idx] = min(pBestCost);
    if minCost < gBestCost
        gBestCost = minCost;
        gBest = pBest(:,idx);
    end

    % ===== 2. KIỂM TRA ĐIỀU KIỆN DỪNG SỚM =====
    if abs(gBestCost - old_gBestCost) < 1e-12
        cnt = cnt + 1;
    else
        cnt = 0;
    end

    fprintf('[CF-PSO] Iter %d | Cost = %.3e | Repeat: %d\n', it, gBestCost, cnt);

    if cnt >= minn
        fprintf('=> Dừng sớm: Hệ số thu hẹp đã giúp hội tụ tĩnh sau %d vòng.\n', minn);
        break;
    end
    
    old_gBestCost = gBestCost;

    % ===== 3. Velocity & position update (CF-PSO) =====
    for p = 1:nParticles
        % Chi nhân với toàn bộ cụm vận tốc để đảm bảo tính ổn định hệ thống
        vel(:,p) = chi * ( ...
            vel(:,p) ...
            + c1*rand*(pBest(:,p) - phi_p(:,p)) ...
            + c2*rand*(gBest - phi_p(:,p)) );

        phi_p(:,p) = phi_p(:,p) + vel(:,p);
        phi_p(:,p) = mod(phi_p(:,p) + pi, 2*pi) - pi;
    end
end

W_cf = amp .* exp(1j * gBest);
end