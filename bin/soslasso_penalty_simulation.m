x = [rand(10,10),zeros(10,90)];
ix = randperm(100);

z = zeros(4,1);
lamL1 = [0.1;0.1;0.1;0.1];
lamSOS = [0.1;0.1;0.1;0.1];
gs = [10;10;1;100];
c = categorical([0;1;1;1],0:1,{'local','permuted'});
T = table(c,lamSOS,lamL1,gs,z,'VariableNames',{'condition','lamSOS','lamL1','gsize','sos_penalty'});

T.sos_penalty(1) = sum(soslasso_penalty(x, 0.1, 0.1, 10, 0));
T.sos_penalty(2) = sum(soslasso_penalty(x(:,ix), 0.1, 0.1, 10, 0));
T.sos_penalty(3) = sum(soslasso_penalty(x(:,ix), 0.1, 0.1, 1, 0));
T.sos_penalty(4) = sum(soslasso_penalty(x(:,ix), 0.1, 0.1, 100, 0));

disp(T)
