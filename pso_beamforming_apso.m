function W_apso = pso_beamforming_apso(iter_pso, alpha, Aq, W0, PdM, minn)
% Thêm tham số đầu vào 'minn': số vòng lặp tối đa cho phép gBestCost đứng yên
M = length(W0);
V = Aq(:, alpha);
Pd = PdM(:, alpha);
amp = abs(W0);

nParticles = 30;
c1 = 2.0;
c2 = 2.0;

% Khởi tạo
phi = -pi + 2*pi*rand(M, nParticles);
vel = zeros(M, nParticles);
pBest = phi;
pBestCost = inf(1, nParticles);
gBestCost = inf;
gBest = phi(:,1);

% Ngưỡng đa dạng để điều chỉnh w
D_high = pi * sqrt(M) * 0.6;
D_low  = pi * sqrt(M) * 0.2;

% Biến hỗ trợ dừng sớm
cnt = 0;
old_gBestCost = inf;

for it = 1:iter_pso
    % ===== 1. Tính toán độ đa dạng bầy đàn (Swarm Diversity) =====
    phi_mean = mean(phi, 2);
    D = mean(vecnorm(phi - phi_mean, 2, 1));
    
    % ===== 2. Hệ số quán tính thích nghi (Adaptive Weight) =====
    if D > D_high
        w = 0.9;    % Bầy đàn đang phân tán -> Tăng khám phá (Exploration)
    elseif D < D_low
        w = 0.4;    % Bầy đàn đang co cụm -> Tập trung khai thác (Exploration)
    else
        w = 0.6;    % Trạng thái chuyển đổi
    end
    
    % ===== 3. Đánh giá Fitness =====
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
    
    % ===== 4. KIỂM TRA ĐIỀU KIỆN DỪNG SỚM =====
    if abs(gBestCost - old_gBestCost) < 1e-12
        cnt = cnt + 1;
    else
        cnt = 0; % Reset bộ đếm nếu có cải thiện
    end
    
    fprintf('[APSO] Iter %d | D=%.2f | w=%.2f | Cost=%.3e | Repeat: %d\n', ...
        it, D, w, gBestCost, cnt);
    
    if cnt >= minn
        fprintf('=> Dừng sớm: gBest không cải thiện sau %d vòng lặp.\n', minn);
        break;
    end
    
    old_gBestCost = gBestCost;

    % ===== 5. Cập nhật vận tốc & vị trí =====
    for p = 1:nParticles
        vel(:,p) = w*vel(:,p) ...
            + c1*rand*(pBest(:,p)-phi(:,p)) ...
            + c2*rand*(gBest-phi(:,p));
        phi(:,p) = phi(:,p) + vel(:,p);
        
        % Giữ pha trong khoảng [-pi, pi]
        phi(:,p) = mod(phi(:,p)+pi, 2*pi) - pi;
    end
end

W_apso = amp .* exp(1j*gBest);
end