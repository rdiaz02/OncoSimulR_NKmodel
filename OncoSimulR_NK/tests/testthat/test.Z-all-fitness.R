RNGkind("Mersenne-Twister")

test_that("catches identical gene names in different modules", {
    ## long, because it uses a complex and easy to miss problem
    p4 <- data.frame(parent = c(rep("Root", 4), "A", "B", "D", "E", "C", "F"),
                     child = c("A", "B", "D", "E", "C", "C", "F", "F", "G", "G"),
                     s = c(0.01, 0.02, 0.03, 0.04, 0.1, 0.1, 0.2, 0.2, 0.3, 0.3),
                     sh = c(rep(0, 4), c(-.9, -.9), c(-.95, -.95), c(-.99, -.99)),
                     typeDep = c(rep("--", 4), 
                         "XMPN", "XMPN", "MN", "MN", "SM", "SM"))
    oe <- c("C > F" = -0.1, "H > I" = 0.12)
    sm <- c("I:J"  = -1)
    sv <- c("-K:M" = -.5, "K:-M" = -.5)
    epist <- c(sm, sv)
    modules <- c("Root" = "Root", "A" = "a1",
                 "B" = "b1, b2", "C" = "c1",
                 "D" = "d1, d2", "E" = "e1",
                 "F" = "f1, f2", "G" = "g1",
                 "H" = "h1, h2", "I" = "i1",
                 "J" = "j1, k2", "K" = "k1, k2", "M" = "m1")
    set.seed(1) ## for repeatability
    noint <- rexp(5, 10)
    names(noint) <- paste0("n", 1:5)
    expect_error(allFitnessEffects(rT = p4, epistasis = epist, orderEffects = oe,
                                   noIntGenes = noint, geneToModule = modules))
})




test_that("long example OK", {
    p4 <- data.frame(parent = c(rep("Root", 4), "A", "B", "D", "E", "C", "F"),
                     child = c("A", "B", "D", "E", "C", "C", "F", "F", "G", "G"),
                     s = c(0.01, 0.02, 0.03, 0.04, 0.1, 0.1, 0.2, 0.2, 0.3, 0.3),
                     sh = c(rep(0, 4), c(-.9, -.9), c(-.95, -.95), c(-.99, -.99)),
                     typeDep = c(rep("--", 4), 
                         "XMPN", "XMPN", "MN", "MN", "SM", "SM"))
    oe <- c("C > F" = -0.1, "H > I" = 0.12)
    sm <- c("I:J"  = -1)
    sv <- c("-K:M" = -.5, "K:-M" = -.5)
    epist <- c(sm, sv)
    modules <- c("Root" = "Root", "A" = "a1",
                 "B" = "b1, b2", "C" = "c1",
                 "D" = "d1, d2", "E" = "e1",
                 "F" = "f1, f2", "G" = "g1",
                 "H" = "h1, h2", "I" = "i1",
                 "J" = "j1, j2", "K" = "k1, k2", "M" = "m1")
    set.seed(1) ## for repeatability
    ## These are seeds in R; no problems with different compilers, etc.
    noint <- rexp(5, 10)
    names(noint) <- paste0("n", 1:5)
    fea <- allFitnessEffects(rT = p4, epistasis = epist, orderEffects = oe,
                             noIntGenes = noint, geneToModule = modules)
    expect_true(all.equal(evalGenotype("k1 > i1 > h2", fea), 0.5)) ## 0.5
    expect_true(all.equal(evalGenotype("k1 > h1 > i1", fea), 0.5 * 1.12)) ## 0.5 * 1.12
    expect_true(all.equal(evalGenotype("k2 > m1 > h1 > i1", fea), 1.12)) ## 1.12
    nnn <- noint[3]; names(nnn) <- NULL
    expect_true(all.equal(evalGenotype("k2 > m1 > h1 > i1 > c1 > n3 > f2", fea), (1 + nnn) * 0.1 * 0.05 * 0.9 * 1.12)) ## 1.12 * 0.1 * (1 + noint[3]) * 0.05 * 0.9
    randomGenotype <- function(fe, ns = NULL) {
        gn <- setdiff(c(fe$geneModule$Gene,
                        fe$long.geneNoInt$Gene), "Root")
        if(is.null(ns)) ns <- sample(length(gn), 1)
        return(paste(sample(gn, ns), collapse = " > "))
    }
    ## the following, all checked by hand. I wonder if seed will move around?
    set.seed(2) ## for reproducibility
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),
                          0.1 * (1 + noint[1]), check.names = FALSE))
    ## Genotype:  k2 > i1 > c1 > n1 > m1
    ##  Individual s terms are : 0.0755182 -0.9
    ##  Fitness:  0.107552 
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),
                          (1 + noint[2]), check.names = FALSE))
    ## Genotype:  n2 > h1 > h2
    ##  Individual s terms are : 0.118164
    ##  Fitness:  1.11816 
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),
                          (1 + noint[3]) * (1 + noint[4]) * (1 + noint[5]) *
                              1.02 * 1.1 * 1.03 * .05 * 1.3 * .9,
                          check.names = FALSE))
    ## Genotype:  d2 > k2 > c1 > f2 > n4 > m1 > n3 > f1 > b1 > g1 > n5 > h1 > j2
    ##  Individual s terms are : 0.0145707 0.0139795 0.0436069 0.02 0.1 0.03 -0.95 0.3 -0.1
    ##  Fitness:  0.0725829 
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),
                          (1 + noint[1]) * (1 + noint[2]) *
                              1.01 * 1.02 * .1 * .05 * .9 * 1.12,
                          check.names = FALSE))
    ## Genotype:  h2 > c1 > f1 > n2 > b2 > a1 > n1 > i1
    ##  Individual s terms are : 0.0755182 0.118164 0.01 0.02 -0.9 -0.95 -0.1 0.12
    ##  Fitness:  0.00624418 
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),  0,
                          check.names = FALSE))
    ## Genotype:  h2 > j1 > m1 > d2 > i1 > b2 > k2 > d1 > b1 > n3 > n1 > g1 > h1 > c1 > k1 > e1 > a1 > f1 > n5 > f2
    ##  Individual s terms are : 0.0755182 0.0145707 0.0436069 0.01 0.02 -0.9 0.03 0.04 0.2 0.3 -1 -0.1 0.12
    ##  Fitness:  0 
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),  0,
                          check.names = FALSE))
    ## Genotype:  n1 > m1 > n3 > i1 > j1 > n5 > k1
    ##  Individual s terms are : 0.0755182 0.0145707 0.0436069 -1
    ##  Fitness:  0 
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),
                          (1 + noint[1]) * (1 + noint[2]) * (1 + noint[4]) *
                              1.01 * 1.02 * .1 * 1.03 * .05 * 1.3 * 0.5
                        , check.names = FALSE))
    ## Genotype:  d2 > n1 > g1 > f1 > f2 > c1 > b1 > d1 > k1 > a1 > b2 > i1 > n4 > h2 > n2
    ##  Individual s terms are : 0.0755182 0.118164 0.0139795 0.01 0.02 -0.9 0.03 -0.95 0.3 -0.5
    ##  Fitness:  0.00420528 
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),
                          (1 + noint[3]) * (1 + noint[4]) * 1.01 *
                              1.1 * 1.03 * .05 * .5,
                          check.names = FALSE))
    ## Genotype:  j1 > f1 > j2 > a1 > n4 > c1 > n3 > k1 > d1 > h1
    ##  Individual s terms are : 0.0145707 0.0139795 0.01 0.1 0.03 -0.95 -0.5
    ##  Fitness:  0.0294308 
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),
                          (1 + noint[3]) * (1 + noint[4]) * (1 + noint[5]) *
                            1.02 * 1.1 * 0.05, check.names = FALSE))
    ## Genotype:  n5 > f2 > f1 > h2 > n4 > c1 > n3 > b1
    ##  Individual s terms are : 0.0145707 0.0139795 0.0436069 0.02 0.1 -0.95
    ##  Fitness:  0.0602298 
    expect_true(all.equal(evalGenotype(randomGenotype(fea), fea),
                          1.03 * 0.05, check.names = FALSE))
    ## Genotype:  h1 > d1 > f2
    ##  Individual s terms are : 0.03 -0.95
    ##  Fitness:  0.0515 
})


set.seed(NULL)
