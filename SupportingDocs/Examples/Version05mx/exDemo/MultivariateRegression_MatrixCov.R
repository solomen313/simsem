library(simsem)
library(semTools)
library(OpenMx)

############################# Fitting multivariateRegFit

myRegDataCov<-matrix(
	c(0.808,-0.110, 0.089, 0.361,
	 -0.110, 1.116, 0.539, 0.289,
	  0.089, 0.539, 0.933, 0.312,
	  0.361, 0.289, 0.312, 0.836),
	nrow=4,
	dimnames=list(
		c("w","x","y","z"),
		c("w","x","y","z"))
)
	
myRegDataMeans <- c(2.582, 0.054, 2.574, 4.061)
names(myRegDataMeans) <- c("w","x","y","z")

multivariateRegModel <- mxModel("Multiple Regression Matrix Specification", 
	mxData(
		observed=myRegDataCov,
		type="cov", 
		numObs=100,
		mean=myRegDataMeans
	),
    mxMatrix(
    	type="Full", 
    	nrow=4, 
    	ncol=4,
        values=c(0,1,0,1,
                 0,0,0,0,
                 0,1,0,1,
                 0,0,0,0),
        free=c(F, T, F, T,
               F, F, F, F,
               F, T, F, T,
               F, F, F, F),
        labels=c(NA, "betawx", NA, "betawz",
                 NA,  NA,     NA,  NA, 
                 NA, "betayx", NA, "betayz",
                 NA,  NA,     NA,  NA),
        byrow=TRUE,
        name="A"
    ),
    mxMatrix(
    	type="Symm", 
    	nrow=4, 
    	ncol=4, 
        values=c(1,  0, 0,  0,
                 0,  1, 0, .5,
                 0,  0, 1,  0,
                 0, .5, 0,  1),
        free=c(T, F, F, F,
               F, T, F, T,
               F, F, T, F,
               F, T, F, T),
        labels=c("residualw",  NA,     NA,         NA,
                  NA,         "varx",  NA,        "covxz",
                  NA,          NA,    "residualy", NA,
                  NA,         "covxz", NA,        "varz"),
        byrow=TRUE,
        name="S"
    ),
    mxMatrix(
    	type="Iden", 
    	nrow=4, 
    	ncol=4,
        name="F"
    ),
    mxMatrix(
    	type="Full", 
    	nrow=1, 
    	ncol=4,
        values=c(0,0,0,0),
        free=c(T,T,T,T),
        labels=c("betaw","meanx","betay","meanz"),
        name="M"
    ),
    mxRAMObjective("A","S","F","M",dimnames=c("w","x","y","z"))
)
     
multivariateRegFit <- mxRun(multivariateRegModel)
fitMeasuresMx(multivariateRegFit)
multivariateRegFitSim <- sim(10, multivariateRegFit, n = 200)
summary(multivariateRegFitSim)
