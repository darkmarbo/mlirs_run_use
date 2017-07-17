# -*- coding: utf-8 -*-
import sys
import string
import re

if len(sys.argv)<3:
    print "usage: %s input_file output_file"%(sys.argv[0])
    sys.exit(0)

f_in=open(sys.argv[1])
f_out=open(sys.argv[2],'w')
num_all = 0;

all_line_in=f_in.readlines()
ii=0;
for line in all_line_in:
    vec_word=re.split('\t',line)
    if len(vec_word) < 2:
        print("%s\tdict format err!"%(line));
        continue;
    word=vec_word[0];
    num = int(vec_word[1]);
    num_all = num_all + num;
    ii = ii + 1;

f_in.close()
f_out.write("总计 %d 个词 \n总频次 %d \n"%(ii,num_all));

f_in_re = open(sys.argv[1])
num_all_tmp = 0;
ii = 0;
num_th = int(float(num_all)*0.97);
num_line = 0;
all_line_in=f_in_re.readlines()
for line in all_line_in:
    vec_word=re.split('\t',line)
    if len(vec_word) < 2:
        print("dict format err!");
        continue;
    word=vec_word[0];
    num = int(vec_word[1]);
    num_all_tmp = num_all_tmp + num;
    ii += 1;
    if (num_all_tmp > num_th):
        num_line = ii;
        f_out.write("当前 %d 加和后 %d \n"%(num,num_all_tmp));
        f_out.write("%d line \n"%(ii));
        break;

f_in_re.close()
f_out.close()

sys.exit(0);



