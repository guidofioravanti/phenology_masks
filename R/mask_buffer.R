rm(list=objects())
library("terra")
library("purrr")
library("rworldmap")
library("sf")
library("dplyr")
#library("furrr")

#plan(strategy=multicore,workers=2)

rworldmap::countriesCoarse->mondo
cleangeo::clgeo_Clean(mondo)->mondo
st_as_sf(mondo) %>%
  filter(GEOUNIT=="Spain")->mondo

vect(mondo)->vmondo

list.files(pattern="^.+tif")->ffile
c(ffile[36],ffile,ffile[1])->ffile2

numeroFile<-length(ffile2)
#numeroFile<-3

purrr::map(2:numeroFile,.f=function(.qualeFile){ #
  
  rast(ffile2[.qualeFile])->grid_on_the_right
  rast(ffile2[.qualeFile-1])->grid_on_the_left  
  
  crop(grid_on_the_left,mondo)->grid_on_the_left
  crop(grid_on_the_right,mondo)->grid_on_the_right
  
  ifel(((grid_on_the_right==1) & (grid_on_the_left==0)),1,grid_on_the_left)->ris
  
  # writeRaster(grid_on_the_left,glue::glue("./ris_left/{ffile2[.qualeFile-1]}.tif"),overwrite=TRUE)
  # writeRaster(grid_on_the_right,"./ris_left/{ffile2[.qualeFile]}.tif",overwrite=TRUE)
  # writeRaster(ris,glue::glue("./ris_left/ris{ffile2[.qualeFile-1]}.tif"),overwrite=TRUE)
  # writeRaster(ris-grid_on_the_left,glue::glue("./ris_left/diff{ffile2[.qualeFile-1]}.tif"),overwrite=TRUE)
  # 
  ris
  
})->listaOut1


purrr::map(1:(length(listaOut1)-1),.f=function(.qualeFile){
  
  rast(ffile2[.qualeFile])->grid_on_the_left
  crop(grid_on_the_left,mondo)->grid_on_the_left
  
  listaOut1[[.qualeFile+1]]->grid_on_the_right
  
  ifel(((grid_on_the_right==0) & (grid_on_the_left==1)),1,grid_on_the_right)->ris
  # mydiff<-ris-grid_on_the_left
  # browser()
  # writeRaster(grid_on_the_left,glue::glue("./ris_right/{ffile2[.qualeFile]}.tif"),overwrite=TRUE)
  # writeRaster(grid_on_the_right,glue::glue("./ris_right/{ffile2[.qualeFile+1]}.tif"),overwrite=TRUE)
  writeRaster(ris,glue::glue("./ris_right/buffered_{ffile2[.qualeFile+1]}"),overwrite=TRUE)
  # writeRaster(mydiff,glue::glue("./ris_right/diff{ffile2[.qualeFile+1]}.tif"),overwrite=TRUE)
  
  ris
  
  
  
})->listaFinale


#writeCDF(rast(listaFinale),"finale.nc",overwrite=TRUE)

rast(listaFinale)->zz



