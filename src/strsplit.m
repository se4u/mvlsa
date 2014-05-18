function tokens=strsplit(s, d)
tokens={};
j=1;
t=1;
for i=1:length(s)
    if s(i)==d
        tokens{t}=s(j:i-1);
        t=t+1;
        j=i+1;
    end
end
tokens{t}=s(j:i);