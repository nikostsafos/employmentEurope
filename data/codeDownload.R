require(tidyr) # Separate
library(reshape2) # melt

setwd("~/Dropbox/- Code/- Github/employmentEurope/code")

# fileURL = 'http://ec.europa.eu/eurostat/estat-navtree-portlet-prod/BulkDownloadListing?sort=1&downfile=data%2Fnama_10_a10_e.tsv.gz'
# download.file(fileURL, destfile = '../rawData/nama_10_a10_e.tsv.gz')
# rm(fileURL)

dat <- read.table(("../rawData/nama_10_a10_e.tsv.gz"), sep = "\t", header=TRUE, na.strings=": ")

dat <- separate(data=dat, col='unit.nace_r2.na_item.geo.time',
                into = c('unit', 'nace_r2', 'na_item', 'geo'), sep = ",")

dat <- melt(dat, id.vars=c('unit', 'nace_r2', 'na_item', 'geo'))

dat$variable = gsub('X', '', dat$variable)
# flags = unique(gsub('[0-9]|\\.', '', dat$value))
dat$value = gsub(' | p| e|: c| d|- |- e|- e| - p|- d| b|- b|-', '', dat$value)
dat = na.omit(dat)
dat$value = as.numeric(dat$value)
dat$variable = as.numeric(dat$variable)
dat = na.omit(dat)

unit = read.csv('../backup/nama_10_a10_eUNIT.tsv', sep = '\t', header = T)
nace_r2 = read.csv('../backup/nama_10_a10_eNACE_R2.tsv', sep = '\t', header = T)
na_item = read.csv('../backup/nama_10_a10_eNA_ITEM.tsv', sep = '\t', header = T)
geo = read.csv('../backup/countries.tsv', sep = '\t', header = T)

dat = dat[
        dat$unit == 'PC_TOT_PER' 
        & dat$na_item %in% c('EMP_DC') 
        & !dat$nace_r2 %in% c('TOTAL', 'C')
        & dat$variable >= 1990
        & !dat$geo %in% c('EU28', 'EU15', 'EA', 'EA19', 'EA12', 'IS', 'NO', 'CH', 'ME', 'MK', 'AL', 'RS', 'TR', 'XK')
          ,]

dat = merge(dat, geo,
            by.dat = 'geo',
            by.geo = 'geo')

dat = merge(dat, na_item,
            by.dat = 'na_item',
            by.na_item = 'na_item')

dat = merge(dat, unit,
            by.dat = 'unit',
            by.unit = 'unit')

dat = merge(dat, nace_r2,
            by.dat = 'nace_r2',
            by.nace_r2 = 'nace_r2')

dat = subset(dat, select = c('Country',
                             'Industry',
                             'variable',
                             'value'))

colnames(dat)[3:4] = c('Year', 'Value')

rm(geo, na_item, unit, nace_r2)

dat = spread(dat, Industry, Value)
dat = melt(dat, id.vars = c('Country', 'Year'))
colnames(dat)[3:4] = c('Sector', 'Value')
write.csv(dat, '../cleanData/employment.csv', row.names = F)


df = unique(dat$Country)
df = paste0('<option value="', df, '">', df, '</option>')
write.csv(df, 'countryList.txt', row.names = F)