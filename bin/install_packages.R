#!/usr/bin/Rscript

# Set CRAN mirror
r = getOption("repos")
r["CRAN"] = "https://cran.csiro.au/"
options(repos = r)

# Data wrangling
install.packages("readxl")
install.packages("dplyr")
install.packages("tidyr")
install.packages("forcats")

# Data visualisation
install.packages("ggplot2")
install.packages("viridis")
install.packages("cowplot")
install.packages("ggnewscale")

# Spatial/maps (don't need these for now)
#install.packages("ozmaps")
#install.packages("sf")
#install.packages("raster")

# Statistical analyses
install.packages("vegan")
install.packages("psych")
