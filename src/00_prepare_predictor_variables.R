#############################################################################
# Prepare predictor variable data for downstream processes such as climatic # 
# variable selection and redundancy analyses. Predictor variables include:  #
#   1. Climatic variables                                                   #
#   2. Population structure                                                 #
#   3. Geography (lat/longs)                                                #
#############################################################################

## Load packages ##
library(dplyr)
library(tidyr)

## Load environmental variables ##
# 10 environmental variables based on Lott et al. (2022) retrieved from ALA
clim <- 
  read.table("~/GitHub/phasco_genes/example/records-2022-06-08.tsv", sep = "\t", header = T, check.names = F) %>%
  select(Latitude = decimalLatitude, Longitude = decimalLongitude, 
         temp_annMaxMean = `Temperature - annual max mean`, 
         temp_annMinMean = `Temperature - annual min mean`,
         temp_annRange = `Temperature - annual range`,
         rain_annMean = `Precipitation - annual mean`, 
         solar_annMean = `Radiation - annual mean (Bio20)`, 
         elevation = Elevation,
         veg_index = `Enhanced Vegetation Index (2012-03-05)`,
         soil_moisture_annMean = `Moisture Index - annual mean (Bio28)`,
         soil_nutrients = `Nutrient status`,
         soil_ph = `Ph - soil`)

# Test for correlations between climate variables

## Extract coordinates ##
# Load the koala metadata and extract the environmental variables that 
# correspond to all koala coordinates (lat/longs).
coords <- read.csv("~/Dropbox/koala/01_data/Koala_Metadata.csv")

## Load population structure information ##
pc_vec <- read.table("~/GitHub/phasco_genes/data/JG-308_samples_filtered_pca.eigenvec") %>% dplyr::select(-V2)
colnames(pc_vec) <- c("vcf.ID", paste("PC", 1:(ncol(pc_vec)-1), sep = ""))

# Read eigenvalues and set plot axes
#pc_val <- scan("~/GitHub/phasco_genes/data/JG-308_samples_filtered_pca.eigenval")
#pc1_lab <- paste("PC1 (", round(unpruned_val[1], 2), "%)", sep = "")
#pc2_lab <- paste("PC2 (", round(unpruned_val[2], 2), "%)", sep = "")

## Merge all three types of data ## 
predictors <- 
  coords %>% filter(vcf.ID != "") %>%
  left_join(pc_vec %>% select(vcf.ID, PC1, PC2, PC3, PC4, PC5, PC6), by = "vcf.ID") %>%
  left_join(clim, by = c("Latitude", "Longitude")) %>%
  distinct()

rownames(predictors) <- predictors$Sample
predictors <- predictors %>% select(-Koala.ID)  

## Save file ##
saveRDS(predictors, "~/GitHub/phasco_genes/data/predictors.rds")
rm(clim, coords, pc_vec)
