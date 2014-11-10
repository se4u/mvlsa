function data = get_msr_data()
msr_qf = getenv('MSR_QUESTIONS');
msr_af = getenv('MSR_ANSWERS');
questions=textscan(fopen(msr_qf), '%s', 'Delimiter', '\n');
questions=questions{1};
answers=textscan(fopen(msr_af), '%s', 'Delimiter', '\n');
answers=answers{1};
data={};
for i=1:length(answers)
    options=questions(i*5-4:i*5);
    correct_option=get_correct_option(strsplit(answers{i}, ' '));
    [question, opt_idx]=get_question(strsplit(options{1}, ' '));
    for j=1:5
        o=strsplit(options{j}, ' ');
        o=o{find_index_of_optional_word(o)};
        options{j}=o(2:end-1);
    end
    data=[data; {question, opt_idx, options, correct_option}];
end
