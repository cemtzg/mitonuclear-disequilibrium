library("dplyr")

args <- commandArgs(trailingOnly = TRUE)

# parse your command line arguments
x <- as.numeric(args[1]) # args[1] contains argument 1
y <- as.numeric(args[2]) # args[2] contains argument 2
zz <- as.numeric(args[3]) # args[3] contains argument 3, numero de individuos
zpath <- args[4] # args[4] contains argument 4, output path

# data.frame toli be filled
wf_df <- data.frame()
# effective population sizes
#sizes <- c(500) #nuclear
#sizes <- c(656) #nuclear AFR
sizes <- c(zz) #numero de individuos


# starting allele frequencies
#starting_p <- c(0.93)
starting_p <- c(x)

# number of generations
n_gen <- 35


# number of replicates per simulation
n_reps <- y


for(N in sizes){
  for(p in starting_p){
    p0 <- p
    for(j in 1:n_gen){
      X <- rbinom(n_reps, 2*N, p)
      p <- X / (2*N)
      rows <- data.frame(replicate = 1:n_reps, N = rep(N, n_reps), 
                         gen = rep(j, n_reps), p0 = rep(p0, n_reps), 
                         p = p)
      wf_df <- bind_rows(wf_df, rows)
    }
  }
}

# plot it up!

#write it on a file
preArchivo <-paste("SimulationTable", x, sep = "_")
nombreArchivo1 <-paste(zpath, preArchivo, sep = "/")
nombreArchivo <-paste(nombreArchivo1, "txt", sep = ".")

#File name
write.table(wf_df, file = nombreArchivo, sep = "\t",
            row.names = TRUE, col.names = TRUE)

