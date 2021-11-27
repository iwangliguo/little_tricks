function [BEST1,best_f,particlesize_k,totaltime]=PPPSO(xl,xu,ratio,ratio1,narvs,K1,K2) %BEST1最终值 best_f迭代过程值，particlesize_k种群变化值 K1：相遇概率 K2：捕捉概率
% clc,clear
tic;
MaxNum=5000;  %粒子迭代次数
E=10^-3;    %与鹰相遇时的速度上限  shpere noise swefel2 为-2
% narvs=D;     %自变量个数
particlesize=200;%粒子群初始规模
particlesize_set=200; %粒子群规模设定值
sum_e=0;   
c1=2.05;  %每个粒子个体学习因子
c2=2.05;   %每个粒子社会学习银子
w=0.7298;   %收敛因子
% xu=-600;
% xl=600;
xbounds=[xl,xu];  %自变量范围
% ratio=0.4;   %初始化速度的比例   
% ratio1=10^-100;  %重生和繁衍兔子的随机速度比例    
% K1=0.1 ;      %遇到鹰的概率 （小于一定速度，控制以下程序的概率）相遇概率
% K2=0.1;      %被鹰抓走的概率 捕捉概率
PP=0.45;      %PID比例系数   繁殖比例系数
II=0.01;     %PID积分系数
DD=0;        
% particlesize_add=0;
vmax=ratio*(xbounds(2)-xbounds(1));      %最大速度
vmax1=ratio1*(xbounds(2)-xbounds(1));    %重生、繁衍兔子的随机最大速度
x=xbounds(1)+(xbounds(2)-xbounds(1))*rand(particlesize,narvs);  %初始化位置
v=vmax*(rand(particlesize,narvs)-0.5)*2;   %初始化飞翔速度
f=zeros(particlesize,1);
for i=1:particlesize
    f(i)=fitness(x(i,:),narvs);
end
personalbest_x=x;
personalbest_fval=f;
% [globalbest_fval,a]=min(personalbest_fval); %将目前个人最好适应度函数值和位置a赋给全局最好适应度函数值 globalbest_fval 1个
% globalbest_x=personalbest_x(a,:);           %将目前个人最优位置赋给全局最优位置 globalbest_x 1行narvs列


k=1;
best_f=zeros(MaxNum,1);          %每次迭代最优的值
best_x=zeros(MaxNum,narvs);
e=zeros(MaxNum,1);
particlesize_k=zeros(MaxNum,1);
while k<=MaxNum
    
    %*****************************初始化*******************************
    for i=1:particlesize
        f(i)=fitness(x(i,:),narvs);
        if f(i)<personalbest_fval(i)     %判断当前位置是否是历史上最佳值
            personalbest_fval(i)=f(i);
            personalbest_x(i,:)=x(i,:);
        end
    end
    
    [globalbest_fval, a]=min(personalbest_fval);
    globalbest_x=personalbest_x(a,:);
    best_x(k,:)=globalbest_x;     %记录每一次迭代最好的x
    best_f(k)=globalbest_fval;    %记录每一次迭代最小值
    
    %*************************更新速度和位置*****************************
    
    for i=1:particlesize
        v(i,:)=w*(v(i,:)+c1*rand()*(personalbest_x(i,:)-x(i,:))+c2*rand()*(globalbest_x-x(i,:))); %按收敛因子的速度更新公式
        x(i,:)=x(i,:)+v(i,:);
        x(i,:)=max(x(i,:),xbounds(1));
        x(i,:)=min(x(i,:),xbounds(2));
    end
     
    %*************************设定兔子是否遇到鹰****************************
    
    B=zeros(particlesize,1);    %每个粒子的状态
    V=zeros(particlesize,1);    %每个粒子的平均速度
    for i=1:particlesize
        V(i)=0;
        for j=1:narvs
            V(i)=V(i)+v(i,j)^2;
        end
        V(i)= sqrt(V(i));
        if V(i)<E
            if rand()<K1 && personalbest_fval(i)~=globalbest_fval % 小于遇到鹰的概率且 不是种群中的最优值
                if rand()<K2
                    B(i)=1;
                else
                    B(i)=2;
                end
            end
        end
    end
    
     PX=find(B==1);         %被鹰抓走 PX返回位置 矩阵
%      if ~isempty(PX) 
     if ~isempty(PX) && particlesize>=0.5*particlesize_set
        if length(PX)<=0.5*particlesize
            particlesize=particlesize-length(PX);
            x(PX,:)=[];
            f(PX)=[];
            personalbest_fval(PX)=[];
            personalbest_x(PX,:)=[];
            v(PX,:)=[];
            V(PX)=[];
        else
            particlesize=particlesize-round(0.5*particlesize);
            x(PX(1:round(0.5*particlesize)),:)=[];
            f(PX(1:round(0.5*particlesize)))=[];
            personalbest_fval(PX(1:round(0.5*particlesize)))=[];
            personalbest_x(PX(1:round(0.5*particlesize)),:)=[];
            v(PX(1:round(0.5*particlesize)),:)=[];
            V(PX(1:round(0.5*particlesize)))=[];
        end
    end
    
    PX=find(B==2);  %重生 随机跑到别的洞 每个洞被选中的概率相同 即存在同一个洞可能被选中多次的情况
    if ~isempty(PX)
        for j=1:length(PX)
            A=randperm(particlesize);
            x(PX(j),:)= personalbest_x(A(1),:);    %兔子现在的位置跑到，随机一个个人历史最优位置（洞）
            v(PX(j),:)=vmax1*(rand(1,narvs)-0.5)*2;
            personalbest_x(PX(j),:)=personalbest_x(A(1),:); 
            personalbest_fval(PX(j))=personalbest_fval(A(1)); 
            f(PX(j))=f(A(1));
        end
    end
    
    %*************************兔子繁衍（兔子排序，每个兔子只能生1个，从最好的兔子顺序繁衍）****************************
%     
%     if k>1
%         e(k)=particlesize_set-particlesize;
%         sum_e=sum_e+e(k);
%         particlesize_add=round(PP*e(k)+II*sum_e+DD*(e(k)-e(k-1)));    %PID调节 种群增加值particlesize_add
%         if   particlesize_add>0
%             [I,IX]=sort(personalbest_fval(1:particlesize),'ascend');    %把个人历史最优值从小到大排序
%             for i=1:particlesize_add
%                 x(particlesize+i,:)= personalbest_x(IX(i),:);
%                 personalbest_x(particlesize+i,:)=personalbest_x(IX(i),:);
%                 personalbest_fval(particlesize+i)=personalbest_fval(IX(i));
%                 f(particlesize+i)=f(IX(i));
%                 v(particlesize+i,:)=vmax1*(rand(1,narvs)-0.5)*2;
%             end
%             particlesize=particlesize+particlesize_add;
%         end
%     end


if k>1
    e(k)=particlesize_set-particlesize;
    sum_e=sum_e+e(k);
    particlesize_add=round(PP*e(k)+II*sum_e+DD*(e(k)-e(k-1)));    %PID调节 种群增加值particlesize_add
    if   particlesize_add>0
        for i=1:particlesize_add
            A=randperm(particlesize);
            x(particlesize+i,:)= personalbest_x(A(1),:);
            personalbest_x(particlesize+i,:)=personalbest_x(A(1),:);
            personalbest_fval(particlesize+i)=personalbest_fval(A(1));
            f(particlesize+i)=f(A(1));
            v(particlesize+i,:)=vmax1*(rand(1,narvs)-0.5)*2;
        end
        particlesize=particlesize+particlesize_add;
    end
end
particlesize_k(k)=particlesize;
k=k+1;
% particlesize_addk(k)= particlesize_add;
end
totaltime=toc;
BEST1=best_f(k-1);
% plot(1:k-1,best_f(1:k-1))
% plot(1:k-1,particlesize_k(1:k-1))
end

