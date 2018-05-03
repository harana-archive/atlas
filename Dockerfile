FROM                                anapsix/alpine-java:8_jdk_unlimited

ENV   ATLAS_CLIENT_HEAP	            1024MB \
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

RUN                                 mkdir -p /opt/atlas && tar xz -C /opt/atlas -f /atlas.tgz && \
                                    rm -rf /atlas.tgz

RUN                                 mkdir -p /opt/atlas/libext && tar xz -C /opt/atlas/libext -f /dynamodb-janusgraph-deps.tgz && \
                                    rm -rf /dynamodb-janusgraph-deps.tgz && \
                                    mv /opt/atlas/libext/target/* /opt/atlas/libext && rm -fr /opt/atlas/libext/target \
                                    mv /dynamodb-janusgraph-storage-backend.jar /opt/atlas/libext

RUN                                 ls -al / && ls -al /opt/atlas/libext

EXPOSE                              21000

CMD                                 ["/bin/bash", "-c", "/opt/atlas/bin/atlas_start.py; tail -fF /opt/atlas/logs/application.log"]
