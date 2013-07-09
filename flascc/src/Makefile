FLASCC = ../../../../../CrossBridge/sdk
LIBNAME = bytelib
AS3COMPILER= asc2.jar
$?nativepath=$(abspath $(1))
$?AS3COMPILERARGS=java $(JVMARGS) -jar $(call nativepath,$(FLASCC)/usr/lib/$(AS3COMPILER)) -merge -md

AS3COMPILERARGS=java -jar $(FLASCC)/usr/lib/$(AS3COMPILER) -merge -md
all:
	@echo "-------- PassingData --------"
	@echo "-> Generate SWIG wrappers around the functions in the library"
	"$(FLASCC)/usr/bin/swig" -as3 -module $(LIBNAME) -outdir . -includeall -ignoremissing -o $(LIBNAME)_wrapper.c swig.i

	@echo "-> Compile the SWIG wrapper to ABC"
	$(AS3COMPILERARGS) -abcfuture -AS3 -import $(call nativepath,$(FLASCC)/usr/lib/builtin.abc) -import $(call nativepath,$(FLASCC)/usr/lib/playerglobal.abc) $(LIBNAME).as
	# rename the output so the compiler doesn't accidentally use both this .as file along with the .abc file we just produced
	mv $(LIBNAME).as $(LIBNAME).as3

	@echo "-> Compile the library into a SWC"
	"$(FLASCC)/usr/bin/gcc" $(BASE_CFLAGS) $(LIBNAME).abc $(LIBNAME)_wrapper.c flascc.c $(LIBNAME).c -emit-swc=sample.$(LIBNAME) -o $(LIBNAME).swc

	@echo "-> Clean All"
	rm -f *_wrapper.c *.swf *.as3 *.abc
