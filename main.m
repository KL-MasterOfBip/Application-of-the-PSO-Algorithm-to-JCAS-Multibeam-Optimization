close all;
clear;
clc;

theta = (-90:0.1:90-0.1)*pi/180;
lambda = 1;
M = 12;

A = generateSteeringVector(theta, M, lambda);
desDirs_c = 0.0;
W_ref = zeros(M, size(desDirs_c, 2));

Q = 160;
phi = 1;
eqDir = -1:phi/Q:1-phi/Q;
Aq = generateQuantizedArrResponse(M, eqDir);

[PdM, P_refGen, W0] = generateDesPattern(eqDir, sin(desDirs_c), Aq);
P_init = ones(size(eqDir));
PM = P_init;

alpha = sort([find(ismember(eqDir, eqDir(1:4:end))), find(PdM)]);

% Phần cần tập trung nhất
% Thuật toán ILS được dùng trong bài toán gốc
%W_ref(:, 1) = twoStepILS(1000, alpha, Aq, W0, PM, PdM);

% Số lần lặp của giá trị tốt nhất không đổi sau nhiều lần thử
minn = 300
% Thuật toán PSO gốc
%W_ref(:, 1) = pso_beamforming_origin(1000, Aq, alpha, W0, PdM, minn); 

% Biến thế của PSO: LDIW-PSO
%W_ref(:, 1) = pso_beamforming_ldiw(1000, alpha, Aq, W0, PdM, minn); 

% Biến thể của PSO: APSO
%W_ref(:, 1) = pso_beamforming_apso(1000, alpha, Aq, W0, PdM, minn);

% Biến thể của PSO: CF-PSO
%W_ref(:, 1) = pso_beamforming_cfpso(1000, alpha, Aq, W0, PdM, minn);

% Biến thể của PSO: Multi-swarm
%W_ref(:, 1) = MultiSwarm_PSO(1000, 10, alpha, Aq, W0, PdM, minn);

% -------------------------------------
% Sử dụng bằng cách ta thêm "%" hoặc xóa để thay đổi hàm ta muốn (Xóa chú
% thích hoặc thêm)

plot(eqDir, zeros(size(eqDir)));
hold on
plot(eqDir, 10*log10(PdM/max(PdM)), 'm-*')
hold on
plot(eqDir, 10*log10(P_refGen/max(P_refGen)), '--black')
hold on
plot(eqDir, 10*log10(abs(W_ref'*Aq)/max(abs(W_ref'*Aq))), 'r')
legend('Initial', 'Desired', 'Conventional 12-element ULA', 'Optimized', ...
    'Location', 'northoutside', 'NumColumns', 4)
xlabel("Equivalent directions")
ylabel("|A|, dB")
xlim([-1 1])
ylim([-35, 1])

spacing = 0.2;
deltas = -0.8:spacing:0.8;
W_dd = zeros(M, size(deltas, 2));

for i=1:size(deltas, 2)
    W_dd(:, i) = displacePattern(W_ref, deltas(i), M);
end

figure;
hold on
for i = 1:size(deltas, 2)
    plot(eqDir, 10*log10(abs(W_dd(:, i)'*Aq)/max(abs(W_dd(:, i)'*Aq))))    
end
xlim([-1 1])
ylim([-35, 0])
xlabel("Equivalent directions")
ylabel("|A|, dB")
grid on

ro = 0.5; 

W_dd = W_dd./vecnorm(W_dd, 2, 2);
W_t = zeros(M, size(deltas, 2)-1);
comBeamIdx = cast(size(deltas, 2)/2, 'uint32');

j = 1;
for i = 1:size(W_dd, 2)
    if i ~= comBeamIdx
        W_t(:, j) = sqrt(ro)*W_dd(:, comBeamIdx) + sqrt(1-ro)*W_dd(:, i);
        j = j + 1;
    end
end

plot(eqDir, 10*log10(abs(W_t(:, 1)'*Aq)/max(abs(W_t(:, 1)'*Aq))))
xlabel("\theta, rad")
ylabel("|A(\theta)|, dB")
xlim([-1 1])
grid on

figure;
hold on;
for i = 1:size(W_t, 2)
    plot(theta, 10*log10(abs(W_t(:, i)'*A)/max(abs(W_t(:, i)'*A))));
end
xlabel("\theta, rad")
ylabel("|A(\theta)|, dB")
grid on
xlim([-pi/2, pi/2])
ylim([-15, 0])
