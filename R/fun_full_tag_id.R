#' Create full tag name
#' 
#' @importFrom stringr str_pad
#'
#' @param tag tag ID, either numeric or character
#' @param short TRUE or FALSE for short or long tag ID
#'
#' @return Full or short tag ID as character
#' @export
#'
#' @examples
#' 
#' tag = 123
#' 
#' atl_full_tag_id(tag)
#' atl_full_tag_id(tag, short = TRUE)
#' 
atl_full_tag_id <- function(tag, short = FALSE){
  
  # Make sure tagID has 4 digits
  x = stringr::str_pad(as.character(tag), 4, pad = "0")
  
  # Paste together to get full tag ID
  y = paste0("3100100", x)
  
  # Return full or short tagID as character string
  ifelse(short == TRUE, return(x), return(y))
  
}
