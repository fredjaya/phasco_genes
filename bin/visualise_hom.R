#!/usr/bin/Rscript

# Testing
#setwd("/home/fredjaya/GitHub/phasco_genes/")
#path_coords <- "data/metadata.csv"
#path_het <- "data/aqp4.het"
#str_gene <- "AQP4"

#CLI 
args <- commandArgs(trailingOnly = T)
path_metadata <- args[1]
path_het <- args[2]
str_gene <- args[3]

#paste("args0_metadata", path_metadata)
#paste("args1_het", path_het)
#paste("args2_gene", str_gene)

# Load libraries
library(dplyr)
library(tidyr)
library(ggplot2)
library(readxl)
library(ozmaps) # how to in conda
library(sf)
library(viridis)
library(cowplot)

# Set ggplot theme
theme_fj <- theme_minimal() +
  theme(panel.grid = element_blank(),
        panel.border = element_rect(fill = NA, colour = 'grey'))

# Read sample coordinates, state and LGA information
metadata <- read.csv("data/metadata.csv")

# Prep vcftools --het output
het <- 
  read.table(path_het, header = T) %>%
  left_join(metadata, by = c(INDV = 'vcf_id')) %>%
  rename(OHOM = `O.HOM.`, EHOM = `E.HOM.`)

# Create maps for OHOM, EHOM and F
ohom_map <- 
  ggplot() +
  geom_sf(data = ozmap_data("states"), size = 0.2, fill = NA, colour = 'black') +
  geom_point(data = het, aes(x = Longitude, y = Latitude, color = OHOM), size = 1, alpha = 0.7) +
  coord_sf(xlim = c(144, 155), ylim = c(-25, -40)) +
  scale_colour_viridis() +
  theme_fj +
  labs(colour = "Observed homozygosity") +
  theme(legend.position = "top") +
  guides(colour = guide_colorbar(title.position = "top"))

ehom_map <- 
  ggplot() +
  geom_sf(data = ozmap_data("states"), size = 0.2, fill = NA, colour = 'black') +
  geom_point(data = het, aes(x = Longitude, y = Latitude, color = EHOM), size = 1, alpha = 0.7) +
  coord_sf(xlim = c(144, 155), ylim = c(-25, -40)) +
  scale_colour_viridis() +
  theme_fj +
  labs(colour = "Expected homozygosity") +
  theme(legend.position = "top") +
  guides(colour = guide_colorbar(title.position = "top"))

F_map <- 
  ggplot() +
  geom_sf(data = ozmap_data("states"), size = 0.2, fill = NA, colour = 'black') +
  geom_point(data = het, aes(x = Longitude, y = Latitude, color = `F`), size = 1, alpha = 0.7) +
  coord_sf(xlim = c(144, 155), ylim = c(-25, -40)) +
  scale_colour_viridis() +
  theme_fj +
  labs(colour = "Inbreeding Coefficient (F)") +
  theme(legend.position = "top") +
  guides(colour = guide_colorbar(title.position = "top"))

# Create plot and save
p1 <- plot_grid(ohom_map, ehom_map, F_map, nrow = 1, labels = str_gene)
p1_filename <- paste(str_gene, "_het.png", sep = "")
ggsave(p1_filename, p1, width = 8, height = 5, scale = 1.5)