%Refer to: https://blog.csdn.net/Tiger_v/article/details/80274658
%============== Kalman filtering ================
clc; 
clear;
close all;
 
% ����������У�ԭʼ���ݣ�underlying ground-truth���ǣ��������Ϊ��һ����������
% �����ߡ�
% ������������������Ϊ�Ը������������ߵĴ������Ĺ۲�����
% ���underlying ground-truth���Կ����Ǳ���˵һ������ֱ���˶����������ʱ��仯
% �ľ��롣
% ϵͳ״̬������ɢʱ���ľ�����ٶȡ�
% ��Ҫ���ƵĲ������������˶��ٶȡ�
% �������ֽ���(one possible explanation, not limited to this one)�����԰Ѿ���
% ���ٶ����Ϊ״̬������
% Ҳ����˵�����X[0]�������Ϊ���룬X[1]�������Ϊ�˶��ٶȡ��������¾���A������
% ����ͺ�ֱ�׶�����������ˡ�
% ��H��ʾ�۲����(measurement sensitivity matrix)����Ϊʵ����ֻ�ܹ۲⵽���룬��
% ��H = [1 0]. Hȡ����ģ�ͱ�������ԡ�

% ����1��P�ĳ�ʼֵ���ȷ������ʼֵ�����ս����Ӱ����Ӱ�������ٶ���
% ����2��Q�������ȷ����
% ����3��R�������ȷ����
% ����4��A����״̬Ǩ�ƣ����Ҳ��Ӧ��ȡ����ϵͳģ�ͱ���
%        ���Ҳ��һ��ٶ�Ϊ��̬����ģ��пɱ�������

%=============== generate data ====================
v_true    = 2;
true_dist = (0 : v_true : 200); % True travelling distance.
noise = randn(1, length(true_dist));
sigma = 0.316; 
meas_dist = true_dist + noise*sigma;

%=============== Least Square Method for average velocity estimation=======
%   y = H * v
%       y(1) = 1 * v
%       y(2) = 2 * v
%       y(3) = 3 * v
%       ... ==> H = [1 2 3 4 ...]'
%   y: meas_dist, measured data
%   v: velocity to be estimated
y     = meas_dist';
H_ls  = (1:1:length(meas_dist))'; 
G_ls  = H_ls' * H_ls;
G_inv = inv(G_ls);
v_ls  = G_inv * (H_ls' * y);
fprintf(1, 'The estimated velocity from least-sqaure method = %g, ground-truth = %g\n', v_ls, v_true);

%=============== Velocity estimation based on IIR filtering=======
iir_alpha = 0.9;
v_instantaneous = meas_dist(2:end)-meas_dist(1:length(meas_dist)-1);
v_iir = zeros(1, length(v_instantaneous)); 
v_iir(1) = v_instantaneous(1);

for k = 2:length(v_instantaneous)
    v_iir(k) = iir_alpha * v_iir(k-1) + (1-iir_alpha) * v_instantaneous(k);
end

figure;
plot(v_iir); title('Velocity estimation based on IIR filtering');grid on;

%=============== Kalman filtering ===========================
% ��ز���
X = [0; 0];         % k-1 ʱ�̵�ϵͳ״̬, inclcuding distance and velocity
Q = [0.0001 0; 0 0.0001];     % ϵͳ���̵�Э����--the covariance of the underlying and unknown process noise.
%P = [1 0; 0 1];     % k-1 ʱ�̵�ϵͳ״̬��Ӧ��Э�������--what is the physical interpretation for P?
P = Q;              % Initialize P to Q. Is it reasonable? To be confirmed.
A = [1 1; 0 1];     % ϵͳ��������--state transition matrix
H = [1 0];          % ����ϵͳ�Ĳ���
R = sigma^2;        % �������̵�Э����--the covariance of the underlying and unknown measurement process noise.
                    % 
X_buf = zeros(2, length(meas_dist));
X_buf(:,1) = X;

for i = 2:length(true_dist)
    X_k = A*X;      % k ʱ�̵�ϵͳ״̬, in this example, no external input is assumed, hence the next state depends only on the previous state. 
    P_k = A*P*A' + Q;                 % k ʱ�̵�ϵͳ״̬��Ӧ��Э�������
    Kg  = P_k*H' / (H*P_k*H' + R);    % ����������(Kalman Gain)
    X   = X_k + Kg*(meas_dist(i) - H*X_k);  % kʱ�̵�ϵͳ״̬�����Ż�����ֵ
    P   = (eye(2) - Kg*H) * P_k;      % ����kʱ�̵�ϵͳ״̬��Ӧ��Э�������

    X_buf(:,i) = X;    

end

% �����ʾ�ٶ�
figure;
scatter([2:1:length(true_dist)], meas_dist(2:end)-meas_dist(1:length(meas_dist)-1), 20, 's', 'filled', 'red');  grid on;
hold on;
plot([1:1:length(true_dist)], X_buf(2,:)); 
plot(v_iir);
title('Measured instantaneous velocity vs Estimated velocity by Kalman Filter');
legend('Instantaneous velocity by Naive calculation', 'Estimation by Kalman Filter','Estimation by IIR');

figure; 
subplot(2,1,1); hold on; grid on;
plot(meas_dist); scatter([1:1:length(true_dist)], X_buf(1,:), 5); title('Measured distance vs Estimated distance');
subplot(2,1,2); plot(X_buf(1,:)-meas_dist);title('Difference between Measured distance vs Estimated distance');grid on;

