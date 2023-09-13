function x=isnetav
disp('-->> Checking status internet connection');
[~,b]=dos('ping -n 1 www.github.io');
n=strfind(b,'Lost');
n1=b(n+7);
if(n1=='0')
    x=1;
    disp('-->> The internet connection is good');
else
    x=0;
    disp('-->> There some problems with the insternet connection');
end
end
