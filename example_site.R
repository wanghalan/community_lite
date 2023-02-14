# initialize
library(community)
output <- paste0(tempdir(), "/example_site")
init_site(output)
data <- data.frame(
  ID = 1:78,
  matrix(rnorm(234), 78, dimnames = list(NULL, c("x", "y", "z")))
)
write.csv(data, paste0(output, "/docs/data/data.csv"), row.names = FALSE)

library(catchment)
download_census_shapes(paste0(output, "/docs"), name = "states")

# rewrite site.R
writeLines('
page_navbar("Site Title")
page_menu(
  input_select("X Variable:", "variables", default = "x", id = "selected_x"),
  default_open = TRUE
)
output_plot("selected_x", "y", "z", id = "main_plot")
output_info("features.name", c(
  "variables.long_name" = "value",
  "variables.description",
  "variables.statement"
), subto = c("main_plot", "main_map"), floating = TRUE)
output_map(
  list(name = "data", id_property = "GEOID", url = paste0(output, "/docs/states.geojson")),
  color = "z", id = "main_map"
)
', paste0(output, "/site.R"))

# add data and build
data_add(
  paste0(output, "/docs/data/data.csv"),
  list(
    variables = list(
      z = list(
        long_name = "Variable Z",
        description = "A random variable, drawn from a normal distribution.",
        statement = "{features.name} has a Z value of {value}"
      )
    ),
    ids = list(
      variable = "ID",
      map = list(
        "3" = list(name = "No State 3"),
        "7" = list(name = "No State 7")
      )
    )
  )
)
site_build(output, open_after = TRUE, serve = TRUE)
