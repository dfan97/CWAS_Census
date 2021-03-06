library(RMySQL)
library(truncnorm)
# set to your directory
setwd("/Users/dfan/Dropbox/Research Lab Projects/Undergraduate/Harvard-MIT 2016/Code/CWAS_Census/ShinyApp")

# code modified from phewas.R to be for county populations, not individuals
con <- dbConnect(MySQL(), user = "root", password = "root", dbname = "PheWAS", unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")
df <- dbReadTable(conn = con, name = "data")
dbDisconnect(con)
simulateControlCohort <- function(n, countyPop) {
  mat <- as.data.frame(t(replicate(n, rbinom(n = nrow(df), size = countyPop, rtruncnorm(1, a = 0, b = 1, mean = 0, sd = 0.001)))))
  names(mat) <- paste("i", df$icd9, sep = "")
  # all are non-diabetic
  mat$i250 <- 0
  return(mat)
}

con <- dbConnect(MySQL(), user = "root", password = "root", dbname = "census2000", unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")
data2000 <- dbReadTable(conn = con, name = "acs")
dbDisconnect(con)
con <- dbConnect(MySQL(), user = "root", password = "root", dbname = "census2010", unix.sock="/Applications/MAMP/tmp/mysql/mysql.sock")
data2010 <- dbReadTable(conn = con, name = "acs")
dbDisconnect(con)

icd9 <- as.data.frame(rbind(t(sapply(data2000$population, function(y) as.numeric(simulateControlCohort(1, y))))))
county <- cbind(data2000$county, icd9)
names(county) <- c('STCOU', names(simulateControlCohort(1,1)))
write.table(county, file = "testFile.csv", sep = ",", row.names = FALSE) #row.names = FALSE prevents 1 -> length from being printed
