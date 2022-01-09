#
# Title: "How much caffeine is in my Starbucks drink"
# Author: "Alvaro Munoz"
# Date: "01/09/2022"
# Dataset: https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-12-21/starbucks.csv
# Output: "starbucks_draw.png"
#
#
# Libraries
if(!require(tidyverse))install.packages("tidyverse")
if(!require(cowplot))install.packages("cowplot")
if(!require(magick))install.packages("magick")
if(!require(stringr))install.packages("stringr")
#
filepath <- "~\\R Projects\\starbucks-beverages\\Data\\"
output <- "~\\R Projects\\starbucks-beverages\\Output\\"
#
# Read dataset 
starbucks = readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2021/2021-12-21/starbucks.csv')
#
# Line used to download the file to my local drive as a backup
#  write.csv(starbucks, paste0(filepath, "starbucks.csv"))
#
# Identify top caffeine beverages by product
beverages <- data.table::data.table(starbucks, key = c("product_name", "caffeine_mg"))
beverages <- beverages[ , head(.SD, 1), by = c("product_name", "caffeine_mg")]
#
# Create a function to set the caffeine level
concentration <- function(.caffeine){
  ifelse(.caffeine <= 0, 
          yes = "None",
          no = ifelse(.caffeine <= 100, 
                       yes = "Low",
                       no = ifelse(.caffeine <= 200, 
                                    yes = "Medium",
                                    no = ifelse(.caffeine <= 300,
                                                 yes = "High", no = "Intense"
                                    )
                       )
          )
  )
}
#
# Test function 
concentration(.caffeine = 100)
concentration(.caffeine = 340)
#
# Apply function to the entire dataset using column 2
beverages <- beverages %>%
  mutate(content = apply(beverages[ , 2], 2, concentration))
#
# Prepare labels for the coord_polar chart
label_datapoints <- data.frame(id = 1:nrow(beverages),
                               product_name = str_to_title(beverages$product_name),
                               size = beverages$size,
                               content = factor(beverages$content, levels = c("None", "Low", "Medium", "High", "Intense")),
                               caffeine_mg = beverages$caffeine_mg)
#
# Sort drinks by amount of caffeine
label_datapoints <- label_datapoints %>%
  arrange(caffeine_mg)
#
# Format data points
empty_bar <- 4   # Interspace between caffeine levels
to_add <- data.frame(matrix(NA, empty_bar * nlevels(label_datapoints$content), ncol(label_datapoints)))
colnames(to_add) <- colnames(label_datapoints)
to_add$content <- rep(levels(label_datapoints$content), each = empty_bar)
label_datapoints <- rbind(label_datapoints, to_add)
label_datapoints <- label_datapoints %>% arrange(content)
label_datapoints$id <- seq(1, nrow(label_datapoints))
#
# Adjust the angle of all the labels 
angle <- 90 - 360 * (label_datapoints$id - 0.5) / nrow(label_datapoints)
label_datapoints$hjust <- if_else(angle < -90, 1, 0) 
label_datapoints$angle <- if_else(angle < -90, angle + 180, angle)
#
# Create a data frame for base lines
base_label_datapoints <- label_datapoints %>% 
  group_by(content) %>%
  summarise(start = min(id), end = max(id) - empty_bar) %>%
  rowwise() %>%
  mutate(title = mean(c(start, end)))
#
# Create dataviz
starbucks_plot <- ggplot(label_datapoints, aes(x = as.factor(id), y = caffeine_mg, fill = content)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  ylim(-250, 500) +
  theme_minimal() +
  theme(axis.text = element_blank(), 
        axis.title = element_blank(), 
        panel.grid = element_blank(),
        plot.margin = unit(rep(-1, 4), "cm"),
        legend.title = element_blank (),
        legend.text = element_blank ()) +
  coord_polar(start = 0) +
  geom_text(data = label_datapoints,
            aes(x = id, y = caffeine_mg + 10,
                label = paste0(product_name, " - ", size, " [", caffeine_mg, " mg]"),
                hjust = hjust),
            color = "white",
            fontface = "bold",
            alpha = 0.6,
            size = 3.0,
            angle = label_datapoints$angle,
            inherit.aes = FALSE) +
  geom_segment(data = base_label_datapoints, aes(x = start, y = -5, xend = end, yend = -5),
               colour = "white",
               alpha = 0.8,
               size = 0.8,
               inherit.aes = FALSE) +
  geom_text(data = base_label_datapoints, aes(x = title, y = -18, label = content),
            hjust = c(1, 1, 0, 0, 0),
            colour = "white",
            alpha = 0.8,
            size = 5,
            fontface = "bold",
            inherit.aes = FALSE)
#
# Draw dataviz
starbucks_draw <- ggdraw() +
  draw_plot(starbucks_plot, scale = 1, x = 0.05, y = -0.05) +
  draw_label("How much caffeine is\nin my Starbucks drink",
             x = 0.8,
             y = 0.9,
             size = 55,
             color = "white",
             fontface = "bold") +
  draw_label("Dataset: Starbucks Coffee Company | Dataviz: @amaburto | 2022",
             x = 0.3,
             y = 0.05,
             size = 25,
             color = "white") +
  draw_image(image = "~\\R Projects\\starbucks-beverages\\logo.png",
             x = 0.04,
             y = -0.05,
             scale = 0.1)
# 
# Save dataviz
ggsave(filename = (paste0(output, "starbucks_draw.png")),
       height = 28, 
       width = 28,
       bg = "black")
#
# End of file