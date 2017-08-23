%%% INICIALIZACIA %%%
iptsetpref('UseIPPL', false); %% vypnutie pouzivania IPP kniznic (aby sa f. imfilter spravala genericky) 
original = imread('xfajci00.bmp'); %%Nacitanie originalneho obrazku
current = imread('xfajci00.bmp');	%% Obrazok , ktory sa bude modifikovat

%%% ZAOSTRENIE OBRAZU POMOCOU LINEARNEHO FILTRU %%%
outputimg = 'step1.bmp'; %%obrazok so zmenami
shpmatrix = [-0.5 -0.5 -0.5; -0.5 5 -0.5; -0.5 -0.5 -0.5]; %% Filter H
img_sharpen = imfilter(current, shpmatrix); %% zaostrenie obrazu
imwrite (img_sharpen, outputimg); %% ulozenie obrazku

%%% OTOCENIE OBRAZU OKOLO ZVISLEJ OSI %%%
outputimg = 'step2.bmp';
img_flipped = fliplr(img_sharpen); %% preklopenie obrazu
imwrite (img_flipped, outputimg);

%%% MEDIANOVY FILTER %%%
outputimg = 'step3.bmp';
img_medianf = medfilt2(img_flipped, [5 5]); %%filtrovanie podla medianu
imwrite(img_medianf,outputimg);

%%% ROZMAZANIE OBRAZU %%%
outputimg = 'step4.bmp';
blurmatrix = [1 1 1 1 1; 1 3 3 3 1; 1 3 9 3 1; 1 3 3 3 1; 1 1 1 1 1] / 49; %% Filter H
img_blurred = imfilter(img_medianf, blurmatrix); %% rozmazanie obrazku
imwrite(img_blurred, outputimg);

%%% CHYBA V OBRAZE %%%
img_compared = fliplr (img_blurred); %% pretocenie obrazku naspat
current_imgdbl = im2double(img_compared);
orig_imgdbl	 = im2double(original); %% pretypovanie na double

err = 0;

imgsize = size (original);
imgsizeX = min (imgsize);
imgsizeY = max (imgsize);
%% pocitanie chyby
for ( i=1: imgsizeX)
	for (j=1: imgsizeY)
		err = err + abs(orig_imgdbl(i,j) - current_imgdbl(i,j));
	end;
end;

error = (err / (imgsizeX * imgsizeY))*255

%%% ROZTIAHNUTIE HISTOGRAMU %%%
outputimg = 'step5.bmp';
blurred_imgdbl = im2double(img_blurred);

%% generovanie minimalnej a maximalnej hodnoty v obraze
min_ = min(blurred_imgdbl);
in_L = min(min_);
max_ = max(blurred_imgdbl);
in_H = max(max_);

out_L = 0.0;
out_H = 1.0;

%% roztiahnutie obrazu
img_adjusted = imadjust (img_blurred, [in_L in_H], [out_L out_H]);
imwrite(img_adjusted,outputimg);

%%% SMERDAJNA ODCHYLKA A PRIEMERNA HODNOTA %%%
%% bez modifikacie roztiahnutim
blurred_imgdbl = im2double(img_blurred);
mean_nohis	 = mean2(blurred_imgdbl)*255
stddev_nohis 	 = std2(blurred_imgdbl)*255

%% pre obraz modifikovany roztiahnutim
img_adjdbl	 = im2double(img_adjusted);
mean_his		 = mean2(img_adjdbl)*255
stddev_his	 = std2(img_adjdbl)*255

%%% KVANTIZACIA OBRAZU %%%
N = 2; %% velkost kvantizacie
a = 0;
b = 255;

outputimg = 'step6.bmp';
quant_tmp = zeros(imgsizeX, imgsizeY);
blur_tmp = double(img_blurred);
for (i=1: imgsizeX)
	for (j = 1: imgsizeY)
	quant_tmp(i,j) = round(((2^N)-1)*(blur_tmp(i,j)-a)/(b-a))*(b-a)/((2^N)-1) + a;
	end;
end;

img_quantified = uint8(quant_tmp);
imwrite(img_quantified, outputimg);
