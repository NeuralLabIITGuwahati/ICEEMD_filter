% ICEEMD function which takes in white noise imfs as an additional input
% 

function [modes,its]=ICEEMD_wn(x,Nstd,NR,modes_white_noise,MaxIter,SNRFlag)
x=x(:)';
desvio_x=std(x);
modes=zeros(size(x));
temp=zeros(size(x));
aux=zeros(size(x));
if desvio_x ==0
   modes = x;
   its = 0;
   disp('signal is constant\n')
   return
end
x=x/desvio_x;


iter=zeros(NR,round(log2(length(x))+5));

for i=1:NR %calculates the first mode
    xi=x+Nstd*modes_white_noise{i}(1,:)./std(modes_white_noise{i}(1,:));
    [temp, o, it]=emd(xi,'MAXMODES',1,'MAXITERATIONS',MaxIter);
    temp=temp(1,:);
    aux=aux+(xi-temp)/NR;
    iter(i,1)=it;
end;

modes= x-aux; %saves the first mode

fprintf(' Generated %d th IMF \n',size(modes,1));

medias = aux;
k=1;
aux=zeros(size(x));
es_imf = min(size(emd(medias(end,:),'MAXMODES',1,'MAXITERATIONS',MaxIter)));

while es_imf>1 %calculates the rest of the modes
    for i=1:NR
        tamanio=size(modes_white_noise{i}); 
        if tamanio(1)>=k+1 % Checks if number of any k+1th mode of IMF is available
            noise=modes_white_noise{i}(k+1,:);
            if SNRFlag == 2
                noise=noise/std(noise); %adjust the std of the noise
            end;
            noise=Nstd*noise; % Modulating noise amplitude
            try
                [temp,o,it]=emd(medias(end,:)+std(medias(end,:))*noise,'MAXMODES',1,'MAXITERATIONS',MaxIter);
            catch    
                it=0; disp('catch 1 '); disp(num2str(k))
                temp=emd(medias(end,:)+std(medias(end,:))*noise,'MAXMODES',1,'MAXITERATIONS',MaxIter);
            end;
            temp=temp(end,:);
        else
            try
                [temp, o, it]=emd(medias(end,:),'MAXMODES',1,'MAXITERATIONS',MaxIter);
            catch
                temp=emd(medias(end,:),'MAXMODES',1,'MAXITERATIONS',MaxIter);
                it=0; disp('catch 2 sin ruido')
            end;
            temp=temp(end,:);
        end;
        aux=aux+temp/NR;
    iter(i,k+1)=it;    
    end;
    modes=[modes;medias(end,:)-aux];
    
    fprintf(' Generated %d th IMF \n',size(modes,1));
    
    medias = [medias;aux];
    aux=zeros(size(x));
    k=k+1;
    es_imf = min(size(emd(medias(end,:),'MAXMODES',1,'MAXITERATIONS',MaxIter)));
end;
modes = [modes;medias(end,:)];
modes=modes*desvio_x;
its=iter;
