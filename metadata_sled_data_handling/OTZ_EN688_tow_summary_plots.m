load 'C:\Users\ISIIS WHOI\gss_logs\OTZ_EN688_sled_data.mat'
t = diff(sled_table.matdate);
ii = find(t>1/24);
ii = [0; ii; size(sled_table,1)];

for c = 1:length(ii)-1
    sled_table.tow((ii(c)+1):(ii(c+1)),1) = c;
end

sled_table.datetime = datetime(sled_table.matdate, 'ConvertFrom', 'datenum');
%%
t = diff(sled_table.matdate);
it = find(t<1/24);
disp('hours towed:')
disp(sum(t(it))*24)

swd = sw_dist(sled_table.TS_LATITUDE_DEG, sled_table.TS_LONGITUDE_DEG, 'km');
dz = abs(diff(sled_table.DEPTH_M));
tt = find(swd<.1);
disp('km towed:')
disp(sum(sqrt((dz(tt).^2+(swd(tt)*1000).^2)))/1000)
disp('horizontal km')
disp(sum(swd(tt)))
disp('vertical km')
disp(sum(dz(tt))/1000)

%%
figure, set(gcf, 'position', [25 700 1450 300])
hold on
%plot(sled_table.datetime, sled_table.DEPTH_M), set(gca, 'ydir', 'reverse')
for c = 1:length(ii)-1
    text(sled_table.datetime(ii(c)+1), -50, ['Tow ' num2str(c)])
    iii = (sled_table.tow==c);
    plot(sled_table.datetime(iii), sled_table.DEPTH_M(iii), 'b') 
end
set(gca, 'ydir', 'reverse', 'box', 'on', 'ylim', [0 1000])
grid on
%%
WBAT = [-70-12.1387/60 38+59.1258/60];
figure, set(gcf, 'position', [440 300 1200 700])
t = tiledlayout(3,4, 'tilespacing', 'compact');
for c = 1:11
    n(c) = nexttile;
    x = sled_table.TS_LONGITUDE_DEG(sled_table.tow==c);
    y = sled_table.TS_LATITUDE_DEG(sled_table.tow==c);
    p1 = plot(WBAT(1), WBAT(2), 'cd', 'markerfacecolor', 'c');
    hold on
    p4 = plot(x,y);
    axis([-70.35 -69.7 38.75 39.1])
    %text(WBAT(1), WBAT(2),'  WBAT', 'color', 'c')
    title(['Tow ' num2str(c)])
    p2 = plot(x(1),y(1), 'go', 'markerfacecolor', 'g');
    p3 = plot(x(end),y(end), 'rs', 'markerfacecolor', 'r');
    grid on
end
ylabel(t, 'Latitude'), xlabel(t, 'Longitude')
legend(n(11), [p1 p2 p3 p4], 'WBAT', 'Start tow', 'End tow', 'tow')