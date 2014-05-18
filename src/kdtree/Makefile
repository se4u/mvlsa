#--------------------------------------------------------------------B----------#
#                                                                              #
#                              COMPILER FLAGS                                  #
#                                                                              #
# CPPONLY flag removes mex-portions (includes and MEX iterface function) to    #
# allow C++ independent testing                                                #
#------------------------------------------------------------------------------#
# --- RELEASE --- #
CXXFLAGS =  -O3 -Wall -fmessage-length=0 -D CPPONLY
# --- DEBUG   --- #
# CXXFLAGS =  -O3 -Wall -fmessage-length=0 -D CPPONLY -D DEBUG

MXX = /usr/local/bin/mex
MEXEXT = mexa64
MXXFLAGS = -I/usr/local/R2012a/extern/include
ARCHIVENAME = kdtree

#------------------------------------------------------------------------------#
#                                                                              #
#                              DEPENDENCY RULES                                # 
#                                                                              #
# USAGE OF RELEASE AND DEBUG MODE                                              #
# to compile a release file (without debug hooks and more efficient) just type #
# make. On the other hand, to enable debugging portions of the code (output)   #
# and add debugging links to the binary (needed for line by line execution)    #
# use :make debug"                                                             #
#                                                                              #
# EXPLANATION OF A RULE                                                        #
# anything (%) that terminates in .bin for which an explicit rule is not       #  
# available is made dependable on the file which has same name but .cpp        #
# extension. The compiler (CXX) with options (CXXFLAGS) is called on each of   #
# the elements that trigger the rule ($@, which is left side of ":") and       #
# produces an output with filename expressed by the "first" of elements from   #
# which it depends ($< or right side of ":")                                   #
#------------------------------------------------------------------------------#
HDRS = KDTree.h MyHeaps.h
TARGET =  kdtree_build kdtree_delete kdtree_nearest_neighbor kdtree_range_query \
		  kdtree_ball_query kdtree_k_nearest_neighbors
BINTARGET = $(TARGET:%=%.bin)
MEXTARGET = $(TARGET:%=%.$(MEXEXT))
### MANUALLY REDUCED TARGETS
# TARGET = kdtree_build
# MEXTARGET = kdtree_build.$(MEXEXT)

all:  $(MEXTARGET) $(BINTARGET)

debug: CXXFLAGS += -D DEBUG -g
debug: all

%.bin : %.cpp
	$(CXX) $(CXXFLAGS) -o $@ $<

%.mexa64 : %.cpp
	$(MXX) $(MXXFLAGS) -o $@ $<

clean:
	@rm -f $(OBJS) $(BINTARGET) $(MEXTARGET)
	@rm -rf  *.dSYM
	@rm -rf *.bin
	@echo "clean completed"
