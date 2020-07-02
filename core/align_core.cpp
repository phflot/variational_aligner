// Date     : 17.07.2019
// Author   : Philipp Flotho
// Copyright 2020 by Philipp Flotho, All rights reserved.

#include <mex.h>
#include <math.h>
#include <stdlib.h>

/* input arguments */
#define FY 0
#define FYY 1
#define FREF_Y 2
#define V 3
#define ALPHA 4
#define ITERATIONS 5
#define UPDATE_LAG 6
#define VERBOSE 7
#define A_DATA 8
#define A_SMOOTH 9
#define HX 10
#define HY 11
#define ORDER 12
#define WEIGHT 13

/* output arguments */
#define DV 0

/* constants */
#define OMEGA 1.95


void nonlinearity_smoothness(double* psi_smooth, double *dv, const double *v, double a, int ny, double hx, double hy, int i);
void nonlinearity(double *psi,
	const double *fy, const double *fyy, const double* f_ref, double *dv, int nx, int ny,
	int n_channels, const double *a, int i);

void mexFunction(int nlhs, mxArray* plhs[],
	int nrhs, const mxArray* prhs[]) {

	/* input arguments */
	double hx;
	double hy;
	int verbose; /* if 0 no terminal output */

	/* checking number of inputs */
	if (nrhs < 10)
		mexErrMsgIdAndTxt("OF:input_parameters",
			"at least 9 inputs required.");


	/* setting inputs */
	const double* fy = mxGetPr(prhs[FY]);
	const double* fyy = mxGetPr(prhs[FYY]);
	const double* f_ref_y = mxGetPr(prhs[FREF_Y]);

	const double* weight = mxGetPr(prhs[WEIGHT]);

	const mxArray *v_mat = prhs[V];

	const double* v = mxGetPr(prhs[V]);
	mwSize ny = mxGetM(prhs[V]);
	mwSize nx = mxGetN(prhs[V]);

	mwSize n_channels;	
	if (mxGetNumberOfDimensions(prhs[FY]) < 3) {
		n_channels = 1;
	}
	else {
		n_channels = mxGetDimensions(prhs[FY])[2];
		// printf("Numbers of dimensions = %i\n", n_channels);
	}

	const double* a_data = mxGetPr(prhs[A_DATA]);
	const size_t* order = (size_t*)mxGetPr(prhs[ORDER]);
	const double alpha = mxGetScalar (prhs[ALPHA]);
    double a_smooth = mxGetScalar(prhs[A_SMOOTH]);
	int iterations = (int)mxGetScalar(prhs[ITERATIONS]);
	int update_lag = (int)mxGetScalar(prhs[UPDATE_LAG]);

	hx = mxGetScalar(prhs[HX]);
	hy = mxGetScalar(prhs[HY]);

	verbose = (int) mxGetScalar(prhs[VERBOSE]);

	/* checking number of outputs */
	if (nlhs != 1) 
		mexErrMsgIdAndTxt("OF:output_parameters",
			"One output required.");
    
	mxArray* dv_mat = mxCreateDoubleMatrix(ny, nx, mxREAL);

	plhs[DV] = dv_mat;

	double* dv = mxGetPr(dv_mat);

	if (verbose) {
		printf("Starting OF calculation with alpha = %f and %i iterations and update lag of %i. /n",
			alpha, iterations, update_lag);
	}

	mxArray* psi_mat = mxCreateNumericArray(
		mxGetNumberOfDimensions(prhs[FY]), 
		mxGetDimensions(prhs[FY]), mxDOUBLE_CLASS, mxREAL);
	double *psi = mxGetPr(psi_mat);
	mxArray* psi_smooth_mat = mxCreateDoubleMatrix(ny, nx, mxREAL);
	double* psi_smooth = mxGetPr(psi_smooth_mat);

	for (int i = 0; i < nx * ny; i++) {
		dv[i] = 0;
		psi_smooth[i] = 1;
		psi[i] = 1;
	}

	double w_down, w_up, w_sum;
	
	int idx, idx_up, idx_down;
	
	double denom_u, denom_v, num_u, num_v;
	// const double weight = 1.0 / (double)n_channels;

	int nd_idx, idx_left, i;
	int ref_idx;
	int iteration_counter = 0;
    
	for (int it = 1; it < nx - 1; it++) {
		iteration_counter = 0;
		i = it; //  order[it];
		
		for (int j = 1; j < ny - 1; j++) {
			idx = j + i * ny;
			//idx_left = j + (order[it-1]) * ny;
			idx_left = j + (i - 1) * ny;


			dv[idx] = dv[idx_left];
		}


		while (iteration_counter++ < iterations) {
        
			if (iteration_counter % update_lag == 0) {
				nonlinearity(psi, fy, fyy, f_ref_y, dv, nx, ny, n_channels, a_data, i);
				nonlinearity_smoothness(psi_smooth, dv, v, a_smooth, ny, hx, hy, i);
			}

            for (int j = 1; j < ny - 1; j++) {

				idx = j + i * ny;
				idx_down = (j + 1) + i * ny;
				idx_up = (j - 1) + i * ny;

				w_down =  j < ny - 2 ? 
                    0.5 * (psi_smooth[idx]  + psi_smooth[idx_down]) * alpha / (hy * hy) : 0;
				w_up =	  j > 1      ? 
                    0.5 * (psi_smooth[idx]  + psi_smooth[idx_up]) * alpha / (hy * hy) : 0;
				w_sum = w_up + w_down;

				denom_u = 0;
				denom_v = 0;
				num_u = 0;
				num_v = 0;
				for (int k = 0; k < n_channels; k++) {
					nd_idx = j + i * ny + k * (nx * ny);
					ref_idx = j + k * ny;

					num_v -= weight[nd_idx] * psi[nd_idx] * (fy[nd_idx] * fyy[nd_idx] - f_ref_y[ref_idx] * fyy[nd_idx]);

					denom_v += weight[nd_idx] * psi[nd_idx] * fyy[nd_idx] * fyy[nd_idx];
				}

				denom_v += w_sum;

				dv[idx] = (1 - OMEGA) * dv[idx] +
					OMEGA * (num_v
						+ w_up * (v[idx_up] + dv[idx_up])
						+ w_down * (v[idx_down] + dv[idx_down])
						- w_sum * (v[idx]))
					/ (denom_v);
			}
		}
	}
	mxDestroyArray(psi_smooth_mat);
	mxDestroyArray(psi_mat);
}

mxArray* p_sum(const mxArray* m1, const mxArray* m2) {
	mxArray* out[1];
	mxArray* tmp1 = mxDuplicateArray(m1);
	mxArray* tmp2 = mxDuplicateArray(m2);
	mxArray* rhs[2] = { tmp1, tmp2 };
	mexCallMATLAB(1, out, 2, rhs, "+");
	mxDestroyArray(tmp1);
	mxDestroyArray(tmp2);
	return out[0];
}

void nonlinearity_smoothness(double* psi_smooth, double *dv, 
	const double *v, double a, int ny, double hx, double hy, int i) {

	double eps = 0.00001;

	double vy;
	
	double tmp;
	int idx, idx_up, idx_down;
	for (int j = 1; j < ny - 1; j++) {
		idx = j + i * ny;
		idx_up = (j - 1) + i * ny;
		idx_down = (j + 1) + i * ny;

		vy = (1 / (2 * hy)) * (v[idx_down] + dv[idx_down] - v[idx_up] - dv[idx_up]);

		tmp = vy * vy;
		tmp = tmp < 0 ? 0 : tmp;
		psi_smooth[idx] = a * pow(tmp + eps, a - 1);
	}
}

void nonlinearity(double *psi,
	const double *fy, const double *fyy, const double* f_ref, double *dv, 
	int nx, int ny, int n_channels, const double* a, int i) {
	
	double eps = 0.00001;
	double tmp;
	
	int nd_idx, ref_idx, idx;
	for (int k = 0; k < n_channels; k++) {
			for (int j = 0; j < ny; j++) {
				ref_idx = j + k * ny;
				idx = j + i * ny;
				nd_idx = idx + k * (nx * ny);

				tmp = fy[nd_idx] + fyy[nd_idx] * dv[idx] - f_ref[ref_idx];
				tmp = tmp < 0 ? 0 : tmp * tmp;
				psi[nd_idx] = a[k] * pow(tmp + eps, a[k] - 1);
			}
	}
}