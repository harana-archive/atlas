FROM                                anapsix/alpine-java:8_jdk_unlimited

ENV   ATLAS_HOME                    /opt/atlas \
      ATLAS_LIB                     /opt/atlas/libext \
      ATLAS_CLIENT_HEAP	            1024MB \
      ATLAS_MIN_THREADS             10 \
      ATLAS_MAX_THREADS             100 \
      ATLAS_THREAD_QUEUE_SIZE       100 \
      DYNAMODB_REGION               ap-southeast-2 \
      DYNAMODB_ES_CAPACITY_READ     2 \
      DYNAMODB_ES_CAPACITY_WRITE    2 \
      DYNAMODB_ES_READ_RATE         2 \
      DYNAMODB_ES_WRITE_RATE        2 \
      DYNAMODB_GI_CAPACITY_READ     2 \
      DYNAMODB_GI_CAPACITY_WRITE    2 \
      DYNAMODB_GI_READ_RATE         2 \
      DYNAMODB_GI_WRITE_RATE        2

COPY                                /atlas.tgz /atlas.tgz
COPY                                /dynamodb-janusgraph-deps.tgz /dynamodb-janusgraph-deps.tgz
COPY                                /dynamodb-janusgraph-storage-backend.jar /dynamodb-janusgraph-storage-backend.jar

RUN                                 mkdir -p ${ATLAS_HOME} && tar xz -C ${ATLAS_HOME} -f /atlas.tgz && \
                                    rm -rf /atlas.tgz

RUN                                 mkdir -p ${ATLAS_LIB} && tar xz -C ${ATLAS_LIB} -f /dynamodb-janusgraph-deps.tgz && \
                                    rm -rf /dynamodb-janusgraph-deps.tgz && \
                                    mv /dynamodb-janusgraph-storage-backend.jar ${ATLAS_LIB}

RUN                                 ls -al / && ls -al ${ATLAS_LIB}

EXPOSE                              21000

CMD                                 ["/bin/bash", "-c", "${ATLAS_HOME}/bin/atlas_start.py; tail -fF ${ATLAS_HOME}/logs/application.log"]
