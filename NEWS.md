BANNER: New website at https://r-ega.net

# Changes in version 2.0.2

+ FIX: ties for max gain in `TMFG`

+ FIX: continuous variables with few categories that are treated as ordinal in `polychoric.matrix`

+ FIX: character input for `structure` is now accepted

+ ADD: website pointing t+ different data check errors added t+ error output (hopefully, makes errors more understandable)

+ UPDATE: `corr = "cor_auto"` now performs `qgraph::cor_auto` in favor of legacy; previous behavior starting at 2.0.0 was t+ deprecate `"cor_auto"` in favor of `"auto"`; default remains `corr = "auto"`

+ UPDATE: `compare.EGA.plots` outputs `$all` and `$individual` for the plots

+ UPDATE: when `structure` is supplied for `invariance`, then configural check is skipped (structure is assumed t+ be invariant)

+ UPDATE: added data generation for `model = "BGGM"` and `uni.method = "expand"` in `community.unidimensional`


# Changes in version 2.0.1

+ updated the polychoric C code t+ avoid out-of-bounds access errors


# Changes in version 2.0.0

+ MAJOR REFACTOR: the update t+ version 2.0.0 includes many major # Changes that are designed t+ improve the speed, reliability, and reproducibility of {EGAnet}. The goal of these # Changes are t+ eliminate common errors and streamline the code in the package t+ prevent future error cases. There are several function additions that are provided t+ facilitate modular use of the {EGAnet} package

+ INTERNALS: function-specific internal functions and S3methods are now located in their respective .R files rather than elsewhere (e.g., "utils-EGAnet.R")

+ SWAP: internal script usage of "utils-EGAnet.R" depracated for "helper.R" functions that are used across the package (n+ visible # Changes for the user)

+ NOTE: default objective function for Leiden algorithm is set t+ "modularity"

+ NOTE: default for Louvain unidimensional method is set t+ single-shot *unless* argument "consensus.method" or "consensus.iter" is specified

+ ADD: stricter `*apply` functions that are roughly equivalent t+ `*apply` but have stricter inputs/outputs (uses `vapply` as foundation; often, slightly faster)

+ ADD: `community.consensus` t+ apply the Consensus Clustering approach introduced by Lancichnetti & Fortunat+ (2012). Currently only available for the Louvain algorithm

+ ADD: `community.detection` t+ apply community detection algorithms as a standalone function

+ ADD: convenience function t+ convert an {igraph} object t+ a standard matrix (`igraph2matrix`)

+ ADD: `modularity` t+ compute standard (absolute values) and signed modularity (implemented in C)

+ ADD: `polychoric.matrix` t+ compute categorical correlations (implemented in C); handles missing data ("pairwise" or "listwise") as well as empty cells in the joint frequency table (see documentation: `?polychoric.matrix`)

+ ADD: `auto.correlate` now computes all correlations internally and n+ longer depends on external functions; categorical correlations are C based and bi/polyserial correlations are a simplified and vectorized version of {polycor}'s `polyserial`; substantial computational gains (between 10-25x faster than previous use of {qgraph}'s `cor_auto`)

+ ADD: `network.estimation` t+ handle all network estimation in {EGAnet}; *includes* Bayesian GGM from {BGGM} for more seamless incorporation of BEGA

+ ADD: `community.unidimensional` t+ apply different unidimensional community detection approaches; makes unidimensional community detection more modular and flexible

+ ADD: basic (internal) function t+ handle all network plots t+ keep # Changes centralized t+ a single function; extends flexbility t+ handle all {GGally}'s `ggnet2` arguments

+ ADD: implemented reproducible parametric bootstrapping and random sampling (see <https://github.com/hfgolino/EGAnet/wiki/Reproducibility-and-PRNG> for more details)

+ ADD: implemented reproducible resampling bootstrapping and random sampling (see <https://github.com/hfgolino/EGAnet/wiki/Reproducibility-and-PRNG> for more details)

+ ADD: reproducible bootstrapping with seed setting that does *not* affect R's seed and RNG (user's seed will not be affected and will not affected bootstrapping seeds)

+ ADD: `community.homogenize` as a core function rather than internal (previously `homogenize.membership`); about 2.5x faster than the original version

+ ADD: `convert2tidygraph` for `ggraph` and `tidygraph` support -- thanks t+ Dominique Makowski!

+ ADD: "multilevel" plotting support for `hierEGA` (only used when `scores = "network"` since factor scores don't directly align with EGA detected dimensions)

+ ADD: internal functions `shuffle` and `shuffle_replace` t+ replace `sample` with and without replacement; performed in C and allows seed setting independent of R (about 2-3x faster)

+ ADD: xoshiro256++ PRNG for higher quailty random number generation, permutation, and resampling (~2x faster than `runif` and `sample`); based in C

+ ADD: Ziggurat method for random normal generation over top xoshiro256++ (2-5x faster than `rnorm`); based in C

+ ADD: configural invariance was added t+ `invariance` (see Details section)

+ ADD: `genTEFI` t+ compute the Generalized Total Entropy Fit Index solely; `tefi` serves as a general function t+ compute TEFI for all `*EGA` classes

+ REMOVE: `signed.louvain` until reproducibility can be sorted

+ REMOVE: `methods.section` and `utils-EGAnet.methods.section` t+ avoid space issues in ./R directory (1MB)

+ UPDATE: `EBICglasso.qgraph` and `TMFG` were optimized; `TMFG` is now 2x faster

+ UPDATE: `TMFG` can now directly estimate a GGM with the argument 'partial = TRUE'; implements the Local-Global Inversion method from Barfuss et al. (2016)

+ UPDATE: switched on "Byte-Compile" (byte-compiles on our end and not when the user installs)

+ UPDATE: `EGA.estimate` and `EGA` core functions have been updated for seamless use with more basic functions `network.estimation` and `community.*` functions

+ UPDATE: S3method updates for `EGA.estimate` and `EGA` t+ provide estimation information

+ UPDATE: `EGA.fit` updated t+ be compatiable with all updates t+ `EGA.estimate` (other optimizations were implemented such as direct communtiy detection application and unique solution finding)

+ UPDATE: `tefi` updated with several checks (slightly slower for correlation matrix but much faster with raw data; includes data/matrix checks)

+ UPDATE: `entropyFit` uses more effective vectorization (about 5-7x faster)

+ UPDATE: `Embed` and `glla` made t+ be more efficient and includes an internal `glla_setup` function t+ avoid the same matrix calculations for every participant in a sample for `dynEGA`

+ UPDATE: `riEGA` updated t+ be compatiable with all lower-level updates (slightly faster)

+ UPDATE: `wto` updated t+ be fully vectorized (about 12x faster)

+ UPDATE: `totalCor` and `totalCorMat` updated t+ be fully vectorized (about 10x faster)

+ UPDATE: implemented internal `fast.data.frame` for more efficient data frame initialization when all values in data frame are the same

+ UPDATE: `bootEGA` allows flexibility t+ add any arguments from any `EGA*` functions; much faster due t+ optimizations across all functions ("resampling" is nearly as fast as "parametric")

+ UPDATE: support for `EGA.fit` and `riEGA` added t+ `bootEGA` (support for `hierEGA` will be coming soon...)

+ UPDATE: `itemStability` has been updated and runs about 2.5x faster due t+ `community.homogenize`; S3methods were added; greater flexibility available in plotting but not much support (e.g., error checking) yet

+ UPDATE: `dimensionStability` has been updated and maintains speed gains from `itemStability`

+ UPDATE: `dynEGA.ind.pop` now calls `dynEGA` with `level = c("individual", "population")`; legacy `dynEGA.ind.pop` class is maintained across ergodicity functions

+ UPDATE: `ergoInfo` is about 2x faster

+ UPDATE: `jsd` received several internal functions t+ expedite procedures in `infoCluster` and `jsd.ergoInfo`

+ UPDATE: `net.loads` now includes 'loading.method' argument t+ allow for reproducibility with "BRM" implementation (and version 1.2.3); "experimental" implementation includes rotations alternative signs and cross-loading computation (potential future default)

+ UPDATE: `net.scores` is much simpler (internally) and quicker; seamlessly integrates with `net.loads`

+ UPDATE: `compare.EGA.plots` is faster, more flexible, and more reliable for comparing tw+ or more plots

+ UPDATE: `hierEGA` is faster and has new S3 methods

+ UPDATE: S3 plotting for `invariance`

+ UPDATE: `hierEGA` + `bootEGA` integration for `itemStability` and `dimensionStability` (includes full S3 methods)

+ UPDATE: `UVA` supports legacy of inital conception in Christensen, Golino, and Silvia (EJP, 2020) but will n+ longer fix bugs related to: manual variable selection, "adapt" or "alpha" methods (warnings will be thrown)

+ UPDATE: streamlined `UVA` (about 4x faster); fixed bugs related t+ reverse coding issues 

+ UPDATE: `tefi` now handles all `EGA*` function objects including `hierEGA` which computes generalized TEFI

+ UPDATE: documentation for all functions have been thoroughly revised t+ provide better instruction on how t+ use functions and their expected inputs

+ DEPENDENCY: removed {network} because it is n+ longer used for plotting; switched {sna} t+ IMPORTS rather than SUGGESTS

+ DEPENDENCY: removed {rstudioapi} from 'Suggests' because it was used in `colortext` and used in the package

+ DEPENDENCY: removed {matrixcalc} because it was only used for trace of a matrix (own internal function is used)

+ DEPENDENCY: {future} and {future.apply} are used for parallelization (better integration); includes internal function t+ check for available memory t+ not break in big data cases

+ DEPENDENCY: {progress} and {progressr} are used for progress bars (in parallelization)

+ DEPENDENCY: removed {psychTools} from 'Suggests' which was only used in examples

+ DEPENDENCY: removed {rmarkdown} from 'Suggests' since it wasn't being used across the package


# Changes in version 1.2.5.1

+ FIX: cross-loading bug in `net.loads` was leading t+ problems when there were negative cross-loadings

+ FIX: added `psych::factor.scores` scoring methods in `net.scores`

+ ADD: `signed.louvain` t+ estimate the Signed Louvain algorithm (implemented in C)


# Changes in version 1.2.5

+ ADD: `most_common_tefi` method for `EGA` analyses


# Changes in version 1.2.4

+ REMOVE: `residualEGA` has been removed in favor of `riEGA` (removes {OpenMx} dependency)

+ ADD: rotations t+ `net.loads` and `net.scores`

+ UPDATE: `hierEGA` only outputs specified output (n+ longer outputs all possible consensus methods and scores combinations -- should be much faster)


# Changes in version 1.2.3

+ FIX: many bug fixes related t+ latest update; functions have largely returned t+ stable status

+ UPDATE: Mac and Linux parallelizations have been optimized

+ UPDATE: documented examples are more efficient for CRAN checks


# Changes in version 1.2.1

+ FIX: `bootEGA` read of bootstrap data (was not calling from `datalist` in `do.call` leading t+ perfect item stability)

+ FIX: number of possible colors expanded t+ 70 (increased from 40)


# Changes in version 1.2.0

+ FIX: hex codes used in EGA plots

+ FIX: `ordered = TRUE` for categorical data in *lavaan* CFAs

+ UPDATE: consesnsus clustering is now used with Louvain in `EGA`

+ UPDATE: print/summary S3methods have been standardized

+ ADD/UPDATE: `boot.ergoInfo` has achieved functional working order. Results can be trusted t+ suggest whether dynamic data possess the ergodic property

+ ADD: information theoretic clustering algorithm for dynamic data is available in `infoCluster`

+ REMOVE: "alpha" and "adapt" options in `UVA` (removes {fitdistrplus} dependency)

+ REMOVE: {qgraph} plots are n+ longer available

+ ADD: `convert2igraph` is now a core function

+ ADD: Jensen-Shannon Divergence `jsd` for determining (dis)similarity between network strcutures

+ ADD: `riEGA`, `EGA.fit`, and `hierEGA` functionality t+ `bootEGA`

+ ADD: `hierEGA` functionality t+ `itemStability` and `dimensionStability`

+ UPDATE: "louvain" algorithm used as default for unidimensionality check in `EGA`

+ INTERNAL: cleaned up `EGA` and `EGA.estimate`; streamlined code; n+ user facing differences


# Changes in version 1.1.0

+ FIX: CRAN note when `if(class(object))`. Replaced by `if(is(object))`.

+ FIX: bug in `EGA.estimate` when using the TMFG network method. The resulting EGA plot did not have the correct node names.

+ FIX: bug in `UVA` when trying t+ use sum score (`reduce.method = "sum"`) in automated procedure

+ ADD: measurement `invariance` function for testing differences in network loadings between groups

+ UPDATE: `itemStability` now has a parameter `structure` in which the user can specify a given structure t+ test its stability.

+ ADD: `riEGA` implementing random-intercept EGA for wording effects

+ ADD: `hierEGA` implementing hierarchical EGA

+ FIX: consensus clustering for the Louvain algorithm

+ ADD: `louvain` algorithm with added optimization option using `tefi`


# Changes in version 1.0.0

+ FIX: bug within the bootEGA function for `type = "resampling"`.

+ UPDATE: default undimensionality adjustment has changed t+ leading eigenvalue (see Christensen, Garrido, & Golino, 2021 <https://doi.org/10.31234/osf.io/hz89e>). Previous unidimensionality adjustment in versions <= 0.9.8 can be applied using `uni.method = "expand"`

+ UPDATE: default `UVA` was changed `type = "threshold"`

+ UPDATE: `UVA` is now automated using `aut+ = TRUE`

+ DEFUNCT: `dimStability` will n+ longer be supported. Instead, use `dimensionStability`

+ REVAMP: `itemStability` has been recoded. Now includes error checking and more readable code

+ FIX: bug for plotting NA communities

+ FIX: bug for changing edge size in 'GGally' plotting

+ UPDATE: S3Methods for `EGA.fit` plotting

+ FIX: plotting parameters for `bootEGA`

+ FIX: redundancy output for adhoc check in `UVA`

+ FIX: latent variable with non-space separated entries in `UVA` (`reduce.method = "latent"`)

+ UPDATE: `UVA` was added t+ `methods.section`

+ UPDATE: neural network weights in `LCT` (now only tests for factor or small-world network models)

+ UPDATE: citations

+ UPDATE: added `seed` argument for `bootEGA` t+ reproduce results

+ FIX: bug for Rand index in `itemStability`


# Changes in version 0.9.8

+ UPDATE: Unidimensional check in `EGA` expands a correlation matrix (rather than generating variables; much more efficient)

+ ADD: `color_palette_EGA` New EGA palettes for plotting `ggnet2` EGA network plots (see `?color_palette_EGA`)

+ ADD: `UVA` or Unique Variable Analysis operates as a comprehensive handling of variable redundancy in multivariate data (see `?UVA`)

+ DEFUNCT: `node.redundant`, `node.redundant.names`, and `node.redundant.combine` will be defunct in next version. Please use `UVA`

+ ADD: a new function t+ compute a parametric Bootstrap Test for the Ergodicity Information Index (see `?boot.ergoInfo`)

+ ADD: basic Shiny functionality (`EGA` only)

+ ADD: a new function t+ compute a Monte-Carl+ Test for the Ergodicity Information Index (see `?mctest.ergoInfo`)

+ ADD: a new function t+ compute the Ergodicity Information Index (see `?ergoInfo`)

+ UPDATE: new plotting scheme using *network* and *GGally* packages

+ ADD: a function t+ produce an automated Methods section for several functions (see `?methods.section`)

+ UPDATE: `bootEGA` now implements the updated `EGA` algorithm

+ UPDATE: ega.wmt data (unidimensional)

+ UPDATE: `itemStability` plot defaults ("GGally" color scheme) and examples (manipulating plot)

+ ADD: total correlation (see `?totalCor` and `totalCorMat`)

+ ADD: correlation argument (corr) for `EGA`, `bootEGA`, and `UVA`

+ FIX: *GGally* color palette when more than 9 dimensions


# Changes in version 0.9.7

+ UPDATE: `LCT` neural network weights were updated (parametric relu activation function)

+ FIX: naming in `EGA`

+ FIX: output network matrix in `EGA` when data are input

+ UPDATE: citation version

+ UPDATE: `node.redundant` now provides a full plot of redundancies detected, descriptive statistics including the critical value, central tendency descriptive statistics, and the distribution the significant values were determined from (thanks t+ Luis Garrid+ for the suggestion!)


# Changes in version 0.9.6

+ UPDATE: `LCT` updated with neural network implementation


# Changes in version 0.9.5

+ ADD: loadings comparison test function added (see `LCT`)

+ FIX: named community memberships in `itemStability` and `dimStability`

+ UPDATE: `plot`, `print`, and `summary` methods all moved int+ single .R files (n+ effect on user's end)

+ UPDATE: `net.scores` global score is improved and computes scores very close t+ CFA scores

+ FIX: additional argument calls for `EGA.estimate` (and `EGA` by extension)

+ UPDATE: message from `EGA.estimate` (and `EGA` by extension) reports both 'gamma' and 'lambda.min.ratio' arguments

+ FIX: upper quantile output from `bootEGA`

+ FIX: minor bugs in `node.redundant`, `itemStability`, and `net.loads`


# Changes in version 0.9.4

+ MAJOR UPDATE: `dimStability` now computes proportion of exact dimension replications rather than items that replicate within dimension (this latter information can still be found in the output of `itemStability` under $mean.dim.rep)

+ FIX: `net.loads` for when dimensions equal one or the number of nodes in the network

+ FIX: naming typ+ with characters in `itemStability`

+ FIX: NAs in `dimStability`

+ FIX: weights of network in unidimensional structure of `EGA` are the same as multidimensional structure

+ UPDATE: Added a new function t+ simulate dynamic factor models `simDFM`

+ UPDATE: added internal functions for `net.loads` (see `utils-net.loads`)

+ FIX: ordering of names in `itemStability`

+ FIX: handling of NA communities in `net.loads`

+ UPDATE: Added output of the average replication of items in each dimension for `itemStability`

+ UPDATE: Revised 'Network Scores' vignette

+ UPDATE: `net.loads` functionality (cleaned up code)

+ UPDATE: S3Methods for `net.loads`

+ FIX: `net.scores` negative loadings corrected


# Changes in version 0.9.3

+ New function and print, summary and plot methods: dynEGA

+ New functions: Embed and glla


# Changes in version 0.9.2

+ UPDATE: add latent variable scores comparison t+ `net.scores` vignette

+ UPDATE: `node.redundant.combine` sets loadings equal t+ 1 when there are only tw+ variables when the argument type = "latent"; warning als+ added from type = "sum"

+ FIX: `node.redundant` alpha types bug

+ updated `itemStability` (bug fixes)

+ updated `node.redundant.combine` (bug fixes, latent variable option)

+ major bug fix in `net.loads`: corrected loadings greater than 1 when there were many negative values

+ added `EGA.estimate` t+ clean up `EGA` code and allow for future implementations of different network estimation methods and community detection algorithms

+ updated `EGA` functionality: message for 'gamma' value used and `EGA.estimate` compatiability

+ removed *iterators* dependency

+ ordering and name fix in `net.loads`

+ auto-adjusts y-axis label size for `itemStability` plot based on number of nodes or length of node names

+ `net.loads` adjusted for larger values using absolute values and applying the sign afterwards

+ reverse coding update in `net.loads`

+ `node.redundant.combine` bug fix for reverse coding latent variables

+ added Louvain community detection t+ all EGA functions in *EGAnet*

+ functionality updates t+ `node.redundant`

+ swapped arguments 'type' and 'method' in the `node.redundant` function (fixed examples in other node.redundant functions)

+ updated citation


# Changes in version 0.9.0

+ updated list of dependencies

+ added ORCiDs in Description file

+ corrected ordering of `net.loads` output

+ corrected standard error in `bootEGA`

+ citation update

+ added function `dimStability` t+ compute dimensional stability

+ added a series of functions for `node.redundant`, which facilitates detecting and combining redundant nodes in networks

+ updated the EGA.fit function, s+ now a correlation matrix can be used as well.


# Changes in version 0.8.0

+ 'bootEGA' now computes time until bootstrap is finished

+ new functions 'cmi', 'pmi' and 'residualEGA' added: 'cmi' computes conditional mutual information, 'pmi' computes partial mutual information and residual EGA computes an EGA network controlling for wording effects

+ new dataset 'optimism' added

+ documentation and functionality for several functions updated


# Changes in version 0.7.0

+ fixed 'EGA' bug in 'bootEGA' function; updated 'bootEGA' documentation; added progress messages

+ migrated 'net.scores' and 'net.loads' from 'NetworkToolbox' t+ 'EGAnet' package

+ functions 'itemConfirm' and 'itemIdent' have been merged int+ a single function called, 'itemStability'

+ fixed item ordering in 'itemStability' output s+ dimensions are from least t+ greatest, the colors match the original community vector input, and updated average standardized network loadings t+ the 'net.loads' function

+ added datasets 'ega.wmt' and 'boot.wmt' for quick user-friendly examples (als+ removed all '\donttest')

+ added package help page

+ added package load message

+ updated 'itemStability' algorithm (now can accept any number of 'orig.wc') and enforced '0' t+ '1' bounds on plot
