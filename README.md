# mlirs_run_use

srilm 安装


libiconv-1.14:
    首先检查是否有 libiconv 库 : 
        locate libiconv.so.2
                在makefiel文件中使用-liconv调用libiconv动态库文件时，
                若出现“error while loading sharedlibraries: libiconv.so.2”错误，解决方法为：
                $updatedb
                $locate libiconv.so.2
                $ln -s /usr/local/lib/libiconv.so.2 /usr/lib/libiconv.so.2
                $ln -s /usr/local/lib/libiconv.so /usr/lib/libiconv.so
                $ldconfig

    安装 srilm的依赖库   http://blog.csdn.net/ownfire/article/details/47276219 
    srclib/stdio.in.h 第698行修改如下： (已经修改过了)

        -_GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");

        +#if defined(__GLIBC__) && !defined(__UCLIBC__) && !__GLIBC_PREREQ(2, 16)
        + _GL_WARN_ON_USE (gets, "gets is a security hole - use fgets instead");
        +#endif
            其中 （“-”开始行为删除，“+”开始行为增加）
            删除一行，增加三行 
    依次进行: ./Configure  &&   make  &&  make install


srilm:
    srilm 原始下载备份 
    参考:  http://www.cnblogs.com/tongyan/p/3214577.html
    1.下载http://www.speech.sri.com/projects/srilm/download.html
    2.解压：tar zxvf srilm.tar.gz

    3.修改 Makefile 
        3.1 找到： 
                # SRILM = /home/speech/stolcke/project/srilm/devel
        　　　  另起一行输入 SRILM 的安装路径  SRILM = $(PWD)
        3.2 找到：
        　　　　MACHINE_TYPE := $(shell $(SRILM)/sbin/machine-type)
                可以shell命令执行 : 
                    sbin/machine-type 
                    查看机器类型:i686-m64或i686-gcc4

    4.修改common/Makefile.machine.i686-gcc4或i686-m64
    　　4.1 找到：
            i686-m64:
                GCC_FLAGS = -march=athlon64 -m64  -liconv  -Wall \
                            -Wno-unused-variable -Wno-uninitialized


            i686-gcc4:不需要修改
    　　　　　GCC_FLAGS = -mtune=pentium3 -Wall -Wno-unused-variable -Wno-uninitialized

    　　　　　CC = $(GCC_PATH)gcc $(GCC_FLAGS) -Wimplicit-int
    　　　　　CXX = $(GCC_PATH)g++ $(GCC_FLAGS) -DINSTANTIATE_TEMPLATES

    　　　　　这里是为了告诉 SRILM 系统使用的 compiler(c 和 c++)，
                符合安装情况，不需要修改。如果是 64 位 CPU，需要做相应调整

    　　4.2 找到：没动
    　　　　　TCL_INCLUDE =
    　　　　　TCL_LIBRARY =
    　　　　　修改为
    　　　　　TCL_INCLUDE =
    　　　　　TCL_LIBRARY =
    　　　　　NO_TCL = X　　
    　　4.3 找到：没动
    　　　　　GAWK = /usr/bin/awk   
    　　　　　修改为
    　　　　　GAWK = /usr/bin/gawk


    5. 执行 make World 


配置环境变量:
    打开 /root/.bash_profile :
        SRILM=/home/szm/cd/g_srilm/srilm
        PATH=$PATH:$SRILM/bin:$SRILM/bin/i686-m64
        export SRILM
        export PATH
       
    执行  source /root/.bash_profile  生效 


注意事项:
    glibcxx 库错误  
    如果执行 ngram-count 命令的时候，出现如下错误类型：
     ./bin/i686-m64/ngram-count: /lib64/libstdc++.so.6: \
         version `GLIBCXX_3.4.20' not found (required by ./bin/i686-m64/ngram-count)

     修改 /etc/ld.so.conf 文件内容：
        include ld.so.conf.d/*.conf
        /usr/local/lib64
        /usr/local/lib
        /usr/lib
    然后调用  ldconfig  重新加载配置即可。
    【 /usr/local/lib64 目录下的 libstdc++.so.6.0.20】



