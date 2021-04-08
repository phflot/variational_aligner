# Toolbox for fast, variational 1D alignment

The code is written in Matlab and C++. The preprint of our paper can be found on [bioRxiv](https://www.biorxiv.org/content/10.1101/2020.06.27.151522v1) and the project website [here](https://phflot.github.io/variational_aligner/).

## Download

Download the repository via
```
$ git clone https://github.com/phflot/variational_aligner.git
```

## ImageJ and Fiji Plugin

An ImageJ and Fiji plugin for the alignment of linescans is available [here](https://github.com/phflot/variational_aligner_IJ).

## Documentation and Usage

The Code can be compiled and installed with the ```set_path.m``` file. The file ```examples/align_noise.m``` reproduces the alignment of random data from our paper and can be referred to for the usage of the alignment functions. The script ```examples/linescan_example.m``` demonstrates the alignment of 2D multichannel linescan data. 

## Citation
If you use this code for your work, please cite
  
> Flotho, P., Thinnes, D., Kuhn, B., Roome, C. J., Vibell, J. F., & Strauss, D. J. (2021). Fast variational alignment of non-flat 1D displacements for applications in neuroimaging. Journal of Neuroscience Methods, 353, 109076.

BibTeX entry
```
@article{floth21,
  title={Fast variational alignment of non-flat 1D displacements for applications in neuroimaging},
  author={Flotho, Philipp and Thinnes, David and Kuhn, Bernd and Roome, Christopher J and Vibell, Jonas F and Strauss, Daniel J},
  journal = {Journal of Neuroscience Methods},
  volume = {353},
  pages = {109076},
  year = {2021},
  issn = {0165-0270},
  doi = {https://doi.org/10.1016/j.jneumeth.2021.109076},
  url = {https://www.sciencedirect.com/science/article/pii/S016502702100011X},
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