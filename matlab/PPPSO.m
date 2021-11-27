function [BEST1,best_f,particlesize_k,totaltime]=PPPSO(xl,xu,ratio,ratio1,narvs,K1,K2) %BEST1����ֵ best_f��������ֵ��particlesize_k��Ⱥ�仯ֵ K1���������� K2����׽����
% clc,clear
tic;
MaxNum=5000;  %���ӵ�������
E=10^-3;    %��ӥ����ʱ���ٶ�����  shpere noise swefel2 Ϊ-2
% narvs=D;     %�Ա�������
particlesize=200;%����Ⱥ��ʼ��ģ
particlesize_set=200; %����Ⱥ��ģ�趨ֵ
sum_e=0;   
c1=2.05;  %ÿ�����Ӹ���ѧϰ����
c2=2.05;   %ÿ���������ѧϰ����
w=0.7298;   %��������
% xu=-600;
% xl=600;
xbounds=[xl,xu];  %�Ա�����Χ
% ratio=0.4;   %��ʼ���ٶȵı���   
% ratio1=10^-100;  %�����ͷ������ӵ�����ٶȱ���    
% K1=0.1 ;      %����ӥ�ĸ��� ��С��һ���ٶȣ��������³���ĸ��ʣ���������
% K2=0.1;      %��ӥץ�ߵĸ��� ��׽����
PP=0.45;      %PID����ϵ��   ��ֳ����ϵ��
II=0.01;     %PID����ϵ��
DD=0;        
% particlesize_add=0;
vmax=ratio*(xbounds(2)-xbounds(1));      %����ٶ�
vmax1=ratio1*(xbounds(2)-xbounds(1));    %�������������ӵ��������ٶ�
x=xbounds(1)+(xbounds(2)-xbounds(1))*rand(particlesize,narvs);  %��ʼ��λ��
v=vmax*(rand(particlesize,narvs)-0.5)*2;   %��ʼ�������ٶ�
f=zeros(particlesize,1);
for i=1:particlesize
    f(i)=fitness(x(i,:),narvs);
end
personalbest_x=x;
personalbest_fval=f;
% [globalbest_fval,a]=min(personalbest_fval); %��Ŀǰ���������Ӧ�Ⱥ���ֵ��λ��a����ȫ�������Ӧ�Ⱥ���ֵ globalbest_fval 1��
% globalbest_x=personalbest_x(a,:);           %��Ŀǰ��������λ�ø���ȫ������λ�� globalbest_x 1��narvs��


k=1;
best_f=zeros(MaxNum,1);          %ÿ�ε������ŵ�ֵ
best_x=zeros(MaxNum,narvs);
e=zeros(MaxNum,1);
particlesize_k=zeros(MaxNum,1);
while k<=MaxNum
    
    %*****************************��ʼ��*******************************
    for i=1:particlesize
        f(i)=fitness(x(i,:),narvs);
        if f(i)<personalbest_fval(i)     %�жϵ�ǰλ���Ƿ�����ʷ�����ֵ
            personalbest_fval(i)=f(i);
            personalbest_x(i,:)=x(i,:);
        end
    end
    
    [globalbest_fval, a]=min(personalbest_fval);
    globalbest_x=personalbest_x(a,:);
    best_x(k,:)=globalbest_x;     %��¼ÿһ�ε�����õ�x
    best_f(k)=globalbest_fval;    %��¼ÿһ�ε�����Сֵ
    
    %*************************�����ٶȺ�λ��*****************************
    
    for i=1:particlesize
        v(i,:)=w*(v(i,:)+c1*rand()*(personalbest_x(i,:)-x(i,:))+c2*rand()*(globalbest_x-x(i,:))); %���������ӵ��ٶȸ��¹�ʽ
        x(i,:)=x(i,:)+v(i,:);
        x(i,:)=max(x(i,:),xbounds(1));
        x(i,:)=min(x(i,:),xbounds(2));
    end
     
    %*************************�趨�����Ƿ�����ӥ****************************
    
    B=zeros(particlesize,1);    %ÿ�����ӵ�״̬
    V=zeros(particlesize,1);    %ÿ�����ӵ�ƽ���ٶ�
    for i=1:particlesize
        V(i)=0;
        for j=1:narvs
            V(i)=V(i)+v(i,j)^2;
        end
        V(i)= sqrt(V(i));
        if V(i)<E
            if rand()<K1 && personalbest_fval(i)~=globalbest_fval % С������ӥ�ĸ����� ������Ⱥ�е�����ֵ
                if rand()<K2
                    B(i)=1;
                else
                    B(i)=2;
                end
            end
        end
    end
    
     PX=find(B==1);         %��ӥץ�� PX����λ�� ����
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
    
    PX=find(B==2);  %���� ����ܵ���Ķ� ÿ������ѡ�еĸ�����ͬ ������ͬһ�������ܱ�ѡ�ж�ε����
    if ~isempty(PX)
        for j=1:length(PX)
            A=randperm(particlesize);
            x(PX(j),:)= personalbest_x(A(1),:);    %�������ڵ�λ���ܵ������һ��������ʷ����λ�ã�����
            v(PX(j),:)=vmax1*(rand(1,narvs)-0.5)*2;
            personalbest_x(PX(j),:)=personalbest_x(A(1),:); 
            personalbest_fval(PX(j))=personalbest_fval(A(1)); 
            f(PX(j))=f(A(1));
        end
    end
    
    %*************************���ӷ��ܣ���������ÿ������ֻ����1��������õ�����˳���ܣ�****************************
%     
%     if k>1
%         e(k)=particlesize_set-particlesize;
%         sum_e=sum_e+e(k);
%         particlesize_add=round(PP*e(k)+II*sum_e+DD*(e(k)-e(k-1)));    %PID���� ��Ⱥ����ֵparticlesize_add
%         if   particlesize_add>0
%             [I,IX]=sort(personalbest_fval(1:particlesize),'ascend');    %�Ѹ�����ʷ����ֵ��С��������
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
    particlesize_add=round(PP*e(k)+II*sum_e+DD*(e(k)-e(k-1)));    %PID���� ��Ⱥ����ֵparticlesize_add
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

