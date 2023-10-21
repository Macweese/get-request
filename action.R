library(rvest)
library(dplyr)
library(tidyverse)
library(XML)
library(RJSONIO)
library(httr)

x <- (Sys.time() %>% force_tz("UTC") %>% {gsub(":","-",.)} %>% {sub("\\..*"," UTC",.)})
url = "https://runelite.net/plugin-hub"
p = rvest::read_html(url)
html <- rvest::read_html("https://runelite.net/plugin-hub")
v <- rvest::read_html("https://raw.githubusercontent.com/runelite/plugin-hub/master/runelite.version") %>% html_text2()
manifest <- glue::glue('https://repo.runelite.net/plugins/manifest/{v}_full.js') %>% {httr::content(httr::GET(.),type="application/javascript")}
n <- as.integer(manifest)
n[n == 0 | n == 23] <- 32
ut = rawToChar(as.raw(n))

res <- sub("^.*?[{][\"]display[\"]","",ut,useBytes=TRUE)
res <- glue::glue('{{"display"{res}')
writeLines(res,glue::glue('data/{x}/MANIFEST {x}','.JSON'))

pluginhub <- rvest::read_html(glue::glue('https://api.runelite.net/runelite-{v}/pluginhub')) %>% html_text2()

dat = RJSONIO::fromJSON(pluginhub)
raw <- data.frame(dat)
writeLines(toJSON(dat,pretty=TRUE),glue::glue('data/{x}/RAW {x}','.JSON'))

plugin = p %>% html_nodes(".card-title a") %>% html_text()
authors = p %>% html_nodes(".text-muted a") %>% html_text()
installs <- str_extract(p %>% html_nodes(".badge-primary") %>% html_text(), "([[:digit:]|[:punct:]]+)")

data <- data.frame(Plugin=plugin, Authors=authors, Installs=installs, stringsAsFactors=FALSE)

write.csv(data,glue::glue('data/{x}/plain','.CSV'),row.names = FALSE) # Pain
