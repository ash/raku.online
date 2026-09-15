#!/usr/bin/env rakupp
# Text::Calendar — One month, and a year
# https://raku.online/modules/text-calendar/#one-month-and-a-year
#
# Install what it needs, then run it:
#     rakupp install Text::Calendar
#     rakupp 02-year.raku
#
# Run under Raku++ 3.28.0 and Rakudo 2026.08 every time the site is
# built; the build fails if the output below stops matching.

use Text::Calendar;

say calendar-year(2026, :per-row(4));

# Output:
#                                   2026
#     
#     January                February               March                  April                  
#     Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   
#               1  2  3  4                      1                      1          1  2  3  4  5   
#      5  6  7  8  9 10 11    2  3  4  5  6  7  8    2  3  4  5  6  7  8    6  7  8  9 10 11 12   
#     12 13 14 15 16 17 18    9 10 11 12 13 14 15    9 10 11 12 13 14 15   13 14 15 16 17 18 19   
#     19 20 21 22 23 24 25   16 17 18 19 20 21 22   16 17 18 19 20 21 22   20 21 22 23 24 25 26   
#     26 27 28 29 30 31      23 24 25 26 27 28      23 24 25 26 27 28 29   27 28 29 30            
#     
#     May                    June                   July                   August                 
#     Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   
#                  1  2  3    1  2  3  4  5  6  7          1  2  3  4  5                   1  2   
#      4  5  6  7  8  9 10    8  9 10 11 12 13 14    6  7  8  9 10 11 12    3  4  5  6  7  8  9   
#     11 12 13 14 15 16 17   15 16 17 18 19 20 21   13 14 15 16 17 18 19   10 11 12 13 14 15 16   
#     18 19 20 21 22 23 24   22 23 24 25 26 27 28   20 21 22 23 24 25 26   17 18 19 20 21 22 23   
#     25 26 27 28 29 30 31   29 30                  27 28 29 30 31         24 25 26 27 28 29 30   
#     
#     September              October                November               December               
#     Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   Mo Tu We Th Fr Sa Su   
#         1  2  3  4  5  6             1  2  3  4                      1       1  2  3  4  5  6   
#      7  8  9 10 11 12 13    5  6  7  8  9 10 11    2  3  4  5  6  7  8    7  8  9 10 11 12 13   
#     14 15 16 17 18 19 20   12 13 14 15 16 17 18    9 10 11 12 13 14 15   14 15 16 17 18 19 20   
#     21 22 23 24 25 26 27   19 20 21 22 23 24 25   16 17 18 19 20 21 22   21 22 23 24 25 26 27   
#     28 29 30               26 27 28 29 30 31      23 24 25 26 27 28 29   28 29 30 31            
