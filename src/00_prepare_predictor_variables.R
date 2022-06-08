#############################################################################
# Prepare predictor variable data for downstream processes such as climatic # 
# variable selection and redundancy analyses. Predictor variables include:  #
#   1. Climatic variables                                                   #
#   2. Population structure                                                 #
#   3. Geography (lat/longs)                                                #
#############################################################################

## Load packages ##
library(raster)
library(dplyr)
library(tidyr)

## Load environmental variable rasters ##
# 19 environmental variables (10m) and elevation were retrieved from 
# https://www.worldclim.org/data/bioclim.html 
bio_tifs <- stack("~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_1.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_2.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_3.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_4.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_5.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_6.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_7.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_8.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_9.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_10.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_11.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_12.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_13.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_14.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_15.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_16.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_17.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_18.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_bio_19.tif",
            "~/Dropbox/koala/01_data/worldclim/wc2.1_10m_elev.tif")

bio_names <- c("Annual Mean Temperature",
               "Mean Diurnal Range",
               "Isothermality",
               "Temperature Seasonality",
               "Max Temp of Warmest Month",
               "Max Temp of Coldest Month",
               "Temperature Annual Range",
               "Mean Temp of Wettest Quarter",
               "Mean Temp of Driest Quarter",
               "Mean Temp of Warmest Quarter",
               "Mean Temp of Coldest Quarter",
               "Annual Precipitation",
               "Precipitation of Wettest Month",
               "Precipitation of Driest Month",
               "Precipitation Seasonality",
               "Precipitation of Wettest Quarter",
               "Precipitation of Driest Quarter",
               "Precipitation of Warmest Quarter",
               "Precipitation of Coldest Quarter",
               "Elevation")

## Extract coordinates ##
# Load the koala metadata and extract the environmental variables that 
# correspond to all koala coordinates (lat/longs).
metadata <- 
  read.csv("~/GitHub/phasco_genes/data/metadata.csv") %>%
  dplyr::select(Sample = vcf_id, State, LGA, Latitude, Longitude)

# Convert metadata to SpatialPointsDataFrame and specify columns with coords
# and extract environmental variables per occurrence
metadata_sp <- metadata
coordinates(metadata_sp) = ~Longitude+Latitude
clim <- raster::extract(bio_tifs, metadata_sp, sp = T)

# A bit of wrangling to prepare for correct merging with other variables
clim <- 
  as.data.frame(clim@data) %>%
  select(-State, -LGA)
rownames(clim) <- clim$Sample
clim <- clim %>% select(-Sample)
names(clim) <- bio_names

## Load population structure information ##
pc_vec <- read.table("~/GitHub/phasco_genes/data/JG-308_samples_filtered_pca.eigenvec") %>% dplyr::select(-V2)
colnames(eigenvec) <- c("Sample", paste("PC", 1:(ncol(pc_vec)-1)))

# Read eigenvalues and set plot axes
pc_val <- scan("~/GitHub/phasco_genes/data/JG-308_samples_filtered_pca.eigenval")
#pc1_lab <- paste("PC1 (", round(unpruned_val[1], 2), "%)", sep = "")
#pc2_lab <- paste("PC2 (", round(unpruned_val[2], 2), "%)", sep = "")

## Merge all three types of data ## 
predictors <- 
  metadata %>%
  left_join(pc_vec %>% select(Sample, PC1, PC2, PC3, PC4, PC5, PC6), by = "Sample") %>%
  left_join(clim_scaled %>% mutate(Sample = rownames(.)), by = "Sample")

rownames(predictors) <- predictors$Sample
predictors <- predictors %>% select(-Sample)  

## Save file ##
saveRDS(predictors, "~/GitHub/phasco_genes/data/predictors.rds")
