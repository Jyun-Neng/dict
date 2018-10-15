TESTS = test_cpy test_ref

TEST_DATA = s Tai
TEST_FIND = f Taiwan

CFLAGS = -O0 -Wall -Werror -g

# Control the build verbosity                                                   
ifeq ("$(VERBOSE)","1")
    Q :=
    VECHO = @true
else
    Q := @
    VECHO = @printf
endif

GIT_HOOKS := .git/hooks/applied

.PHONY: all clean

all: $(GIT_HOOKS) $(TESTS)

$(GIT_HOOKS):
	@scripts/install-git-hooks
	@echo

OBJS_LIB = \
    tst.o bloom.o

OBJS := \
    $(OBJS_LIB) \
    test_cpy.o \
    test_ref.o

deps := $(OBJS:%.o=.%.o.d)

test_%: test_%.o $(OBJS_LIB)
	$(VECHO) "  LD\t$@\n"
	$(Q)$(CC) $(LDFLAGS)  -o $@ $^ -lm

%.o: %.c
	$(VECHO) "  CC\t$@\n"
	$(Q)$(CC) -o $@ $(CFLAGS) -c -MMD -MF .$@.d $<

test:  $(TESTS)
	echo 3 | sudo tee /proc/sys/vm/drop_caches;
	perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
                ./test_cpy --bench $(TEST_DATA)
	perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
				./test_ref --bench $(TEST_DATA)

test_find:  $(TESTS)
	echo 3 | sudo tee /proc/sys/vm/drop_caches;
	perf stat --repeat 100 \
                -e cache-misses,cache-references,instructions,cycles \
				./test_ref --bench $(TEST_FIND)

test_plot:
	gnuplot scripts/runtimeFind.gp
	eog runtimeFind.png

bench_test: $(TESTS)
	@for test in $(TESTS); do\
		./$$test --bench $(TEST_DATA); \
	done

bench: $(TESTS)
	./test_cpy --bench; \

plot: bench
	gnuplot scripts/runtime3.gp
	eog runtime3.png


clean:
	$(RM) $(TESTS) $(OBJS)
	$(RM) $(deps)
	rm -f  bench_cpy.txt bench_ref.txt ref.txt cpy.txt caculate

-include $(deps)
