#' @title Item Stability Statistics from \code{\link[EGAnet]{bootEGA}}
#'
#' @description Based on the \code{\link[EGAnet]{bootEGA}} results, this function
#' computes and plots the number of times an variable is estimated
#' in the same dimension as originally estimated by an empirical
#' \code{\link[EGAnet]{EGA}} structure or a theoretical/input structure.
#' The output also contains each variable's replication frequency (i.e., proportion of
#' bootstraps that a variable appeared in each dimension
#'
#' @param bootega.obj A \code{\link[EGAnet]{bootEGA}} object
#'
#' @param IS.plot Boolean (length = 1).
#' Should the plot be produced for \code{item.replication}?
#' Defaults to \code{TRUE}
#'
#' @param structure Numeric (length = number of variables).
#' A theoretical or pre-defined structure.
#' Defaults to \code{NULL} or the empirical \code{\link[EGAnet]{EGA}}
#' result in the \code{bootega.obj}
#'
#' @param ... Deprecated arguments from previous versions of \code{\link[EGAnet]{itemStability}}
#'
#' @return Returns a list containing:
#'
#' \item{membership}{A list containing:
#'
#' \itemize{
#'
#' \item \code{empirical} --- A vector of the empirical memberships from the
#' empirical \code{\link[EGAnet]{EGA}} result
#'
#' \item \code{bootstrap} --- A matrix of the homogenized memberships from the replicate samples in
#' the \code{\link[EGAnet]{bootEGA}} results
#'
#' \item \code{structure} --- A vector of the structure used in the analysis. If \code{structure = NULL}, then this output
#' will be the same as \code{empirical}
#'
#' }
#'
#' }
#'
#' \item{item.stability}{A list containing:
#'
#' \itemize{
#'
#' \item \code{empirical.dimensions} --- A vector of the proportion of times each item replicated
#' within the structure defined by \code{structure}
#'
#' \item \code{all.dimensions} --- A matrix of the proportion of times each item replicated
#' in each of the \code{structure} defined dimensions
#'
#' }
#'
#' }
#'
#' \item{plot}{Plot output if \code{IS.plot = TRUE}}
#'
#' @examples
#' # Load data
#' wmt <- wmt2[,7:24]
#'
#' \dontrun{
#' # Standard EGA example
#' boot.wmt <- bootEGA(
#'   data = wmt, iter = 500,
#'   type = "parametric", ncores = 2
#' )}
#'
#' # Standard item stability
#' wmt.is <- itemStability(boot.wmt)
#'
#' \dontrun{
#' # EGA fit example
#' boot.wmt.fit <- bootEGA(
#'   data = wmt, iter = 500,
#'   EGA.type = "EGA.fit",
#'   type = "parametric", ncores = 2
#' )
#'
#' # EGA fit item stability
#' wmt.is.fit <- itemStability(boot.wmt.fit)
#'
#' # Hierarchical EGA example
#' boot.wmt.hier <- bootEGA(
#'   data = wmt, iter = 500,
#'   EGA.type = "hierEGA",
#'   type = "parametric", ncores = 2
#' )
#'
#' # Hierarchical EGA item stability
#' wmt.is.hier <- itemStability(boot.wmt.hier)
#'
#' # Random-intercept EGA example
#' boot.wmt.ri <- bootEGA(
#'   data = wmt, iter = 500,
#'   EGA.type = "riEGA",
#'   type = "parametric", ncores = 2
#' )
#'
#' # Random-intercept EGA item stability
#' wmt.is.ri <- itemStability(boot.wmt.ri)}
#'
#' @references
#' \strong{Original implementation of bootEGA} \cr
#' Christensen, A. P., & Golino, H. (2021).
#' Estimating the stability of the number of factors via Bootstrap Exploratory Graph Analysis: A tutorial.
#' \emph{Psych}, \emph{3}(3), 479-500.
#'
#' \strong{Conceptual introduction} \cr
#' Christensen, A. P., Golino, H., & Silvia, P. J. (2020).
#' A psychometric network perspective on the validity and validation of personality trait questionnaires.
#' \emph{European Journal of Personality}, \emph{34}(6), 1095-1108.
#'
#' @author Hudson Golino <hfg9s at virginia.edu> and Alexander P. Christensen <alexpaulchristensen@gmail.com>
#'
#' @seealso \code{\link[EGAnet]{plot.EGAnet}} for plot usage in \code{\link{EGAnet}}
#'
#' @export
#'
# Item Stability function ----
# Updated 18.11.2024
itemStability <- function (bootega.obj, IS.plot = TRUE, structure = NULL, ...){

  # Set up ellipse arguments
  ellipse <- list(...)

  # Cover legacy arguments
  ellipse <- itemStability_deprecation(ellipse)

  # Check for 'structure' in 'ellipse'
  if("structure" %in% names(ellipse)){
    structure <- ellipse$structure
  }

  # Check for 'IS.plot' in 'ellipse'
  if("IS.plot" %in% names(ellipse)){
    IS.plot <- ellipse$IS.plot
  }

  # Argument errors
  itemStability_errors(bootega.obj, IS.plot)

  # Get empirical EGA
  ega_object <- get_EGA_object(bootega.obj)

  # Determine if hierarchical EGA
  hierarchical <- is(ega_object, "hierEGA")

  # Check for hierarchical EGA
  if(hierarchical){

    # Check for structure
    structure <- hierEGA_structure(ega_object, structure)

    # Set up results
    results <- list()

    # Get lower results
    results$lower_order <- itemStability_core(
      ega_object$lower_order, structure$lower_order,
      bootega.obj$lower_order$boot.wc, bootega.obj$lower_order$iter
    )

    # Revalue higher order memberships
    ega_object$higher_order$wc <- single_revalue_memberships(
      ega_object$lower_order$wc, ega_object$higher_order$wc
    )

    # Get higher results
    results$higher_order <- itemStability_core(
      ega_object$higher_order, structure$higher_order,
      bootega.obj$higher_order$boot.wc, bootega.obj$higher_order$iter
    )

    # Set class
    class(results) <- "itemStability"

  }else{

    # Get regular results
    results <- itemStability_core(
      ega_object, structure, bootega.obj$boot.wc, bootega.obj$iter
    )

  }

  # Add methods attributes from `bootEGA` object
  attr(results, "methods") <- bootega.obj[c("EGA.type", "iter", "type")]
  attr(results, "color") <- unique(
    plot(bootega.obj$EGA, produce = FALSE, arguments = TRUE)$ARGS$node.color
  )

  # Check for hierarchical
  if(hierarchical){

    # Get number of legend columns
    legend_rows <- digits(
      max(results$lower_order$membership$structure, na.rm = TRUE)
    ) + 1

    # Set up colors
    colors <- attributes(results)$color

    # Get number of higher order
    higher_ndim <- seq_len(unique_length(structure$higher_order))

    # Get colors
    ## Lower order
    lower_colors <- colors[-higher_ndim]
    lower_colors <- lower_colors[
      structure$lower_order[order(structure$lower_order)]
    ]
    ## Higher order
    higher_colors <- colors[higher_ndim]
    higher_colors <- higher_colors[
      structure$higher_order[order(structure$higher_order)]
    ]

    # Get lower plot
    results$lower_order$plot <- plot(results$lower_order, color = lower_colors, ...) +
      ggplot2::guides(color = ggplot2::guide_legend(nrow = legend_rows))

    # Get higher plot
    results$higher_order$plot <- silent_call(
      plot(results$higher_order, color = higher_colors, ...) +
        ggplot2::guides(color = ggplot2::guide_legend(nrow = legend_rows)) +
        ggplot2::scale_x_discrete(limits = rev(results$lower_order$plot$data$Node))
    )

    # Set up clean side-by-side
    if(!"nrow" %in% names(ellipse) || ellipse$nrow == 1){

      # Remove y-axis title from higher order
      higher_order_plot <- results$higher_order$plot +
        ggplot2::theme(axis.title.y = ggplot2::element_blank())

    }

    # Get final plot
    results$plot <- ggpubr::ggarrange(
      results$lower_order$plot, higher_order_plot,
      labels = c("Lower Order", "Higher Order"),
      ...
    )

  }else{

    # Get plot
    results$plot <- plot(results, ...)

  }

  # Actually send plot
  if(IS.plot){
    silent_plot(results$plot)
  }

  # Return results
  return(results)

}

#' @noRd
# itemStability errors
# Updated 04.08.2023
itemStability_errors <- function(bootega.obj, IS.plot)
{

  # 'bootega.obj' errors
  class_error(bootega.obj, "bootEGA", "itemStability")

  # 'IS.plot' errors
  length_error(IS.plot, 1, "itemStability")
  typeof_error(IS.plot, "logical", "itemStability")

  # 'structure' errors are handled in `get_structure`

}

#' @exportS3Method
# S3 Print Method ----
# Updated 23.07.2023
print.itemStability <- function(x, ...)
{

  # Get attributes
  bootega_attributes <- attr(x, "methods")

  # Set proper EGA type name
  ega_type <- switch(
    bootega_attributes$EGA.type,
    "ega" = "EGA",
    "ega.fit" = "EGA.fit",
    "hierega" = "hierEGA",
    "riega" = "riEGA"
  )

  # Print EGA type
  cat(paste0("EGA Type: ", ega_type), "\n")

  # Set up methods
  cat(
    paste0(
      "Bootstrap Samples: ", bootega_attributes$iter,
      " (", totitle(bootega_attributes$type), ")"
    )
  )

  # Add breakspace
  cat("\n\n")

  # Print replications
  cat("Proportion Replicated in Dimensions:\n\n")

  # Branch for hierarchical EGA
  if(ega_type == "hierEGA"){

    # Print results
    print(
      t(
        data.frame(
          Lower = x$lower_order$item.stability$empirical.dimensions,
          Higher = x$higher_order$item.stability$empirical.dimensions
        )
      )
    )

  }else{

    # Print results
    print(x$item.stability$empirical.dimensions)

  }

}

#' @exportS3Method
# S3 Summary Method ----
# Updated 05.07.2023
summary.itemStability <- function(object, ...)
{
  print(object, ...) # same as print
}

#' @noRd
# Default plotting for `itemStability` ----
# Updated 23.07.2023
item_stability_defaults <- function(organize_df, ellipse)
{

  # Set up default arguments
  item_stability_defaults <- list(
    data = organize_df,
    x = "Node", y = "Replication",
    group = "Community", color = "Community",
    legend.title = "Communities",
    add = "segments", rotate = TRUE, dot.size = 6,
    label = round(organize_df$Replication, 2),
    font.label = list(
      color = "black", size = 8, vjust = 0.5
    ),
    ggtheme = ggpubr::theme_pubr()
  )

  # Change arguments based on used input
  return(overwrite_arguments(item_stability_defaults, ellipse))

}

#' @noRd
# Default for {ggplot2} `theme` ----
# Updated 31.03.2024
ggplot2_theme_defaults <- function(organize_df, ellipse)
{

  # Get dimensions of the data frame
  dimensions <- dim(organize_df)

  # Set size defaults
  size_default <- seq.int(6, 12, 0.25) # length = 25

  # Adjust label sizes based on number of nodes
  number_size <- min(
    which(dimensions[1] > seq.int(200, 0, length.out = 25))
  )

  # Adjust label sizes based on characters in item name
  max_characters <- max(nvapply(organize_df$Node, nchar))
  character_size <- min(
    which(max_characters > seq.int(100, 0, length.out = 25))
  )

  # Get text size
  text_size <- size_default[min(number_size, character_size)]

  # Set up defaults
  theme_defaults <- list(
    legend.title = ggplot2::element_text(face = "bold", hjust = 1),
    axis.title = ggplot2::element_text(face = "bold"),
    axis.text.y = ggplot2::element_text( # size based on above
      size = size_default[min(number_size, character_size)]
    )
  )

  # Get `theme` defaults and overwrite them as necessary
  theme_ARGS <- obtain_arguments(ggplot2::theme, theme_defaults)

  # Overwrite with user-supplied arguments
  return(overwrite_arguments(theme_ARGS, ellipse))

}

#' @exportS3Method
# S3 Plot Method ----
# Updated 16.03.2025
plot.itemStability <- function(x, ...)# plot.type = c("all", "empirical"), ...)
{

  # Check for missing
  # plot.type <- swiftelse(missing(plot.type), "empirical", tolower(plot.type))

  # Obtain ellipse arguments
  ellipse <- list(...)

  # Get attributes
  x_attributes <- attributes(x)

  # Check for hierarchical EGA
  if(
    "methods" %in% names(x_attributes) &&
    x_attributes$methods$EGA.type == "hierega"
  ){

    # Get number of legend columns
    legend_rows <- digits(
      max(x$lower_order$membership$structure, na.rm = TRUE)
    ) + 1

    # Set up colors
    colors <- attributes(x)$color

    # Get number of higher order
    higher_ndim <- seq_len(unique_length(x$higher_order$membership$structure))

    # Get colors
    ## Lower order
    lower_colors <- colors[-higher_ndim]
    lower_colors <- lower_colors[
      x$lower_order$membership$structure[order(x$lower_order$membership$structure)]
    ]
    ## Higher order
    higher_colors <- colors[higher_ndim]
    higher_colors <- higher_colors[
      x$higher_order$membership$structure[order(x$higher_order$membership$structure)]
    ]

    # Get lower plot
    lower_order_plot <- plot(x$lower_order, color = lower_colors, ...) +
      ggplot2::guides(color = ggplot2::guide_legend(nrow = legend_rows))

    # Get higher plot
    higher_order_plot <- silent_call(
      plot(x$higher_order, color = higher_colors, ...) +
        ggplot2::guides(color = ggplot2::guide_legend(nrow = legend_rows)) +
        ggplot2::scale_x_discrete(limits = rev(lower_order_plot$data$Node))
    )

    # Return final plot
    return(
      silent_plot(
        ggpubr::ggarrange(
          lower_order_plot, higher_order_plot,
          labels = c("Lower Order", "Higher Order"),
          ...
        )
      )
    )

  }else{

    # # Check for print
    # if(plot.type == "all"){
    #
    #   # Obtain node names
    #   node_names <- names(x$membership$empirical)
    #
    #   # Obtain dimensions
    #   dimensions <- dim(x$item.stability$all.dimensions)
    #   dim_sequence <- seq_len(dimensions[2])
    #
    #   # Set up for heatmap
    #   heat_df <- data.frame(
    #     Node = factor(
    #       rep(node_names, each = dimensions[2]),
    #       levels = rev(
    #         node_names[
    #           order(
    #             x$membership$empirical,
    #             1 - x$item.stability$empirical.dimensions,
    #             node_names
    #           )
    #         ]
    #       )
    #     ),
    #     Replication = as.vector(t(x$item.stability$all.dimensions)),
    #     Community = factor(rep(dim_sequence, dimensions[1]), levels = dim_sequence)
    #   )
    #
    #   # Set alpha
    #   alpha <- swiftelse("alpha" %in% names(ellipse), ellipse$alpha, 0.70)
    #
    #   # Remove "color" from `ellipse`
    #   if("color" %in% names(ellipse)){
    #     color <- ellipse$color
    #     ellipse <- ellipse[names(ellipse) != "color"]
    #   }
    #
    #   # Set size defaults
    #   size_default <- seq.int(6, 12, 0.25) # length = 25
    #
    #   # Adjust label sizes based on number of nodes
    #   number_size <- min(
    #     which(dimensions[1] > seq.int(200, 0, length.out = 25))
    #   )
    #
    #   # Adjust label sizes based on characters in item name
    #   max_characters <- max(nvapply(as.character(heat_df$Node), nchar))
    #   character_size <- min(
    #     which(max_characters > seq.int(100, 0, length.out = 25))
    #   )
    #
    #   # Get text size
    #   text_size <- size_default[min(number_size, character_size)]
    #
    #   # Plot heatmap
    #   base_canvas <- ggplot2::ggplot(data = heat_df, ggplot2::aes(x = Community, y = Node)) +
    #     ggplot2::geom_tile(ggplot2::aes(fill = Community, alpha = Replication * alpha)) +
    #     ggplot2::geom_text(
    #       label = swiftelse(heat_df$Replication == 0, "", heat_df$Replication),
    #       size = sqrt(number_size) - 1
    #     ) +
    #     ggplot2::scale_fill_manual(
    #       name = "Communities",
    #       values = c(
    #         ggplot2::alpha(attributes(x)$color, alpha = alpha),
    #         rep("grey", dimensions[2] - length(attributes(x)$color))
    #       )
    #     ) +
    #     ggplot2::scale_alpha_continuous(limits = c(0, 1), range = c(0, 1)) +
    #     ggplot2::guides(alpha = "none") +
    #     ggplot2::theme(
    #       panel.background = ggplot2::element_blank(),
    #       axis.ticks = ggplot2::element_blank(),
    #       axis.text = ggplot2::element_text(size = text_size),
    #       axis.title = ggplot2::element_text(size = text_size + 2, face = "bold"),
    #       axis.text.x = ggplot2::element_blank(),
    #       axis.title.x = ggplot2::element_blank(),
    #       legend.title = ggplot2::element_text(size = text_size, face = "bold", hjust = 0.5),
    #       legend.text = ggplot2::element_text(size = text_size - 2),
    #       legend.position = "top"
    #     )
    #
    #   # Update colors
    #   if("scale_color_manual" %in% names(ellipse)){
    #     updated_canvas <- base_canvas +
    #       do.call(ggplot2::scale_color_manual, ellipse$scale_color_manual)
    #   }else if(exists("color", envir = environment())){
    #
    #     # Use defined colors
    #     updated_canvas <- base_canvas +
    #       ggplot2::scale_color_manual(
    #         values = color,
    #         breaks = sort(x$membership$structure)
    #       )
    #
    #   }else{
    #
    #     # Use default of "polychrome"
    #     updated_canvas <- base_canvas +
    #       ggplot2::scale_color_manual(
    #         values = color_palette_EGA(
    #           "polychrome", x$membership$structure, sorted = TRUE
    #         ),
    #         breaks = sort(x$membership$structure)
    #       )
    #
    #   }
    #
    #   # Return plot
    #   return(updated_canvas)
    #
    # }else if(plot.type == "empirical"){

      # Set up for plot
      organize_df <- fast.data.frame(
        c(
          names(x$membership$empirical),
          x$item.stability$empirical.dimensions,
          x$membership$structure
        ), nrow = length(x$membership$structure), ncol = 3,
        colnames = c("Node", "Replication", "Community")
      )

      # Set up data frame structure
      organize_df$Replication <- as.numeric(organize_df$Replication)
      organize_df$Community <- factor(
        x$membership$structure,
        levels = seq_len(unique_length(x$membership$structure))
      )

      # Remove "color" from `ellipse`
      if("color" %in% names(ellipse)){
        color <- ellipse$color
        ellipse <- ellipse[names(ellipse) != "color"]
      }

      # Get base plot
      base_canvas <- do.call(
        ggpubr::ggdotchart,
        item_stability_defaults(organize_df, ellipse)
      )

      # Add additional layer to plot with {ggplot2}'s `theme` updated
      updated_canvas <- base_canvas +
        ggplot2::ylim(c(0, 1)) + # non-negotiable
        do.call( # flexibly allow user to adjust the `theme`
          ggplot2::theme,
          ggplot2_theme_defaults(organize_df, ellipse)
        )

      # Manually update alpha
      updated_canvas$layers[[2]]$aes_params$alpha <- swiftelse(
        "alpha" %in% names(ellipse), ellipse$alpha, 0.70
      )

      # Update colors
      if("scale_color_manual" %in% names(ellipse)){
        updated_canvas <- updated_canvas +
          do.call(ggplot2::scale_color_manual, ellipse$scale_color_manual)
      }else if(exists("color", envir = environment())){

        # Use defined colors
        updated_canvas <- updated_canvas +
          ggplot2::scale_color_manual(
            values = color,
            breaks = sort(x$membership$structure)
          )

      }else{

        # Use default of "polychrome"
        updated_canvas <- updated_canvas +
          ggplot2::scale_color_manual(
            values = color_palette_EGA(
              "polychrome", x$membership$structure, sorted = TRUE
            ),
            breaks = sort(x$membership$structure)
          )

      }

      # Lastly, get x-axis organization
      if("scale_x_discrete" %in% names(ellipse)){
        updated_canvas <- updated_canvas +
          do.call(ggplot2::scale_x_discrete, ellipse$scale_x_discrete)
      }else{ # Otherwise, apply default
        updated_canvas <- updated_canvas +
          ggplot2::scale_x_discrete(limits = rev(updated_canvas$data$Node))
      }

      # Return plot
      return(updated_canvas)

    # }

  }

}

#' @noRd
# Argument Deprecation ----
# Updated 06.07.2023
itemStability_deprecation <- function(ellipse)
{

  # Check if 'orig.wc' has been input as an argument
  if("orig.wc" %in% names(ellipse)){

    # Give deprecation warning
    warning(
      "The 'orig.wc' argument has been deprecated.\n\nInstead, use the 'structure'",
      call. = FALSE
    )

    # Overwrite structure argument
    ellipse$structure <- ellipse$orig.wc

    # Remove 'orig.wc' argument
    ellipse <- ellipse[names(ellipse) != "orig.wc"]

  }

  # Give warning for 'item.freq'
  if("item.freq" %in% names(ellipse)){
    warning("The 'item.freq' argument has been deprecated", call. = FALSE)
  }

  # Check if 'plot.item.rep' has been input as an argument
  if("plot.item.rep" %in% names(ellipse)){

    # Give deprecation warning
    warning(
      paste(
        "The 'plot.item.rep' argument has been deprecated.\n\nInstead use: IS.plot =",
        ellipse$plot.item.rep
      ), call. = FALSE
    )

    # Handle the plot appropriately
    ellipse$IS.plot <- ellipse$plot.item.rep

  }

  # Return ellipse arguments
  return(ellipse)

}

#' @noRd
# `hierEGA` check for structure input ----
# Updated 13.08.2023
hierEGA_structure <- function(ega_object, structure)
{

  # Return NULL if NULL
  if(is.null(structure)){
    return(
      list(
        lower_order = ega_object$lower_order$wc,
        higher_order = single_revalue_memberships(
          ega_object$lower_order$wc, ega_object$higher_order$wc
        )
      )
    )
  }

  # Get names of structure
  structure_names <- names(structure)

  # Not NULL, proceed with lower order
  if(any(structure_names %in% c("lower_order", "higher_order"))){

    # Set up result as NULL
    result <- list(
      lower_order = NULL,
      higher_order = NULL
    )

    # First, check for lower order
    if("lower_order" %in% structure_names){

      # Perform checks
      length_error(structure$lower_order, length(ega_object$lower_order$wc), "hierEGA_structure")

      # If no error, then ensure names
      names(structure$lower_order) <- names(ega_object$lower_order$wc)

      # Send into result
      result$lower_order <- structure$lower_order

    }

    # Then, check for higher order
    if("higher_order" %in% structure_names){

      # Get higher order length
      higher_order_length <- length(ega_object$higher_order$wc)

      # Check for lower order structure
      if(!is.null(result$lower_order)){
        lower_order_length <- unique_length(structure$lower_order)
      }

      # Perform checks
      length_error(
        structure$higher_order, c( # could be length of higher or lower order
          lower_order_length,
          higher_order_length,
          length(ega_object$lower_order$wc)
        ), "hierEGA_structure"
      )

      # Check for higher order length
      if(
        length(structure$higher_order) %in%
        c(lower_order_length, higher_order_length)
      ){

        # Needs to be revalued
        structure$higher_order <- single_revalue_memberships(
          swiftelse( # If NULL, then base on empirical lower order result
            is.null(result$lower_order),
            ega_object$lower_order$wc,
            result$lower_order
          ),
          structure$higher_order
        )

      }


      # If no error, then ensure names
      names(structure$higher_order) <- names(ega_object$lower_order$wc)

      # Send into result
      result$higher_order <- structure$higher_order

    }

    # Return result
    return(result)

  }else{ # Send NULLs and warning

    # Send warning
    warning(
      paste(
        "Input to 'structure' was provided but did not match expected input.",
        "For `hierEGA`, 'structure' should be a list with elements \"lower_order\",",
        "\"higher_order\", or both.\n\nUsing default empirical EGA structure instead"
      ),
      call. = FALSE
    )

    # Send back NULLs
    return(
      list(
        lower_order = NULL,
        higher_order = NULL
      )
    )

  }

}

#' @noRd
# Get structure with error catching ----
# Updated 13.08.2023
get_structure <- function(bootega_wc, structure)
{

  # Update target structure
  if(is.null(structure)){

    # No structure provided, then use empirical EGA
    structure <- bootega_wc

  }else{ # User provided structure... make sure it works

    # Object type error
    object_error(structure, c("vector", "factor", "matrix", "data.frame"), "get_structure")

    # Get object type
    object_type <- get_object_type(structure)

    # Get length of bootstrap (empirical) membership
    wc_length <- length(bootega_wc)

    # Make adjustment for matrix or data frame
    if(object_type %in% c("matrix", "data.frame")){
      structure <- force_vector(structure)
    }

    # Make sure length is the same as bootstrap (empirical) membership
    length_error(structure, wc_length, "get_structure")

    # Finally, force values to be numeric
    structure <- force_numeric(structure)

  }

  # Check that structure isn't missing completely
  if(all(is.na(structure))){
    stop(
      paste0(
        "The 'structure' provided contains all missing values. Check the empirical structure. If you did not provide an empirical structure, then check your `bootEGA` output:`your_output$EGA$wc`",
        "\n\nIf all memberships are `NA`, then your network may be empty or different settings need to be applied in the community detection algorithm of `bootEGA`"
      ),
      call. = FALSE
    )
  }

  # Return the structure
  return(structure)

}

#' @noRd
# Item stability core ----
# Main function -- separated to handle `hierEGA`
# Updated 23.07.2023
itemStability_core <- function(ega_object, structure, bootstrap_structure, iter)
{

  # Get empirical memberships
  empirical_memberships <- ega_object$wc

  # Get node names
  node_names <- names(empirical_memberships)

  # Get structure (with error catching)
  structure <- get_structure(empirical_memberships, structure)

  # Get maximum number of communities
  maximum_communities <- max(
    max(bootstrap_structure, na.rm = TRUE),
    unique_length(structure)
  )

  # Get homogenized memberships
  homogenized_memberships <- community.homogenize(
    target.membership = structure,
    convert.membership = bootstrap_structure
  )

  # Tabulate for each variable and get proportions for each community
  replicate_proportions <- matrix(
    nvapply(  # `matrix` prevents drop to vector when all are unidimensional
      as.data.frame(homogenized_memberships),
      tabulate, maximum_communities,
      LENGTH = maximum_communities
    ), ncol = maximum_communities, byrow = TRUE
  ) / iter

  # Assign names
  dimnames(replicate_proportions) <- list(
    node_names, # nodes
    format_integer( # communities
      numbers = seq_len(maximum_communities),
      places = digits(maximum_communities) - 1
    )
  )

  # Get empirical proportions
  empirical_proportions <- nvapply(
    nrow_sequence(replicate_proportions),
    function(row){replicate_proportions[row, structure[row]]}
  )

  # Ensure proper names
  names(empirical_proportions) <- node_names

  # Initialize results
  results <- list(
    membership = list(
      empirical = empirical_memberships,
      bootstrap = homogenized_memberships,
      structure = structure
    ),
    item.stability = list(
      empirical.dimensions = empirical_proportions,
      all.dimensions = replicate_proportions
    )
  )

  # Set class
  class(results) <- "itemStability"

  # Return results
  return(results)

}

#' @noRd
# Global variables needed for CRAN checks ----
# Updated 30.01.2025
utils::globalVariables(c("Community", "Node", "Replication"))
