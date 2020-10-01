#!/net2/rnd/anaconda3/envs/repro/bin/python

import xesmf
import xarray as xr
import numpy as np

gridspec = '/archive/Raphael.Dussin/datasets/OM4p125/OM4p125_grid_20200213_merged_bathy_unpacked/'

ppstatic = '/archive/Raphael.Dussin/xanadu_esm4_20190304_mom6_2019.12.16/OM4p125_JRA55do1.4_mle3d_cycle3/gfdl.ncrc4-intel16-prod/pp/ocean_annual_z_1x1deg/'

static_src = xr.open_dataset(gridspec + 'ocean_hgrid_d2.nc')
static_src2 = xr.open_dataset(gridspec + 'ocean_static_d2.nc')

static_src['lon'] = xr.DataArray(static_src['x'].values[1::2, 1::2].copy(), dims=('ny2','nx2'))
static_src['lon_b'] = xr.DataArray(static_src['x'].values[0::2,0::2].copy(), dims=('ny2p1','nx2p1'))
static_src['lat'] = xr.DataArray(static_src['y'].values[1::2,1::2].copy(), dims=('ny2','nx2'))
static_src['lat_b'] = xr.DataArray(static_src['y'].values[0::2,0::2].copy(), dims=('ny2p1','nx2p1'))
static_src['area2'] = xr.DataArray(static_src['area'].values[1::2,1::2].copy(), dims=('ny2','nx2'))
static_src['mask'] = static_src2['wet'].rename({'yh':'ny2', 'xh':'nx2'})

static_dst = xr.open_dataset(ppstatic + 'ocean_annual_z_1x1deg.static.nc')

static_dst['lon_b'] = xr.DataArray(np.arange(0,360+1), dims=('lonp1'))
static_dst['lat_b'] = xr.DataArray(np.arange(-90,90+1), dims=('latp1'))
static_dst['mask'] = static_dst['wet'].fillna(0.)

regrid = xesmf.Regridder(static_src, static_dst,
                         method='conservative_normed',
                         periodic=True)

regrid.to_netcdf('conservative_normed_1120x1440_180x360.nc')
