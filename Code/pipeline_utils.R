# Shared utilities for pipeline orchestration.

`%||%` <- function(x, y) {
  if (is.null(x)) {
    return(y)
  }
  if (length(x) == 1 && is.atomic(x) && is.na(x)) {
    return(y)
  }
  x
}

pipeline_log <- function(...) {
  msg <- paste(..., collapse = " ")
  cat(sprintf("[%s] %s\n", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), msg))
}

split_csv <- function(x) {
  if (is.null(x) || is.na(x) || !nzchar(trimws(x))) {
    return(character(0))
  }
  vals <- unlist(strsplit(x, ",", fixed = TRUE))
  vals <- trimws(vals)
  vals[nzchar(vals)]
}

as_bool <- function(x, default = FALSE) {
  if (is.logical(x)) {
    return(x)
  }
  if (is.null(x) || is.na(x)) {
    return(default)
  }
  val <- tolower(trimws(as.character(x)))
  if (val %in% c("true", "t", "1", "yes", "y")) return(TRUE)
  if (val %in% c("false", "f", "0", "no", "n")) return(FALSE)
  default
}

normalize_key <- function(key) {
  tolower(gsub("-", "_", key))
}

parse_cli_args <- function(args = commandArgs(trailingOnly = TRUE)) {
  opts <- list(
    pipeline = "all",
    phases = NULL,
    skip_download = FALSE,
    from = NULL,
    to = NULL,
    strict = TRUE,
    list_steps = FALSE,
    dry_run = FALSE,
    help = FALSE
  )

  i <- 1L
  while (i <= length(args)) {
    arg <- args[[i]]
    if (!startsWith(arg, "--")) {
      stop("Unexpected argument format: ", arg)
    }

    body <- sub("^--", "", arg)
    key <- NULL
    value <- NULL

    if (grepl("=", body, fixed = TRUE)) {
      pieces <- strsplit(body, "=", fixed = TRUE)[[1]]
      key <- pieces[[1]]
      value <- paste(pieces[-1], collapse = "=")
    } else {
      key <- body
      norm_key <- normalize_key(key)
      if (norm_key %in% c("skip_download", "list_steps", "dry_run", "help")) {
        value <- TRUE
      } else {
        if (i == length(args)) {
          stop("Missing value for argument --", key)
        }
        i <- i + 1L
        value <- args[[i]]
      }
    }

    norm_key <- normalize_key(key)
    if (norm_key == "pipeline") {
      opts$pipeline <- tolower(trimws(value))
    } else if (norm_key == "phases") {
      opts$phases <- split_csv(value)
    } else if (norm_key == "skip_download") {
      opts$skip_download <- as_bool(value, default = TRUE)
    } else if (norm_key == "from") {
      opts$from <- tolower(trimws(value))
    } else if (norm_key == "to") {
      opts$to <- tolower(trimws(value))
    } else if (norm_key == "strict") {
      opts$strict <- as_bool(value, default = TRUE)
    } else if (norm_key == "list_steps") {
      opts$list_steps <- as_bool(value, default = TRUE)
    } else if (norm_key == "dry_run") {
      opts$dry_run <- as_bool(value, default = TRUE)
    } else if (norm_key == "help") {
      opts$help <- as_bool(value, default = TRUE)
    } else {
      stop("Unknown argument --", key)
    }

    i <- i + 1L
  }

  opts
}

print_pipeline_help <- function() {
  cat(
    paste(
      "Usage:",
      "  Rscript Code/run_pipeline.R [options]",
      "",
      "Options:",
      "  --pipeline state|county|all         Pipeline selection (default: all)",
      "  --phases download,process,merge,analysis",
      "                                      Comma-separated phase list",
      "  --skip-download                      Remove download phase from selection",
      "  --from <phase>                       Start phase (inclusive)",
      "  --to <phase>                         End phase (inclusive)",
      "  --strict TRUE|FALSE                  Fail fast on missing inputs/outputs (default: TRUE)",
      "  --list-steps                         Print selected steps and exit",
      "  --dry-run                            Print execution plan without running scripts",
      "  --help                               Show this help",
      sep = "\n"
    )
  )
  cat("\n")
}

resolve_selected_phases <- function(opts, phase_order = c("download", "process", "merge", "analysis")) {
  if (!is.null(opts$phases) && length(opts$phases) > 0) {
    selected <- unique(tolower(opts$phases))
  } else {
    selected <- phase_order
  }

  invalid <- setdiff(selected, phase_order)
  if (length(invalid) > 0) {
    stop("Invalid phase(s): ", paste(invalid, collapse = ", "))
  }

  if (!is.null(opts$from) || !is.null(opts$to)) {
    start_idx <- if (is.null(opts$from)) 1L else match(opts$from, phase_order)
    end_idx <- if (is.null(opts$to)) length(phase_order) else match(opts$to, phase_order)

    if (is.na(start_idx)) stop("Invalid --from phase: ", opts$from)
    if (is.na(end_idx)) stop("Invalid --to phase: ", opts$to)
    if (start_idx > end_idx) stop("--from phase occurs after --to phase.")

    range_phases <- phase_order[start_idx:end_idx]
    selected <- phase_order[phase_order %in% selected & phase_order %in% range_phases]
  } else {
    selected <- phase_order[phase_order %in% selected]
  }

  if (isTRUE(opts$skip_download)) {
    selected <- setdiff(selected, "download")
    selected <- phase_order[phase_order %in% selected]
  }

  if (length(selected) == 0) {
    stop("No phases selected after applying filters.")
  }
  selected
}

validate_step_definitions <- function(steps) {
  required <- c("id", "pipeline", "phase", "script")
  for (step in steps) {
    miss <- required[!vapply(required, function(n) !is.null(step[[n]]) && nzchar(step[[n]]), logical(1))]
    if (length(miss) > 0) {
      stop("Step definition missing required field(s): ", paste(miss, collapse = ", "))
    }
  }
  TRUE
}

filter_steps <- function(steps, pipeline = "all", phases = c("download", "process", "merge", "analysis")) {
  allowed_pipelines <- c("state", "county", "all")
  if (!pipeline %in% allowed_pipelines) {
    stop("Invalid pipeline value: ", pipeline)
  }

  selected <- list()
  idx <- 1L
  for (step in steps) {
    pipeline_match <- pipeline == "all" || identical(step$pipeline, pipeline)
    phase_match <- step$phase %in% phases
    if (pipeline_match && phase_match) {
      selected[[idx]] <- step
      idx <- idx + 1L
    }
  }
  selected
}

print_step_list <- function(steps) {
  if (length(steps) == 0) {
    cat("No steps matched current selection.\n")
    return(invisible(NULL))
  }

  cat(sprintf("%-34s %-8s %-9s %s\n", "id", "pipeline", "phase", "description"))
  cat(sprintf("%-34s %-8s %-9s %s\n", strrep("-", 34), strrep("-", 8), strrep("-", 9), strrep("-", 32)))
  for (step in steps) {
    cat(sprintf(
      "%-34s %-8s %-9s %s\n",
      step$id,
      step$pipeline,
      step$phase,
      step$description %||% ""
    ))
  }
}

assert_files_exist <- function(paths, context, strict = TRUE) {
  paths <- paths %||% character(0)
  if (length(paths) == 0) return(TRUE)

  missing <- paths[!file.exists(paths)]
  if (length(missing) == 0) return(TRUE)

  msg <- paste0(
    "Missing ", context, ":\n",
    paste0("  - ", missing, collapse = "\n")
  )
  if (isTRUE(strict)) {
    stop(msg)
  }
  warning(msg, call. = FALSE)
  FALSE
}

is_step_enabled <- function(step) {
  enabled_if <- step$enabled_if %||% NULL
  if (is.null(enabled_if)) return(TRUE)
  if (!is.function(enabled_if)) return(TRUE)
  isTRUE(enabled_if())
}

run_registered_step <- function(step, strict = TRUE, dry_run = FALSE) {
  step_label <- sprintf("[%s] %s", step$id, step$description %||% step$id)

  if (!is_step_enabled(step)) {
    pipeline_log(step_label, "SKIPPED (disabled)")
    return(list(status = "skipped", id = step$id))
  }

  if (isTRUE(dry_run)) {
    pipeline_log(step_label, "PLANNED")
    return(list(status = "planned", id = step$id))
  }

  inputs_ok <- assert_files_exist(step$required_inputs %||% character(0), paste0("required inputs for ", step$id), strict = strict)
  if (!inputs_ok && !isTRUE(strict)) {
    pipeline_log(step_label, "SKIPPED (missing inputs)")
    return(list(status = "skipped", id = step$id))
  }

  if (!file.exists(step$script)) {
    stop("Step script not found: ", step$script)
  }

  pipeline_log(step_label, "START")
  env <- new.env(parent = globalenv())
  sys.source(step$script, envir = env)

  fn_name <- step$function_name %||% NULL
  result <- NULL
  if (!is.null(fn_name) && exists(fn_name, envir = env, inherits = FALSE)) {
    run_fn <- get(fn_name, envir = env, inherits = FALSE)
    result <- run_fn(step$config %||% list())
  } else {
    result <- list(status = "executed_by_source")
  }

  outputs_ok <- assert_files_exist(step$required_outputs %||% character(0), paste0("expected outputs for ", step$id), strict = strict)
  if (!outputs_ok && !isTRUE(strict)) {
    pipeline_log(step_label, "DONE (missing outputs)")
    return(list(status = "completed_with_missing_outputs", id = step$id, result = result))
  }

  pipeline_log(step_label, "DONE")
  list(status = "completed", id = step$id, result = result)
}

run_step_sequence <- function(steps, strict = TRUE, dry_run = FALSE) {
  results <- list()
  if (length(steps) == 0) return(results)

  for (idx in seq_along(steps)) {
    step <- steps[[idx]]
    results[[idx]] <- run_registered_step(step, strict = strict, dry_run = dry_run)
  }
  results
}

summarize_step_results <- function(results) {
  if (length(results) == 0) {
    return(list(total = 0L))
  }
  statuses <- vapply(results, function(x) x$status %||% "unknown", character(1))
  counts <- table(statuses)
  c(list(total = length(results)), as.list(counts))
}
