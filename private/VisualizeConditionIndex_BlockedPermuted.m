load('ConditionIndex.mat','ConditionIndex');
CIwide = unstack(ConditionIndex,'index','subject');
z = CIwide.condition == 'blocked permuted';
BP = CIwide(z,:);

for i = 1:10
    Y(:,i) = BP.unit_category(BP.(sprintf('x%d',i)));
end
disp(Y);
% 
% Y = 
% 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      SH         noise      AH         SH         SH         SH         SH         AH         noise      noise 
%      AH         AH         SH         AH         AH         noise      SH         AH         noise      SH    
%      noise      noise      AH         AH         noise      SH         noise      SH         AH         noise 
%      noise      noise      SH         AH         AH         AH         AH         noise      SH         SH    
%      AH         SH         AH         noise      noise      AH         noise      SH         AH         AH    
%      SH         AH         noise      SH         noise      noise      SH         noise      noise      noise 
%      SH         SH         noise      noise      SH         SH         AH         SH         SH         AH    
%      AH         AH         SH         noise      SH         AH         AH         AH         SH         AH    
%      noise      SH         noise      SH         AH         noise      noise      noise      AH         SH    
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      AH         AH         AH         AH         noise      AH         noise      AH         noise      AH    
%      noise      AH         noise      noise      AH         SH         noise      noise      SH         SH    
%      AH         noise      noise      SH         noise      SH         AH         noise      noise      AH    
%      SH         SH         SH         AH         SH         noise      SH         AH         SH         noise 
%      SH         noise      SH         SH         SH         AH         SH         SH         AH         noise 
%      noise      SH         AH         noise      AH         noise      AH         SH         AH         SH    
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      noise      noise      noise      noise      noise      noise      noise      noise      noise      noise 
%      SH         SH         AH         SH         SH         noise      AH         AH         AH         noise 
%      AH         noise      noise      AH         AH         AH         AH         AH         noise      noise 
%      AH         noise      AH         noise      noise      AH         SH         noise      AH         SH    
%      noise      AH         SH         noise      noise      noise      noise      noise      noise      SH    
%      SH         AH         SH         AH         AH         SH         SH         SH         SH         AH    
%      noise      SH         noise      SH         SH         SH         noise      SH         SH         AH  