function x=isnetav
disp('-->> Checking status internet connection');
[~,b]=dos('ping -n 1 www.taobao.com');
n=strfind(b,'Lost');
n1=b(n+7);
if(n1=='0')
    x=1;
else
    x=0;
end
end
