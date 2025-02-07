clear; close all; clc;
rng('default')

%% Создание лабиринта
n = 10;
fee = -40;

maze = fee*ones(n,n);
for i=1:(n-3)*n
    maze(randi([1,n]),randi([1,n]))=1;
end
maze(1,1) = 1;
maze(n,n) = 40;

disp(maze)
%% Визуализация
n=length(maze);
figure
imagesc(maze)
colormap("spring")
for i=1:n
    for j=1:n
        if maze(i,j)==min(maze)
            text(j,i,'X','HorizontalAlignment','center')
        end
    end
end
text(1,1,'Start','HorizontalAlignment','center')
text(n,n,'Finish','HorizontalAlignment','center')
axis off
Goal=n*n;
%% Создание награды
reward=zeros(n*n);
for i=1:Goal
    reward(i,:)=reshape(maze',1,Goal);
end
for i=1:Goal
    for j=1:Goal
        if j~=i-n  && j~=i+n  && j~=i-1 && j~=i+1 && j~=i+n+1 && j~=i+n-1 && j~=i-n+1 && j~=i-n-1
            reward(i,j)=-Inf;
        end    
    end
end
for i=1:n:Goal
    for j=1:i+n
        if j==i+n-1 || j==i-1 || j==i-n-1
            reward(i,j)=-Inf;
            reward(j,i)=-Inf;
        end
    end
end

%% SARSA

q = randn(size(reward));
gamma=0.6; alpha=0.5; maxItr=100;

for i=1:maxItr
    cs=randi([1 length(reward)],1,1);
    while(1)
        actions=find(reward(cs,:)>0);
        ns=actions(randi([1 length(actions)]));
        actions=find(reward(ns,:)>0);
        randq=q(ns,actions(randi([1,length(actions)])));
        q(cs,ns)=q(cs,ns)+alpha*(reward(cs,ns)+gamma*randq -q(cs,ns));

        if(cs == Goal)
            break;
        end
        cs=ns;
    end
end

for i=1:Goal
    for j=1:Goal
        if j~=i-n  && j~=i+n  && j~=i-1 && j~=i+1 && j~=i+n+1 && j~=i+n-1 && j~=i-n+1 && j~=i-n-1
            q(i,j)=-Inf;
        end    
    end
end
for i=1:n:Goal
    for j=1:i+n
        if j==i+n-1 || j==i-1 || j==i-n-1
            q(i,j)=-Inf;
            q(j,i)=-Inf;
        end
    end
end

%% Прохождение лабиринта от начала до конца

start=1;move=0;
path=[start];
while(move~=Goal)
    [~,move]=max(q(start,:));

    if ismember(move,path)
        [~,x]=sort(q(start,:),'descend');
        move=x(2);
        if ismember(move,path)
            [~,x]=sort(q(start,:),'descend');
            move=x(3);
        end
    end

    path=[path,move];
    start=move;
end
fprintf('Final Path: %s',num2str(path))
pmat=zeros(n,n);
[q, r]=quorem(sym(path),sym(n));
q=double(q+1);r=double(r);
q(r==0)=n;r(r==0)=n;

for i=1:length(q)
   pmat(q(i),r(i))=40;
end

%% Финальный путь

figure
imagesc(maze)
colormap("spring")
for i=1:n
    for j=1:n
        if maze(i,j)==min(maze)
            text(j,i,'X','HorizontalAlignment','center')
        end
        if pmat(i,j)==40
            text(j,i,'\bullet','Color','green','FontSize',28)
        end
    end
end
text(1,1,'Start','HorizontalAlignment','center')
text(n,n,'Finish','HorizontalAlignment','center')

hold on
imagesc(maze,'AlphaData',0.2)
colormap(spring)
hold off
axis off