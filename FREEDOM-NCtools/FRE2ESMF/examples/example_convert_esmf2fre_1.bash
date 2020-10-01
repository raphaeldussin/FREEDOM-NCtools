#!/bin/bash

# NB: this needs to be run on PP/AN because of the fregrid_parallel section

export PATH="/net2/rnd/anaconda3/envs/repro/bin:$PATH"

# some directories with grids and test data:
static1deg=/archive/Raphael.Dussin/xanadu_esm4_20190304_mom6_2019.12.16/OM4p125_JRA55do1.4_mle3d_cycle3/gfdl.ncrc4-intel16-prod/pp/ocean_annual_z_1x1deg/ocean_annual_z_1x1deg.static.nc
gridspec=/archive/Raphael.Dussin/datasets/OM4p125/OM4p125_grid_20200213_merged_bathy_unpacked
annuald2=/archive/Raphael.Dussin/xanadu_esm4_20190304_mom6_2019.12.16/OM4p125_JRA55do1.4_mle3d_cycle3/gfdl.ncrc4-intel16-prod/pp/ocean_annual_z_d2/av/annual_1yr

# create ESMF-style regridding weights
python ./create_esmf_weights_OM4p125_d2_1x1deg.py

# convert to FREGRID-style
../esmf2fre --nx_src 1440 --ny_src 1120 --nx_dst 360 --ny_dst 180 --areafile $static1deg conservative_normed_1120x1440_180x360.nc -o regrid_weights_ESMF2FREGRID.nc

module load fre/bronx-18
module load mpich2

# regrid test data with vanilla fregrid
mpirun -n 4 fregrid_parallel --input_mosaic $gridspec/ocean_mosaic_d2.nc --input_file $annuald2/ocean_annual_z_d2.2018.ann.nc --scalar_field thetao --nlon 360 --nlat 180 --output_file temp_regridded_fre.nc

# regrid using fregrid with the weights we converted from ESMF
fregrid --input_mosaic $gridspec/ocean_mosaic_d2.nc --input_file $annuald2/ocean_annual_z_d2.2018.ann.nc --scalar_field thetao --nlon 360 --nlat 180 --remap_file regrid_weights_ESMF2FREGRID.nc --output_file temp_regridded.nc

# check the results
module load nco
ncdiff temp_regridded.nc temp_regridded_fre.nc -o diff_esmf_vs_fregrid_algo.nc
