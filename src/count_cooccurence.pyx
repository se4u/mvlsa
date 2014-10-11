cimport cython
from libc.stdio cimport *
from libcpp.unordered_map cimport unordered_map

cdef extern from "stdio.h":
    FILE *fopen(const char *, const char *)
    int fclose(FILE *)
    ssize_t getline(char **, size_t *, FILE *)

def read_file(filename):
    filename_byte_string = filename.encode("UTF-8")
    cdef char* fname = filename_byte_string
    cdef FILE* cfile = fopen(fname, "rb")
    if cfile == NULL:
        raise FileNotFoundError(2, "No such file or directory: '%s'" % filename)
    cdef char * line = NULL
    cdef size_t l = 0
    cdef ssize_t read
    while True:
        read = getline(&line, &l, cfile)
        if read == -1: break
        #yield line

    fclose(cfile)
    return []

def count(vocab_fn, text_fn, window_size, target_fn, bos_to_maintain):
    cdef unordered_map[int, int] vocab
