# 作用
1. 类似于a.vim, 但是由于a.vim只能跳转到当前目录和特定目录的对应文件下, 所以对a.vim进行了重写;
2. 在c++/c中, 可以通过`<leader>fh`跳转到光标所在行的头文件;

# 工程支持
* 基于.git工程的支持, 以.git所在路径为根路径, 进行文件查找;
* 基于.svn工程的支持, 以.git所在路径为根路径, 进行文件查找;

# 测试
* 暂时只在windows下通过了测试

# 对标准头文件的支持
* 定义`g:alternateSearchPath`, 就可以通过快`<leader>fh`跳转到对应的头文件, 支持c++, 系统的头文件,如:
``` vim
let g:alternateSearchPath = "D:\\Develop\\Java\\android-ndk-r11b\\sources\\cxx-stl\\gnu-libstdc++\\4.9\\include"
```

# 已经有的命令
`A AS AV AT IH IHS IHV IHT` 和a.vim中有相同的作用
