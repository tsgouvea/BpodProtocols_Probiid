function [ mdl, logodds, nTrialsBack ] = LauGlim( Data, nTrialsBack )
%LAUGLIM Statistical model to predict single trial choice behavior as in
%Lau and Glimcher's JEAB paper (2005?)

if nargin < 2
  nTrialsBack = 5;
end

y = Data.Custom.ChoiceLeft(:);
C = y;
C(y==0) = -1;
R = Data.Custom.Rewarded(:).*C; % hopefully vectors of same length at all times
F = zeros(size(C));
F(C==1&Data.Custom.Baited.Right(:)) = -1;
F(C==-1&Data.Custom.Baited.Left(:)) = 1;

C = repmat(C,1,nTrialsBack);
R = repmat(R,1,nTrialsBack);
F = repmat(F,1,nTrialsBack);

for j = 1:nTrialsBack
    C(:,j) = circshift(C(:,j),j);
    C(1:j,j) = 0;
    R(:,j) = circshift(R(:,j),j);
    R(1:j,j) = 0;
    F(:,j) = circshift(F(:,j),j);
    F(1:j,j) = 0;
end

X = [C, R, F];
X(isnan(X)) = 0;
mdl = fitglm(X,y,'distribution','binomial');
logodds = mdl.predict(X);
logodds = log(logodds) - log(1-logodds);
end
