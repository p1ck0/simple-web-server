BINARY_NAME=server

build:
	as -o server.o server.s && ld -o server server.o

trace:
	strace ./${BINARY_NAME}

run:
	./${BINARY_NAME}

clean:
	rm -f ${BINARY_NAME}.o
	rm -f ${BINARY_NAME}