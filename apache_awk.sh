#!/bin/sh
# Using awk to calculate the percentage of 404 errors in an apache log file.

awk '{ if ($9 != 200) { error += 1 } if ($9 = 200) { ok += 1 } } END { print 100*error/ok "%" }' <apache_log_fileName>
awk '/404/ { error += 1 } /200/ { ok += 1 } END { printf "%.2f\n", 100*error/ok "%" }' <apache_log_fileName>
awk '/404/ { error += 1 } /200/ { ok += 1 } END { print 100*error/ok "%"}' <apache_log_fileName>
awk '{print $10}' <apache_log_fileName> | sort | uniq -c | sort -nr 