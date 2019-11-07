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
orginal_data = (1:2:200);
noise = randn(1, 100);
sigma = 0.316; 
meas_data = orginal_data + noise*sigma;

%=============== Least Square Method for average velocity estimation=======
%   y = H * x + b0
%   y: meas_data, measured data
%   x: velocity to be estimated
%   b0:the initial distance at time 0
y = meas_data';
H_ls = (1:1:length(meas_data))'; 
G_ls = H_ls' * H_ls;
G_inv = inv(G_ls);
x = G_inv * (H_ls' * y);
fprintf(1, 'The estimated velocity from least-sqaure method = %g\n', x);

%=============== Velocity estimation based on IIR filtering=======
iir_alpha = 0.9;
v_instantaneous = meas_data(2:end)-meas_data(1:length(meas_data)-1);
v_esti = zeros(1, length(v_instantaneous)); 
v_esti(1) = v_instantaneous(1);

for k = 2:length(v_instantaneous)
    v_esti(k) = iir_alpha * v_esti(k-1) + (1-iir_alpha) * v_instantaneous(k);
end

figure;
plot(v_esti); title('Velocity estimation based on IIR filtering');grid on;


%=============== Kalman filtering ===========================
% ��ز���
X = [0; 0];         % k-1 ʱ�̵�ϵͳ״̬. 
P = [1 0; 0 1];     % k-1 ʱ�̵�ϵͳ״̬��Ӧ��Э�������--what is the physical interpretation for P?
A = [1 1; 0 1];     % ϵͳ��������--state transition matrix
Q = [0.0001 0; 0 0.0001];     % ϵͳ���̵�Э����--the covariance of the underlying and unknown process noise.
H = [1 0];          % ����ϵͳ�Ĳ���
R = sigma^2;        % �������̵�Э����--the covariance of the underlying and unknown measurement process noise.
                    % 

X_buf = zeros(2, length(meas_data));
X_buf(:,1) = X;

figure;
hold on;
for i = 2:100    
    X_k = A*X;       % k ʱ�̵�ϵͳ״̬, in this example, no external input is assumed, hence the next state depends only on the previous state. 
    P_k = A*P*A' + Q;                 % k ʱ�̵�ϵͳ״̬��Ӧ��Э�������
    Kg  = P_k*H' / (H*P_k*H' + R);    % ����������(Kalman Gain)
    X   = X_k + Kg*(meas_data(i) - H*X_k);  % kʱ�̵�ϵͳ״̬�����Ż�����ֵ
    P   = (eye(2) - Kg*H) * P_k;      % ����kʱ�̵�ϵͳ״̬��Ӧ��Э�������

    X_buf(:,i) = X;    

end

% �����ʾ�ٶ�
scatter([2:1:100], meas_data(2:end)-meas_data(1:length(meas_data)-1), 20, 's', 'filled', 'red');  grid on;
scatter([1:1:100], X_buf(2,:), 5); title('Measured instantaneous velocity vs Estimated velocity');grid on;
plot(v_esti); title('Velocity estimation based on IIR filtering');

figure; 
subplot(2,1,1); hold on; grid on;
plot(meas_data); scatter([1:1:100], X_buf(1,:), 5); title('Measured distance vs Estimated distance');
subplot(2,1,2); plot(X_buf(1,:)-meas_data);title('Difference between Measured distance vs Estimated distance');grid on;

