global filename; % The name of file that contains the embeddings 
global columns; % the number of columns to skip while reading the
                % input file
global dimensions_after_cca; % The number of columns to keep after
                             % CCA

lib_util % Include the following
[view1, view2, words] = prepare_input(filename, columns); % Prepare Input
view1_n = randn(size(view1));
view2_n = randn(size(view2));
[A,B,~,U,V,stats]=canoncorr(view1_n, view2_n);
if usejava('dektop')
    show_orthogonality(U, V); pause
    show_correlation(U); pause
    show_correlation(V); pause
end
f_measure_orig = f_measure(view1_n, view2_n); 
U=U(:, 1:dimension_after_cca);
V=V(:, 1:dimension_after_cca);
saveas(make_word_cloud(U, V, words), 'random_embedding_cca.png');
f_measure_cca = f_measure(U, V);
disp([f_measure_cca  f_measure_orig]);
