function W_pso = pso_beamforming_origin(iter_pso, V_pattern, alpha, W0, PdM, minn)
% Thêm tham số đầu vào 'minn': số lần tối đa gBestCost lặp lại trước khi dừng
N = length(W0);
nParticles = 30;
w  = 0.7;
c1 = 1.5;
c2 = 1.5;

V = V_pattern(:, alpha);
Pd = PdM(:, alpha);
amp = abs(W0);

% Khởi tạo
phi = -pi + 2*pi*rand(N, nParticles);
vel = zeros(N, nParticles);
pBest = phi;
pBestCost = inf(1, nParticles);
gBestCost = inf;
gBest = phi(:,1);

% Các biến phục vụ việc dừng sớm
cnt = 0;             % Biến đếm số lần lặp lại
old_gBestCost = inf; % Lưu giá trị gBest của vòng lặp trước

for it = 1:iter_pso
    for p = 1:nParticles
        W = amp .* exp(1j*phi(:,p));
        PM = abs(W' * V);
        
        % Tính hàm Fitness (MSE)
        cost = sum((PM - Pd).^2, 'all');
        
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
    % So sánh gBestCost hiện tại với vòng lặp trước
    if abs(gBestCost - old_gBestCost) < 1e-12 % Sử dụng sai số nhỏ thay vì so sánh tuyệt đối ==
        cnt = cnt + 1;
    else
        cnt = 0; % Reset bộ đếm nếu giá trị vẫn đang cải thiện
    end
    
    fprintf('[PSO] Iter %d | Best cost = %.4e | Repeat: %d\n', it, gBestCost, cnt);
    
    if cnt >= minn
        fprintf('=> Dừng sớm tại vòng lặp %d do giá trị tốt nhất không đổi sau %d lần.\n', it, minn);
        break;
    end
    
    old_gBestCost = gBestCost; % Cập nhật lại giá trị cũ cho vòng lặp sau
    % ------------------------------------

    % Cập nhật vận tốc và vị trí
    for p = 1:nParticles
        vel(:,p) = w*vel(:,p) ...
            + c1*rand*(pBest(:,p)-phi(:,p)) ...
            + c2*rand*(gBest-phi(:,p));
        phi(:,p) = phi(:,p) + vel(:,p);
        
        % Giữ pha trong khoảng [-pi, pi]
        phi(:,p) = mod(phi(:,p)+pi, 2*pi) - pi;
    end
end

W_pso = amp .* exp(1j*gBest);
end