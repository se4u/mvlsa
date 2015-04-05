import sys
fr_word=dict((e.strip().split()[0], i) for i, e in enumerate(open(sys.argv[1], "rb")))
en_word=dict((e.strip().split()[0], i) for i, e in enumerate(open(sys.argv[2], "rb")))
alignment_filename=sys.argv[3]
out_mat_filename=sys.argv[4]
from Cython.Build import cythonize
from distutils.extension import Extension
import pyximport
pyximport.install(setup_args=dict(ext_modules=
                                  cythonize([ Extension("create_sparse_alignmatCython",
                                                        ['create_sparse_alignmatCython.pyx'],
                                                        extra_compile_args=["-O3"])])))
from create_sparse_alignmatCython import main
main(fr_word, en_word, alignment_filename, out_mat_filename)


