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

