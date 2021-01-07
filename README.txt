TOPPERS/ASP3: 3.6.0 (https://www.toppers.jp/asp3-d-download.html)
linux_gcc: (https://github.com/morioka/toppers-asp3-for-linux) + 3.6.0 update + aarch64/arm support (partial).
rpi3_gcc: (https://github.com/AZO234/RaspberryPi_TOPPERS_ASP3) + 3.6.0 update (build only, no-debug)

x86_64 linux 環境で、何も指定しない場合は x86_64 向けになります。
i386 linux 向けにビルドするには -m32 オプションを指定します。(linux_gcc 元ソースの指定を削除しました)
  mkdir build; cd build
  ../configure.rb -T linux_gcc -o -m32

aarch64/arm linux 向けには static バイナリを作成する必要があります。
(PTR_MANGLE で参照する変数をリンクするため。)
  mkdir build; cd build
  ../configure.rb -T linux_gcc -b -static
  生成された Makefile に、GCC_TARGET を記述してください (aarch64: aarch64-linux-gnu, arm: arm-linux-gnueabihf)
  aarch64 では strict-aliasing の警告でエラー終了するため、KERNEL_CFLAGS に -fno-strict-aliasing を追加してください。
  arm では pass 3 が失敗します。./asp が生成できたので、とりあえず一度コミットします。

Raspberry Pi 3(32bit) は準備中です。
