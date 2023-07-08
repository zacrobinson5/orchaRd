
#install.packages("pacman")
	rm(list = ls())
	devtools::install_github("daniel1noble/orchaRd", ref = "main", force = TRUE)
	pacman::p_load(devtools, tidyverse, metafor, patchwork, R.rsp, orchaRd, emmeans, ape, phytools, flextable, clubSandwich)

########################################
######## FUNCTIONS
########################################
	pub_bias_plot <- function(plot, fe_model, v_model = NULL, col = c("red", "blue"), plotadj = -0.05, textadj = 0.05, branch.size = 1.2, trunk.size = 3){
		      
		# Add check to make sure it's an intercept ONLY model being added. Message to user if not.
		if(length(fe_model$b) > 1){
			stop("The model you are trying to add to the plot is not an intercept only model. Please ensure you have fit an intercept only meta-analysis. See vignette for details: https://daniel1noble.github.io/orchaRd/")
		}
		
		# Get the predictions from the final model and create a label for the plot
			pub_bias_data <- get_ints_dat(fe_model, type = "yang")

		if(is.null(v_model)){
			
			# Add to Existing Orchard Plot
			plot + ggplot2::geom_point(data = pub_bias_data[[1]], ggplot2::aes(x = name, y = pred), color = col[1], shape = "diamond", position = position_nudge(plotadj), size = trunk.size) + 
					ggplot2::geom_linerange(data = pub_bias_data[[1]], ggplot2::aes(x = name, ymin = ci.lb, ymax = ci.ub), color = col[1], position = position_nudge(plotadj), size = branch.size) + 
					ggplot2::geom_hline(yintercept = pub_bias_data[[1]]$pred, linetype = "dashed", color = col[1]) + 
					ggplot2::annotate("text", x = 1+plotadj-textadj, y = pub_bias_data[[1]]$pred+textadj, label = pub_bias_data[[2]], color = col[1], size = 4, hjust = pub_bias_data[[1]]$ci.ub -0.2) 
		} else{
			# Extract the corrected meta-analytic mean and CI
			pub_bias_data2 <- get_ints_dat(v_model, type = "naka")
plotadj = -0.05, textadj = 0.05
			plot + ggplot2::geom_point(data = pub_bias_data[[1]], ggplot2::aes(x = name, y = pred), color = col[1], shape = "diamond", position = position_nudge(plotadj), size = trunk.size) + 
					ggplot2::geom_linerange(data = pub_bias_data[[1]], ggplot2::aes(x = name, ymin = ci.lb, ymax = ci.ub), color = col[1], position = position_nudge(plotadj), size = branch.size) + 
					ggplot2::geom_hline(yintercept = pub_bias_data[[1]]$pred, linetype = "dashed", color = col[1]) + 
					ggplot2::annotate("text", x = 1+plotadj-textadj, y = pub_bias_data[[1]]$pred+textadj, label = pub_bias_data[[2]], color = col[1], size = 4, hjust = pub_bias_data[[1]]$ci.ub -0.2)    + 

					ggplot2::geom_point(data = pub_bias_data2[[1]], ggplot2::aes(x = name, y = pred), color = col[2], shape = "diamond", position = position_nudge(abs(plotadj)), size = trunk.size) + 
					ggplot2::geom_linerange(data = pub_bias_data2[[1]], ggplot2::aes(x = name, ymin = ci.lb, ymax = ci.ub), color = col[2], position = position_nudge(abs(plotadj)), size = branch.size) + 
					ggplot2::geom_hline(yintercept = pub_bias_data2[[1]]$pred, linetype = "dashed", color = col[2]) + 
					ggplot2::annotate("text", x = 1+abs(plotadj)+textadj, y = pub_bias_data2[[1]]$pred-textadj, label = pub_bias_data2[[2]], color = col[2], size = 4, hjust = pub_bias_data2[[1]]$ci.ub +0.2)

			
		}		
	}

  	pub_bias_plot2 <- function(plot, fe_model, v_model = NULL, col = c("red", "blue"), plotadj = -0.05, textadj = 0.05, branch.size = 1.2, trunk.size = 3){
		      
		# Add check to make sure it's an intercept ONLY model being added. Message to user if not.
		if(length(fe_model$b) > 1){
			stop("The model you are trying to add to the plot is not an intercept only model. Please ensure you have fit an intercept only meta-analysis. See vignette for details: https://daniel1noble.github.io/orchaRd/")
		}
		
		# Get the predictions from the final model and create a label for the plot
			pub_bias_data <- get_ints_dat(fe_model, type = "yang")

		if(is.null(v_model)){
			
			# Add to Existing Orchard Plot
			plot + geom_pub_stats_yang(pub_bias_data, plotadj = plotadj, textadj = textadj, branch.size = branch.size, trunk.size = trunk.size) 
		
		} else{
			# Extract the corrected meta-analytic mean and CI
			pub_bias_data2 <- get_ints_dat(v_model, type = "naka")

			plot + geom_pub_stats_yang(pub_bias_data, plotadj = plotadj, textadj = textadj, branch.size = branch.size, trunk.size = trunk.size) + geom_pub_stats_naka(pub_bias_data2, plotadj = plotadj, textadj = textadj, branch.size = branch.size, trunk.size = trunk.size) 
		}		
	}


	geom_pub_stats_yang <-  function(data, col = "red", plotadj = -0.05, textadj = 0.05, branch.size = 1.2, trunk.size = 3){
		list(ggplot2::geom_point(data = data[[1]], ggplot2::aes(x = name, y = pred), color = col, shape = "diamond", position = position_nudge(plotadj), size = trunk.size), 
				ggplot2::geom_linerange(data = data[[1]], ggplot2::aes(x = name, ymin = ci.lb, ymax = ci.ub), color = col, position = position_nudge(plotadj), size = branch.size),
						ggplot2::geom_hline(yintercept = data[[1]]$pred, linetype = "dashed", color = col),
					ggplot2::annotate("text", x = 1+plotadj-textadj, y = data[[1]]$pred+textadj, label = data[[2]], color = col, size = 4, hjust = data[[1]]$ci.ub -0.2)	
		)
	}


	geom_pub_stats_naka <- function(data, col = "blue", plotadj = -0.05, textadj = 0.05, branch.size = 1.2, trunk.size = 3) {
					list(ggplot2::geom_point(data = data[[1]], ggplot2::aes(x = name, y = pred), color = col, shape = "diamond", position = position_nudge(abs(plotadj)), size = trunk.size), 
					ggplot2::geom_linerange(data = data[[1]], ggplot2::aes(x = name, ymin = ci.lb, ymax = ci.ub), color = col, position = position_nudge(abs(plotadj)), size = branch.size), 
					ggplot2::geom_hline(yintercept = data[[1]]$pred, linetype = "dashed", color = col), 
					ggplot2::annotate("text", x = 1+abs(plotadj)+textadj, y = data[[1]]$pred-textadj, label = data[[2]], color = col, size = 4, hjust = data[[1]]$ci.ub +0.2))
	}

	get_ints_dat <- function(model, type = c("naka", "yang")){
			# Extract the corrected meta-analytic mean and CI
				type = match.arg(type)
				
				dat <- data.frame(name  =  "Intrcpt", 
								pred = model$b["intrcpt",], 
								ci.lb = model$ci.lb[1], 
								ci.ub = model$ci.ub[1])
				if(type == "naka"){
				lab <- paste0("Nakagawa Bias Corrected: ", round(dat$pred, 2), 
									", 95% CI (", round(dat$ci.lb, 2), "–", round(dat$ci.ub, 2), ")")
				}

				if(type == "yang"){
				lab <- paste0("Yang Bias Corrected: ", round(dat$pred, 2), 
									", 95% CI (", round(dat$ci.lb, 2), "–", round(dat$ci.ub, 2), ")")
	}

	return(list(dat, lab))
	}


########################################
## EXAMPLE 1: English Example
########################################
	# Data
		data(english)
		# We need to calculate the effect sizes, in this case d
		english <- escalc(measure = "SMD", n1i = NStartControl, sd1i = SD_C, m1i = MeanC, n2i = NStartExpt, sd2i = SD_E, m2i = MeanE, 
						var.names=c("SMD","vSMD"),
						data = english)

	# Our MLMA model
		english_MA1 <- rma.mv(yi = SMD, V = vSMD, random = list( ~ 1 | StudyNo, ~ 1 | EffectID),test = "t", data = english)

	# Step 1: Fit the fixed effect model
		english_MA2 <- rma.mv(yi = SMD, V = vSMD, data = english, test = "t")

		english_MA3 <- rma(yi = SMD, vi = vSMD, data = english, test = "t", method = "FE")

	# Step 2: Correct for dependency 
		english_MA2_1 <- robust(english_MA2, cluster = english$StudyNo, clubSandwich=TRUE)

	# Step 3: Testing modified eggers. Need intercept
		english_MA4 <- rma.mv(yi = SMD, V = vSMD, mod = ~vSMD, random = list( ~ 1 | StudyNo, ~ 1 | EffectID),test = "t", data = english)

	# Now plot the results

		plot <- orchard_plot(english_MA1, group = "StudyNo",  xlab = "Standardized Mean Difference")
		plot2 <- pub_bias_plot(plot, english_MA2_1)
		plot3 <- pub_bias_plot(plot, english_MA2_1, english_MA4)
		plot4 <- pub_bias_plot2(plot, english_MA2_1, english_MA4)

########################################	
## EXAMPLE 2: Eklof example
########################################
	data(eklof)

	# Calculate the effect size
	eklof <- escalc(
	measure = "ROM", n1i = N_control, sd1i = SD_control, m1i = mean_control,
	n2i = N_treatment, sd2i = SD_treatment, m2i = mean_treatment,
	var.names = c("lnRR", "vlnRR"),
	data = eklof
	)

	# Add the observation level factor
	eklof$Datapoint <- as.factor(seq(1, dim(eklof)[1], 1))

	# Also, we can get the sample size, which we can use for weighting if we would like
	eklof$N <- rowSums(eklof[, c("N_control", "N_treatment")])
	eklof_MR0 <- rma.mv(yi = lnRR, V = vlnRR, mods = ~ Grazer.type, random = list(~ 1 | ExptID, ~ 1 | Datapoint), data = eklof)

	# Step 1: Fit the fixed effect model
		eklof_MR01 <- rma.mv(yi = lnRR, V = vlnRR, data = eklof)

	# Step 2: Correct for dependency 
		eklof_MR02 <- robust(eklof_MR01, cluster = eklof$ExptID, clubSandwich=TRUE)	

	# Step 3: Testing modified eggers. Need intercept
		eklof_MR03 <- rma.mv(yi = lnRR, V = vlnRR, mods = ~ vlnRR, random = list(~ 1 | ExptID, ~ 1 | Datapoint), data = eklof)

	# Now plot the results
		plot <- orchard_plot(eklof_MR0, group = "ExptID",  xlab = "Log Response Ratio")
		#plot <- orchard_plot(eklof_MR0_2, group = "ExptID",  xlab = "Log Response Ratio")
		plot2 <- pub_bias_plot(plot, eklof_MR02)
		plot3 <- pub_bias_plot(plot, eklof_MR02, eklof_MR03)
		plot4 <- pub_bias_plot2(plot, eklof_MR02, eklof_MR03, text_pos = 0, textadj = 0)

