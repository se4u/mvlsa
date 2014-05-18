#include <mex.h>
#include <algorithm>
#include <vector>

using namespace std;

class IndexCompare{
private:
    const double* _data;
public:
    IndexCompare(const double* data):_data(data)
    {}
    
    bool operator()(int i, int j) const
    {
        return _data[i] < _data[j];
    }
};

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    double* data = mxGetPr(prhs[0]);
    int d = mxGetM(prhs[0]);
    int n = mxGetN(prhs[0]);    
    int k = (int)(mxGetScalar(prhs[1]));
        
    plhs[0] = mxCreateDoubleMatrix(k, n, mxREAL);    
    plhs[1] = mxCreateDoubleMatrix(k, n, mxREAL);
    double* values = mxGetPr(plhs[0]);
    double* indices = mxGetPr(plhs[1]);
    
    vector<int> tmp(d);    
    
    for (int i = 0; i < n; ++i){
        for (int j = 0; j < d; ++j) 
            tmp[j] = j;
    
//         nth_element(tmp.begin(), tmp.begin()+k, tmp.end(), IndexCompare(data)); without order
        partial_sort(tmp.begin(), tmp.begin()+k, tmp.end(), IndexCompare(data));

        for (int j = 0; j < k; ++j){
            values[j] = data[tmp[j]];
            indices[j] = tmp[j]+1;  // transform from c index (0:k-1) to matlab index (1:k)
        }
        
        data += d;
        values += k;
        indices += k;
    }
}