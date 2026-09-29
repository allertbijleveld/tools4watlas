# Information about the origin / processing  of the data within tools4watlas

### data_example
# We manually choose the data from one individual each of 8 species for 2 tides
# Allert created a SQLite file of these data which is in:
# inst/extdata/watlas_example.SQLite #nolint

library(tools4watlas)
data_example[, .(start = min(datetime), end = max(datetime)), .(tag, species)]
# tag           species               start                 end
# <char>        <char>                <POSc>              <POSc>
# 1:   3027          redshank 2023-09-23 03:13:25 2023-09-23 22:24:23
# 2:   3038          red knot 2023-09-23 01:00:03 2023-09-23 23:59:54
# 3:   3063 bar-tailed godwit 2023-09-23 03:27:52 2023-09-23 22:24:46
# 4:   3100            curlew 2023-09-23 04:21:55 2023-09-23 21:41:10
# 5:   3158     oystercatcher 2023-09-23 01:00:01 2023-09-23 23:59:54
# 6:   3188         turnstone 2023-09-23 01:00:36 2023-09-23 23:41:32
# 7:   3212            dunlin 2023-09-23 01:00:00 2023-09-23 23:59:48
# 8:   3288        sanderling 2023-09-23 01:00:03 2023-09-23 23:59:48

data_example[, .N, tideID]
# tideID     N
# <int> <int>
# 1: 2023513 48776
# 2: 2023514 35639
