FROM ubuntu:noble
 
RUN apt-get update
RUN apt-get install -y git
RUN git clone https://github.com/felt/tippecanoe.git

RUN apt-get install -y make
RUN apt-get install -y g++
RUN apt-get install -y libsqlite3-dev
RUN apt-get install -y libz-dev

WORKDIR /tippecanoe
RUN make -j
RUN make install

WORKDIR /