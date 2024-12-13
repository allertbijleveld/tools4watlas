#' Create full tag ID or tag ID with specific length
#'
#' @author Johannes Krietsch
#' @param tag Tag number (either numeric or character). Maximally provide 6
#' digits, but less work.
#' @param short TRUE or FALSE for short or long tag ID
#' @param n if short = TRUE, how many digits should the short tag ID have?
#'
#' @return Full or short tag ID as character
#' @export
#'
#' @examples
#' tag <- 123
#' atl_full_tag_id(tag)
#' atl_full_tag_id(tag, short = TRUE)
#'
atl_full_tag_id <- function(tag, short = FALSE, n = 4) {
  # check input
  assertthat::assert_that(
    any(is.numeric(tag), is.character(tag)),
    msg = "tag provided must be numeric or character"
  )
  assertthat::assert_that(
    nchar(as.character(tag)) < 7,
    msg = glue::glue("tag should be < 7 digits, but is {nchar(tag)} digits")
  )

  # create long tag number
  tag_full <- as.character(as.numeric(tag) + 31001000000)

  # short format
  tag_last_n <- substr(tag_full, nchar(tag_full) - n + 1, nchar(tag_full))

  # return full or short tag number as character string
  ifelse(short == TRUE,
    return(tag_last_n),
    return(tag_full)
  )
}
