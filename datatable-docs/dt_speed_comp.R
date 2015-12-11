##################
# Create a toy dataset
#   UID:  Unique ID
#   Length:  Day of measure
#   Mass:  Measurment
##################
n_animals<-50000
n_samples<-100
total_rows<-n_animals*n_samples
toy.df<-data.frame( UID = rep(paste("A",1:n_animals,sep="_"), each=n_samples),
                    Length = floor(runif(total_rows,50,250)),
                    Mass = round(rnorm(total_rows, 500, 100),2),
                    stringsAsFactors=F)
head(toy.df)
###################
# calculate mean length/mass for each animal
###################
# naive method

Unique_A<-unique(toy.df$UI)
l_m.vec<-rep(NA,length(Unique_A))

st<-proc.time()
for (i in 1:length(Unique_A)){
  l_m.vec[i]<-mean(toy.df[toy.df$UID==Unique_A[i],"Length"]/toy.df[toy.df$UID==Unique_A[i],"Mass"])
}
l_m_naive<-cbind(Unique_A, l_m.vec)
proc.time()-st
l_m_naive
# better method, still slow...

system.time(
l_m_better<-aggregate(Length/Mass~UID, data=toy.df, FUN=mean)
)

################
# Data.table example
################
library(data.table)
################
# Create data.table

toy.dt<-data.table( UID = rep(paste("A",1:n_animals,sep="_"), each=n_samples),
                    Length = floor(runif(total_rows,50,250)),
                    Mass = round(rnorm(total_rows, 500, 100),2))
# or toy.dt<-data.table(toy.df)
setkey(toy.dt, UID)
################
# Best? way
system.time(
  l_m_best<-toy.dt[,mean(Length/Mass), by=UID]
)
################
# view data
toy.dt
# view tables in memory
tables()
################
