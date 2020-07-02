 # Toolbox for fast, variational 1D alignment

## The code is written in Matlab and C++
===============================================================================================

Example code for the usage of the variational aligner in the context of Event Related Potential.

 author: David Thinnes
 date:  06/27/2020
 function name: [Reg,V] = Var_Alignment(inputImage,method,iter_ref,Fs)

 description:
 the function corrects the latency shift of evoked potentials by choosing a stable
 reference and realigning the 2D Sweep Image of the data.

 it performs 1 dimensional alignment according to the selected reference.
 method: cross correlation, mean of all image rows 
 default: 'Mean'


 ## input: 
===============================================================================================
 type :        input Image (take the Sweep matrix, Single trial matrix as input Image)
 method :      'Cross', 'Mean'                      
 iter_ref :    iterative refinement
 Fs :          Sampling Frequency of the signal

 ## output
===============================================================================================
 Reg =         the realigned image after image registration
   V =         the displacement field of all pixels/samples

 ## Citation
===============================================================================================

If you use this code for your work, please cite
  
> P. Flotho, D. Thinnes, J. F. Vibell and D. J. Strauss, â€œFast Variational Method for the Estimation and Quantization of non-flat Displacements in 1D Signals with Applications in Neuroimagingâ€? (in preparation), 2020. 

BibTeX entry
```
@article{floth20,
    author = {Flotho, P. and Thinnes, D. and Vibell, J. F. and Strauss, D. J.},
    title = {Fast Variational Method for the Estimation and Quantization 
             of non-flat Displacements in 1D Signals with Applications in Neuroimaging},
    journal = {(in preparation)},
    year = {2020}
}
```

If you use this work in the context of EP and ERP analysis, please additionally cite

> D. Thinnes, P. Flotho, F. I. Corona-Strauss, D. J. Strauss and J. F. Vibell, â€œCompensation of P300 Latency Jitter using fast variational 1D Displacement Estimationâ€? (in preparation), 2020. 

BibTeX entry
```
@article{thinn20,
    author = {Thinnes, D. and Flotho, P. and Corona-Strauss, F. I. and Strauss, D. J. and Vibell, J. F.},
    title = {Compensation of P300 Latency Jitter using fast variational 1D Displacement Estimation},
    journal = {(in preparation)},
    year = {2020}
}
```

## example ERP
===============================================================================================
The example ERP is a shifted version of the example ERP c1+c2+c3 from the ERP toolbox artificial data for filtering
see: https://erpinfo.org/artificial-data-for-filtering  ==> fake_data.erp

## The functions BM3D and estimate_noise come from:
===============================================================================================

-------------------------------------------------------------------

  BM3D demo software for image/video restoration and enhancement  
                   Public release v1.9 (26 August 2011) 

-------------------------------------------------------------------

Copyright (c) 2006-2011 Tampere University of Technology. 
All rights reserved.
This work should be used for nonprofit purposes only.

Authors:                     Kostadin Dabov
                             Aram Danieyan
                             Alessandro Foi


BM3D web page:               http://www.cs.tut.fi/~foi/GCF-BM3D


K. Dabov, A. Foi, V. Katkovnik, and K. Egiazarian, "Image 
denoising by sparse 3D transform-domain collaborative filtering," 
IEEE Trans. Image Process., vol. 16, no. 8, August 2007.
