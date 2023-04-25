%close all;
clear;
clc;
clf;
%%
Ratio_Set = [0.2, 0.3, 0.5, 0.8];

for ImgNo = 3
    for ratio_num = 3
        switch ImgNo
            case 1
                OrgName = 'Barbara256rgb.png';
            case 2
                OrgName = 'House256rgb.png';
            case 3
                OrgName = 'lena256.jpg';   
            case 4
                OrgName = 'parrots.tif';          
        end
    end
end
        ratio = Ratio_Set(ratio_num); % ratio of available data, Options: [0.2, 0.3, 0.5, 0.8]
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        x_rgb = imread(OrgName); % Original True Image
        [N,M,dim]=size(x_rgb);
        
        x_yuv = rgb2ycbcr(x_rgb);
        
        x = double(x_yuv(:,:,1)); % Deal with Y Component
        x_org = x;
        x_inpaint_rgb = zeros(size(x_rgb));
        x_inpaint_yuv = zeros(size(x_yuv));
        x_inpaint_yuv(:,:,2) = x_yuv(:,:,2); % Copy U Componet
        x_inpaint_yuv(:,:,3) = x_yuv(:,:,3); % Copy V Componet
        
     MaskType = 1; % 1 for random mask; 2 for text mask
        switch MaskType
            case 1
                rand('seed',0);
                O = double(rand(size(x)) > (1-ratio));
            case 2
                O = imread('TextMask256.png');
                O = double(O>128);
        end    
     % Generate Missing Image
        y_missing_rgb = zeros(size(x_rgb));
        y_missing_rgb(:,:,1) = uint8(double(x_rgb(:,:,1)).*O);
        y_missing_rgb(:,:,2) = uint8(double(x_rgb(:,:,2)).*O);
        y_missing_rgb(:,:,3) = uint8(double(x_rgb(:,:,3)).*O);
        
        y= x.* O;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Considering the Case with Gaussian White Noise.
        % When Noise_flag is zero, no noise is added.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Noise_flag = 0;
        if (Noise_flag)
%             BSNR = 40;
%             Py = var(x(:));
%             sigma = sqrt((Py/10^(BSNR/10)));
            sigma = 5;
            % Add noise
            y=y + sigma*randn(N,M);
        end
                
      ssim_inpainted = ssim_index(y,x);
      psnr_inpainted = psnr(y/255,x/255) ;
      figure(1);imshow(uint8(y_missing_rgb)); title(sprintf('Inpainted,PSNR: %4.2fdB,SSIM: %4.4f',psnr_inpainted,ssim_inpainted),'fontsize',13);
    %%   ����GSR�õ��Ļָ���� ;
          load GSRbarbaraRatio20.mat ; %% ����GSR�õ��Ļָ���� ;
%           load GSRlenaRatio20.mat ;
%            load GSRlenaRatio30.mat ;
           load GSRlenaRatio50.mat ;
%            load GSRlenaRatio80.mat ;
%           load GSRparrotsRatio20.mat ;

        x_inpaint_yuv(:,:,1) = uint8(x_final);
        x_inpaint_rgb = ycbcr2rgb(uint8(x_inpaint_yuv));
     ssim_GSR = ssim_index(x_final,x);
     psnr_GSR = psnr(x_final/255,x/255) ;      
     figure(2);imshow(uint8(x_inpaint_rgb)); title(sprintf('GSR,PSNR: %4.2fdB,SSIM: %4.4f',psnr_GSR, ssim_GSR),'fontsize',13);    
     
     
  %% ���� Wavelet Frame deblurring ALgorithm   
     
   if max(x_final(:))>1 %% ʹ��CSR�����Ϊ��ֵ; ���ҽ�����ֵ��Χ��������0-255�� ��
           x_final = x_final ;
      else
        disp([ 'There is a problem in the intensity range ' ]);
   end
  
   img = x ;
   cimg = y ;
   opts.Im0 = x_final ; %% ʹ��GSR�ָ������Ϊ��ʼֵ ;
     
 % Parameters setting
opts = [];
opts.Level=4;
opts.frame=1;
opts.tol = 5e-4;
opts.maxit = 200; 
opts.maxIt = 1 ; % the maximum stage number 
opts.mu = 0.02 ;
opts.lambda = 0.1 ;

opts.mu = 0.05 ;
opts.lambda = 0.5 ;
opts.gamma = 0; 
     
% Main function
disp('The code is running, Please waiting for a minitue.....')
[rimg,Out] = ISDSBframe_Inpainting(img,cimg,O,opts);
disp('Running finished')
CSNR = snr(cimg,img); CSSIM = ssim_index(cimg,img) ;
RSNR = snr(rimg,img); RSSIM = ssim_index(rimg,img) ;
     
     
x_final = rimg ;     
 [mssim2 ssim_map] = ssim_index(x_final,x);
 psnr2 = psnr(x_final/255,x/255) ;  
 x_inpaint_yuv(:,:,1) = uint8(x_final);
x_inpaint_rgb = ycbcr2rgb(uint8(x_inpaint_yuv)); 
figure(3);imshow(uint8(x_inpaint_rgb));  title(sprintf('Proposed,PSNR: %4.2fdB,SSIM: %4.4f',psnr2,mssim2),'fontsize',13);     
     
     
     
     
     