mex_all;
clc;
clear;
%% Load Dataset
load 'a9a.mat';
%% Multi runs
%TestT2 = zeros(31,100);TimeT2 = zeros(100,1);
%TestT3 = zeros(31,100);TimeT3 = zeros(100,1);
%TestDpGD = zeros(31,100);TimeDpGD = zeros(100,1);
%TestCSGD = zeros(31,100);TimeCSGD = zeros(100,1);
%for i = 1:30   
%load 'a9a.mat';
%% Add Bias
[N, Dim] = size(X);
N=28000;
XX = X(1:28000,:);
XX = full(X');
X = full(X');
%% Set Params
passes = 30; % passes of datasets
%model = 'logistic'; % choose model: logistic / least_square
model = 'least_square';
regularizer = 'L2'; 
init_weight = zeros(Dim, 1);
mu = 0; % L2-regularization parameter
if strcmp(model, 'logistic')
    L =max(sum(XX.^2, 1)) + mu; % Lipschitz constant for Logistic regression
elseif strcmp(model, 'least_square')
    L =max(sum(XX.^2, 1)) + mu; 
end

%% Clipped_dpSGD for Theorem 3.3 (T2);
loop = 4200;  %iteration: passes *N/batchsize 
algorithm = 'Clipped_dpSGD';
epsilon = 2.0;
sigma =1;
step_size = 1/12 *1 / (2 * L*log(4/0.01));           
batchsize1 = 200; 
clip1 = 1/18*(1/64.8)*sqrt(162*loop^2*sigma^2/(log(4/0.01)^2*batchsize1));   %2*L*R0;
var2 = 1/1.42*clip1*batchsize1*sqrt(loop*log(N))/(N*epsilon)*10 /2.5;
var2 = var2^2;
time_1 = 0;
hist_1 = 0;
fprintf('Algorithm: T2\n');
for i = 1:100
    tic;
    [time3, hist3,tidu3] = Interface(X, y, algorithm, model, regularizer, init_weight, mu, L...
        , step_size, loop,var2,batchsize1,clip1);
    time_temp = toc;
    time_1 = time_1 + time_temp;
    hist_1 = hist_1 + hist3;
end
time_1 = time_1 / 100;
hist3 = hist_1 / 100;
BBBB = hist3 ;
hist3 = 1/hist3(1,1)*hist3;
%TestT2(:,i) = hist3;
%TimeT2(i,1) = time;
fprintf('Time: %f seconds \n', time_1);
X_SGD2= (0:1:size(hist3,1)-1)';
hist3 = [X_SGD2, hist3];
%end

%% dpSGD;
loop = 4200;  %iteration: passes *N/batchsize 
algorithm = 'dpSGD';
epsilon = 2.0;
sigma =1;
step_size = 1/12 *1 / (2 * L*log(4/0.01));           
batchsize1 = 200; 
clip1 = 1/18*(1/64.8)*sqrt(162*loop^2*sigma^2/(log(4/0.01)^2*batchsize1));   %2*L*R0;
var1 = clip1*sqrt(loop*log(N))/(N*epsilon) *2000 /2.5;
var1 = var1^2;
time_2 = 0;
hist_2 = 0;
fprintf('Algorithm: dpSGD\n');
for i = 1:100
    tic;
    [time5, hist5,tidu5] = Interface(X, y, algorithm, model, regularizer, init_weight, mu, L...
        , step_size, loop,var1,batchsize1,clip1);
    time_temp = toc;
    time_2 = time_2 + time_temp;
    hist_2 = hist_2 + hist5;
end
time_2 = time_2 / 100;
hist5 = hist_2 / 100;
BBBB5 = hist5 ;
hist5 = 1/hist5(1,1)*hist5; 
%TestT2(:,i) = hist3;
%TimeT2(i,1) = time;
fprintf('Time: %f seconds \n', time_2);
X_SGD4= (0:1:size(hist5,1)-1)';
hist5 = [X_SGD4, hist5];
%end
%% Plot
figure;
X_SGD= X_SGD2;
passes=30;
set(0,'defaultfigurecolor','w');
plot(X_SGD,hist3(:,2),'m--+','linewidth',1.6,'markersize',4);
hold on
plot(X_SGD,hist5(:,2),'k--*','linewidth',1.6,'markersize',4);
xlabel('Number of effective passes','Interpreter','latex');
ylabel('Objective minus best/initial error','Interpreter','latex');
mina = min([min(hist3(:,2)), min(hist5(:, 2))]);
maxx = max([max(hist3(:,2)), max(hist5(:, 2))]); 
axis([1,passes, mina, maxx]); grid on;
leg=legend( 'T2','dpSGD');
set(leg,'Box','off');
set(leg,'FontSize',16);

