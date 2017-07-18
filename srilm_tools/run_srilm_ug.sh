#!/bin/sh -x 

#if(($#<3));then
#    echo "usage: $0 dir_text file_dict lm_name "
#    echo "例子 : $0 原始文本所在目录(里面是文本文件)  词典文件 LM_name"
#    exit 0
#fi
#
#dir_text=$1
#vocab=$2
#lm_name=$3
#
##### 模型裁剪阈值： 越大 裁剪得到的模型越小 一般100M的gz比较合适  
##### 1.2G生成模型的裁剪阈值如下 
prune_4=0.000000002
##### 400M 生成的模型 
#prune_4=0.0000000000002
#
#### -------------------------------------------------------------------------
#### 保留中间文件 
#mkdir -p lm
#
##### 文本处理后的语料 
##### 所有语料  用于训练LM
#text_gz=text_tmp.all.gz
#dir_pro=text_pro_tmp
#
#### 生成LM目录
#lm_4=lm/${lm_name}_4.arpa
#lm_4_prune=lm/${lm_name}_prune_4.arpa
#
#
#
#
##### -------------------------------------------------------------------------
####### 语料清洗  使用字符集 去掉其他字符
#rm -rf ${dir_pro} && mkdir -p ${dir_pro}
#python handleCorpus.py ${dir_text}  ug-cn.chset  0  ${dir_pro} 
#if(($? != 0));then
#    echo "ERROR:handleCorpus.py failed!"
#    exit 0
#fi
#
#rm -rf ${dir_pro}/*.del
###### 所有文本 用于训练模型 
#cat ${dir_pro}/*.ok  | gzip >  ${text_gz}
###cat ${dir_text}/*  | gzip >  ${text_gz}
#
#### -------------------------------------------------------------------------
#
###### 4-gram 用于最终解码 
#ngram-count -order 4  -kndiscount -interpolate -unk -map-unk "<UNK>"\
#    -limit-vocab -vocab $vocab -text ${text_gz} -lm ${lm_4} || exit 1
#
####### 4-gram 4元模型的裁剪  减小最终模型大小  
#ngram -order 4 -prune ${prune_4} -prune-lowprobs -lm ${lm_4} -write-lm ${lm_4_prune} || exit 1
#
#### -------------------------------------------------------------------------
##### 压缩后 供解码器使用 
#cat ${lm_4} | gzip > ${lm_4}.gz
#cat ${lm_4_prune} | gzip > ${lm_4_prune}.gz
#
#rm -rf ${text_gz}
##rm -rf ${dir_pro}


###########################        差值          ##########################################

###3个模型差值   LM1 LM2 LM3 
###-lm        LM1 -lambda         0.8
###-mix-lm    LM2 -mix-lambda2    0.15
###-mix-lm2   LM3
###那么 LM3的 权重 是 1 - LM1 - LM2 

######### 两个模型差值 

LM1=lm_1000M_20w/1000M_20w_4.arpa
LM2=lm_testset_412450/testset_412450_4.arpa
LM_MIX=lm_mix_1000M_0.3.arpa 
LM_MIX_prune=lm_mix_1000M_0.3_prune.arpa

ngram -order 4 -lm ${LM1} -lambda 0.3 -order 4 -mix-lm ${LM2}  -write-lm  ${LM_MIX}
####cat ${LM_MIX} | gzip > ${LM_MIX}.gz
##
ngram -order 4 -prune ${prune_4} -prune-lowprobs -lm ${LM_MIX} -write-lm ${LM_MIX_prune} || exit 1
cat ${LM_MIX_prune} | gzip > ${LM_MIX_prune}.gz


#################################             PPL 计算            ############################################
#
#
####### 计算ppl  
###LM_412=lm_testset_412450/testset_412450_4.arpa
###LM_1G=lm_1000M_20w/1000M_20w_4.arpa
##LM_MIX_08=lm_mix_1000M_0.8_prune.arpa
##LM_MIX_05=lm_mix_1000M_0.5_prune.arpa
LM_MIX_03=lm_mix_1000M_0.3_prune.arpa
file_412=test_412_450_train_set/412_test_data_text.txt
file_450=450_test_data_text.txt
##
####ngram -lm ${LM_412} -order 4 -ppl ${file_412} -debug 0 > ppl.412.LM412
####ngram -lm ${LM_1G} -order 4 -ppl ${file_412} -debug 0 > ppl.412.LM1000M
ngram -lm ${LM_MIX_03} -order 4 -ppl ${file_412} -debug 0 > ppl.412.LM_MIX_03
###
###ngram -lm ${LM_412} -order 4 -ppl ${file_450} -debug 0 > ppl.450.LM412
###ngram -lm ${LM_1G} -order 4 -ppl ${file_450} -debug 0 > ppl.450.LM1000M
ngram -lm ${LM_MIX_03} -order 4 -ppl ${file_450} -debug 0 > ppl.450.LM_MIX_03
###
###
################################################################################################





