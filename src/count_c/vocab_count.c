// Simple tool to extract unigram counts
// Jeffrey Pennington (jpennin@stanford.edu)
// Modified by Pushpendre : September 2014.
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "commoncore.h"
#include "optparser.h"

#define MAX_STRING_LENGTH 1000

int verbose = 2; // 0, 1, or 2
long long min_count = 1; // min occurrences for inclusion in vocab
long long max_vocab = 0; // max_vocab = 0 for no limit
int lowercase = 0;
int replacerandomnumber=0;


/* Vocab frequency comparison; break ties alphabetically */
int CompareVocabTie(const void *a, const void *b) {
    long long c;
    if( (c = ((VOCAB *) b)->count - ((VOCAB *) a)->count) != 0) return ( c > 0 ? 1 : -1 );
    else return (scmp(((VOCAB *) a)->word,((VOCAB *) b)->word));
    
}

/* Vocab frequency comparison; no tie-breaker */
int CompareVocab(const void *a, const void *b) {
    long long c;
    if( (c = ((VOCAB *) b)->count - ((VOCAB *) a)->count) != 0) return ( c > 0 ? 1 : -1 );
    else return 0;
}

int get_counts() {
    long long i = 0, j = 0, vocab_size = 12500;
    char format[20];
    char str[MAX_STRING_LENGTH + 1];
    HASHREC **vocab_hash = inithashtable();
    HASHREC *htmp;
    VOCAB *vocab;
    FILE *fid = stdin;
    
    fprintf(stderr, "BUILDING VOCABULARY\n");
    if(verbose > 1) fprintf(stderr, "Processed %lld tokens.", i);
    sprintf(format,"%%%ds",MAX_STRING_LENGTH);
    while(fscanf(fid, format, str) != EOF){
      if(lowercase == 1) makelowercase(str);
      if(replacerandomnumber == 1) replacerandomnumber_fn(str);
      hashinsert(vocab_hash, str);
    }
    if(verbose > 1) fprintf(stderr, "\033[0GProcessed %lld tokens.\n", i);
    vocab = malloc(sizeof(VOCAB) * vocab_size);
    for(i = 0; i < TSIZE; i++) { // Migrate vocab to array
        htmp = vocab_hash[i];
        while (htmp != NULL) {
            vocab[j].word = htmp->word;
            vocab[j].count = htmp->count;
            j++;
            if(j>=vocab_size) {
                vocab_size += 2500;
                vocab = (VOCAB *)realloc(vocab, sizeof(VOCAB) * vocab_size);
            }
            htmp = htmp->next;
        }
    }
    if(verbose > 1) fprintf(stderr, "Counted %lld unique words.\n", j);
    if(max_vocab > 0 && max_vocab < j)
        // If the vocabulary exceeds limit, first sort full vocab by frequency without alphabetical tie-breaks.
        // This results in pseudo-random ordering for words with same frequency, so that when truncated, the words span whole alphabet
        qsort(vocab, j, sizeof(VOCAB), CompareVocab);
    else max_vocab = j;
    qsort(vocab, max_vocab, sizeof(VOCAB), CompareVocabTie); //After (possibly) truncating, sort (possibly again), breaking ties alphabetically
    
    for(i = 0; i < max_vocab; i++) {
        if(vocab[i].count < min_count) { // If a minimum frequency cutoff exists, truncate vocabulary
            if(verbose > 0) fprintf(stderr, "Truncating vocabulary at min count %lld.\n",min_count);
            break;
        }
        printf("%s %lld\n",vocab[i].word,vocab[i].count);
    }
    if(i == max_vocab && max_vocab < j) if(verbose > 0) fprintf(stderr, "Truncating vocabulary at size %lld.\n", max_vocab);
    fprintf(stderr, "Using vocabulary of size %lld.\n\n", i);
    return 0;
}


int main(int argc, char **argv) {
    int i;
    if (argc == 1) {
        printf("Simple tool to extract unigram counts\n");
        printf("Author: Jeffrey Pennington (jpennin@stanford.edu)\n\n");
        printf("Usage options:\n");
        printf("\t-verbose <int>\n");
        printf("\t\tSet verbosity: 0, 1, or 2 (default)\n");
        printf("\t-max-vocab <int>\n");
        printf("\t\tUpper bound on vocabulary size, i.e. keep the <int> most frequent words. The minimum frequency words are randomly sampled so as to obtain an even distribution over the alphabet.\n");
        printf("\t-min-count <int>\n");
        printf("\t\tLower limit such that words which occur fewer than <int> times are discarded.\n");
	printf("\t-lowercase <int>\n");
	printf("\t\tLower case the input strings or not before processing: 1 or 0 (default)\n");
	printf("\t--replacerandomnumber <int>\n");
	printf("\t\tReplace all words that have 3 'digits' or more and are 5 character or longer by the word <<N>>\n");
        printf("\nExample usage:\n");
        printf("./vocab_count -verbose 2 -max-vocab 100000 -min-count 10 < corpus.txt > vocab.txt\n");
        return 0;
    }
    
    if ((i = find_arg((char *)"-verbose", argc, argv)) > 0) verbose = atoi(argv[i + 1]);
    if ((i = find_arg((char *)"-max-vocab", argc, argv)) > 0) max_vocab = atoll(argv[i + 1]);
    if ((i = find_arg((char *)"-min-count", argc, argv)) > 0) min_count = atoll(argv[i + 1]);
    if ((i = find_arg((char *)"-lowercase", argc, argv)) > 0) lowercase = atoi(argv[i + 1]);
    if ((i = find_arg((char *)"-replacerandomnumber", argc, argv)) > 0) replacerandomnumber = atoi(argv[i + 1]);
    return get_counts();
}


