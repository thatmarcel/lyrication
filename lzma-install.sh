curl -O https://tukaani.org/xz/xz-5.2.4.tar.gz
tar xvfz xz-5.2.4.tar.gz
cd xz-5.2.4
./configure --prefix=/usr/local/xz/5_2_4
make
make install

ln -s /usr/local/xz/5_2_4/bin/lzcat /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzcmp /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzdiff /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzegrep /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzfgrep /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzgrep /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzless /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzma /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzmadec /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzmainfo /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/lzmore /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/unlzma /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/unxz /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xz /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xzcat /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xzcmp /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xzdec /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xzdiff /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xzegrep /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xzfgrep /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xzgrep /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xzless /usr/local/bin/
ln -s /usr/local/xz/5_2_4/bin/xzmore /usr/local/bin/

ln -s /usr/local/xz/5_2_4/include/lzma /usr/local/include/
ln -s /usr/local/xz/5_2_4/include/lzma.h /usr/local/include/

ln -s /usr/local/xz/5_2_4/lib/liblzma.a /usr/local/lib/
ln -s /usr/local/xz/5_2_4/lib/liblzma.la /usr/local/lib/
ln -s /usr/local/xz/5_2_4/lib/liblzma.so /usr/local/lib/
ln -s /usr/local/xz/5_2_4/lib/liblzma.so.5 /usr/local/lib/
ln -s /usr/local/xz/5_2_4/lib/liblzma.so.5.2.4 /usr/local/lib/

ln -s /usr/local/xz/5_2_4/lib/pkgconfig/liblzma.pc /usr/local/lib/pkgconfig/
