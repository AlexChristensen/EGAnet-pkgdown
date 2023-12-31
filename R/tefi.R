#' @title Total Entropy Fit Index using Von Neumman's entropy (Quantum Information Theory) for correlation matrices
#'
#' @description Computes the fit (TEFI) of a dimensionality structure using Von Neumman's entropy 
#' when the input is a correlation matrix. Lower values suggest better fit of a structure to the data. 
#'
#' @param data Matrix, data frame, or \code{*EGA} class object.
#' Matrix or data frame can be raw data or a correlation matrix.
#' All \code{*EGA} objects are accepted. \code{\link[EGAnet]{hierEGA}}
#' input will produced the Generalized TEFI (see \code{\link[EGAnet]{genTEFI}})
#'
#' @param structure Numeric or character vector (length = \code{ncol(data)}).
#' Can be theoretical factors or the structure detected by \code{\link{EGA}}
#' 
#' @param verbose Boolean (length = 1).
#' Whether messages and (insignificant) warnings should be output.
#' Defaults to \code{TRUE} to see all messages and warnings for every 
#' function call.
#' Set to \code{FALSE} to ignore messages and warnings
#' 
#' @return Returns a data frame with columns:
#'
#' \strong{Non-hierarchical Structure}
#'
#' \item{VN.Entropy.Fit}{The Total Entropy Fit Index using Von Neumman's entropy}
#'
#' \item{Total.Correlation}{The total correlation of the dataset}
#'
#' \item{Average.Entropy}{The average entropy of the dataset}
#' 
#' \strong{Hierarchical Structure}
#' 
#' \item{VN.Entropy.Fit}{The Generalized Total Entropy Fit Index using Von Neumman's entropy}
#'
#' \item{Lower.Order.VN}{Lower order (only) Total Entropy Fit Index}
#'
#' \item{Higher.Order.VN}{Higher order (only) Total Entropy Fit Index}
#' 
#'
#' @examples
#' # Load data
#' wmt <- wmt2[,7:24]
#'
#' # Estimate EGA model
#' ega.wmt <- EGA(
#'   data = wmt, model = "glasso",
#'   plot.EGA = FALSE # no plot for CRAN checks
#' )
#'
#' # Compute entropy indices for empirical EGA
#' tefi(ega.wmt)
#' 
#' # User-defined structure (with `EGA` object)
#' tefi(ega.wmt, structure = c(rep(1, 5), rep(2, 5), rep(3, 8)))
#'
#' @references
#' \strong{Initial formalization and simulation} \cr
#' Golino, H., Moulder, R. G., Shi, D., Christensen, A. P., Garrido, L. E., Nieto, M. D., Nesselroade, J., Sadana, R., Thiyagarajan, J. A., & Boker, S. M. (2020).
#' Entropy fit indices: New fit measures for assessing the structure and dimensionality of multiple latent variables.
#' \emph{Multivariate Behavioral Research}.
#'
#' @author Hudson Golino <hfg9s at virginia.edu>, Alexander P. Christensen <alexpaulchristensen@gmail.com>, and Robert Moulder <rgm4fd@virginia.edu>
#'
#' @export
# Total Entropy Fit Index Function (for correlation matrices)
# Updated 09.08.2023
tefi <- function(data, structure = NULL, verbose = TRUE)
{
  
  # Check for errors (returns 'data' and 'ega_class' flag)
  error_return <- tefi_errors(data, verbose)
  
  # Get 'data' and 'ega_class' flag
  data <- error_return$data; ega_class <- error_return$ega_class
  
  # Branch for `EGA` class
  if(any(ega_class)){
    
    # Get `EGA` object
    ega_object <- get_EGA_object(data)
    
    # Get structure
    structure <- get_tefi_structure(data, structure, ega_object)
    
    # Get correlation matrix based on EGA
    if(is(data, "hierEGA")){
      correlation_matrix <- ega_object$lower_order$correlation
    }else{
      correlation_matrix <- ega_object$correlation
    }
    
  }else{ # Non-EGA objects
    
    # Get structure
    structure <- get_tefi_structure(data, structure, NULL)
    
    # Generic function to get necessary inputs
    output <- obtain_sample_correlations(
      data = data, n = 1L, # set to 1 to avoid error
      corr = "auto", na.data = "pairwise", 
      verbose = verbose
    )
    
    # Get correlation matrix
    correlation_matrix <- output$correlation_matrix

  }
  
  # Get absolute correlation matrix
  correlation_matrix <- abs(correlation_matrix)
  
  # Branch based on hierarchical structure
  return(
    swiftelse( # hierarchical will be a list
      get_object_type(structure) == "list",
      tefi_generalized(correlation_matrix, structure, verbose),
      tefi_standard(correlation_matrix, structure, verbose)
    )
  )

}

# Bug Checking ----
# ## Basic input
# data <- wmt2[,7:24]; ega.wmt <- EGA(data, plot.EGA = FALSE)
# data <- ega.wmt$correlation
# structure <- ega.wmt$wc

#' @noRd
# Argument errors
# Updated 19.08.2023
tefi_errors <- function(data, verbose)
{
  
  # Get `EGA` class
  ega_class <- grepl("EGA", class(data))
  
  # 'verbose' errors
  length_error(verbose, 1, "tefi")
  typeof_error(verbose, "logical", "tefi")
  
  # 'data' errors
  if(any(!ega_class)){
    
    # Check for appropriate data
    object_error(data, c("matrix", "data.frame", "tibble"), "tefi")
    
    # Check for tibble
    if(get_object_type(data) == "tibble"){
      data <- as.data.frame(data)
    }
    
    # Ensure usable data
    data <- usable_data(data, verbose)
    
  }
  
  # Return data and `EGA` classes
  return(list(data = data, ega_class = ega_class))
  
}

#' @noRd
# Handle structure input ----
# Updated 06.10.2023
get_tefi_structure <- function(data, structure, ega_object = NULL)
{
  
  # Check for whether `EGA` object is NULL
  if(is.null(ega_object)){
    
    # Get number of variables
    variables <- dim(data)[2]
    
    # Determine if NULL
    if(is.null(structure)){
      
      stop(
        paste(
          "Input to 'structure' was `NULL` and 'data' was not identified as",
          "an `EGA` type object. Input 'data' or an `EGA` type object."
        ),
        call. = FALSE
      )
      
    }else if(get_object_type(structure) == "list"){
      # Determine if list (for hierarchical structures)
      
      # If not `EGA`, then check for proper object structure in `structure`
      if(all(names(structure) %in% c("lower_order", "higher_order"))){
        
        # Perform length check on lower order
        length_error(structure$lower_order, variables, "tefi")
        
        # Get number of communities in lower order
        lower_order_communities <- unique_length(structure$lower_order)
        
        # Perform length check on higher order
        length_error(structure$higher_order, c(lower_order_communities, variables), "tefi")
        
        # Check for whether higher order's length is equal to
        # lower order communities
        if(length(structure$higher_order) == lower_order_communities){
          structure$higher_order <- single_revalue_memberships(
            structure$lower_order, structure$higher_order
          )
        }
        
      }else{ # Bad 'structure' with NULL `EGA` object
        
        stop(
          paste(
            "Input to 'structure' was provided but did not match expected input.",
            "For hierarchical structures, 'structure' should be a list with elements",
            "\"lower_order\" and \"higher_order\""
          ),
          call. = FALSE
        )
        
      }
      
    }else{
      # Perform length check
      length_error(structure, variables, "tefi")
    }

  }else{
    
    # Get flag for hierarchical
    if(is(data, "hierEGA")){ # Use internal `hierEGA_structure` from `itemStability`
      structure <- hierEGA_structure(ega_object, structure)
    }else if(is.null(structure)){ # Use EGA memberships
      structure <- ega_object$wc
    }else{ # Ensure proper length
      length_error(structure, length(ega_object$wc), "tefi")
    }

  }
  
  # Convert if string
  if(is.list(structure)){
    
    # Check for characters
    structure <- lapply(
      structure, function(x){
        
        # If characters, then convert to numeric
        swiftelse(
          is.character(x),
          as.numeric(reindex_memberships(x)),
          x
        )
        
      }
    )
    
  }else if(is.character(structure)){
    structure <- as.numeric(reindex_memberships(structure))
  }
  
  # Return structure
  return(structure)

}

#' @noRd
# `tefi` standard function ----
# Updated 07.08.2023
tefi_standard <- function(correlation_matrix, structure, verbose)
{
  
  # Check structure
  if(anyNA(structure)){
    
    # Determine variables that are NA
    rm.vars <- is.na(structure)
    
    # Send warning message
    if(verbose){
      warning(
        paste(
          "Some variables did not belong to a dimension:", 
          paste0(dimnames(correlation_matrix)[[2]][rm.vars], collapse = ", "),
          "\n\nUse caution: These variables have been removed from the TEFI calculation"
        ), call. = FALSE
      )
    }
    
    # Keep variables
    keep_vars <- !rm.vars
    
    # Keep available variables
    correlation_matrix <- correlation_matrix[keep_vars, keep_vars]
    
    # Remove NAs from structure
    structure <- structure[keep_vars]
    
  }
  
  # Obtain Von Neumann's entropy of density matrix
  H_vn <- matrix_entropy(correlation_matrix / dim(correlation_matrix)[2L])
  
  # Obtain communities
  communities <- unique_length(structure)
  
  # Get Von Neumman entropy by community
  H_vn_wc <- nvapply(seq_len(communities), function(community){
    
    # Get indices
    indices <- structure == community
    
    # Get community matrix
    community_matrix <- correlation_matrix[indices, indices]
    
    # Return Von Neumann entropy
    return(matrix_entropy(community_matrix / dim(community_matrix)[2L]))
    
  })
  
  # Pre-compute values
  ## Mean of community Von Neumann
  mean_H_vn_wc <- mean(H_vn_wc, na.rm = TRUE)
  ## Sum of community Von Neumann
  sum_H_vn_wc <- mean_H_vn_wc * communities
  ## Difference between total and total community
  # H_diff <- H_vn - sum_H_vn_wc
  ## Average entropy
  mean_H_vn <- mean_H_vn_wc - H_vn

  # Set up results
  return(
    fast.data.frame(
      data = c(
        mean_H_vn + ((H_vn - sum_H_vn_wc) * sqrt(communities)),
        sum_H_vn_wc - H_vn,
        mean_H_vn
      ), ncol = 3,
      colnames = c(
        "VN.Entropy.Fit", "Total.Correlation", "Average.Entropy"
      )
    )
  )
  
}

#' @noRd
# `tefi` generalized function ----
# Updated 07.08.2023
tefi_generalized <- function(correlation_matrix, structure, verbose)
{
  
  # Get variables
  variables <- dim(correlation_matrix)[2L]
  
  # Loop over structure to determine NAs at lower or higher order
  NA_memberships <- rowSums(lvapply(structure, is.na, LENGTH = variables))
  
  # Determine variables that are NA
  rm.vars <- NA_memberships != 0

  # Check structure
  if(any(rm.vars)){
    
    # Send warning message
    if(verbose){
      warning(
        paste(
          "Some variables did not belong to a dimension:", 
          paste0(dimnames(correlation_matrix)[[2]][rm.vars], collapse = ", "),
          "\n\nUse caution: These variables have been removed from the TEFI calculation"
        ), call. = FALSE
      )
    }
    
    # Keep variables
    keep_vars <- !rm.vars
    
    # Keep available variables
    correlation_matrix <- correlation_matrix[keep_vars, keep_vars]
    
    # Remove NAs from structure
    structure <- lapply(structure, function(x){x[keep_vars]})
    
  }
  
  # Obtain Von Neumann's entropy of density matrix
  H_vn <- matrix_entropy(correlation_matrix / dim(correlation_matrix)[2L])
  
  # Obtain communities
  lower_communities <- unique_length(structure$lower_order)
  
  # Get Von Neumman entropy by community
  H_vn_wc_lower <- nvapply(seq_len(lower_communities), function(community){
    
    # Get indices
    indices <- structure$lower_order == community
    
    # Get community matrix
    community_matrix <- correlation_matrix[indices, indices]
    
    # Return Von Neumann entropy
    return(matrix_entropy(community_matrix / dim(community_matrix)[2L]))
    
  })
  
  # Obtain communities
  higher_communities <- unique_length(structure$higher_order)
  
  # Get Von Neumman entropy by community
  H_vn_wc_higher <- nvapply(seq_len(higher_communities), function(community){
    
    # Get indices
    indices <- structure$higher_order == community
    
    # Get community matrix
    community_matrix <- correlation_matrix[indices, indices]
    
    # Return Von Neumann entropy
    return(matrix_entropy(community_matrix / dim(community_matrix)[2L]))
    
  })
  
  # FULL Generalized TEFI
  # ((A / B - C) + (C - A) * sqrt(B)) + ((E / B - C) + (C - E) * sqrt(B))
  
  # Simplified Generalized TEFI
  # ((A + E) / B) - (2 * C) + ((2 * C) - A - E) * sqrt(B)
  
  # Where
  # A = sum of the Von Neumann entropy for each lower order community
  A <- sum(H_vn_wc_lower, na.rm = TRUE)
  # B = number of lower order communities (`lower_communities`)
  # C = Von Neumman entropy of the correlation matrix (`H_vn`)
  # E = sum of the Von Neumann entropy for each higher order community
  E <- sum(H_vn_wc_higher, na.rm = TRUE)
  
  # Pre-compute values
  sqrt_lower <- sqrt(lower_communities) # sqrt(B)
  double_H_vn <- 2 * H_vn # 2 * C
  
  # Set up results
  return(
    fast.data.frame(
      c(
        ((A + E) / lower_communities) - double_H_vn + (double_H_vn - A - E) * sqrt_lower,
        (A / lower_communities - H_vn) + (H_vn - A) * sqrt_lower,
        (E / lower_communities - H_vn) + (H_vn - E) * sqrt_lower
      ),
      ncol = 3,
      colnames = c("VN.Entropy.Fit","Lower.Order.VN","Higher.Order.VN")
    )
  )
  
}
