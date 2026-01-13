function W_ms = MultiSwarm_PSO(iter_pso, nSwarm, alpha, Aq, W0, PdM, minn)
M = length(W0);
amp = abs(W0);
Pd = PdM(:, alpha);

% Chia tổng số vòng lặp cho các giai đoạn giao tiếp
T_comm = 5; 
swarmIters = floor(iter_pso / T_comm);

gBestAll = cell(nSwarm,1);
gCostAll = inf(nSwarm,1);
old_globalBestCost = inf;
global_cnt = 0;

fprintf('[Multi-Swarm] Khoi chay % d phan dan song song...\n', nSwarm);

for t = 1:T_comm
    % 1. TOI UU HOA SONG SONG (Parallel Processing)
    parfor s = 1:nSwarm   
        [gBestAll{s}, gCostAll(s)] = APSO_swarm_core( ...
            swarmIters, alpha, Aq, amp, Pd, minn);
    end
    
    % 2. GIAO TIEP GIUA CAC DAN (Communication Phase)
    [currentBestCost, bestIdx] = min(gCostAll);
    globalBest = gBestAll{bestIdx};
    
    % Kiem tra dung som toan cuc
    if abs(currentBestCost - old_globalBestCost) < 1e-12
        global_cnt = global_cnt + 1;
    else
        global_cnt = 0;
    end
    
    fprintf('[Multi-Swarm] Giai doan %d | Best Cost = %.4e | Global Repeat: %d\n', t, currentBestCost, global_cnt);
    
    if global_cnt >= 2 % Neu qua 2 lan giao tiep ma khong cai thien thi dung
        fprintf('=> Dung som toan cuc: Ket qua da toi uu.\n');
        break; 
    end
    
    % 3. TIEM CHUNG (Injection): Lay ke tot nhat day vao cac dan khac
    for s = 1:nSwarm
        gBestAll{s} = globalBest;   
    end
    old_globalBestCost = currentBestCost;
end

[~, finalIdx] = min(gCostAll);
W_ms = amp .* exp(1j * gBestAll{finalIdx});
end