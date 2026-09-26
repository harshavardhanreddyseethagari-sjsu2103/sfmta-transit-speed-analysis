library(httr)
library(jsonlite)
library(dplyr)
library(ggplot2)

# Pulling data from Socrata API in json format
base_url <- "https://data.sf.gov/resource/x344-v6h6.json"

resp <- GET(base_url, query = list(
  `$where` = "vehicle_position_date_time between '2021-06-01T00:00:00' and '2021-06-07T23:59:59'",
  `$limit` = 50000
))

raw_sample <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))
names(raw_sample)

# Data Preprocessing
downtown_lon <- -122.4193
downtown_lat <- 37.7793

sample_data <- raw_sample |>
  mutate(
    loc_x = as.numeric(loc_x),
    loc_y = as.numeric(loc_y),
    average_speed = as.numeric(average_speed),
    vehicle_position_date_time = as.POSIXct(
      vehicle_position_date_time, format = "%Y-%m-%dT%H:%M:%OS"
    )
  ) |>
  filter(
    average_speed > 0,
    loc_y > 37.70, loc_y < 37.83,
    loc_x > -122.52, loc_x < -122.36
  ) |>
  mutate(
    dist_km = sqrt(
      ((loc_y - downtown_lat) * 111.32)^2 +
      ((loc_x - downtown_lon) * 111.32 * cos(downtown_lat * pi / 180))^2
    )
  )

# Choosing Civic Center, SF as the primary reference point
quick_check <- lm(average_speed ~ dist_km, data = sample_data)
summary(quick_check)
cor(sample_data$dist_km, sample_data$average_speed)

# Scatter plot
ggplot(sample_data, aes(x = dist_km, y = average_speed)) +
  geom_point(alpha = 0.15, size = 0.8) +
  geom_smooth(method = "lm", se = TRUE, color = "steelblue") +
  theme_minimal() +
  labs(
    x = "Distance from downtown (km)",
    y = "Average speed (mph)",
    title = "Transit vehicle speed vs. distance from downtown SF"
  )

# For different reference points
centroid <- sample_data |>
  summarize(centroid_lat = mean(loc_y), centroid_lon = mean(loc_x))

ref_points <- list(
  civic_center = c(lat = 37.7793, lon = -122.4193),
  union_square = c(lat = 37.7880, lon = -122.4074),
  centroid     = c(lat = centroid$centroid_lat, lon = centroid$centroid_lon)
)

run_model <- function(ref_lat, ref_lon, data) {
  data <- data |>
    mutate(
      dist_km = sqrt(
        ((loc_y - ref_lat) * 111.32)^2 +
        ((loc_x - ref_lon) * 111.32 * cos(ref_lat * pi / 180))^2
      )
    )
  lm(average_speed ~ dist_km, data = data)
}

results <- lapply(ref_points, function(p) run_model(p["lat"], p["lon"], sample_data))

comparison <- data.frame(
  reference_point = names(results),
  slope = sapply(results, function(m) coef(m)[2]),
  r_squared = sapply(results, function(m) summary(m)$r.squared),
  p_value = sapply(results, function(m) summary(m)$coefficients[2, 4])
)
print(comparison)

# Reporting interval check (data quality) of each data record (row)
top_vehicle <- sample_data |>
  count(vehicle_id, sort = TRUE) |>
  slice(1) |>
  pull(vehicle_id)

one_vehicle <- sample_data |>
  filter(vehicle_id == top_vehicle) |>
  arrange(vehicle_position_date_time) |>
  mutate(
    time_gap_sec = as.numeric(difftime(
      vehicle_position_date_time, lag(vehicle_position_date_time), units = "secs"
    ))
  )
summary(one_vehicle$time_gap_sec)

# save scatter plot, run the following line in R console
# ggsave("output/scatter_plot.png", width = 8, height = 5)