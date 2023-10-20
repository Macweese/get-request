library(rvest)
library(dplyr)
library(tidyverse)

url = "https://runelite.net/plugin-hub"
p = read_html(url)

plugin = p %>% html_nodes(".card-title a") %>% html_text()
authors = p %>% html_nodes(".text-muted a") %>% html_text()
installs <- str_extract(p %>% html_nodes(".badge-primary") %>% html_text(), "([[:digit:]|[:punct:]]+)")

data <- data.frame(Plugin=plugin, Authors=authors, Installs=installs, stringsAsFactors=FALSE)

x <- (Sys.time() %>% force_tz("UTC") %>% {gsub(":","-",.)} %>% {sub("\\..*"," UTC",.)})

#write.csv(data,glue::glue('{x}','.csv'),row.names = FALSE)
write.csv(data,glue::glue('data/{x}','.csv'),row.names = FALSE)
