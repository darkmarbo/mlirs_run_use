# -*- coding: utf-8 -*-

import sys;
import os;
import re;
import traceback


dictMap = {}
flag_gang = 0;

charsetMap = {}

def loadCharset(dictPath):
    lineNum = 0
    
    for line in open(dictPath):
        try:
            new_line = line[:-1].decode('utf-8').strip()

            if not new_line:
                continue

            contents = new_line.split("\t")
            key = contents[0]

            charsetMap[key] = ""
        except Exception as e:
            print(e);
        

def handleDir(inputDir):
    if not os.path.exists(inputDir):
        print ('error')+"\t"+inputDir
        return

    files = os.listdir(inputDir)
    for f1 in files:
        if os.path.isdir(inputDir+"/"+f1):
            handleDir(inputDir+"/"+f1)
            continue

        if f1.endswith(".del") or f1.endswith(".ok"):
            continue
            
        handleFile(inputDir+'/'+f1);

        print "Complete file \t"+inputDir+"/"+f1+" ~"
        
    print "Complete dir \t"+inputDir+" !"

        
def handleFile(filePath):
    fr = open(filePath,'r+');

    fpw_OK = open(filePath+".ok", 'w')
    fpw_Del = open(filePath+".del", 'w')
    
    lineNum = 0
    for line in fr.readlines():
        lineNum += 1
        new_line = "";
        try:
            new_line = line[:-1].decode('utf-8').strip()
        except Exception as e:
            new_line="";
            print(e);

        if not new_line:
            continue

        out_str = ""
        isMatch = True
        for ch in new_line:
            if ch==' ':
                out_str += ch
                continue
            
            if ch in charsetMap:
                if isMatch:
                    out_str += ch
                else:
                    #if len(out_str.strip())>1:
                    fpw_Del.write(out_str.encode('utf-8').strip()+"\n")
                    out_str = ch
                isMatch = True
                
            else:
                if isMatch:
                    if flag_gang == 1 and (ch in "-\'"):
                        out_str += ch;
                        isMatch = True
                        continue;
                    if ch in "0123456789" and out_str[:-1]!=' ':
                        rfindSpace = out_str.rfind(' ')
                        if rfindSpace!=-1:
                            out_str = out_str[:rfindSpace]
                        else:
                            out_str = ""
                    
                    if len(out_str.strip())>1:
                        #fpw_OK.write(out_str.encode('utf-8').strip().upper()+"\n")
                        fpw_OK.write(out_str.encode('utf-8').strip()+"\n")
                    out_str = ch
                else:
                    out_str += ch
                isMatch = False

        if len(out_str.strip())>1:
            if isMatch:
                #fpw_OK.write(out_str.encode('utf-8').strip().upper()+"\n")
                fpw_OK.write(out_str.encode('utf-8').strip()+"\n")
            else:
                fpw_Del.write(out_str.encode('utf-8').strip()+"\n")

    fpw_OK.close()
    fpw_Del.close()
    
    fr.close()


if __name__=='__main__':
    if len(sys.argv)!=4:
        print ("%s inputDir dictPath 1或者0 表示是否保留连接符"%(sys.argv[0]))
        sys.exit(-1);
    else:
        flag_gang = int(sys.argv[3]);
        loadCharset(sys.argv[2])
        handleDir(sys.argv[1])
        sys.exit(0);
        
        
