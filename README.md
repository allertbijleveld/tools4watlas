
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tools4watlas <a href="https://krietsch.github.io/tools4watlas/g"><img src="man/figures/logo.png" align="right" height="300" alt="tools4watlas website" /></a>

<!-- badges: start -->

[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![License: GPL
v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![R-CMD-check](https://github.com/krietsch/tools4watlas/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/krietsch/tools4watlas/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/krietsch/tools4watlas/graph/badge.svg)](https://app.codecov.io/gh/krietsch/tools4watlas)
<!-- badges: end -->

The goal of `tools4watlas` is to provide tools for getting, processing
and plotting WATLAS tracking data. More information on the WATLAS
tracking system can be found in this article published in *Animal
Biotelemetry*: [WATLAS: high-throughput and real-time tracking of many
small birds in the Dutch Wadden
Sea](https://doi.org/10.1186/s40317-022-00307-w).

Visit <https://www.nioz.nl/watlas> to follow tracked birds in real time.

The package `tools4watlas` builds on the package
[`atlastools`](https://github.com/pratikunterwegs/atlastools). A
pipeline with coding examples for cleaning high-throughput tracking data
with `atlastools` is presented in this article in the *Journal of Animal
Ecology*: [A Guide to Pre-processing High-throughput Animal Tracking
Data](https://doi.org/10.1111/1365-2656.13610).

### **Documentation**

Basic workflows and on how to use `tools4watlas` can be found on the
[package website](https://krietsch.github.io/tools4watlas/).

**Vignettes**:

- [`Load and check data`](https://krietsch.github.io/tools4watlas/articles/load_and_check_data.html) -
  How to load and check data.

- [`Process data`](https://krietsch.github.io/tools4watlas/articles/process_data.html) -
  How to process data (calculate speed & angles, filter, smooth and add
  tidal data)

- [`Plot data`](https://krietsch.github.io/tools4watlas/articles/plot_data.html) -
  How to plot data.

- [`Basic workflows`](https://krietsch.github.io/tools4watlas/articles/basic_work_flows.html) -
  Allert’s basic WATLAS data workflow from `tools4watlas 1.0`.

### **Installation**

You can install the latest version of `tools4watlas` from
[GitHub](https://github.com/allertbijleveld/tools4watlas) with:

``` r
library(remotes)
install_github("allertbijleveld/tools4watlas")
```

### **Example**

``` r
library(tools4watlas)
library(ggplot2)

# Load example data
data <- data_example

# Create base map
bm = atl_create_bm(data, buffer = 800)

# Plot points and tracks
bm +
  geom_path(data = data, aes(x, y, colour = tag), alpha = 0.1, 
            show.legend = FALSE) +
  geom_point(data = data, aes(x, y, colour = tag), size = 0.5, 
             show.legend = FALSE)
```

<div class="figure">

<img src="man/figures/README-unnamed-chunk-3-1.png" alt="Example tracks" width="100%" />
<p class="caption">
Example tracks
</p>

</div>

### **Work in progress**

More examples of workflows aimed at processing, plotting and adding
environmental data to WATLAS tracking data are being prepared. If you
have a request, please contact [Allert
Bijleveld](mailto:allert.bijleveld@nioz.nl).

We are working on the following vignettes at the moment:

- Animate movement data
- Residency patch analysis

Other to do’s:

- Background map data of the whole Wadden Sea
- Choose nice example data

### **Acknowledgments**

Many people and organisations are involved in hosting the WATLAS
equipment, without whom WATLAS would not be possible. We therefore thank
Hoogheemraadschap Hollands Noorderkwartier, Koninklijke Nederlandse
Redding Maatschappij, Staatsbosbeheer, Marine Eco Analytics, Koninklijke
Luchtmacht, Het Posthuys (Vlieland), Natuurmonumenten, Wetterskip
Fryslan, Afsluitdijk Wadden Center, Vermilion, Rijkswaterstaat, Carl
Zuhorn, Lenze Hofstee and Lydia de Loos. We thank Natuurmonumenten for
access to Griend and using their facilities. Also, we thank Hein de
Vries, Klaas-Jan Daalder, Hendrik-Jan Lokhorst, Bram Fey, Wim-Jan Boon
from the RV Navicula and RV Stern, as well as the many other NIOZ staff
and volunteers that facilitated this work. We would particularly like to
thank Anita Koolhaas, Hinke and Cornelis Dekinga for their help with
building the receiver stations. We thank Jeras de Jonge, Martin Laan,
Sander Asjes, and Aris van der Vis for their technical help, and
Benjamin Gnep for persistently replacing broken LNA’s. Thanks to Marten
Tacoma for visualizing the tracking data in real time on
www.nioz.nl/watlas and Ingrid de Raad for help posting WATLAS-related
news. We also thank the Minerva Foundation and the Minerva Center for
Movement Ecology for supporting the development and maintenance of all
ATLAS systems, and for Yotam Orchan and Yoav Bartan for their most
valuable technical assistance.

<p align="middle">
<a href="https://www.nioz.nl/en">
<img src="man/figures/NIOZ_logo_ENG_RGB.png" align="middle" height="150" alt="nioz website" />
</a>
</p>
