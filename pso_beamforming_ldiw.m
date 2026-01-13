function W_ldiw = pso_beamforming_ldiw(iter_pso, alpha, Aq, W0, PdM, minn)
% Thêm tham số đầu vào 'minn': số vòng lặp tối đa cho phép gBestCost đứng yên
M = length(W0);
V = Aq(:, alpha);
Pd = PdM(:, alpha);
amp = abs(W0);

nParticles = 30;
w_max = 0.9;
w_min = 0.4;
c1 = 2.0;
c2 = 2.0;

% Khởi tạo
phi = -pi + 2*pi*rand(M, nParticles);
vel = zeros(M, nParticles);
pBest = phi;
pBestCost = inf(1, nParticles);
gBestCost = inf;
gBest = phi(:,1);

% Biến hỗ trợ dừng sớm
cnt = 0;
old_gBestCost = inf;

for it = 1:iter_pso
    % Hệ số quán tính giảm dần theo thời gian (LDIW)
    w = w_max - (w_max - w_min) * it / iter_pso;
    
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
    
    % --- KIỂM TRA ĐIỀU KIỆN DỪNG SỚM ---
    if abs(gBestCost - old_gBestCost) < 1e-12
        cnt = cnt + 1;
    else
        cnt = 0; % Reset nếu có cải thiện dù là nhỏ nhất
    end
    
    fprintf('[LDIW-PSO] Iter %d | w=%.2f | Cost=%.3e | Repeat: %d\n', it, w, gBestCost, cnt);
    
    if cnt >= minn
        fprintf('=> Dừng sớm: gBest không đổi sau %d vòng lặp.\n', minn);
        break;
    end
    
    old_gBestCost = gBestCost;
    % ------------------------------------

    % Cập nhật vận tốc và vị trí
    for p = 1:nParticles
        vel(:,p) = w*vel(:,p) ...
            + c1*rand*(pBest(:,p)-phi(:,p)) ...
            + c2*rand*(gBest-phi(:,p));
        phi(:,p) = phi(:,p) + vel(:,p);
        
        % Giới hạn pha trong khoảng [-pi, pi]
        phi(:,p) = mod(phi(:,p)+pi, 2*pi) - pi;
    end
end

W_ldiw = amp .* exp(1j*gBest);
end