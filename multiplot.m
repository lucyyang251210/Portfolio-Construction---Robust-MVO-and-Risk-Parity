%% Clear the memory and console
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
clc
format short

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. DEFINE PARAMETERS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

load('samplePeriod');
load('sampleticker');
models = ["OLS", "FF","LASSO", "BSS"];
optMethods = ["MVO", "robustMVO", "RP", "cVar"];
% modelName = "OLS";
% optName = "MVO";

for ii = 1:4
    modelName = string(models(ii));
    for jj = 1:4
        optName = string(optMethods(jj));
        
        load(modelName+optName+'portfValue');
        porfValueAll{ii,jj} = portfValue;
        load(modelName+optName+'weights');
        weightsAll{ii,jj} = x;
    end
end

% load('OLSMVOportfValue');
% OLSMVOportfValue = portfValue;
% load('OLSMVOportfValue');
% OLSMVOportfValue = portfValue;


%% OLS
% Calculate the dates of the out-of-sample period
%plotDates = dates(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) );

fig1 = figure(1);
hold on
p1 = plot(plotDates, porfValueAll{1,1});
M1 = string(optMethods(1));
p2 = plot(plotDates, porfValueAll{1,2});
M2 = string(optMethods(2));
p3 = plot(plotDates, porfValueAll{1,3});
M3 = string(optMethods(3));
p4 = plot(plotDates, porfValueAll{1,4});
M4 = string(optMethods(4));

legend([p1,p2,p3,p4], [M1, M2,M3,M4]);

datetick('x','dd-mmm-yyyy','keepticks','keeplimits');
set(gca,'XTickLabelRotation',30);
title('OLS Portfolio wealth evolution', 'FontSize', 14)
ylabel('Total wealth','interpreter','latex','FontSize',12);

% Define the plot size in inches
set(fig1,'Units','Inches', 'Position', [0 0 8, 5]);
pos1 = get(fig1,'Position');
set(fig1,'PaperPositionMode','Auto','PaperUnits','Inches',...
    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig1,'fileName','-dpdf','-r0');

% If you want to save the figure as .png for use in MS Word
fileName1 = "OLS wealth";
print(fig1,fileName1,'-dpng','-r0');

%% FF
% Calculate the dates of the out-of-sample period
%plotDates = dates(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) );

fig2 = figure(2);
hold on
p1 = plot(plotDates, porfValueAll{2,1});
M1 = string(optMethods(1));
p2 = plot(plotDates, porfValueAll{2,2});
M2 = string(optMethods(2));
p3 = plot(plotDates, porfValueAll{2,3});
M3 = string(optMethods(3));
p4 = plot(plotDates, porfValueAll{2,4});
M4 = string(optMethods(4));

legend([p1,p2,p3,p4], [M1, M2,M3,M4]);

datetick('x','dd-mmm-yyyy','keepticks','keeplimits');
set(gca,'XTickLabelRotation',30);
title('FF Portfolio wealth evolution', 'FontSize', 14)
ylabel('Total wealth','interpreter','latex','FontSize',12);

% Define the plot size in inches
set(fig2,'Units','Inches', 'Position', [0 0 8, 5]);
pos1 = get(fig2,'Position');
set(fig2,'PaperPositionMode','Auto','PaperUnits','Inches',...
    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig1,'fileName','-dpdf','-r0');

% If you want to save the figure as .png for use in MS Word
fileName2 = "FF wealth";
print(fig2,fileName2,'-dpng','-r0');

%% LASSO
% Calculate the dates of the out-of-sample period
%plotDates = dates(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) );

fig3 = figure(3);
hold on
p1 = plot(plotDates, porfValueAll{3,1});
M1 = string(optMethods(1));
p2 = plot(plotDates, porfValueAll{3,2});
M2 = string(optMethods(2));
p3 = plot(plotDates, porfValueAll{3,3});
M3 = string(optMethods(3));
p4 = plot(plotDates, porfValueAll{3,4});
M4 = string(optMethods(4));

legend([p1,p2,p3,p4], [M1, M2,M3,M4]);

datetick('x','dd-mmm-yyyy','keepticks','keeplimits');
set(gca,'XTickLabelRotation',30);
title('LASSO Portfolio wealth evolution', 'FontSize', 14)
ylabel('Total wealth','interpreter','latex','FontSize',12);

% Define the plot size in inches
set(fig3,'Units','Inches', 'Position', [0 0 8, 5]);
pos1 = get(fig3,'Position');
set(fig3,'PaperPositionMode','Auto','PaperUnits','Inches',...
    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig1,'fileName','-dpdf','-r0');

% If you want to save the figure as .png for use in MS Word
fileName3 = "LASSO wealth";
print(fig3,fileName3,'-dpng','-r0');

%% BSS
% Calculate the dates of the out-of-sample period
%plotDates = dates(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) );

fig4 = figure(4);
hold on
p1 = plot(plotDates, porfValueAll{4,1});
M1 = string(optMethods(1));
p2 = plot(plotDates, porfValueAll{4,2});
M2 = string(optMethods(2));
p3 = plot(plotDates, porfValueAll{4,3});
M3 = string(optMethods(3));
p4 = plot(plotDates, porfValueAll{4,4});
M4 = string(optMethods(4));

legend([p1,p2,p3,p4], [M1, M2,M3,M4]);

datetick('x','dd-mmm-yyyy','keepticks','keeplimits');
set(gca,'XTickLabelRotation',30);
title('BSS Portfolio wealth evolution', 'FontSize', 14)
ylabel('Total wealth','interpreter','latex','FontSize',12);

% Define the plot size in inches
set(fig4,'Units','Inches', 'Position', [0 0 8, 5]);
pos1 = get(fig4,'Position');
set(fig4,'PaperPositionMode','Auto','PaperUnits','Inches',...
    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig1,'fileName','-dpdf','-r0');

% If you want to save the figure as .png for use in MS Word
fileName4 = "BSS wealth";
print(fig4,fileName4,'-dpng','-r0');

%%
%--------------------------------------------------------------------------
% 3.3 Portfolio weights plot
%--------------------------------------------------------------------------

% Portfolio weights

fig2 = figure(2);
area(x')
legend(tickers, 'Location', 'eastoutside','FontSize',12);
title('Portfolio weights', 'FontSize', 14)
ylabel('Weights','interpreter','latex','FontSize',12);
xlabel('Rebalance period','interpreter','latex','FontSize',12);

% Define the plot size in inches
set(fig2,'Units','Inches', 'Position', [0 0 8, 5]);
pos1 = get(fig2,'Position');
set(fig2,'PaperPositionMode','Auto','PaperUnits','Inches',...
    'PaperSize',[pos1(3), pos1(4)]);

% If you want to save the figure as .pdf for use in LaTeX
% print(fig2,'fileName2','-dpdf','-r0');
fileName2 = modelName + optName + "weights";
% If you want to save the figure as .png for use in MS Word
print(fig2,fileName2,'-dpng','-r0');
