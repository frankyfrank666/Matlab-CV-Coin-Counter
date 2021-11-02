% AddCoinToCountAndPlot

%      Dime | Nickel | Quarter
% Radius 22 | 30     | 40
% Color red | green  | magenta
% Value  10 | 5      | 25

function [coinvalue,x_plot,y_plot,col] = AddCoinToPlotAndCount(x,y,cls)
% initialize radians for defining x_plot and y_plot using cos and sin functions
rads = 0:2*pi/32:2*pi;
% initialize parameters for radius and color of circle for each type of coin

if cls == 1 
    coinvalue = 10;
    col = 'red';
    diam = 22;
    
elseif cls == 2
    coinvalue = 5;
    col = 'green';
    diam = 30;
else
    coinvalue = 25;
    col = 'magenta';
    diam = 40;
end

x_plot = x + diam * cos(rads);
y_plot = y + diam * sin(rads);

plot(x_plot,y_plot,col);
end