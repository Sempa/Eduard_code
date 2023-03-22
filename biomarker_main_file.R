####Sedia
# target_assay_value <- 2.
GV_AssayName <- 'LAg-Sedia'
GV_assay_value_stepsize <- 0.01
GV_interval_step <- 2
time_stepsize <- 1
GV_assayvalueTh <- seq(0.01, 5, GV_assay_value_stepsize)
GV_vec_time <- seq(0, 1000, time_stepsize)
GV_interval_length <- 600
assay_value_th <- c(.2, .3, .5, 1, 1.5, 2, 2.5, 3, 3.5, 4)# assay_value_th <- c(.2, .3 ,.5, 1.5, 4)
pr_t_logit_cubic <- readRDS("data/pr_t_logit_evaluations_sedia.rds")
source("~/GitHub/Eduard_code/likelihood_ploting - generic.R")

####Maxim
# target_assay_value <- 2.
GV_AssayName <- 'LAg-Maxim'
GV_assay_value_stepsize <- 0.01
GV_interval_step <- 2
time_stepsize <- 1
GV_assayvalueTh <- seq(0.1, 5, GV_assay_value_stepsize)
GV_vec_time <- seq(0, 1000, time_stepsize)
GV_interval_length <- 600
assay_value_th <- c(.2, .3, .5, 1, 1.5, 2, 2.5, 3, 3.5, 4)# assay_value_th <- c(.2, .3 ,.5, 1.5, 4)
pr_t_logit_cubic <- readRDS("data/pr_t_logit_evaluations_Maxim.rds")
source("~/GitHub/Eduard_code/likelihood_ploting - generic.R")

####ArchitectAvidity
# target_assay_value <- 2.
GV_AssayName <- 'ArchitectAvidity'
GV_assay_value_stepsize <- 1
GV_interval_step <- 2
time_stepsize <- 1
GV_assayvalueTh <- seq(55, 105, GV_assay_value_stepsize)
GV_vec_time <- seq(0, 1000, time_stepsize)
GV_interval_length <- 600
assay_value_th <- c(60, 70, 80, 90, 100)# assay_value_th <- c(.2, .3 ,.5, 1.5, 4)
pr_t_logit_cubic <- readRDS("data/pr_t_logit_evaluations_architect.rds")
source("~/GitHub/Eduard_code/likelihood_ploting - generic.R")

####ArchitectUnmodified
# target_assay_value <- 2.
GV_AssayName <- 'ArchitectUnmodified'
GV_assay_value_stepsize <- 1
GV_interval_step <- 2
time_stepsize <- 1
GV_assayvalueTh <- seq(0, 800, GV_assay_value_stepsize)
GV_vec_time <- seq(0, 1000, time_stepsize)
GV_interval_length <- 600
assay_value_th <- c(20, 50, 70, 100, 170, 200, 300, 400, 500, 600)# assay_value_th <- c(.2, .3 ,.5, 1.5, 4)
pr_t_logit_cubic <- readRDS("data/pr_t_logit_evaluations_ArchitectUnmodified.rds")
source("~/GitHub/Eduard_code/likelihood_ploting - generic.R")
