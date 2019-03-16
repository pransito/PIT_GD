library ( "caTools" )

# Extract common bandwidth
Bw <- ( density ( iris$Petal.Width ))$bw

# Get iris data
Sample <- with ( iris, split ( Petal.Width, Species ))[ 2:3 ]

# Estimate kernel densities using common bandwidth
Densities <- lapply ( Sample, density,
                      bw = Bw,
                      n = 512,
                      from = -1,
                      to = 3 )

# Plot
plot( Densities [[ 1 ]], xlim = c ( -1, 3 ),
      col = "steelblue",
      main = "" )
lines ( Densities [[ 2 ]], col = "orange" )

# Overlap
X <- Densities [[ 1 ]]$x
Y1 <- Densities [[ 1 ]]$y
Y2 <- Densities [[ 2 ]]$y

Overlap <- pmin ( Y1, Y2 )
polygon ( c ( X, X [ 1 ]), c ( Overlap, Overlap [ 1 ]),
          lwd = 2, col = "hotpink", border = "n", density = 20) 

# Integrate
Total <- trapz ( X, Y1 ) + trapz ( X, Y2 )
(Surface <- trapz ( X, Overlap ) / Total)
SText <- paste ( sprintf ( "%.3f", 100*Surface ), "%" )
text ( X [ which.max ( Overlap )], 1.2 * max ( Overlap ), SText )


## code adapted for our case ==================================================

# Extract common bandwidth
Bw <- ( density (cur_dat$value,bw = 'bcv'))$bw

# Get iris data
Sample <- with ( cur_dat, split (value, variable ))[ 1:2 ]

# Estimate kernel densities using common bandwidth
Densities <- lapply ( Sample, density,
                      bw = Bw,
                      n = 1024,
                      from = 0,
                      to = 1 )

# standardize to sum equals 1
Densities$H0$y = Densities$H0$y/sum(Densities$H0$y)
Densities$Ha_auc$y = Densities$Ha_auc$y/sum(Densities$Ha_auc$y)

# Plot
plot( Densities [[ 1 ]], xlim = c (0, 1),
      col = "steelblue",
      main = "" )
lines ( Densities [[ 2 ]], col = "orange" )

# Overlap
X <- Densities [[ 1 ]]$x
Y1 <- Densities [[ 1 ]]$y
Y2 <- Densities [[ 2 ]]$y

Overlap <- pmin ( Y1, Y2 )
polygon ( c ( X, X [ 1 ]), c ( Overlap, Overlap [ 1 ]),
          lwd = 2, col = "hotpink", border = "n", density = 20) 

# Integrate
Total <- trapz ( X, Y1 ) + trapz ( X, Y2 )
#Total <- trapz ( X, Y2 )
(Surface <- trapz ( X, Overlap ) / Total)
SText <- paste ( sprintf ( "%.3f", 100*Surface ), "%" )
text ( X [ which.max ( Overlap )], 1.2 * max ( Overlap ), SText )
