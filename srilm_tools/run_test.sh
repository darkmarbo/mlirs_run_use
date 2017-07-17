#!/bin/sh

#cat text_pro/* |sort|uniq > text_pro_sort/text_ug_all.uniq  

head -310000 text_pro.all.count.sort | awk -F"\t" '{if(length($0)<50){print $2}}' > ttt
head -300000 ttt > dict.ug.300000 
