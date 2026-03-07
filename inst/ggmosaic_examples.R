library(dplyr)
library(ggplot2)
library(marimekko)
library(ggmosaic)

# A few modifications to data
flights <- fly %>%
  filter(!is.na(do_you_recline), !is.na(rude_to_recline))

# --- ggmosaic ---
ggplot(data = flights) +
  geom_mosaic(aes(x = product(do_you_recline), fill = do_you_recline), divider = "vbar") +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(y = "Do you recline?", x = "", title = "Bar Chart")

# --- marimekko --- (bar chart = standardized one-variable plot)
ggplot(flights) +
  geom_bar(aes(y = do_you_recline, fill = do_you_recline)) +
  theme_marimekko() +
  labs(y = "Do you recline?", x = "", title = "Bar Chart")

# --- ggmosaic ---
ggplot(data = flights) +
  geom_mosaic(aes(x = product(do_you_recline), fill = do_you_recline), divider = "vspine") +
  theme(axis.text.x = element_blank(), axis.ticks.x = element_blank()) +
  labs(y = "Do you recline?", x = "", title = "Spine Plot")

# --- marimekko --- (spine plot = single-variable formula)
ggplot(flights) +
  geom_marimekko(
    aes(fill = do_you_recline),
    formula = ~do_you_recline
  ) +
  scale_x_marimekko() +
  theme_marimekko() +
  coord_flip() +
  labs(y = "Do you recline?", x = "", title = "Spine Plot")

# --- ggmosaic ---
ggplot(data = flights) +
  geom_mosaic(aes(x = product(do_you_recline, rude_to_recline), fill = do_you_recline),
    divider = c("vspine", "hbar")
  ) +
  labs(x = "Is it rude to recline?", y = "Do you recline?", title = "Stacked Bar Chart")

# --- marimekko --- (stacked bar chart = two-variable formula)
# wrong: ggmosaic just produce stacked barchart with do_you_recline levels as y-axis labels
ggplot(flights) +
  geom_marimekko(
    aes(fill = do_you_recline),
    formula = ~ rude_to_recline | do_you_recline
  ) +
  scale_x_marimekko() +
  scale_y_marimekko() +
  theme_marimekko() +
  labs(x = "Is it rude to recline?", y = "Do you recline?", title = "Stacked Bar Chart")

# --- ggmosaic ---
ggplot(data = flights) +
  geom_mosaic(aes(x = product(do_you_recline, rude_to_recline), fill = do_you_recline)) +
  labs(y = "Do you recline?", x = "Is it rude to recline?", title = "Mosaic Plot (2 variables)")

# --- marimekko --- (mosaic plot = two-variable formula)
ggplot(flights) +
  geom_marimekko(
    aes(fill = do_you_recline),
    formula = ~ rude_to_recline | do_you_recline
  ) +
  scale_x_marimekko() +
  scale_y_marimekko() +
  theme_marimekko() +
  labs(y = "Do you recline?", x = "Is it rude to recline?", title = "Mosaic Plot (2 variables)")


# --- ggmosaic ---
ggplot(data = flights) +
  geom_mosaic(aes(
    x = product(eliminate_reclining, do_you_recline, rude_to_recline),
    fill = do_you_recline, alpha = eliminate_reclining
  )) +
  scale_alpha_manual(values = c(.7, .9)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
  labs(
    y = "Do you recline?", x = "Eliminate reclining?:Is it rude to recline?",
    title = "Mosaic Plot (3 variables)"
  )

# --- marimekko --- (3 variables via geom_marimekko, formula-based)
ggplot(flights) +
  geom_marimekko(
    aes(fill = do_you_recline),
    formula = ~ rude_to_recline | do_you_recline | eliminate_reclining
  ) +
  scale_x_marimekko() +
  scale_y_marimekko() +
  theme_marimekko() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
  labs(
    y = "Do you recline?",
    x = "Eliminate reclining? : Is it rude to recline?",
    title = "Mosaic Plot (3 variables)"
  )

# --- ggmosaic ---
ggplot(data = flights) +
  geom_mosaic(aes(
    x = product(do_you_recline, eliminate_reclining, rude_to_recline),
    fill = do_you_recline, alpha = eliminate_reclining
  ), divider = ddecker()) +
  scale_alpha_manual(values = c(.7, .9)) +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
  labs(
    y = "Do you recline?", x = "Eliminate reclining?: Is it rude to recline?",
    title = "Double Decker Plot"
  )

# --- marimekko --- (double decker = all h except last v)
# ddecker: h(rude_to_recline), h(eliminate_reclining), v(do_you_recline)
# Formula: ~ rude_to_recline + eliminate_reclining | do_you_recline
ggplot(flights) +
  geom_marimekko(
    aes(fill = do_you_recline),
    formula = ~ rude_to_recline + eliminate_reclining | do_you_recline
  ) +
  scale_x_marimekko() +
  scale_y_marimekko() +
  theme_marimekko() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
  labs(
    y = "Do you recline?",
    x = "Eliminate reclining? : Is it rude to recline?",
    title = "Double Decker Plot"
  )


ggplot(flights) +
  geom_marimekko(
    aes(fill = interaction(eliminate_reclining, rude_to_recline)),
    formula = ~ do_you_recline | eliminate_reclining + rude_to_recline
  ) +
  scale_x_marimekko() +
  scale_y_marimekko() +
  theme_marimekko() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
  labs(
    y = "Do you recline?",
    x = "Eliminate reclining? : Is it rude to recline?",
    title = "Double Decker Plot"
  )


# extreme example
flights6 <- fly %>%
  filter(
    !is.na(do_you_recline), !is.na(rude_to_recline),
    !is.na(eliminate_reclining), !is.na(gender),
    !is.na(has_child_under_18), !is.na(window_shade)
  )

ggplot(flights6) +
  geom_marimekko(
    aes(fill = interaction(do_you_recline, gender, window_shade)),
    formula = ~ rude_to_recline | do_you_recline | eliminate_reclining | gender | has_child_under_18 | window_shade
  ) +
  scale_x_marimekko() +
  scale_y_marimekko() +
  theme_marimekko() +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, vjust = .5)) +
  labs(title = "Mosaic Plot (6 variables, 5 direction changes)")


ggplot(titanic) +
  geom_marimekko(
    aes(fill = Survived, alpha = after_stat(.proportion), weight = Freq),
    formula = ~ Class | Survived
  ) +
  scale_x_marimekko() +
  scale_y_marimekko() +
  guides(alpha = "none")


# --- scale_fill_manual: choose colors for specific levels ---
titanic <- as.data.frame(Titanic)
ggplot(titanic) +
  geom_marimekko(
    aes(fill = Survived, weight = Freq),
    formula = ~ Class | Survived
  ) +
  scale_fill_manual(values = c("No" = "grey80", "Yes" = "steelblue")) +
  scale_x_marimekko() +
  scale_y_marimekko()

# --- conditional fill based on residuals ---
# Highlight only cells with |residual| > 2 (significant deviation)
# Step 1: compute tiles with fortify_marimekko
tiles <- fortify_marimekko(titanic, Class, Survived, weight = Freq, residuals = TRUE)
tiles$significant <- ifelse(abs(tiles$.resid) > 2, "significant", "not significant")

ggplot(tiles) +
  geom_rect(aes(
    xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
    fill = significant
  ), colour = "white", alpha = 0.9) +
  scale_fill_manual(values = c(
    "significant" = "firebrick",
    "not significant" = "grey80"
  )) +
  scale_x_marimekko() +
  scale_y_marimekko()

# --- fill by residual sign (positive = over-represented, negative = under-represented) ---
tiles$direction <- ifelse(tiles$.resid > 0, "over-represented", "under-represented")

ggplot(tiles) +
  geom_rect(aes(
    xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax,
    fill = direction, alpha = abs(tiles$.resid)
  ), colour = "white") +
  scale_fill_manual(values = c(
    "over-represented" = "steelblue",
    "under-represented" = "firebrick"
  )) +
  scale_x_marimekko() +
  scale_y_marimekko() +
  guides(alpha = "none")

# todo:

# check which contingency table statistics can be applied: https://en.wikipedia.org/wiki/Contingency_table
# do you want to extend package to handle 2x2 tables specificly? (odds ratios etc.)
