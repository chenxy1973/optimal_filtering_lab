%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ��Ȩ������
%     ���������ϸ����ע����ο�
%     ��Сƽ�����ң�������.�����˲�ԭ����Ӧ��[M].���ӹ�ҵ�����磬2017.4
%     ������ԭ������+����+����+����ע��
%     ����˳����д��������ʾ�޸�
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% �ļ����ƣ�main432.m
% ����˵����Ӳ��Ͷ��ʵ�飬�����ģ��
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function main432

p=0.4;
%error('����Ĳ���N��ο����е�ֵ���ã�Ȼ��ɾ�����д���')
N=10000;
 
sum=0
 
for k=1:N
 
    cion1=binornd(1,p);
    cion2=binornd(1,p);
 
    sum=sum+cion1*cion2; 
 
    P(k)=sum/k;
end
 
figure
hold on;box on;
plot(1:N,P);
xlabel('k');
ylabel('���������Ƶ��');
plot([1,N],[p^2,p^2],'r-','LineWidth',2);
legend('Experiment result','Ground truth');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%