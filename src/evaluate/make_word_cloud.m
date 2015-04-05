function fig_handle=make_word_cloud(a, b, w)

assert(length(a)==length(b));
assert(2*length(a)==length(w));

absmax=max([max(max(abs(a))), max(max(abs(b)))]);
a=a/absmax;
b=b/absmax;
fig_handle=figure();
if size(a,2)<2
    return
end    
xlim([-1 1]);
ylim([-1 1]);
for i = 1:length(a)
    text(a(i, 1), a(i, 2), w{2*(i-1)+1});
    text(b(i, 1), b(i, 2), w{2*i});
end