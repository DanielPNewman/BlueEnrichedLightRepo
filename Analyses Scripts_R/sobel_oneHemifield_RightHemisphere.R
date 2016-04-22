sobel_oneHemifield_RightHemisphere <- function(dataframe,IV,MED,DV){
    
    dat <- dataframe
    dat$IV<-IV
    dat$MED<-MED
    dat$DV=DV
    
    
    library(lme4)
    
    # Path "a" - MED prediced by IV 
    MED_InterceptsOnly<-lmer(MED ~ 1 + (1 | LightCondOrder/ID) + (1 |Light) +(1|ITI) +(1|MotionDirection) + (1|Quadrant) + (1|ValidTrialNum), data = dat, REML=F,   na.action = na.exclude)
    MED_IV<-update(MED_InterceptsOnly, .~. + IV)
    Path_a_SigTest<-as.data.frame(anova(MED_InterceptsOnly,MED_IV))
    Path_a_Coefficients<-as.data.frame(summary(MED_IV)[10])
    a=Path_a_Coefficients[2,1] # a=coefficient for the association between IV and mediator
    se.a<-Path_a_Coefficients[2,2] # se.a=standard error of a.
    
    # Path "b" - DV prediced by MED (after controlling for IV)
    DV_IV<-lmer(DV ~ IV + (1 | LightCondOrder/ID) + (1 |Light) +(1|ITI) +(1|MotionDirection) + (1|Quadrant) + (1|ValidTrialNum), data = dat, REML=F, na.action = na.exclude)
    DV_MED<-update(DV_IV, .~. + MED) # DV prediced by MED (when the IV is also a predictor of the DV)
    Path_b_SigTest<-as.data.frame(anova(DV_IV,DV_MED))
    Path_b_Coefficients<-as.data.frame(summary(DV_MED)[10])
    b<-Path_b_Coefficients[3,1] # b=coefficient for the association between the mediator and the DV (when the IV is also a predictor of the DV).
    se.b<-Path_b_Coefficients[3,2] # se.b=standard error of b
    
    # Path "c" - DV predicted by the IV
    DV_InterceptsOnly<-lmer(DV ~ 1 + (1 | LightCondOrder/ID) + (1 |Light) +(1|ITI) +(1|MotionDirection) + (1|Quadrant) + (1|ValidTrialNum), data = dat, REML=F, na.action = na.exclude)
    Path_c_SigTest<-as.data.frame(anova(DV_InterceptsOnly,DV_IV))
    Path_c_Coefficients<-as.data.frame(summary(DV_IV)[10])
    c<-Path_c_Coefficients[2,1] # c=coefficient for the association between IV and the DV 
    se.c<-Path_c_Coefficients[2,2] # se.c=standard error of c
    
    #Path "c.prime"  - the effect of IV on DV, (after controlling for MED)
    DV_MED_noIV<-lmer(DV ~ MED + (1 | LightCondOrder/ID) + (1 |Light) +(1|ITI) +(1|MotionDirection) + (1|Quadrant) + (1|ValidTrialNum), data = dat, REML=F, na.action = na.exclude) #controlling for MED
    DV_IV_MEDcontrol<-update(DV_MED_noIV, .~. + IV)
    Path_c.prime_SigTest<-as.data.frame(anova(DV_MED_noIV,DV_IV_MEDcontrol))
    Path_c.prime_Coefficients<-as.data.frame(summary(DV_IV_MEDcontrol)[10])
    c.prime<-Path_c.prime_Coefficients[3,1] #c.prime=coefficient for the association between IV and the DV, after controlling for MED
    se.c.prime<-Path_c.prime_Coefficients[3,2] #Sc.prime=standard error of c.prime
    
    #   Sobel test equation:
    #   z-value = a*b/SQRT(b^2*se.a^2 + a^2*se.b^2) :
    ind.eff <- a*b
    se.ind.eff <- sqrt((b^2 * se.a^2) + (a^2 * se.b^2))
    zvalue <- ind.eff/se.ind.eff
    Sobel_pvalue_2sided=2*pnorm(-abs(zvalue))
    #   The reported p-values are drawn from the unit 
    #   normal distribution under the assumption of a two-tailed z-test of the hypothesis 
    #   that the mediated effect equals zero in the population. +/- 1.96 are the critical
    #   values of the test ratio which contain the central 95% of the unit normal distribution.
    
    
    c.sig <- 0
    c.sig[Path_c_SigTest[2,8] < .05] <- 1
    a.sig <- 0
    a.sig[Path_a_SigTest[2,8] < .05] <- 1
    b.sig <- 0
    b.sig[Path_b_SigTest[2,8] < .05] <- 1
    c.prime.sig <- 0
    c.prime.sig[Path_c.prime_SigTest[2,8]< .05] <- 1
    suppression <- 0
    suppression[abs(c.prime) < abs(c)] <- 1
    Inconsistent.Mediation<-0
    Inconsistent.Mediation[sign(c.prime)==sign(a*b)]<-1
    
    mediation.test <- list(c.sig=c.sig, a.sig=a.sig, b.sig=b.sig, c.prime.sig=c.prime.sig, suppression=suppression,Inconsistent.Mediation=Inconsistent.Mediation)
    
    
    ######################################################################################################################################
    
    cat("Standard Mediation Model\n")
    
    cat("    IV -- c --> DV\n\n")
    
    cat("          M           \n")
    cat("         / \\         \n")
    cat("      a /   \\ b      \n")
    cat("       /     \\       \n")
    cat("      /       \\      \n")
    cat("     IV - c' -> DV    \n")
    
    
    cat("--------------------------------\n")
    cat("Mediation Model Path Results\n")
    cat("--------------------------------\n")
    cat("The classic 4 steps in establishing mediation\n")
    cat("(discussed by Baron and Kenny (1986), Judd and Kenny\n")
    cat("(1981), and James and Brett (1984)):\n")
    cat("\n")
    cat("Step1:\nShow that the IV affects the DV:\n")
    cat("Path c:\n")
    print(Path_c_Coefficients)
    print(Path_c_SigTest[2,])
    cat("Is Path c significant (at p<.05): ")
    if(mediation.test[[1]] == 1) cat("YES\n")  else cat("NO\n")
    cat("--------------------------------\n")
    cat("Step2:\nShow that the IV affects the mediator:\n")
    cat("Path a\n")
    print(Path_a_SigTest[2,])
    cat("Is Path a significant (at p<.05): ")
    if(mediation.test[[2]] == 1) cat("YES\n")  else cat("NO\n")
    cat("--------------------------------\n")
    cat("Step3:\nShow that the mediator affects the DV:\n")
    cat("Path b\n")
    print(Path_b_SigTest[2,])
    cat("Is Path b significant (at p<.05): ")
    if(mediation.test[[3]] == 1) cat("YES\n")  else cat("NO\n")
    cat("--------------------------------\n")
    cat("Step4:\nShow that the affect of the IV on the DV\n")
    cat("shrinks upon the addition of the mediator\n")
    cat("to the model:\n")
    cat("Does IV-->DV shrink after controlling for mediator?\n")
    if(mediation.test[[5]] == 1) cat("YES\n")  else cat("NO\n")
    if(mediation.test[[5]] == 0){
        cat("So Step 4 not satisfied, check if there is 'Inconsistent Mediation'???\n")
        if(mediation.test[[6]] == 0) cat("YES\n")  else cat("NO\n")
    }
    cat("--------------------------------\n")
    cat("\n")
    
    cat("--------------------------------\n")
    cat("Inconsistent Mediation Checks:\n")
    cat("Is coefficient of c' opposite in sign to a*b?)\n")
    if(mediation.test[[6]] == 0) cat("YES\n")  else cat("NO\n")
    cat("Is c' even larger than c ?\n")
    if(abs(c.prime)>abs(c)) cat("YES\n")  else cat("NO\n")
    if(mediation.test[[6]] == 0) cat("With 'inconsistent mediation', it can be the case that Step 1 is not be met,\nbut there is still mediation (MacKinnon, Fairchild, and Fritz, 2007), use Sobel test to find out\n")
    cat("\n")
    cat("Lets look at parth c' (c.prime) for good measure:\n")
    print(Path_c.prime_SigTest[2,])
    cat("Is Path c' (c.prime) significant (at p<.05): ")
    if(mediation.test[[4]] == 1) cat("YES\n")  else cat("NO\n")
    cat("--------------------------------\n")
    cat("\n")
    
    cat("--------------------------------\n")
    cat("Check that c = c'+ a*b  (i.e. total effect = direct effect + indirect effect),\n")
    cat("since we are using multilevel models to estimate the coefficients, they may be slightly differnt\n")
    cat("but this difference should be small:\n")
    cat("c= ")
    cat(c)
    cat("\n")
    cat("c'+(a*b)= ")
    cat(c.prime+ind.eff)
    cat("\n")
    cat("Difference between them:\n")
    cat(all.equal(c,(c.prime+ind.eff)))
    cat("\n")
    cat("Indirect Effect:\n")
    cat(ind.eff)
    cat("\n\n")
    
    cat("###############################\n")
    cat("###############################\n")
    cat("###############################\n")
    cat("Results of Sobel Test for indirect effect:\n")
    cat("Indirect Effect:\n")
    cat(ind.eff)
    cat("\n")
    cat("Standard Error of Indirect Effect:\n")
    cat(se.ind.eff)
    cat("\n")
    cat("Sobel Test z-value:\n")
    cat(zvalue)
    cat("\n")
    cat("Sobel Test p-value:\n")
    cat(Sobel_pvalue_2sided)
    cat("\n")
    cat("###############################\n")
    cat("###############################\n")
    cat("###############################\n")
    
    
    require(diagram)
    names<-c("Right Hemisphere pre-\ntarget alpha power", "Light\nIntensity", "Left Hemifield\nTarget RT") 
    # names is a vector of names specifying the names you wish to have in your diagram (MED, IV, DV) in that order.
    # names is a vector of names specifying the names you wish to have in your diagram (MED, IV, DV) in that order.
    
    openplotmat()
    elpos <- coordinates(c(1,2),relsize = 1)
    fromto <- matrix(ncol=2,byrow=T,data=c(1,3,2,1,2,3))
    nr <- nrow(fromto)
    arrpos <- matrix(ncol=2,nrow=nr)
    for (i in 1:nr){
        arrpos[i,] <- straightarrow(to=elpos[fromto[i,2],],from = elpos[fromto[i,1],],lwd=2,arr.pos=.75,arr.length=.5)
    }
    textrect(elpos[1,], radx=0.12,rady=0.1, lab=names[1])
    textrect(elpos[2,], radx=0.1,rady=0.1, lab=names[2])
    textrect(elpos[3,], radx=0.1,rady=0.1, lab=names[3])
    
    labs<-c("a = ", "b = ", "c' = ")
    pvals<-c(round(Path_a_SigTest[2,8],3), round(Path_b_SigTest[2,8],3), round(Path_c.prime_SigTest[2,8],3))
    parms <- c(round(a,2),round(b,2),round(c.prime,2))
    plabs <- parms
    plabsse <- c(round(se.a,2),round(se.b,2),round(se.c.prime,2))
    if (mediation.test$a.sig==1) plabs[1] <- paste(plabs[1],"*",sep=" ")
    if (mediation.test$b.sig==1) plabs[2] <- paste(plabs[2],"*",sep=" ")
    if (mediation.test$c.sig==1) plabs[3] <- paste(plabs[3],"*",sep=" ")
    plabs <- paste(labs, plabs,"\n(se=",plabsse,", p=",pvals,")",sep="")
    text(arrpos[1,1] + .05, arrpos[1,2] + .15, plabs[2])
    text(arrpos[2,1] -.15, arrpos[2,2] - .1, plabs[1])
    text(arrpos[3,1] -.12, arrpos[3,2] -.05, plabs[3])
    text(0.25, 0.95,  paste("Sobel Test:\nIndirect Effect=",round(ind.eff,2),", se=",round(se.ind.eff,2),", p=",round(Sobel_pvalue_2sided,2),"*"))
    
    
    
    png("Figure3.png",  width = 10*600, height = 6*600, units = "px", res = 600)
    
    openplotmat()
    elpos <- coordinates(c(1,2),relsize = 1)
    fromto <- matrix(ncol=2,byrow=T,data=c(1,3,2,1,2,3))
    nr <- nrow(fromto)
    arrpos <- matrix(ncol=2,nrow=nr)
    for (i in 1:nr){
        arrpos[i,] <- straightarrow(to=elpos[fromto[i,2],],from = elpos[fromto[i,1],],lwd=2,arr.pos=.75,arr.length=.5)
    }
    textrect(elpos[1,], radx=0.12,rady=0.1, lab=names[1])
    textrect(elpos[2,], radx=0.1,rady=0.1, lab=names[2])
    textrect(elpos[3,], radx=0.1,rady=0.1, lab=names[3])
    
    labs<-c("a = ", "b = ", "c' = ")
    pvals<-c(round(Path_a_SigTest[2,8],3), round(Path_b_SigTest[2,8],3), round(Path_c.prime_SigTest[2,8],3))
    parms <- c(round(a,2),round(b,2),round(c.prime,2))
    plabs <- parms
    plabsse <- c(round(se.a,2),round(se.b,2),round(se.c.prime,2))
    if (mediation.test$a.sig==1) plabs[1] <- paste(plabs[1],"*",sep=" ")
    if (mediation.test$b.sig==1) plabs[2] <- paste(plabs[2],"*",sep=" ")
    if (mediation.test$c.sig==1) plabs[3] <- paste(plabs[3],"*",sep=" ")
    plabs <- paste(labs, plabs,"\n(se=",plabsse,", p=",pvals,")",sep="")
    text(arrpos[1,1] + .05, arrpos[1,2] + .15, plabs[2])
    text(arrpos[2,1] -.15, arrpos[2,2] - .1, plabs[1])
    text(arrpos[3,1] -.12, arrpos[3,2] -.05, plabs[3])
    text(0.25, 0.95,  paste("Sobel Test:\nIndirect Effect=",round(ind.eff,2),", se=",round(se.ind.eff,2),", p=",round(Sobel_pvalue_2sided,2),"*"))
    
    dev.off()
    
    
    
}
