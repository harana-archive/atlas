FROM        anapsix/alpine-java:8_jdk_unlimited

RUN         apk add --update \
            python \
            python-dev \
            py-pip \
            build-base \
            && pip install virtualenv \
            && rm -rf /var/cache/apk/*

ENV         ATLAS_SERVER_HEAP=-Xmx1024m \
            ATLAS_SERVER_OPTS=\              
            ATLAS_METRICS_GRAPHITE_HOSTNAME=localhost \      
            ATLAS_METRICS_GRAPHITE_PORT=localhost \    
            ATLAS_METRICS_GRAPHITE_PREFIX=atlas_logs \                 
            ATLAS_LOGS_ELASTICSEARCH_HOSTNAME=localhost \ 
            ATLAS_LOGS_ELASTICSEARCH_PORT=9200 \      
            ATLAS_LOGS_ELASTICSEARCH_PREFIX=atlas_logs \               
            ATLAS_THREAD_QUEUE_SIZE=100 \
            DYNAMODB_CREDENTIALS_PROVIDER=com.amazonaws.auth.DefaultAWSCredentialsProviderChain \
            DYNAMODB_CREDENTIALS_ARGS= \
            DYNAMODB_REGION=ap-southeast-2 \
            DYNAMODB_ENDPOINT= \
            DYNAMODB_PREFIX=atlas \
            DYNAMODB_METRICS_PREFIX=metrics \
            DYNAMODB_ES_CAPACITY_READ=2 \
            DYNAMODB_ES_CAPACITY_WRITE=2 \
            DYNAMODB_ES_READ_RATE=2 \
            DYNAMODB_ES_WRITE_RATE=2 \
            DYNAMODB_GI_CAPACITY_READ=2 \
            DYNAMODB_GI_CAPACITY_WRITE=2 \
            DYNAMODB_GI_READ_RATE=2 \
            DYNAMODB_GI_WRITE_RATE=2 \
            ELASTICSEARCH_HOSTNAME=localhost  \
            ELASTICSEARCH_PORT=9200 \
            ELASTICSEARCH_INDEX=atlas

COPY        /atlas.tgz /

RUN         mkdir -p /opt/atlas && tar xz -C /opt/atlas -f /atlas.tgz --strip-components 1 && rm -rf /atlas.tgz

RUN         mkdir /opt/atlas/libext

COPY        /dynamodb-janusgraph-storage-backend.jar /opt/atlas/libext

COPY        /dynamodb-janusgraph-deps.tgz /

RUN         tar xz -C /opt/atlas/libext -f /dynamodb-janusgraph-deps.tgz && rm -fr /dynamodb-janusgraph-deps.tgz

COPY        /conf/* /opt/atlas/conf/

RUN         cd /opt/atlas/conf && \
            sed -i -e "s/##DYNAMODB_CREDENTIALS_PROVIDER##/${DYNAMODB_CREDENTIALS_PROVIDER}/" atlas-application.properties && \
            sed -i -e "s/##DYNAMODB_CREDENTIALS_ARGS##/${DYNAMODB_CREDENTIALS_ARGS}/" atlas-application.properties && \
            sed -i -e "s/##DYNAMODB_REGION##/${DYNAMODB_REGION}/" atlas-application.properties && \
            sed -i -e "s/##DYNAMODB_ENDPOINT##/${DYNAMODB_ENDPOINT}/" atlas-application.properties && \
            sed -i -e "s/##DYNAMODB_PREFIX##/${DYNAMODB_PREFIX}/" atlas-application.properties && \
            sed -i -e "s/##DYNAMODB_METRICS_PREFIX##/${DYNAMODB_METRICS_PREFIX}/" atlas-application.properties && \
            sed -i -e "s/##ELASTICSEARCH_HOSTNAME##/${ELASTICSEARCH_HOSTNAME}/" atlas-application.properties && \
            sed -i -e "s/##ELASTICSEARCH_PORT##/${ELASTICSEARCH_PORT}/" atlas-application.properties && \
            sed -i -e "s/##ELASTICSEARCH_INDEX##/${ELASTICSEARCH_INDEX}/" atlas-application.properties
               
RUN         cd /opt/atlas/conf && \
            sed -i -e "s/##ATLAS_SERVER_HEAP##/${ATLAS_SERVER_HEAP}/" atlas-env.sh && \
            sed -i -e "s/##ATLAS_SERVER_OPTS##/${ATLAS_SERVER_OPTS}/" atlas-env.sh

EXPOSE      21000

CMD         ["/bin/bash"]