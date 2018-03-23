function [X,I] = whichmin( x )
    [~,I] = min(x(:,1));
    X = x(I,:);
end

