# washr API drift check (openwashdata/pkgreview#77).
# Every `washr::name` the skills execute or instruct (skills/**: SKILL.md
# bodies, the reference files, and code lines of the check script) must be an
# export of the installed washr; the installed version is reported against
# the floor recorded in skills/pkgreview-core/WASHR_FLOOR. Exit 1 on a missing
# export or an installed version below the floor. Base R plus washr.
# docs/ is not scanned: it records history and proposals (a fixed typo, a
# function that never existed, a function washr has not shipped yet), and
# R comment lines are skipped for the same reason.
root <- normalizePath(file.path(dirname(sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])), ".."))
floor <- trimws(readLines(file.path(root, "skills", "pkgreview-core", "WASHR_FLOOR"), warn = FALSE)[1])
if (!requireNamespace("washr", quietly = TRUE)) stop("washr is not installed")
installed <- as.character(packageVersion("washr"))
cat(sprintf("washr installed: %s; recorded floor: %s\n", installed, floor))
files <- list.files(file.path(root, "skills"), "\\.(md|R)$", recursive = TRUE, full.names = TRUE)
calls <- list()
for (f in files) {
  txt <- readLines(f, warn = FALSE)
  if (grepl("\\.R$", f)) txt[grepl("^\\s*#", txt)] <- ""
  m <- regmatches(txt, gregexpr("washr::[A-Za-z_.][A-Za-z0-9_.]*", txt))
  for (i in seq_along(m)) for (nm in m[[i]]) calls[[sub("^washr::", "", nm)]] <- c(calls[[sub("^washr::", "", nm)]], sprintf("%s:%d", sub(paste0("^", root, "/"), "", f), i))
}
exports <- getNamespaceExports("washr")
missing <- setdiff(names(calls), exports)
cat(sprintf("%d distinct washr call(s) named in the repository: %s\n", length(calls), paste(sort(names(calls)), collapse = ", ")))
status <- 0L
if (length(missing)) {
  status <- 1L
  for (nm in missing) cat(sprintf("DRIFT: washr::%s is not exported by washr %s; named in %s\n", nm, installed, paste(unique(calls[[nm]]), collapse = ", ")))
} else cat("every named call is exported\n")
if (utils::compareVersion(installed, floor) < 0) {
  status <- 1L
  cat(sprintf("FLOOR: installed washr %s is below the recorded floor %s\n", installed, floor))
} else if (utils::compareVersion(installed, floor) > 0) {
  cat(sprintf("NOTE: CRAN washr %s is newer than the floor %s; review NEWS.md of washr for changes to reconcile\n", installed, floor))
}
quit(status = status)
