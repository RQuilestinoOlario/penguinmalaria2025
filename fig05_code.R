# libraries 
required_packages <- c(
  "readr", "dplyr", "tidyr", "stringr", "janitor",
  "sf", "rnaturalearth", "rnaturalearthdata", "countrycode",
  "ggplot2", "scales", "patchwork"
)

installed <- required_packages %in% rownames(installed.packages())
if (any(!installed)) {
  install.packages(required_packages[!installed])
}

# functions
read_gt_geomap <- function(path, label = NULL) {
  df <- suppressMessages(read_csv(path, skip = 2, col_names = c("country","hits"), show_col_types = FALSE)) %>%
    mutate(hits = ifelse(hits == "<1", "0", as.character(hits))) %>%
    mutate(hits = suppressWarnings(as.numeric(hits))) %>%
    filter(!is.na(country)) %>%
    mutate(term = label %||% tools::file_path_sans_ext(basename(path))) %>%
    mutate(iso3 = countrycode(country, "country.name", "iso3c", warn = FALSE)) %>%
    mutate(iso3 = case_when(
      country %in% c("Falkland Islands (Islas Malvinas)") ~ "FLK",
      country %in% c("Congo - Kinshasa","DR Congo","Democratic Republic of the Congo") ~ "COD",
      country %in% c("Congo - Brazzaville","Republic of the Congo") ~ "COG",
      country %in% c("Côte d’Ivoire","Cote d'Ivoire") ~ "CIV",
      country %in% c("Eswatini","Swaziland") ~ "SWZ",
      country %in% c("Cape Verde","Cabo Verde") ~ "CPV",
      country %in% c("Myanmar (Burma)","Myanmar") ~ "MMR",
      country %in% c("Palestine") ~ "PSE",
      TRUE ~ iso3
    ))
  df
}

plot_geomap <- function(df, panel_tag, fill_high) {
  world <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
    select(iso_a3, name_long, geometry)
  
  df_map <- df %>%
    left_join(world, by = c("iso3" = "iso_a3")) %>%
    filter(!is.na(geometry)) %>%
    st_as_sf()
  
  ggplot(df_map) +
    geom_sf(aes(fill = hits), color = "white", linewidth = 0.2) +
    scale_fill_gradient(limits = c(0,100), oob = squish,
                        low = "#f9f9f9", high = fill_high,
                        name = "Interest (0–100)") +
    coord_sf(crs = "+proj=robin") +
    theme_void(base_size = 11) +
    theme(legend.position = "bottom",
          plot.tag = element_text(face = "bold", size = 12, margin = margin(6,0,0,6))) +
    labs(tag = panel_tag)
}

# maps b and c
gm1 <- read_gt_geomap("fig05_map_malariapenguin.csv",
                      label = '"malaria" + "penguin"')
p_map1 <- plot_geomap(gm1, panel_tag = "(c)", fill_high = "#0072B2") +
  labs(title = 'Interest by region: "malaria" + "penguin"',
       subtitle = "Google Trends • Worldwide • Web search")

gm2 <- read_gt_geomap("fig05_map_avianmalariapenguin.csv",
                      label = '"avian malaria" + "penguin"')
p_map2 <- plot_geomap(gm2, panel_tag = "(b)", fill_high = "#D55E00") +
  labs(title = 'Interest by region: "avian malaria" + "penguin"',
       subtitle = "Google Trends • Worldwide • Web search")

# line graph a
mt <- suppressMessages(read_csv("fig05_line_yearlytrends.csv", skip = 2, show_col_types = FALSE)) %>%
  clean_names()
names(mt)[1:3] <- c("date","avian_malaria_plus_penguin","malaria_plus_penguin")

mt_long <- mt %>%
  mutate(date = as.Date(paste0(date,"-01"))) %>%
  pivot_longer(-date, names_to = "series", values_to = "hits") %>%
  mutate(series = recode(series,
                         avian_malaria_plus_penguin = '"avian malaria" + "penguin"',
                         malaria_plus_penguin       = '"malaria" + "penguin"'))

p_line <- ggplot(mt_long, aes(date, hits, color = series)) +
  geom_line(linewidth = 0.9) +
  scale_y_continuous(limits = c(0,100), expand = expansion(mult = c(0,0.05))) +
  scale_x_date(date_breaks = "3 years", labels = label_date("%Y")) +
  scale_color_manual(values = c('"avian malaria" + "penguin"' = "#D55E00",
                                '"malaria" + "penguin"' = "#0072B2"),
                     name = NULL) +
  labs(y = "Relative interest (0–100)", x = NULL) +
  theme_minimal(base_size = 12) +
  theme(panel.grid.minor = element_blank(),
        legend.position = "bottom",
        plot.tag = element_text(face = "bold", size = 12, margin = margin(6,0,0,6))) +
  labs(tag = "(a)",
       title = "Google search interest for penguins + malaria terms (2004–present)",
       subtitle = "Worldwide • Web search • Monthly",
       caption = "Source: Google Trends. Values are relative; 100 = peak within each query set.")

# plot together
combo <- p_line / (p_map2 | p_map1) +
  plot_layout(heights = c(1,1), guides = "collect") &
  theme(
    legend.position = "bottom",
    plot.tag = element_text(
      family = "sans", face = "bold",
      size = 22,                # increase tag size
      margin = margin(4, 0, 0, 8)  # slight spacing
    )
  )
combo

# export
ggsave("google_trends_penguins_malaria_COMBO_okabeito.png", combo,
       width = 12, height = 10, dpi = 300)
ggsave("google_trends_penguins_malaria_COMBO_okabeito.pdf", combo,
       width = 12, height = 10)