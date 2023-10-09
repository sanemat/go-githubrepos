.PHONY: download/gobump
download/gobump:
	curl -O -L --output-dir ../temp https://github.com/x-motemen/gobump/releases/download/v0.2.0/gobump_v0.2.0_linux_amd64.tar.gz

.PHONY: extract/gobump
extract/gobump:
	tar -xzvf ../temp/gobump_v0.2.0_linux_amd64.tar.gz -C ../bin

.PHONY: install/gobump
install/gobump:
	cp ../bin/gobump_v0.2.0_linux_amd64/gobump ../bin/.
