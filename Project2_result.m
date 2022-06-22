function [elapsetime,SR,avgTurnover] = Project2_result(portfValue,turnover,elapsetime,riskFree,dates,returns)

    %helper function to return result
    %
    % *************** WRITE YOUR CODE HERE ***************
    %----------------------------------------------------------------------

    % Calculate the observed portfolio returns
    portfRets = portfValue(2:end) ./ portfValue(1:end-1) - 1;

    % Calculate the portfolio excess returns
    portfExRets = portfRets - table2array(riskFree(dates >= datetime(returns.Properties.RowNames{1}) + calyears(5) + calmonths(1),: ));

    % Calculate the portfolio Sharpe ratio 
    SR = (geomean(portfExRets + 1) - 1) / std(portfExRets);

    % Calculate the average turnover rate
    avgTurnover = mean(turnover(2:end));

    % Print Sharpe ratio and Avg. turnover to the console
    disp(['Elapsed time is: ',num2str(elapsetime)]);
    disp(['Sharpe ratio: ', num2str(SR)]);
    disp(['Avg. turnover: ', num2str(avgTurnover)]);

end
