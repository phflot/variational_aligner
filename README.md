# Toolbox for fast, variational 1D alignment

The code is written in Matlab and C++

## Download

Download the repository via
```
$ git clone https://github.com/phflot/variational_aligner.git
```

## ImageJ and Fiji Plugin

Our method for the alignment of linescans is also available as a plugin for ImageJ and Fiji [here](https://github.com/phflot/variational_aligner_IJ).

## Documentation and Usage

The Code can be compiled and installed with the ```set_path.m``` file. The file ```examples/align_noise.m``` reproduces the alignment of random data from our paper and can be referred to for the usage of the alignment functions. 

## Citation
If you use this code for your work, please cite
  
> P. Flotho, D. Thinnes, B. Kuhn, C. J. Roome, J. F. Vibell and D. J. Strauss, “Fast Variational Alignment of non-flat 1D Displacements for Applications in Neuroimaging” (bioRxiv), 2020. 

BibTeX entry
```
@article{floth20,
    author = {Flotho, P. and Thinnes, D. and Kuhn, B. and Roome, C. J. and Vibell, J. F. and Strauss, D. J.},
    title = {Fast Variational Alignment of non-flat 1D Displacements for Applications in Neuroimaging},
	elocation-id = {2020.06.27.151522},
	year = {2020},
	doi = {10.1101/2020.06.27.151522},
	publisher = {Cold Spring Harbor Laboratory},
	URL = {https://www.biorxiv.org/content/early/2020/06/29/2020.06.27.151522},
	eprint = {https://www.biorxiv.org/content/early/2020/06/29/2020.06.27.151522.full.pdf},
	journal = {bioRxiv}
}
```

If you use this work in the context of EP and ERP analysis, please additionally cite

> D. Thinnes, P. Flotho, F. I. Corona-Strauss, D. J. Strauss and J. F. Vibell, “Compensation of P300 Latency Jitter using fast variational 1D Displacement Estimation” (in preparation), 2020. 

BibTeX entry
```
@article{thinn20,
    author = {Thinnes, D. and Flotho, P. and Corona-Strauss, F. I. and Strauss, D. J. and Vibell, J. F.},
    title = {Compensation of P300 Latency Jitter using fast variational 1D Displacement Estimation},
    journal = {(in preparation)},
    year = {2020}
}
```