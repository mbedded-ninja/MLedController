#
# @file 			Makefile
# @author 			Geoffrey Hunter <gbmhunter@gmail.com> (wwww.mbedded.ninja)
# @edited 			n/a
# @created			2014-10-13
# @last-modified 	2014-10-24
# @brief 			Makefile for Linux-based make, to compile the MLedController library, example code and run unit test code.
# @details
#					See README in repo root dir for more info.

SRC_CC := g++
SRC_OBJ_FILES := $(patsubst %.cpp,%.o,$(wildcard src/*.cpp))
SRC_LD_FLAGS := -pthread
SRC_CC_FLAGS := -Wall -g -c -O0 -I. -I./lib -std=c++11 -pthread

DEP_LIB_PATHS := -L ../MAssert -L ../MUnitTest -L ../MOsal -L ../MHal -L ../MList -L ../MVector
DEP_LIBS := -l MAssert -l MUnitTest -l MOsal -l MHal -l MList -l MVector
DEP_INCLUDE_PATHS := -I../

TEST_CC := g++
TEST_OBJ_FILES := $(patsubst %.cpp,%.o,$(wildcard test/*.cpp))
TEST_LD_FLAGS := -pthread
TEST_CC_FLAGS := -Wall -g -c -O0 -I. -I./lib -std=c++11 -pthread

EXAMPLE_CC := g++
EXAMPLE_OBJ_FILES := $(patsubst %.cpp,%.o,$(wildcard example/*.cpp))
EXAMPLE_LD_FLAGS := -pthread
EXAMPLE_CC_FLAGS := -Wall -g -c -O0 -I. -I./lib -std=c++11 -pthread

.PHONY: depend clean

# All
all: src test
	
	# Run unit tests:
	@./test/Tests.elf

#======== SRC LIB ==========#

src : deps $(SRC_OBJ_FILES)
	# Make library
	ar r libMLedController.a $(SRC_OBJ_FILES)
	
# Generic rule for src object files
src/%.o: src/%.cpp
	# Compiling src/ files
	$(SRC_CC) $(SRC_CC_FLAGS) -MD -o $@ $< $(DEP_INCLUDE_PATHS)
	-@cp $*.d $*.P >/dev/null 2>&1; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
		-e '/^$$/ d' -e 's/$$/ :/' < $*.d >> $*.P; \
		rm -f $*.d >/dev/null 2>&1

-include $(SRC_OBJ_FILES:.o=.d)
	
	
# ======== DEPENDENCIES ========

deps :
	# Downloading and building dependencies...
	if [ ! -d ../MUnitTest ]; then \
	git clone https://github.com/mbedded-ninja/MUnitTest ../MUnitTest; \
	fi;
	$(MAKE) -C ../MUnitTest/ all
	if [ ! -d ../MAssert ]; then \
	git clone https://github.com/mbedded-ninja/MAssert ../MAssert; \
	fi;
	$(MAKE) -C ../MAssert/ all
	if [ ! -d ../MOsal ]; then \
	git clone https://github.com/mbedded-ninja/MOsal ../MOsal; \
	fi;
	$(MAKE) -C ../MOsal/ all
	if [ ! -d ../MHal ]; then \
	git clone https://github.com/mbedded-ninja/MHal ../MHal; \
	fi;
	$(MAKE) -C ../MHal/ all
	if [ ! -d ../MList ]; then \
	git clone https://github.com/mbedded-ninja/MList ../MList; \
	fi;
	$(MAKE) -C ../MList/ all
	if [ ! -d ../MVector ]; then \
	git clone https://github.com/mbedded-ninja/MVector ../MVector; \
	fi;
	$(MAKE) -C ../MVector/ all
	
# ======== TEST ========
	
# Compiles unit test code
test : deps $(TEST_OBJ_FILES) | src
	# Compiling unit test code
	g++ $(TEST_LD_FLAGS) -o ./test/Tests.elf $(TEST_OBJ_FILES) -L./ -lMLedController $(DEP_LIB_PATHS) $(DEP_LIBS)

# Generic rule for test object files
test/%.o: test/%.cpp
	# Compiling test/ files
	$(TEST_CC) $(TEST_CC_FLAGS) -MD -o $@ $< $(DEP_INCLUDE_PATHS)
	-@cp $*.d $*.P >/dev/null 2>&1; \
	sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\\$$//' \
		-e '/^$$/ d' -e 's/$$/ :/' < $*.d >> $*.P; \
		rm -f $*.d >/dev/null 2>&1

-include $(TEST_OBJ_FILES:.o=.d)
	
	
# ====== CLEANING ======
	
clean: clean-src clean-deps clean-ut
	
clean-src:
	@echo " Cleaning src object files..."; $(RM) ./src/*.o
	@echo " Cleaning src dependency files..."; $(RM) ./src/*.d
	@echo " Cleaning src static library..."; $(RM) ./*.a
	@echo " Cleaning test object files..."; $(RM) ./test/*.o
	@echo " Cleaning test dependency files..."; $(RM) ./test/*.d
	@echo " Cleaning test executable..."; $(RM) ./test/*.elf
	@echo " Cleaning example object files..."; $(RM) ./example/*.o
	@echo " Cleaning example executable..."; $(RM) ./example/*.elf
	
clean-deps:
	@echo " Cleaning deps...";
	$(MAKE) -C ../MUnitTest/ clean
	$(MAKE) -C ../MAssert/ clean
	$(MAKE) -C ../MOsal/ clean
	$(MAKE) -C ../MHal/ clean
	$(MAKE) -C ../MList/ clean
	$(MAKE) -C ../MVector/ clean
	
clean-ut:
	@echo " Cleaning test object files..."; $(RM) ./test/*.o
	@echo " Cleaning test executable..."; $(RM) ./test/*.elf
	


	
