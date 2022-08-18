for kk=1:16
    idx=find(snm==kk);
    alldata{2,kk}=psttrial(idx,:);
end

for jj=1:80
    eval(sprintf('sktms=unit_record_spike(2).negspcounts.cl1.iter%i;',jj))
    allspktms{jj}=fix(sktms*1000)+1;
    psttrial(jj,1:2000)=0;
    psttrial(jj,allspktms{jj}(find(allspktms{jj}<=2000)))=1;
end

for jj=1:305
    for kk=1:16
        nrep=size(all_animals_response_cell_arr{jj,kk},1);
        if nrep~=0
        respall(jj,kk,:)=mean(reshape(mean(all_animals_response_cell_arr{jj,kk},1),10,250));
    end
    end
end

for kk=1:4
    subplot(2,2,kk),plot(squeeze(mean(squeeze(respall(:,kk+3:4:12,:))))')
    hold on
    for jj=1:3
        plot([50+(jj-1)*gap(kk)+5*(jj-1) 50+(jj-1)*gap(kk)+5*(jj-1)],[0 .03],'r')
        plot([55+(jj-1)*gap(kk)+5*(jj-1) 55+(jj-1)*gap(kk)+5*(jj-1)],[0 .03],'g')
    end
end