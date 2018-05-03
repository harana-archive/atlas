FROM                                anapsix/alpine-java:8_jdk_unlimited

ENV   ATLAS_HOME                    /opt/atlas
ENV   ATLAS_CLIENT_HEAP	            1024MB
ENV   ATLAS_MIN_THREADS             10
ENV   ATLAS_MAX_THREADS             100
ENV   ATLAS_THREAD_QUEUE_SIZE       100

ENV   DYNAMODB_REGION               ap-southeast-2
ENV   DYNAMODB_ES_CAPACITY_READ     2
ENV   DYNAMODB_ES_CAPACITY_WRITE    2
ENV   DYNAMODB_ES_READ_RATE         2
ENV   DYNAMODB_ES_WRITE_RATE        2
ENV   DYNAMODB_GI_CAPACITY_READ     2
ENV   DYNAMODB_GI_CAPACITY_WRITE    2
ENV   DYNAMODB_GI_READ_RATE         2
ENV   DYNAMODB_GI_WRITE_RATE        2

COPY                                /atlas.tgz /atlas.tgz
COPY                                /dynamodb-janusgraph-deps.tgz /dynamodb-janusgraph-deps.tgz
COPY                                /dynamodb-janusgraph-storage-backend.jar /dynamodb-janusgraph-storage-backend.jar

RUN                                 mkdir -p ${ATLAS_HOME} && \
                                    tar xz -C ${ATLAS_HOME} -f /atlas.tgz --strip-component=1 && \
                                    rm -rf /atlas.tgz

RUN                                 mkdir -p ${ATLAS_HOME}/libext &&
                                    tar xz -C ${ATLAS_HOME}/libext -f /dynamodb-janusgraph-deps.tgz --strip-component=1 && \
                                    rm -rf /dynamodb-janusgraph-deps.tgz && \
                                    mv /dynamodb-janusgraph-storage-backend.jar ${ATLAS_HOME}/libext

RUN                                 ls -al / && ls -al ${ATLAS_HOME}/libext

EXPOSE 21000

CMD ["/bin/bash", "-c", "${ATLAS_HOME}/bin/atlas_start.py; tail -fF ${ATLAS_HOME}/logs/application.log"]
