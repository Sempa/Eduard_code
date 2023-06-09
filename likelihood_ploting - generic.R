libraries <- c(
  "plyr", "ggplot2", "tidyverse", "data.table", "pracma",
  "cubature", "Rmisc", "gridExtra", "RColorBrewer", "splines", "coda"
)
for (x in libraries) {
  library(x, character.only = TRUE, warn.conflicts = FALSE, quietly = TRUE)
}

#' Logit function to generate Pr_t function
#' @param t is time, in days, since infection
#' @param parameters set of model parameters as evaluated in the glm function
#' @examples
#' func_logit_cubic(100, c(1, 0.5, 0.4, .003))
#' func_logit_cubic(500, c(1, -0.5, -0.4, -.003))
func_logit_cubic <- function(t, parameters) {
  1 / (1 + exp(-(parameters[1] + parameters[2] * t + parameters[3] * t^2 + parameters[4] * t^3
  )))
}
#' cloglog function to generate Pr_t function
#' @param t is time, in days, since infection
#' @param parameters set of model parameters as evaluated in the glm function
#' @examples
#' func_cloglog_cubic(100, c(1, 0.5, 0.4, .003))
#' func_cloglog_cubic(500, c(1, -0.5, -0.4, -.003))
func_cloglog_cubic <- function(t, parameters) {
  1 - exp(-exp(parameters[1] + parameters[2] * t + parameters[3] * t^2 + parameters[4] * t^3))
}

#' cloglog function to generate Pr_t function
#' @param t is time, in days, since infection
#' @param parameters set of model parameters as evaluated in the glm function
#' @examples
#' func_cloglog_cubic(100, c(1, 0.5, 0.4, .003))
#' func_cloglog_cubic(500, c(1, -0.5, -0.4, -.003))
functional_form_clogloglinear <- function(t, parameters) {
  1 - exp(-exp(parameters[1] + (parameters[2]) * log(t)))
}

#' Pr_t function used to generate Pr_t values using a logit link function.
#' this function receives a dataset, assay_value threshold or assay_value and interval between last negative to first positive.
#' @param data_set Patient dataset to be evaluated
#' @param GV_assayvalueTh assay_value threshold to be evaluated
#' @param t_since_inf interval size between last negative and first positive. This variable is a vector
#' @param parameters set of model parameters as evaluated in the glm function
pr_t_fun_logit_cubic <- function(data_set, GV_assayvalueTh, t_since_inf) {
  pr_t <- c(0)
  dat <- data_set %>%
    mutate(eddi_1 = eddi, eddi_2 = eddi^2, eddi_3 = eddi^3)
  counter <- 0
  for (i in 1:length(GV_assayvalueTh)) {
    counter <- counter + 1
    dat <- dat %>%
      mutate(recency = ifelse(assay_value <= GV_assayvalueTh[i] & viral_load > 1000 & eddi <= 1000, 1, 0))
    
    model <- suppressWarnings(glm2::glm2(recency ~ 1 + eddi_1 + eddi_2 + eddi_3, #
                                         family = stats::binomial(link = "logit"),
                                         data = dat
    ))
    pr_t_data <- rep(0, length(t_since_inf))
    for (j in 1:length(pr_t_data)) {
      pr_t_data[j] <- func_logit_cubic(parameters = c(
        model$coefficients[[1]], model$coefficients[[2]],
        model$coefficients[[3]], model$coefficients[[4]]
      ), t = j)
    }
    pr_t <- c(pr_t, pr_t_data)
  }
  return(pr_t[-1])
}

#' Pr_t function used to generate Pr_t values using a cloglog link function.
#' this function receives a dataset, assay_value threshold or assay_value and interval between last negative to first positive.
#' @param data_set Patient dataset to be evaluated
#' @param GV_assayvalueTh assay_value threshold to be evaluated
#' @param t_since_inf interval size between last negative and first positive. This variable is a vector
#' @param parameters set of model parameters as evaluated in the glm function
pr_t_fun_loglog_cubic <- function(data_set, GV_assayvalueTh, t_since_inf) {
  pr_t <- c(0)
  dat <- data_set %>%
    mutate(eddi_1 = eddi, eddi_2 = eddi^2, eddi_3 = eddi^3)
  counter <- 0
  for (i in 1:length(GV_assayvalueTh)) {
    counter <- counter + 1
    dat <- dat %>%
      mutate(recency = ifelse(assay_value <= GV_assayvalueTh[i] & viral_load > 1000 & eddi <= 1000, 1, 0))
    
    model <- suppressWarnings(glm2::glm2(recency ~ 1 + eddi_1 + eddi_2 + eddi_3, #
                                         family = stats::binomial(link = "cloglog"),
                                         data = dat
    ))
    
    pr_t_data <- rep(0, length(t_since_inf))
    for (j in 1:length(pr_t_data)) {
      pr_t_data[j] <- func_cloglog_cubic(parameters = c(
        model$coefficients[[1]], model$coefficients[[2]],
        model$coefficients[[3]], model$coefficients[[4]]
      ), t = j)
    }
    pr_t <- c(pr_t, pr_t_data)
  }
  return(pr_t[-1])
}


#' Pr_t function used to generate Pr_t values using a cloglog link function.
#' this function receives a dataset, assay_value threshold or assay_value and interval between last negative to first positive.
#' @param data_set Patient dataset to be evaluated
#' @param GV_assayvalueTh assay_value threshold to be evaluated
#' @param t_since_inf interval size between last negative and first positive. This variable is a vector
#' @param parameters set of model parameters as evaluated in the glm function
pr_t_fun_cloglinear<- function(data_set, GV_assayvalueTh, t_since_inf) {
  pr_t <- c(0)
  dat <- data_set %>%
    mutate(eddi_1 = eddi, eddi_2 = eddi^2, eddi_3 = eddi^3)
  counter <- 0
  for (i in 1:length(GV_assayvalueTh)) {
    counter <- counter + 1
    dat <- dat %>%
      mutate(recency = ifelse(assay_value <= GV_assayvalueTh[i] & viral_load > 1000 & eddi <= 1000, 1, 0))
    
    model <- suppressWarnings(glm2::glm2((recency) ~ 1 + I(log(eddi_1)),
                                         family = stats::binomial(link = "cloglog"),
                                         data = dat
    ))
    pr_t_data <- rep(0, length(t_since_inf))
    for (j in 1:length(pr_t_data)) {
      pr_t_data[j] <- functional_form_clogloglinear(parameters = c(
        model$coefficients[[1]], model$coefficients[[2]]#,
        # model$coefficients[[3]], model$coefficients[[4]]
      ), t = j)
    }
    pr_t <- c(pr_t, pr_t_data)
  }
  return(pr_t[-1])
}

#' Generates a vector of numbers on either side of and closest to the
#' target assay_value, which is used to generate Likelihood
#' @param value_x Patient assay_value as measurement, after the first HIV positive test.
#' @param vec_y A vector of ODns from 0.01 to 4 step size 0.01
#' @param to_select number to be selected from of ODns closest of the target assay_value, to be selected.
nearest_numbers <- function(value_x, vec_y, to_select) {
  # browser()
  y <- sort(vec_y)
  value_diff <- abs(value_x - y)
  dat <- (data.frame(y, value_diff) %>%
            arrange(value_diff) # %>%
          # filter(y!= value_x)
  )[1:(to_select + 1), 1]
  dat_1 <- ifelse(dat %in% value_x, dat, c(dat[1:to_select], value_x))
  return(dat_1)
}

#' Generates the glm model parameters used in the computation of likelihood of the target assay_value
#' given an inter-test interval target assay_value
#' @param dat a dataset of Pr_t values by assay_value threshold and per day over 1000 daystime that's brought in as a matrix.
#' @param value_x Patient assay_value as measurement, after the first HIV positive test.
#' @param to_select number to be selected from of ODns closest of the target assay_value, to be selected.
#' @param t_since_ln duration of inter-test interval.
#'
if (GV_AssayName == "LAg-Sedia" | GV_AssayName == "LAg-Maxim") {
  vec_y <- seq(0.01, 5, GV_assay_value_stepsize)
} else if (GV_AssayName == "ArchitectAvidity") {
  vec_y <- seq(20, 245, GV_assay_value_stepsize)
} else if (GV_AssayName == "Geenius") {
  vec_y <- seq(0.01, 5, GV_assay_value_stepsize)
} else if (GV_AssayName == "ArchitectUnmodified") {
  vec_y <- seq(0, 870, GV_assay_value_stepsize)
}
likelihood_param_quad_function <- function(dat, target_assay_value, GV_assay_value_stepsize, t_since_ln) {
  # browser()
  vec_x <- c(nearest_numbers(value_x = target_assay_value, vec_y = vec_y, to_select = 6))
  dat <- subset(as.data.frame(dat) %>% mutate(x = as.character(threshold)), x %in% as.character(vec_x))
  pr_t_slope_data <- data.frame(
    t_var = NA,
    intercept = NA,
    linear_term = NA,
    quad_term = NA
  )
  counter <- 0
  for (i in 1:length(t_since_ln)) {
    counter <- counter + 1
    m1 <- suppressWarnings(glm2::glm2(pr_t ~ 1 + threshold + I(threshold^2), #
                                      family = stats::gaussian(link = "identity"),
                                      data = subset(dat, GV_vec_time == t_since_ln[i])
    ))
    
    pr_t_slope_data[counter, ] <- c(
      t_var = GV_vec_time[i],
      intercept = m1$coefficients[[1]],
      linear_term = m1$coefficients[[2]],
      quad_term = m1$coefficients[[3]]
    )
  }
  return(pr_t_slope_data)
}

#' Generates the likelihood of the target assay_value given an inter-test interval.
#' We differentiate a quadratic polynomial and evaluate it, per time point in the inter-test interval, using
#' parameters generated in likelihood_param_quad_function.
#' @param param_datset dataset of intercept (not really important as it doesn't get used),
#' linear, and quadratic terms that are used in evaluating the quad function.
#' @param assay_value is the target assay_value
#' @param t_since_ln vector of time points in the inter-test interval
#'
likelihood_fun <- function(param_datset, assay_value, t_since_ln) {
  l <- rep(0, length(t_since_ln))
  ff <- expression(1 + param1 * t + param2 * t^2)
  f <- D(ff, "t")
  counter <- 0
  for (j in 1:length(t_since_ln)) {
    counter <- counter + 1
    param1 <- as.numeric(param_datset$linear_term[[j]])
    param2 <- as.numeric(param_datset$quad_term[[j]])
    t <- assay_value
    l[counter] <- eval(f)
  }
  
  likelihood <- data.frame(l = ifelse(l < 0, 0, l)) %>% #
    mutate(
      time_t = t_since_ln,
      bigL = l / (trapz(time_t, l))
    )
  return(likelihood)
}
dat_combine <- data.frame(l = NA, time_t = NA, bigL = NA, assay_value  = NA)
for (i in 1:length(assay_value_th )) {
  likelihood <- likelihood_fun(
    param_datset = likelihood_param_quad_function(
      dat = as.matrix(pr_t_logit_cubic), target_assay_value = assay_value_th [i],
      GV_assay_value_stepsize  = GV_assay_value_stepsize , t_since_ln = seq(0, GV_interval_length, GV_interval_step)
    ),
    assay_value  = assay_value_th [i],
    t_since_ln = seq(0, GV_interval_length, GV_interval_step)
  ) %>%
    mutate(assay_value  = assay_value_th [i])
  dat_combine <- rbind(dat_combine, likelihood)
}

dat_combine <- dat_combine %>%
  filter(!is.na(time_t)) %>%
  mutate(`assay value`  = as.factor(assay_value ))
plot6 <- ggplot(
  data = dat_combine,
  aes(x = time_t, y = bigL, colour = `assay value`)
) +
  geom_line(size = 2.5) +
  xlab("Days since infection") +
  ylab("Posterior Density") +
  theme_bw() +
  scale_x_reverse(expand = c(0, 0)) + scale_y_continuous(breaks = c(0)) +
  scale_colour_manual(values = c("#A6CEE3", "#1F78B4", "#B2DF8A", "#33A02C", "#FB9A99", "#E31A1C", "#FDBF6F", "#FF7F00", "#CAB2D6", "#6A3D9A")) +
  coord_fixed(ratio = 1)+ 
  theme(
    text = element_text(size = 22),
    axis.line = element_line(colour = "black"), panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(), panel.background = element_blank(),
    panel.border = element_blank(),
    aspect.ratio = 1,
    plot.margin = unit(c(0, 0, 0, 0), "null")
  ) 
# plot5 
fill_name <- paste(GV_AssayName, Sys.Date(), sep = "_")

jpeg(paste('figures/', fill_name, '.jpeg', sep = ''), units = "in", width = 8, height = 6, res = 300)

print(grid.arrange(plot6, ncol = 1, nrow = 1))

dev.off()

pdf(paste('figures/', fill_name, '.pdf', sep = ''), width = 9, height = 5.5)

print(grid.arrange(plot6, ncol = 1, nrow = 1))

dev.off()
