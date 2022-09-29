%s = imread('G:\EN649_06Feb2020_013\Basler_avA2300-25gm__22955661__20200206_143812268_194.tiff');
load('get_pixel_size.mat')

figure
plot(short_axis1(:,2), '.'), title('short1')
figure
plot(short_axis2(:,2), '.'), title('short2')
figure
plot(long_axis1(:,1), '.'), title('long1')
figure
plot(long_axis2(:,1), '.'), title('long2')

%slope set
mean([22.45 22.58 22.78 22.08]) %22.47


