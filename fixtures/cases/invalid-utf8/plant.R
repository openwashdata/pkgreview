# Plants invalid UTF-8 in a copy of pkgreviewtest (openwashdata/pkgreview#86).
# Run by setup.sh inside the copy. The bytes are Latin-1 text that was read
# without declaring its encoding, the pattern behind the three crashes named
# in the issue. They are built from raw values here so that no file with
# invalid bytes is tracked in this repository.

latin1_bytes <- function(...) rawToChar(as.raw(c(...)))
geneve <- latin1_bytes(0x47, 0x65, 0x6e, 0xe8, 0x76, 0x65)        # "Geneve" with e grave
zurich <- latin1_bytes(0x5a, 0xfc, 0x72, 0x69, 0x63, 0x68)        # "Zurich" with u umlaut
protegee <- latin1_bytes(0x70, 0x72, 0x6f, 0x74, 0xe9, 0x67, 0xe9, 0x65)

# 1. Dataset: three values in region, two in waterSource. Encoding() is
#    "unknown" for all five, unlike the latin1-declared strings of defect D3.
load("data/pkgreviewtest.rda")
pkgreviewtest$region[c(2, 7, 11)] <- geneve
pkgreviewtest$waterSource[c(3, 5)] <- paste("source", protegee)
stopifnot(sum(!validUTF8(pkgreviewtest$waterSource)) == 2L,
          all(Encoding(pkgreviewtest$region[c(2, 7, 11)]) == "unknown"))
save(pkgreviewtest, file = "data/pkgreviewtest.rda")

# 2. Dictionary: one description with the same kind of bytes.
dict <- readLines("data-raw/dictionary.csv", warn = FALSE)
i <- grep("Type of water source", dict, fixed = TRUE, useBytes = TRUE)
stopifnot(length(i) == 1L)
dict[i] <- paste0(dict[i], " (source ", protegee, ")")
writeLines(dict, "data-raw/dictionary.csv", useBytes = TRUE)

# 3. Processing script: one commented-out assignment, appended so that the
#    line numbers of the existing block (defect D12) stay where they are.
#    Before the fix the line was skipped with a warning, so the
#    commented-out-code count missed it.
con <- file("data-raw/data_processing.R", open = "ab")
writeBin(charToRaw(paste0("# office <- \"", zurich, "\"\n")), con)
close(con)
