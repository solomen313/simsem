library(simsem)
library(semTools)
library(OpenMx)

######################### Fitting 

data(myGrowthMixtureData)

class1 <- mxModel("Class1", 
    type="RAM",
    manifestVars=c("x1","x2","x3","x4","x5"),
    latentVars=c("intercept","slope"),
    # residual variances
    mxPath(
    	from=c("x1","x2","x3","x4","x5"), 
        arrows=2,
        free=TRUE, 
        values = c(1, 1, 1, 1, 1),
        labels=c("residual","residual","residual","residual","residual")
    ),
    # latent variances and covariance
    mxPath(
    	from=c("intercept","slope"), 
        arrows=2,
		connect="unique.pairs",
        free=TRUE, 
        values=c(1, .4, 1),
        labels=c("vari1", "cov1", "vars1")
    ),
    # intercept loadings
    mxPath(
    	from="intercept",
        to=c("x1","x2","x3","x4","x5"),
        arrows=1,
        free=FALSE,
        values=c(1, 1, 1, 1, 1)
    ),
    # slope loadings
    mxPath(
    	from="slope",
        to=c("x1","x2","x3","x4","x5"),
        arrows=1,
        free=FALSE,
        values=c(0, 1, 2, 3, 4)
    ),
    # manifest means
    mxPath(from="one",
        to=c("x1", "x2", "x3", "x4", "x5"),
        arrows=1,
        free=FALSE,
        values=c(0, 0, 0, 0, 0)
    ),
    # latent means
    mxPath(from="one",
        to=c("intercept", "slope"),
        arrows=1,
        free=TRUE,
        values=c(0, -1),
        labels=c("meani1", "means1")
    ),
    # enable the likelihood vector
    mxExpectationRAM(A = "A",
        S = "S",
        F = "F",
        M = "M",
        vector = TRUE),
	mxFitFunctionML()
) # close model

class2 <- mxModel(class1,
	# latent variances and covariance
    mxPath(
    	from=c("intercept","slope"), 
        arrows=2,
		connect="unique.pairs",
        free=TRUE, 
        values=c(1, .5, 1),
        labels=c("vari2", "cov2", "vars2")
    ),
    # latent means
    mxPath(from="one",
        to=c("intercept", "slope"),
        arrows=1,
        free=TRUE,
        values=c(5, 1),
        labels=c("meani2", "means2")
    ),
	name="Class2"
) 

classP <- mxMatrix("Full", 2, 1, free=c(TRUE, FALSE), 
          values=1, lbound=0.001, 
          labels = c("p1", "p2"), name="Props")

classS <- mxAlgebra(Props%x%(1/sum(Props)), name="classProbs")

algObj <- mxAlgebra(-2*sum(
          log(classProbs[1,1]%x%Class1.objective + classProbs[2,1]%x%Class2.objective)), 
          name="mixtureObj")
          
obj <- mxFitFunctionAlgebra("mixtureObj")
      
gmm <- mxModel("Growth Mixture Model",
	mxData(
    	observed=myGrowthMixtureData,
        type="raw"
    ),
    class1, class2,
    classP, classS,
    algObj, obj
	)      

gmmFit <- mxRun(gmm, suppressWarnings=TRUE)
fitMeasuresMx(gmmFit)
gmmFitSim <- sim(10, gmmFit, n = list(0.4 * 500, 0.6 * 500), mxMixture = TRUE)
summary(gmmFitSim)
