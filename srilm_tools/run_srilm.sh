#!/bin/sh -x 

if(($#<3));then
    echo "usage: $0 dir_text chset.txt top-N "
    echo "例子 : $0 原始文本目录  字符集列表 选取top-N个词 "
    exit 0
fi

dir_text=$1
file_chset=$2
top_N=$3

### 保留中间文件 
mkdir -p tmp
mkdir -p lm

### 初始变量 
#### 文本处理后的语料 
dir_text_pro=${dir_text}_pro
file_count=${dir_text_pro}.all.count

#### 模型训练 变量 
#vocab=dict.ug.${top_N}
#vocab=dict.ug.22w
#vocab=412_text.dict
#vocab=dict.ug.30w
vocab=dict.ug.209972

text_gz=tmp/${dir_text_pro}.all.gz

lm_3=lm/${dir_text}_3.arpa
lm_4=lm/${dir_text}_4.arpa
lm_3_prune=lm/${dir_text}_prune_3.arpa
lm_4_prune=lm/${dir_text}_prune_4.arpa
#lm_4_mix=lm/${dir_text}_4_mix.arpa

prune_3=0.0000005
prune_4=0.00000005




##### 语料清洗  使用字符集 去掉其他字符
#rm -rf ${dir_text_pro}  &&  mkdir -p ${dir_text_pro}
#python handleCorpus.py ${dir_text}  ${file_chset}  0 
#if(($? != 0));then
#    echo "ERROR:handleCorpus.py failed!"
#    exit 0
#fi
#rm -rf ${dir_text}/*.del
#mv ${dir_text}/*.ok  ${dir_text_pro}

######## 提取词频 
#cat ${dir_text_pro}/* > tmp/${dir_text_pro}.all
#python count.py   tmp/${dir_text_pro}.all    tmp/${file_count} 
#sort -n -r tmp/${file_count} > ${file_count}.sort
#
##### 选取top-N 
#head -${top_N}  ${file_count}.sort  > tmp/${file_count}.sort.${top_N}

#### 去掉词频 只保留单词 做词典  
#awk -F"\t" '{print $2}' tmp/${file_count}.sort.${top_N} > ${vocab}


#### --------------------------------------------------------
####### 训练文本
cat ${dir_text_pro}/* | gzip >  ${text_gz}


##### 3-gram 用于画图的小模型   
ngram-count -order 3  -kndiscount -interpolate -unk -map-unk "<UNK>"\
    -limit-vocab -vocab $vocab -text ${text_gz} -lm ${lm_3} || exit 1


#### 3-gram 3元模型的裁剪  
ngram -order 3 -prune ${prune_3} -prune-lowprobs -lm ${lm_3} -write-lm ${lm_3_prune} || exit 1

##### 4-gram 用于最终解码 
ngram-count -order 4  -kndiscount -interpolate -unk -map-unk "<UNK>"\
    -limit-vocab -vocab $vocab -text ${text_gz} -lm ${lm_4} || exit 1

##### 4-gram 4元模型的裁剪  
ngram -order 4 -prune ${prune_4} -prune-lowprobs -lm ${lm_4} -write-lm ${lm_4_prune} || exit 1

### 压缩后 供解码器使用 
cat ${lm_3} | gzip > ${lm_3}.gz
cat ${lm_3_prune} | gzip > ${lm_3_prune}.gz
cat ${lm_4} | gzip > ${lm_4}.gz
cat ${lm_4_prune} | gzip > ${lm_4_prune}.gz

rm -rf ${text_gz}



######  模型插值  0 123 
####     0为主模型(-lm 0.arpa -lambda 0.7)   
####     1为用于插值的模型(-mix-lm 1.arpa -mix-lambda2 0.12)
####     2为用于插值的模型(-mix-lm2 2.arpa -mix-lambda3 0.13)
####     3为用于插值的模型(-mix-lm3 3.arpa 剩余比例0.05)
#ngram -debug 1\
#    -order 4  -lm 0.arpa  -lambda 0.7\
#    -order 4 -mix-lm  1.arpa  -mix-lambda2 0.12\
#    -order 4 -mix-lm2 2.arpa  -mix-lambda3 0.13\
#    -order 4 -mix-lm3 3.arpa  -write-lm mix.arpa



##### 分词
##seg_dir=/home/srilm_test/word_seg
###seg_dir=/home/srilm_test/ICTCLAS2014/src/sample/c_seg
##ls -1 data/text|while read line
##do
##	cp -r data/text/$line $seg_dir 
##	cd $seg_dir && ./run.sh $line $line.seg && cd - 
##	mv $seg_dir/$line.seg data/seg 
##done



