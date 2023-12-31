mex_all;
clc;
clear;
%% Load Dataset
%load 'a9a.mat';
load 'diabetes.mat'
%% Multi runs
%TestT2 = zeros(31,100);TimeT2 = zeros(100,1);
%TestT3 = zeros(31,100);TimeT3 = zeros(100,1);
%TestDpGD = zeros(31,100);TimeDpGD = zeros(100,1);
%TestCSGD = zeros(31,100);TimeCSGD = zeros(100,1);
%for i = 1:30   
%load 'a9a.mat';
%% Add Bias
[N, Dim] = size(X);
%N=28000;
N = 500;
%XX = X(1:28000,:);
XX = X(1:500,:);
XX = full(X');
X = full(X');
%% Set Params
passes = 30; % passes of datasets
model = 'logistic'; % choose model: logistic / least_square
%model = 'least_square';
regularizer = 'L2'; 
init_weight = zeros(Dim, 1);
mu = 0; % L2-regularization parameter
if strcmp(model, 'logistic')
    L =max(sum(XX.^2, 1)) + mu; % Lipschitz constant for Logistic regression
elseif strcmp(model, 'least_square')
    L =max(sum(XX.^2, 1)) + mu; 
end
%% Run Algorithms
%% DP_GD
algorithm = 'DP_GD';
loop = 30; 
step_size_gd = 8 / (24 * L*log(4/0.01));
fprintf('Algorithm: %s\n', algorithm);
time_1 = 0;
hist = 0;
for i=1:300
    tic;
    [time1, hist1, tidu1] = Interface(X, y, algorithm, model, regularizer, init_weight, mu, L...
        , step_size_gd, loop); 
    time_temp = toc;
    time_1 = time_1 + time_temp;
    hist = hist + hist1;
end
time = time_1 / 300;
hist1 = hist / 300;
hist1 = 1/hist1(1,1)*hist1; hist11 = hist1(1,1);
%TestDpGD(:,i) = hist1;
%TimeDpGD(i,1) = time;
%fprintf('Time: %f seconds \n', time);
fprintf('Time: %f seconds, loss: %f \n', [time, hist1(end)]);
X_SGD= (0:1:size(hist1,1)-1)';
hist1 = [X_SGD, hist1];
%% Clipped_dpSGD for Theorem 3.5 (T3)
loop = 625;  %iteration: passes *N/batchsize 
algorithm = 'Clipped_dpSGD';
epsilon = 1.0;
sigma =1; % 
step_size_T3 = 10 / (24 * L*log(4*loop/0.01));
batchsize = 24; 
clip = 1/300*sqrt(162*loop^2*sigma^2/(log(4*loop/0.01)^2*batchsize));        %4*L*R0+2*genD;
var = 0.5*clip*batchsize*sqrt(loop*log(N))/(N*epsilon);
var = var^2;
fprintf('Algorithm: T3\n');
init_weight = zeros(Dim, 1);
time_1 = 0;
hist = 0;
for i=1:300
    tic;
    [time2, hist2,tidu2] = Interface(X, y, algorithm, model, regularizer, init_weight, mu, L...
        , step_size_T3, loop,var,batchsize,clip);
    time_temp = toc;
    time_1 = time_1 + time_temp;
    hist = hist + hist2;
end
time = time_1 / 300;
hist2 = hist / 300;
BBB = hist2;
hist2 = 1/hist2(1,1)*hist2; hist22 = hist2(1,1);
%TestT3(:,i) = hist2;
%TimeT3(i,1) = time;
%fprintf('Time: %f seconds \n', time);
fprintf('Time: %f seconds, loss: %f \n', [time, hist2(end)]);
X_SGD1= (0:1:size(hist2,1)-1)';
hist2 = [X_SGD1, hist2];

%% Clipped_dpSGD for Theorem 3.3 (T2);
loop = 625;  %iteration: passes *N/batchsize 
algorithm = 'Clipped_dpSGD';
epsilon = 1.0;
sigma =1;
step_size_T2 = 10/12 *1 / (2 * L*log(4/0.01));           
batchsize1 = 24; 
clip1 = 1/18*(1/64.8)*sqrt(162*loop^2*sigma^2/(log(4/0.01)^2*batchsize1));   %2*L*R0;
var2 = 0.7*clip1*batchsize1*sqrt(loop*log(N))/(N*epsilon);
var2 = var2^2;
fprintf('Algorithm: T2\n');
time_1 = 0;
hist = 0;
for i=1:300
    tic;
    [time3, hist3,tidu3] = Interface(X, y, algorithm, model, regularizer, init_weight, mu, L...
        , step_size_T2, loop,var2,batchsize1,clip1);
    time_temp = toc;
    time_1 = time_1 + time_temp;
    hist = hist + hist3;
end
time = time_1 / 300;
hist3 = hist / 300;    
BBBB = hist3 ;
hist3 = 1/hist3(1,1)*hist3; hist33 = hist3(1,1);
%TestT2(:,i) = hist3;
%TimeT2(i,1) = time;
fprintf('Time: %f seconds, loss: %f \n', [time, hist3(end)]);
X_SGD2= (0:1:size(hist3,1)-1)';
hist3 = [X_SGD2, hist3];
%end

%% dpSGD;
loop = 625;  %iteration: passes *N/batchsize 
algorithm = 'dpSGD';
epsilon = 1.0;
sigma =1;
step_size_dpsgd = sqrt(loop)^(-5/3) * 0.01^(0.5)*20 /1.5;         % 1/12 *1 / (2 * L*log(4/0.01));           
batchsize1 = 24; 
%clip1 = 1/18*(1/64.8)*sqrt(162*loop^2*sigma^2/(log(4/0.01)^2*batchsize1));   %2*L*R0;
clip1_dpsgd = sigma*(1/sqrt(loop)^(2/3))* 0.01^(-0.5) * 2/5;
var1 = 0.5*clip1_dpsgd*24*sqrt(loop*log(N))/(N*epsilon)*sqrt(1.95)*2/3;
var1 = var1^2;
fprintf('Algorithm: dpSGD\n');
time_1 = 0;
hist = 0;
for i=1:300
    tic;
    [time5, hist5,tidu5] = Interface(X, y, algorithm, model, regularizer, init_weight, mu, L...
        , step_size_dpsgd, loop,var1,batchsize1,clip1_dpsgd);
    time_temp = toc;
    time_1 = time_1 + time_temp;
    hist = hist + hist5;
end
time = time_1 / 300;
hist5 = hist / 300;   
BBBB5 = hist5 ;
hist5 = 1/hist5(1,1)*hist5; hist55 = hist5(1,1);
%TestT2(:,i) = hist3;
%TimeT2(i,1) = time;
%fprintf('Time: %f seconds \n', time);
fprintf('Time: %f seconds, loss: %f \n', [time, hist5(end)]);
X_SGD4= (0:1:size(hist5,1)-1)';
hist5 = [X_SGD4, hist5];
%end
%% non-private Clipped_SGD
loop = 625;  %iteration: passes *N/batchsize 
algorithm = 'CSGD';
sigma =1;
step_size_no = 10 / (24 * L*log(4/0.01));           
batchsize2 = 24;
clip2 = 1/14*sqrt(54*loop*sigma^2/(log(4*loop/0.01)*batchsize2));  
fprintf('Algorithm: CSGD\n');
time_1 = 0;
hist = 0;
for i=1:300
    tic;
    [time4, hist4,tidu4] = Interface(X, y, algorithm, model, regularizer, init_weight, mu, L...
        , step_size_no, loop,clip2,batchsize2);
    time_temp = toc;
    time_1 = time_1 + time_temp;
    hist = hist + hist4;
end
time = time_1 / 300;
hist4 = hist / 300; 
BBBBB = hist4 ;
hist4 = 1/hist4(1,1)*hist4; hist44 = hist4(1,1);
%TestCSGD(:,i) = hist4;
%TimeCSGD(i,1) = time;
%fprintf('Time: %f seconds \n', time);
fprintf('Time: %f seconds, loss: %f \n', [time, hist4(end)]);
X_SGD3= (0:1:size(hist4,1)-1)';
hist4 = [X_SGD3, hist4];
%end
%% Plot
figure;
passes=30;
set(0,'defaultfigurecolor','w');
plot(X_SGD,hist1(:,2),'b--o','linewidth',1.6,'markersize',4);
hold on
plot(X_SGD,hist3(:,2),'m--+','linewidth',1.6,'markersize',4);
hold on
plot(X_SGD,hist2(:,2),'r--^','linewidth',1.6,'markersize',4);
hold on
plot(X_SGD,hist4(:,2),'g--*','linewidth',1.6,'markersize',4);
hold on
plot(X_SGD,hist5(:,2),'k--*','linewidth',1.6,'markersize',4);
xlabel('Number of effective passes','Interpreter','latex', 'Fontsize',16);
ylabel('Objective minus best/initial error','Interpreter','latex','Fontsize',16);
mina = min([min(hist1(:, 2)), min(hist2(:, 2)),min(hist3(:,2)), min(hist4(:, 2)),  min(hist5(:, 2))]);
maxx = max([max(hist1(:, 2)), max(hist2(:, 2)),max(hist3(:,2)), max(hist4(:, 2)),  max(hist5(:, 2))]); 
axis([1,passes, mina, maxx]); grid on;
title('diabetes, real data','FontSize',16)
leg=legend('DP-GD', 'CC thm','UC thm','baseline', 'DP-SGD', 'location', 'southwest');
set(leg,'Box','off');
set(leg,'FontSize',12);
